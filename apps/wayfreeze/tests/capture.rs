use image::{Rgb, RgbImage};
use std::fs;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use std::process::{Command, Output};
use std::time::{Duration, Instant};

fn executable(path: &Path, body: &str) {
    let shell = std::env::split_paths(&std::env::var_os("PATH").unwrap())
        .map(|directory| directory.join("sh"))
        .find(|path| path.is_file())
        .expect("A POSIX shell is required for the test tools");
    fs::write(path, format!("#!{}\n{body}\n", shell.display())).unwrap();
    fs::set_permissions(path, fs::Permissions::from_mode(0o755)).unwrap();
}

fn setup(directory: &Path, grim: &str) -> Command {
    executable(
        &directory.join("swaymsg"),
        r#"
printf '%s\n' "$*" >> "$TEST_STATE/log"
case "$*" in
    '-t get_outputs -r')
        if [ -f "$TEST_STATE/created" ] && [ -f "$TEST_STATE/fail-discovery" ]; then
            rm -f "$TEST_STATE/fail-discovery"
            echo simulated IPC failure >&2
            exit 1
        fi
        printf '[{"name":"DP-1","active":true,"focused":true,"hdr":true,"scale":1.5,"rect":{"x":0,"y":0,"width":4,"height":4}},{"name":"HEADLESS-1"}'
        if [ -f "$TEST_STATE/created" ]; then
            printf ',{"name":"HEADLESS-2"}'
        fi
        printf ']\n'
        ;;
    '-r create_output')
        : > "$TEST_STATE/created"
        printf '[{"success":true}]\n'
        ;;
    *unplug)
        if [ -f "$TEST_STATE/fail-unplug" ]; then
            printf '[{"success":false,"error":"unplug failed"}]\n'
            exit 0
        fi
        rm -f "$TEST_STATE/created"
        printf '[{"success":true}]\n'
        ;;
    *'focus output'*)
        if [ -f "$TEST_STATE/fail-focus" ]; then
            printf '[{"success":false,"error":"focus failed"}]\n'
        else
            printf '[{"success":true}]\n'
        fi
        ;;
    *) printf '[{"success":true}]\n' ;;
esac
"#,
    );
    executable(&directory.join("grim"), grim);
    let mut command = Command::new(env!("CARGO_BIN_EXE_wayfreeze"));
    command
        .env("XDG_RUNTIME_DIR", directory)
        .env("TEST_STATE", directory)
        .env(
            "PATH",
            format!("{}:{}", directory.display(), std::env::var("PATH").unwrap()),
        );
    command
}

fn successful_capture(directory: &Path) -> Command {
    RgbImage::from_pixel(6, 6, Rgb([12, 34, 56]))
        .save(directory.join("source.png"))
        .unwrap();
    let mut command = setup(
        directory,
        r#"
for argument do destination="$argument"; done
cp "$TEST_STATE/source.png" "$destination"
"#,
    );
    command.arg("--all");
    command
}

fn assert_restored(directory: &Path) {
    let log = fs::read_to_string(directory.join("log")).unwrap();
    assert!(log.contains("-r output \"HEADLESS-2\" unplug"), "{log}");
    assert!(!log.contains("-r output \"HEADLESS-1\" unplug"), "{log}");
    assert!(!log.contains("hide_cursor"), "{log}");
    assert!(!log.contains("get_config"), "{log}");
    assert!(log.contains("-r focus output \"DP-1\""), "{log}");
    assert!(!directory.join("created").exists());
    assert!(!fs::read_dir(directory).unwrap().any(|entry| {
        entry
            .unwrap()
            .file_name()
            .to_string_lossy()
            .starts_with("wayfreeze-")
    }));
}

#[test]
fn concurrent_session_is_rejected_without_changing_desktop() {
    let directory = tempfile::tempdir().unwrap();
    let lock = fs::File::create(directory.path().join("wayfreeze.lock")).unwrap();
    lock.lock().unwrap();
    let result = successful_capture(directory.path()).output().unwrap();
    assert_eq!(result.status.code(), Some(1));
    assert!(result.stdout.is_empty());
    assert!(String::from_utf8_lossy(&result.stderr).contains("already running"));
    assert!(!directory.path().join("log").exists());
}

#[test]
fn sdr_capture_skips_ineligible_outputs_without_creating_virtual_output() {
    let directory = tempfile::tempdir().unwrap();
    let mut command = successful_capture(directory.path());
    executable(
        &directory.path().join("swaymsg"),
        r#"
printf '%s\n' "$*" >> "$TEST_STATE/log"
case "$*" in
    '-t get_outputs -r')
        printf '%s\n' '[{"name":"DP-1","active":true,"scale":1.5,"rect":{"x":0,"y":0,"width":4,"height":4}},{"name":"off","active":true,"power":false},{"name":"inactive","active":false},{"name":"vr","active":true,"non_desktop":true},{"name":"HEADLESS-1","active":true}]'
        ;;
    *) printf '[{"success":false}]\n' ;;
