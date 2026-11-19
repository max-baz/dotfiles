use anyhow::{Context, Result, ensure};
use image::{GenericImage, ImageEncoder, RgbImage, imageops};
use serde::{Deserialize, Serialize};
use std::fs::File;
use std::io::BufWriter;
use std::path::{Path, PathBuf};

#[derive(Clone, Copy, Debug, Default, Deserialize, Serialize, PartialEq)]
pub struct Rect {
    pub x: i32,
    pub y: i32,
    pub width: u32,
    pub height: u32,
}

impl Rect {
    pub fn parse(geometry: &str) -> Result<Self> {
        let parts: Vec<_> = geometry.split_whitespace().collect();
        ensure!(parts.len() == 2, "Invalid selection: {geometry}");
        let (x, y) = parts[0]
            .split_once(',')
            .context("Selection must start with x,y")?;
        let (width, height) = parts[1]
            .split_once('x')
            .context("Selection must end with WIDTHxHEIGHT")?;
        let rect = Self {
            x: x.parse()?,
            y: y.parse()?,
            width: width.parse()?,
            height: height.parse()?,
        };
        ensure!(rect.width > 0 && rect.height > 0, "Empty selection");
        Ok(rect)
    }

    fn right(self) -> i64 {
        i64::from(self.x) + i64::from(self.width)
    }

    fn bottom(self) -> i64 {
        i64::from(self.y) + i64::from(self.height)
    }

    fn intersect(self, other: Self) -> Option<Self> {
        let x = self.x.max(other.x);
        let y = self.y.max(other.y);
        let right = self.right().min(other.right());
        let bottom = self.bottom().min(other.bottom());
        (right > i64::from(x) && bottom > i64::from(y)).then(|| Self {
            x,
            y,
            width: (right - i64::from(x)) as u32,
            height: (bottom - i64::from(y)) as u32,
        })
    }
}

fn yes() -> bool {
    true
}

