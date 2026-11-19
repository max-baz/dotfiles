mod capture;
mod freeze;
mod process;
mod screenshot;
#[cfg(test)]
mod selection_tests;

use anyhow::{Context, Result, bail, ensure};
use clap::Parser;
use process::ManagedChild;
use signal_hook::consts::{SIGINT, SIGTERM};
use std::fs::{File, OpenOptions, TryLockError};
use std::io::{BufRead, BufReader, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode, Stdio};
use std::sync::{
    Arc,
    atomic::{AtomicBool, Ordering},
    mpsc,
};
use std::time::{Duration, Instant};

#[derive(Parser)]
#[command(version, about)]
struct Args {
    #[arg(
        short,
        long,
        default_value = "-",
        help = "PNG destination, or - for stdout"
    )]
    output: PathBuf,
    #[arg(
        long,
        default_value = "slurp",
        help = "Area selector command returning x,y WIDTHxHEIGHT"
    )]
    selector: String,
    #[arg(long, help = "Capture all outputs without selecting an area")]
    all: bool,
}

fn wait_ready(child: &mut ManagedChild, cancelled: &AtomicBool) -> Result<()> {
    let stdout = child
        .child
        .stdout
        .take()
        .context("Overlay stdout is missing")?;
    let (sender, receiver) = mpsc::channel();
    std::thread::spawn(move || {
        let mut line = String::new();
        let ready = BufReader::new(stdout).read_line(&mut line).is_ok() && line.trim() == "ready";
        let _ = sender.send(ready);
    });
    let deadline = Instant::now() + Duration::from_secs(10);
    loop {
        if cancelled.load(Ordering::Relaxed) {
            bail!("Interrupted");
        }
        match receiver.recv_timeout(Duration::from_millis(20)) {
            Ok(true) => return Ok(()),
            Ok(false) | Err(mpsc::RecvTimeoutError::Disconnected) => {
                bail!("Frozen overlays failed to appear")
            }
            Err(mpsc::RecvTimeoutError::Timeout) => {}
        }
        if Instant::now() >= deadline {
            bail!("Timed out waiting for frozen overlays");
        }
    }
}

fn select_area(
    command: &str,
    directory: &Path,
    overlay: &mut ManagedChild,
    cancelled: &AtomicBool,
) -> Result<Option<screenshot::Rect>> {
    let path = directory.join("selection");
    let mut selector = ManagedChild::spawn(
        Command::new("sh")
            .arg("-c")
            .arg(command)
            .stdout(File::create(&path)?),
    )?;
    loop {
        if cancelled.load(Ordering::Relaxed) {
            bail!("Interrupted");
        }
        if overlay.child.try_wait()?.is_some() {
            bail!("Frozen overlays closed during selection");
        }
        if let Some(status) = selector.child.try_wait()? {
            if !status.success() {
                ensure!(status.code() == Some(1), "Area selector failed: {status}");
                return Ok(None);
            }
            let selection = std::fs::read_to_string(&path)?;
            return Ok(Some(screenshot::Rect::parse(selection.trim())?));
        }
        std::thread::sleep(Duration::from_millis(20));
    }
}

fn screenshot(args: &Args, directory: &Path, cancelled: &AtomicBool) -> Result<bool> {
    let session = capture::Session::prepare()?;
    let captures = capture::capture(directory, &session.outputs, cancelled)?;
    if cancelled.load(Ordering::Relaxed) {
        bail!("Interrupted");
    }
    let mut overlay = None;
    let selection = if args.all {
        None
    } else {
        let manifest = directory.join("captures.json");
        serde_json::to_writer(File::create(&manifest)?, &captures)?;
        let mut child = ManagedChild::spawn(
            Command::new(std::env::current_exe()?)
                .arg("__freeze")
                .arg(&manifest)
                .stdout(Stdio::piped()),
        )?;
        wait_ready(&mut child, cancelled)?;
        let Some(selection) = select_area(&args.selector, directory, &mut child, cancelled)? else {
            drop(child);
            session.finish()?;
            return Ok(false);
        };
        overlay = Some(child);
        Some(selection)
    };
    let image = screenshot::crop(&captures, selection)?;
    drop(overlay);
    session.finish()?;
    if cancelled.load(Ordering::Relaxed) {
        bail!("Interrupted");
    }
    screenshot::save(&image, &args.output)?;
    Ok(true)
}

fn run(args: Args, cancelled: &AtomicBool) -> Result<bool> {
    let runtime =
        PathBuf::from(std::env::var_os("XDG_RUNTIME_DIR").context("XDG_RUNTIME_DIR is not set")?);
    let lock = OpenOptions::new()
        .create(true)
        .truncate(false)
        .write(true)
        .open(runtime.join("wayfreeze.lock"))?;
    match lock.try_lock() {
        Ok(()) => {}
        Err(TryLockError::WouldBlock) => bail!("Another screenshot session is already running"),
        Err(TryLockError::Error(error)) => return Err(error.into()),
    }
    let directory = tempfile::Builder::new()
        .prefix("wayfreeze-")
        .tempdir_in(runtime)?;
    screenshot(&args, directory.path(), cancelled)
}

fn main() -> ExitCode {
    let arguments: Vec<_> = std::env::args_os().collect();
    if arguments.get(1).is_some_and(|arg| arg == "__freeze") {
        return match arguments
            .get(2)
            .context("Missing overlay manifest")
            .and_then(|path| freeze::run(Path::new(path)))
        {
            Ok(()) => ExitCode::SUCCESS,
            Err(error) => {
                eprintln!("wayfreeze: {error:#}");
                ExitCode::FAILURE
            }
        };
    }
    let args = Args::parse();
    let cancelled = Arc::new(AtomicBool::new(false));
    for signal in [SIGINT, SIGTERM] {
        if let Err(error) = signal_hook::flag::register(signal, Arc::clone(&cancelled)) {
            eprintln!("wayfreeze: {error}");
            return ExitCode::FAILURE;
        }
    }
    let result = run(args, &cancelled);
    if cancelled.load(Ordering::Relaxed) {
        return ExitCode::from(130);
    }
    match result {
        Ok(true) => ExitCode::SUCCESS,
        Ok(false) => ExitCode::from(2),
        Err(error) => {
            let _ = writeln!(std::io::stderr(), "wayfreeze: {error:#}");
            ExitCode::FAILURE
        }
    }
}