esac
"#,
    );
    executable(
        &directory.path().join("grim"),
        r#"
printf '%s\n' "$*" >> "$TEST_STATE/grim-log"
for argument do destination="$argument"; done
cp "$TEST_STATE/source.png" "$destination"
"#,
    );
    let result = command.output().unwrap();
    assert!(
        result.status.success(),
        "{}",
        String::from_utf8_lossy(&result.stderr)
    );
    let image = image::load_from_memory(&result.stdout).unwrap().to_rgb8();
    assert_eq!(image.dimensions(), (6, 6));
    assert_eq!(image.get_pixel(0, 0).0, [12, 34, 56]);
    assert_eq!(
        fs::read_to_string(directory.path().join("log")).unwrap(),
        "-t get_outputs -r\n"
    );
    let grim = fs::read_to_string(directory.path().join("grim-log")).unwrap();
    assert_eq!(grim.lines().count(), 1);
    assert!(grim.starts_with("-o DP-1 -s 1.5 "), "{grim}");
}

#[test]
fn failed_hdr_capture_restores_desktop_and_keeps_existing_headless_output() {
    let directory = tempfile::tempdir().unwrap();
    let result = setup(directory.path(), "echo simulated failure >&2; exit 19")
        .arg("--all")
        .output()
        .unwrap();
    assert_eq!(result.status.code(), Some(1));
    assert!(result.stdout.is_empty());
    assert_restored(directory.path());
}

#[test]
fn all_outputs_produces_png_and_uses_sdr_virtual_capture() {
    let directory = tempfile::tempdir().unwrap();
    let Output {
        status,
        stdout,
        stderr,
    } = successful_capture(directory.path()).output().unwrap();
    assert!(status.success(), "{}", String::from_utf8_lossy(&stderr));
    let image = image::load_from_memory(&stdout).unwrap().to_rgb8();
    assert_eq!(image.dimensions(), (6, 6));
    assert_eq!(image.get_pixel(0, 0).0, [12, 34, 56]);
    let log = fs::read_to_string(directory.path().join("log")).unwrap();
    assert!(log.contains("color_profile srgb render_bit_depth 8"));
    assert_restored(directory.path());
}

#[test]
fn transient_discovery_failure_does_not_leak_virtual_output() {
    let directory = tempfile::tempdir().unwrap();
    fs::write(directory.path().join("fail-discovery"), "").unwrap();
    let result = successful_capture(directory.path()).output().unwrap();
    assert!(
        result.status.success(),
        "{}",
        String::from_utf8_lossy(&result.stderr)
    );
    let image = image::load_from_memory(&result.stdout).unwrap().to_rgb8();
    assert_eq!(image.dimensions(), (6, 6));
    assert_restored(directory.path());
}

#[test]
fn temporary_output_cleanup_failure_does_not_report_success() {
    let directory = tempfile::tempdir().unwrap();
    fs::write(directory.path().join("fail-unplug"), "").unwrap();
    let result = successful_capture(directory.path()).output().unwrap();
    assert_eq!(result.status.code(), Some(1));
    assert!(result.stdout.is_empty());
    assert!(String::from_utf8_lossy(&result.stderr).contains("Could not remove temporary output"));
    let log = fs::read_to_string(directory.path().join("log")).unwrap();
    assert!(log.contains("-r focus output \"DP-1\""));
}

#[test]
fn focus_restore_failure_does_not_report_success() {
    let directory = tempfile::tempdir().unwrap();
    fs::write(directory.path().join("fail-focus"), "").unwrap();
    let result = successful_capture(directory.path()).output().unwrap();
    assert_eq!(result.status.code(), Some(1));
    assert!(result.stdout.is_empty());
    assert!(String::from_utf8_lossy(&result.stderr).contains("Could not restore output focus"));
    assert!(!directory.path().join("created").exists());
}

#[test]
fn stalled_sway_ipc_times_out() {
    let directory = tempfile::tempdir().unwrap();
    let mut command = setup(directory.path(), "exit 1");
    executable(&directory.path().join("swaymsg"), "exec sleep 10");
    let started = Instant::now();
    let result = command.arg("--all").output().unwrap();
    assert_eq!(result.status.code(), Some(1));
    assert!(String::from_utf8_lossy(&result.stderr).contains("timed out"));
    assert!(started.elapsed() < Duration::from_secs(6));
}

#[test]
fn interrupt_during_capture_removes_virtual_output_and_restores_focus() {
    let directory = tempfile::tempdir().unwrap();
    let mut child = setup(
        directory.path(),
        r#"
: > "$TEST_STATE/capturing"
sleep 60
"#,
    )
    .arg("--all")
    .spawn()
    .unwrap();
    let deadline = Instant::now() + Duration::from_secs(5);
    while !directory.path().join("capturing").exists() {
        assert!(Instant::now() < deadline, "Capture did not start");
        std::thread::sleep(Duration::from_millis(10));
    }
    unsafe {
        libc::kill(child.id() as i32, libc::SIGTERM);
    }
    let deadline = Instant::now() + Duration::from_secs(5);
    let status = loop {
        if let Some(status) = child.try_wait().unwrap() {
            break status;
        }
        assert!(
            Instant::now() < deadline,
            "Interrupted capture did not exit"
        );
        std::thread::sleep(Duration::from_millis(10));
    };
    assert_eq!(status.code(), Some(130));
    assert_restored(directory.path());
}
