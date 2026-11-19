use crate::process;
use crate::screenshot::{Capture, Output};
use anyhow::{Context, Result, bail, ensure};
use std::path::Path;
use std::process::Command;
use std::sync::atomic::{AtomicBool, Ordering};
use std::time::Duration;

fn quote(value: &str) -> String {
    serde_json::to_string(value).expect("String serialization cannot fail")
}

fn sway(command: &str) -> Result<()> {
    let result = process::output(Command::new("swaymsg").args(["-r", command]))?;
    let replies: Vec<serde_json::Value> = serde_json::from_slice(&result.stdout)?;
    for reply in replies {
        ensure!(
            reply["success"] == true,
            "Sway command {command:?} failed: {}",
            reply["error"]
        );
    }
    Ok(())
}

fn outputs() -> Result<Vec<Output>> {
    let result = process::output(Command::new("swaymsg").args(["-t", "get_outputs", "-r"]))?;
    serde_json::from_slice(&result.stdout).context("Invalid Sway output information")
}

pub struct Session {
    pub outputs: Vec<Output>,
    focused: Option<String>,
}

impl Session {
    pub fn prepare() -> Result<Self> {
        let outputs: Vec<_> = outputs()?
            .into_iter()
            .filter(|output| {
                output.active
                    && output.power
                    && !output.non_desktop
                    && !output.name.starts_with("HEADLESS-")
            })
            .collect();
        ensure!(!outputs.is_empty(), "No active physical outputs");
        for output in &outputs {
            ensure!(
                output.scale.is_finite() && output.scale > 0.0,
                "Invalid scale for {}",
                output.name
            );
        }
        let focused = outputs
            .iter()
            .find(|output| output.focused)
            .map(|output| output.name.clone());
        Ok(Self { outputs, focused })
    }

    fn restore(&mut self) -> Result<()> {
        if let Some(focused) = &self.focused {
            sway(&format!("focus output {}", quote(focused)))
                .context("Could not restore output focus")?;
            self.focused = None;
        }
        Ok(())
    }

    pub fn finish(mut self) -> Result<()> {
        self.restore()
    }
}

impl Drop for Session {
    fn drop(&mut self) {
        if let Err(error) = self.restore() {
            eprintln!("wayfreeze: {error:#}");
        }
    }
}

struct Headless {
    name: String,
    removed: bool,
}

impl Headless {
    fn create() -> Result<Self> {
        let before = outputs()?;
        let creation = sway("create_output");
        let mut created = outputs()
            .or_else(|first| {
                outputs().with_context(|| format!("Initial output discovery failed: {first:#}"))
            })?
            .into_iter()
            .filter(|output| !before.iter().any(|previous| previous.name == output.name));
        let output = created
            .next()
            .context("Sway did not create a virtual output")?;
        ensure!(
            created.next().is_none() && output.name.starts_with("HEADLESS-"),
            "Could not identify the temporary headless output"
        );
        let headless = Self {
            name: output.name,
            removed: false,
        };
        creation?;
        Ok(headless)
    }

    fn configure(&self, output: &Output) -> Result<()> {
        let width = crate::screenshot::pixels(f64::from(output.rect.width) * output.scale)?;
        let height = crate::screenshot::pixels(f64::from(output.rect.height) * output.scale)?;
        sway(&format!(
            "output {} mode {width}x{height} position {} {} scale {} transform normal hdr off color_profile srgb render_bit_depth 8",
            quote(&self.name),
            output.rect.x,
            output.rect.y,
            output.scale,
        ))?;
        std::thread::sleep(Duration::from_millis(200));
        Ok(())
    }

    fn remove(&mut self) -> Result<()> {
        if !self.removed {
            sway(&format!("output {} unplug", quote(&self.name)))
                .with_context(|| format!("Could not remove temporary output {}", self.name))?;
            self.removed = true;
        }
        Ok(())
    }
}

impl Drop for Headless {
    fn drop(&mut self) {
        if let Err(error) = self.remove() {
            eprintln!("wayfreeze: {error:#}");
        }
    }
}

pub fn capture(
    directory: &Path,
    physical: &[Output],
    cancelled: &AtomicBool,
) -> Result<Vec<Capture>> {
    let mut sorted: Vec<_> = physical.iter().collect();
    sorted.sort_by_key(|output| output.hdr);
    let mut headless = None;
    let mut captures = Vec::new();
    for (index, output) in sorted.into_iter().enumerate() {
        if cancelled.load(Ordering::Relaxed) {
            bail!("Interrupted");
        }
        let target = if output.hdr {
            if headless.is_none() {
                headless = Some(Headless::create()?);
            }
            let headless = headless.as_ref().expect("Headless output was created");
            headless.configure(output)?;
            &headless.name
        } else {
            &output.name
        };
        let path = directory.join(format!("output-{index}.png"));
        process::interruptible_output(
            Command::new("grim")
                .arg("-o")
                .arg(target)
                .arg("-s")
                .arg(output.scale.to_string())
                .arg(&path),
            cancelled,
        )?;
        captures.push(Capture {
            output: output.clone(),
            path,
        });
    }
    if let Some(headless) = &mut headless {
        headless.remove()?;
    }
    Ok(captures)
}
