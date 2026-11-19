use anyhow::{Context, Result, bail, ensure};
use std::io::{Read, Seek, SeekFrom};
use std::os::unix::process::CommandExt;
use std::process::{Child, Command, Output};
use std::sync::atomic::{AtomicBool, Ordering};
use std::time::{Duration, Instant};

pub fn output(command: &mut Command) -> Result<Output> {
    collect(command, None, Some(Duration::from_secs(3)))
}

pub fn interruptible_output(command: &mut Command, cancelled: &AtomicBool) -> Result<Output> {
    collect(command, Some(cancelled), None)
}

fn collect(
    command: &mut Command,
    cancelled: Option<&AtomicBool>,
    timeout: Option<Duration>,
) -> Result<Output> {
    let mut stdout = tempfile::tempfile()?;
    let mut stderr = tempfile::tempfile()?;
    let mut child = ManagedChild::spawn(
        command
            .stdout(stdout.try_clone()?)
            .stderr(stderr.try_clone()?),
    )?;
    let started = Instant::now();
    let status = loop {
        if cancelled.is_some_and(|cancelled| cancelled.load(Ordering::Relaxed)) {
            bail!("Interrupted");
        }
        if let Some(status) = child.child.try_wait()? {
            break status;
        }
        if timeout.is_some_and(|timeout| started.elapsed() >= timeout) {
            bail!("Command {command:?} timed out");
        }
        std::thread::sleep(Duration::from_millis(20));
    };
    stdout.seek(SeekFrom::Start(0))?;
    stderr.seek(SeekFrom::Start(0))?;
    let mut result = Output {
        status,
        stdout: Vec::new(),
        stderr: Vec::new(),
    };
    stdout.read_to_end(&mut result.stdout)?;
    stderr.read_to_end(&mut result.stderr)?;
    ensure!(
        status.success(),
        "Command {command:?} failed: {}",
        String::from_utf8_lossy(&result.stderr).trim()
    );
    Ok(result)
}

pub struct ManagedChild {
    pub child: Child,
}

impl ManagedChild {
    pub fn spawn(command: &mut Command) -> Result<Self> {
        let child = command
            .process_group(0)
            .spawn()
            .with_context(|| format!("Could not run {command:?}"))?;
        Ok(Self { child })
    }
}

impl Drop for ManagedChild {
    fn drop(&mut self) {
        unsafe {
            libc::kill(-(self.child.id() as i32), libc::SIGKILL);
        }
        let _ = self.child.wait();
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn cleanup_stops_background_children_after_shell_exits() {
        let directory = tempfile::tempdir().unwrap();
        let marker = directory.path().join("survived");
        let mut child = ManagedChild::spawn(
            Command::new("sh")
                .args(["-c", "(sleep 0.2; printf survived > \"$1\") & exit 0", "sh"])
                .arg(&marker),
        )
        .unwrap();
        assert!(child.child.wait().unwrap().success());
        drop(child);
        std::thread::sleep(Duration::from_millis(500));
        assert!(!marker.exists(), "Background child survived cleanup");
    }
}