#[derive(Clone, Debug, Default, Deserialize, Serialize)]
pub struct Output {
    pub name: String,
    #[serde(default)]
    pub active: bool,
    #[serde(default = "yes")]
    pub power: bool,
    #[serde(default)]
    pub non_desktop: bool,
    #[serde(default)]
    pub focused: bool,
    #[serde(default)]
    pub hdr: bool,
    #[serde(default)]
    pub scale: f64,
    #[serde(default)]
    pub rect: Rect,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct Capture {
    pub output: Output,
    pub path: PathBuf,
}

pub fn pixels(value: f64) -> Result<u32> {
    let rounded = value.round();
    ensure!(
        rounded.is_finite() && rounded >= 1.0 && rounded <= f64::from(u32::MAX),
        "Image dimension is outside the supported range: {value}"
    );
    Ok(rounded as u32)
}

fn bounds(captures: &[Capture]) -> Result<Rect> {
    let x = captures
        .iter()
        .map(|capture| capture.output.rect.x)
        .min()
        .context("No captures")?;
    let y = captures
        .iter()
        .map(|capture| capture.output.rect.y)
        .min()
        .context("No captures")?;
    let right = captures
        .iter()
        .map(|capture| capture.output.rect.right())
        .max()
        .context("No captures")?;
    let bottom = captures
        .iter()
        .map(|capture| capture.output.rect.bottom())
        .max()
        .context("No captures")?;
    Ok(Rect {
        x,
        y,
        width: (right - i64::from(x)).try_into()?,
        height: (bottom - i64::from(y)).try_into()?,
    })
}

pub fn crop(captures: &[Capture], selection: Option<Rect>) -> Result<RgbImage> {
    let area = match selection {
        Some(selection) => selection,
        None => bounds(captures)?,
    };
    let intersections: Vec<_> = captures
        .iter()
        .filter_map(|capture| {
            area.intersect(capture.output.rect)
                .map(|intersection| (capture, intersection))
        })
        .collect();
    ensure!(
        !intersections.is_empty(),
        "Selection does not intersect a captured output"
    );
    let scale = intersections
        .iter()
        .map(|(capture, _)| capture.output.scale)
        .fold(0.0, f64::max);
    let mut result = RgbImage::new(
        pixels(f64::from(area.width) * scale)?,
        pixels(f64::from(area.height) * scale)?,
    );
    for (capture, intersection) in intersections {
        let rect = capture.output.rect;
        let image = image::open(&capture.path)
            .with_context(|| format!("Cannot open {}", capture.path.display()))?
            .to_rgb8();
        let width = pixels(
            f64::from(intersection.width) * f64::from(image.width()) / f64::from(rect.width),
        )?;
        let height = pixels(
            f64::from(intersection.height) * f64::from(image.height()) / f64::from(rect.height),
        )?;
        ensure!(
            width <= image.width() && height <= image.height(),
            "Crop exceeds source image"
        );
        let source_x = (((i64::from(intersection.x) - i64::from(rect.x)) as f64
            * f64::from(image.width())
            / f64::from(rect.width))
        .round() as u32)
            .min(image.width() - width);
        let source_y = (((i64::from(intersection.y) - i64::from(rect.y)) as f64
            * f64::from(image.height())
            / f64::from(rect.height))
        .round() as u32)
            .min(image.height() - height);
        let target_x =
            ((i64::from(intersection.x) - i64::from(area.x)) as f64 * scale).round() as u32;
        let target_y =
            ((i64::from(intersection.y) - i64::from(area.y)) as f64 * scale).round() as u32;
        let target_right =
            ((intersection.right() - i64::from(area.x)) as f64 * scale).round() as u32;
        let target_bottom =
            ((intersection.bottom() - i64::from(area.y)) as f64 * scale).round() as u32;
        let mut tile = imageops::crop_imm(&image, source_x, source_y, width, height).to_image();
        if tile.dimensions() != (target_right - target_x, target_bottom - target_y) {
            tile = imageops::resize(
                &tile,
                target_right - target_x,
                target_bottom - target_y,
                imageops::FilterType::Lanczos3,
            );
        }
        result.copy_from(&tile, target_x, target_y)?;
    }
    Ok(result)
}

pub fn save(image: &RgbImage, destination: &Path) -> Result<()> {
    let writer: Box<dyn std::io::Write> = if destination == Path::new("-") {
        Box::new(std::io::stdout().lock())
    } else {
        Box::new(
            File::create(destination)
                .with_context(|| format!("Cannot create {}", destination.display()))?,
        )
    };
    let mut writer = BufWriter::new(writer);
    image::codecs::png::PngEncoder::new(&mut writer).write_image(
        image.as_raw(),
        image.width(),
        image.height(),
        image::ExtendedColorType::Rgb8,
    )?;
    std::io::Write::flush(&mut writer)?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use image::Rgb;

    fn capture(directory: &Path, name: &str, rect: Rect, scale: f64, color: [u8; 3]) -> Capture {
        let path = directory.join(format!("{name}.png"));
        RgbImage::from_pixel(
            (f64::from(rect.width) * scale).round() as u32,
            (f64::from(rect.height) * scale).round() as u32,
            Rgb(color),
        )
        .save(&path)
        .unwrap();
        Capture {
            output: Output {
                name: name.into(),
                rect,
                scale,
                ..Output::default()
            },
            path,
        }
    }

    #[test]
    fn selection_spans_fractional_scale_and_negative_origin() {
        let directory = tempfile::tempdir().unwrap();
        let captures = vec![
            capture(
                directory.path(),
                "DP-1",
                Rect {
                    x: -4,
                    y: 0,
                    width: 4,
                    height: 4,
                },
                1.5,
                [255, 0, 0],
            ),
            capture(
                directory.path(),
                "eDP-1",
                Rect {
                    x: 0,
                    y: 0,
                    width: 4,
                    height: 4,
                },
                2.0,
                [0, 0, 255],
            ),
        ];
        let image = crop(&captures, Some(Rect::parse("-2,1 4x2").unwrap())).unwrap();
        assert_eq!(image.dimensions(), (8, 4));
        assert_eq!(image.get_pixel(0, 0).0, [255, 0, 0]);
        assert_eq!(image.get_pixel(3, 3).0, [255, 0, 0]);
        assert_eq!(image.get_pixel(4, 0).0, [0, 0, 255]);
        assert_eq!(image.get_pixel(7, 3).0, [0, 0, 255]);
    }

    #[test]
    fn crop_preserves_saved_pixels_at_selected_offset() {
        let directory = tempfile::tempdir().unwrap();
        let capture = capture(
            directory.path(),
            "DP-1",
            Rect {
                x: 10,
                y: 20,
                width: 4,
                height: 4,
            },
            1.5,
            [0, 0, 0],
        );
        let mut original = image::open(&capture.path).unwrap().to_rgb8();
        original.put_pixel(3, 2, Rgb([12, 34, 56]));
        original.save(&capture.path).unwrap();
        let image = crop(&[capture], Some(Rect::parse("12,21 2x2").unwrap())).unwrap();
        assert_eq!(image.dimensions(), (3, 3));
        assert_eq!(image.get_pixel(0, 0).0, [12, 34, 56]);
    }

    #[test]
    fn full_desktop_keeps_gaps_between_outputs_black() {
        let directory = tempfile::tempdir().unwrap();
        let captures = vec![
            capture(
                directory.path(),
                "left",
                Rect {
                    x: -2,
                    y: 0,
                    width: 2,
                    height: 2,
                },
                1.0,
                [255, 0, 0],
            ),
            capture(
                directory.path(),
                "right",
                Rect {
                    x: 2,
                    y: 0,
                    width: 2,
                    height: 2,
                },
                1.0,
                [0, 0, 255],
            ),
        ];
        let image = crop(&captures, None).unwrap();
        assert_eq!(image.dimensions(), (6, 2));
        assert_eq!(image.get_pixel(0, 0).0, [255, 0, 0]);
        assert_eq!(image.get_pixel(2, 0).0, [0, 0, 0]);
        assert_eq!(image.get_pixel(5, 0).0, [0, 0, 255]);
    }
}
