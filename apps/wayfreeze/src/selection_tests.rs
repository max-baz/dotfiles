use super::*;

fn overlay(cancelled: &AtomicBool) -> ManagedChild {
    let mut child = ManagedChild::spawn(
        Command::new("sh")
            .args(["-c", "printf 'ready\\n'; exec sleep 60"])
            .stdout(Stdio::piped()),
    )
    .unwrap();
    wait_ready(&mut child, cancelled).unwrap();
    child
}

#[test]
fn selector_returns_area_while_overlay_stays_alive() {
    let directory = tempfile::tempdir().unwrap();
    let cancelled = AtomicBool::new(false);
    let mut child = overlay(&cancelled);
    let selection = select_area(
        "printf '12,21 2x2\\n'",
        directory.path(),
        &mut child,
        &cancelled,
    )
    .unwrap();
    assert_eq!(
        selection,
        Some(screenshot::Rect::parse("12,21 2x2").unwrap())
    );
    assert!(child.child.try_wait().unwrap().is_none());
}

#[test]
fn cancelling_selector_does_not_produce_an_area() {
    let directory = tempfile::tempdir().unwrap();
    let cancelled = AtomicBool::new(false);
    let mut child = overlay(&cancelled);
    assert!(
        select_area("exit 1", directory.path(), &mut child, &cancelled)
            .unwrap()
            .is_none()
    );
}

#[test]
fn closed_overlay_aborts_selection() {
    let directory = tempfile::tempdir().unwrap();
    let cancelled = AtomicBool::new(false);
    let mut child = overlay(&cancelled);
    child.child.kill().unwrap();
    child.child.wait().unwrap();
    let started = Instant::now();
    let error = select_area("exec sleep 60", directory.path(), &mut child, &cancelled).unwrap_err();
    assert!(error.to_string().contains("Frozen overlays closed"));
    assert!(started.elapsed() < Duration::from_secs(2));
}

#[test]
fn interrupt_stops_waiting_for_selector() {
    let directory = tempfile::tempdir().unwrap();
    let cancelled = Arc::new(AtomicBool::new(false));
    let mut child = overlay(&cancelled);
    let signal = Arc::clone(&cancelled);
    let interrupt = std::thread::spawn(move || {
        std::thread::sleep(Duration::from_millis(50));
        signal.store(true, Ordering::Relaxed);
    });
    let started = Instant::now();
    let result = select_area("exec sleep 60", directory.path(), &mut child, &cancelled);
    interrupt.join().unwrap();
    assert!(result.is_err());
    assert!(started.elapsed() < Duration::from_secs(2));
}
