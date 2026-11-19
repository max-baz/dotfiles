use crate::screenshot::Capture;
use anyhow::{Context, Result, bail, ensure};
use std::collections::HashMap;
use std::fs::File;
use std::io::Write;
use std::os::fd::AsFd;
use std::path::Path;
use wayland_client::{
    Connection, Dispatch, QueueHandle, delegate_noop,
    protocol::{
        wl_buffer, wl_callback, wl_compositor, wl_output, wl_region, wl_registry, wl_shm,
        wl_shm_pool, wl_surface,
    },
};
use wayland_protocols::wp::viewporter::client::{wp_viewport, wp_viewporter};
use wayland_protocols_wlr::layer_shell::v1::client::{zwlr_layer_shell_v1, zwlr_layer_surface_v1};

struct Overlay {
    surface: wl_surface::WlSurface,
    layer: zwlr_layer_surface_v1::ZwlrLayerSurfaceV1,
    _viewport: wp_viewport::WpViewport,
    buffer: wl_buffer::WlBuffer,
    _file: File,
    output_id: u32,
    width: u32,
    height: u32,
    configured: bool,
}

#[derive(Default)]
struct State {
    compositor: Option<wl_compositor::WlCompositor>,
    shm: Option<wl_shm::WlShm>,
    shell: Option<zwlr_layer_shell_v1::ZwlrLayerShellV1>,
    viewporter: Option<wp_viewporter::WpViewporter>,
    outputs: HashMap<u32, (wl_output::WlOutput, String)>,
    overlays: Vec<Overlay>,
    pending: usize,
    error: Option<String>,
}

impl Dispatch<wl_registry::WlRegistry, ()> for State {
    fn event(
        state: &mut Self,
        registry: &wl_registry::WlRegistry,
        event: wl_registry::Event,
        _: &(),
        _: &Connection,
        qh: &QueueHandle<Self>,
    ) {
        match event {
            wl_registry::Event::Global {
                name,
                interface,
                version,
            } => match interface.as_str() {
                "wl_compositor" if version >= 4 => {
                    state.compositor = Some(registry.bind(name, version.min(4), qh, ()))
                }
                "wl_shm" => state.shm = Some(registry.bind(name, 1, qh, ())),
                "zwlr_layer_shell_v1" => {
                    state.shell = Some(registry.bind(name, version.min(4), qh, ()))
                }
                "wp_viewporter" => state.viewporter = Some(registry.bind(name, 1, qh, ())),
                "wl_output" if version >= 4 => {
                    state
                        .outputs
                        .insert(name, (registry.bind(name, 4, qh, name), String::new()));
                }
                _ => {}
            },
            wl_registry::Event::GlobalRemove { name } => {
                if state
                    .overlays
                    .iter()
                    .any(|overlay| overlay.output_id == name)
                {
                    state.error = Some("An output disappeared during selection".into());
                }
                state.outputs.remove(&name);
            }
            _ => {}
        }
    }
}

impl Dispatch<wl_output::WlOutput, u32> for State {
    fn event(
        state: &mut Self,
        _: &wl_output::WlOutput,
        event: wl_output::Event,
        id: &u32,
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        if let wl_output::Event::Name { name } = event
            && let Some(output) = state.outputs.get_mut(id)
        {
            output.1 = name;
        }
    }
}

impl Dispatch<zwlr_layer_surface_v1::ZwlrLayerSurfaceV1, usize> for State {
    fn event(
        state: &mut Self,
        _: &zwlr_layer_surface_v1::ZwlrLayerSurfaceV1,
        event: zwlr_layer_surface_v1::Event,
        index: &usize,
        _: &Connection,
        qh: &QueueHandle<Self>,
    ) {
        match event {
            zwlr_layer_surface_v1::Event::Configure {
                serial,
                width,
                height,
            } => {
                let overlay = &mut state.overlays[*index];
                overlay.layer.ack_configure(serial);
                if (width != 0 && width != overlay.width)
                    || (height != 0 && height != overlay.height)
                {
                    state.error = Some("Output geometry changed during selection".into());
                    return;
                }
                if !overlay.configured {
                    overlay.surface.frame(qh, *index);
                    overlay.surface.attach(Some(&overlay.buffer), 0, 0);
                    overlay.surface.damage_buffer(0, 0, i32::MAX, i32::MAX);
                    overlay.surface.commit();
                    overlay.configured = true;
                }
            }
            zwlr_layer_surface_v1::Event::Closed => {
                state.error = Some("A frozen overlay was closed by the compositor".into());
            }
            _ => {}
        }
    }
}

impl Dispatch<wl_callback::WlCallback, usize> for State {
    fn event(
        state: &mut Self,
        _: &wl_callback::WlCallback,
        event: wl_callback::Event,
        _: &usize,
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        if let wl_callback::Event::Done { .. } = event {
            state.pending -= 1;
            if state.pending == 0 {
                println!("ready");
                let _ = std::io::stdout().flush();
            }
        }
    }
}

delegate_noop!(State: ignore wl_compositor::WlCompositor);
delegate_noop!(State: ignore wl_shm::WlShm);
delegate_noop!(State: ignore wl_shm_pool::WlShmPool);
delegate_noop!(State: ignore wl_buffer::WlBuffer);
delegate_noop!(State: ignore wl_surface::WlSurface);
delegate_noop!(State: ignore wl_region::WlRegion);
delegate_noop!(State: ignore zwlr_layer_shell_v1::ZwlrLayerShellV1);
delegate_noop!(State: ignore wp_viewporter::WpViewporter);
delegate_noop!(State: ignore wp_viewport::WpViewport);

pub fn run(manifest: &Path) -> Result<()> {
    let captures: Vec<Capture> = serde_json::from_reader(File::open(manifest)?)?;
    ensure!(!captures.is_empty(), "No images to freeze");
    let connection = Connection::connect_to_env().context("Cannot connect to Wayland")?;
    let mut queue = connection.new_event_queue::<State>();
    let qh = queue.handle();
    connection.display().get_registry(&qh, ());
    let mut state = State::default();
    queue.roundtrip(&mut state)?;
    queue.roundtrip(&mut state)?;
    let compositor = state
        .compositor
        .clone()
        .context("wl_compositor v4 is required")?;
    let shm = state.shm.clone().context("wl_shm is required")?;
    let shell = state.shell.clone().context("wlr-layer-shell is required")?;
    let viewporter = state
        .viewporter
        .clone()
        .context("wp_viewporter is required")?;
    state.pending = captures.len();
    for (index, capture) in captures.into_iter().enumerate() {
        let (&output_id, (output, _)) = state
            .outputs
            .iter()
            .find(|(_, (_, name))| name == &capture.output.name)
            .with_context(|| format!("Output {} disappeared", capture.output.name))?;
        let mut image = image::open(&capture.path)?.into_rgba8();
        let width = i32::try_from(image.width())?;
        let height = i32::try_from(image.height())?;
        let stride = width.checked_mul(4).context("Image stride overflow")?;
        let size = stride.checked_mul(height).context("Image size overflow")?;
        for pixel in image.as_mut().as_chunks_mut::<4>().0 {
            let alpha = u32::from(pixel[3]);
            let value = (alpha << 24)
                | ((u32::from(pixel[0]) * alpha / 255) << 16)
                | ((u32::from(pixel[1]) * alpha / 255) << 8)
                | (u32::from(pixel[2]) * alpha / 255);
            pixel.copy_from_slice(&value.to_ne_bytes());
        }
        let mut file = tempfile::tempfile()?;
        file.write_all(image.as_raw())?;
        let pool = shm.create_pool(file.as_fd(), size, &qh, ());
        let buffer =
            pool.create_buffer(0, width, height, stride, wl_shm::Format::Argb8888, &qh, ());
        pool.destroy();
        let surface = compositor.create_surface(&qh, ());
        let region = compositor.create_region(&qh, ());
        surface.set_input_region(Some(&region));
        region.destroy();
        let viewport = viewporter.get_viewport(&surface, &qh, ());
        viewport.set_destination(
            capture.output.rect.width.try_into()?,
            capture.output.rect.height.try_into()?,
        );
        let layer = shell.get_layer_surface(
            &surface,
            Some(output),
            zwlr_layer_shell_v1::Layer::Overlay,
            "wayfreeze".into(),
            &qh,
            index,
        );
        layer.set_anchor(
            zwlr_layer_surface_v1::Anchor::Top
                | zwlr_layer_surface_v1::Anchor::Bottom
                | zwlr_layer_surface_v1::Anchor::Left
                | zwlr_layer_surface_v1::Anchor::Right,
        );
        layer.set_size(capture.output.rect.width, capture.output.rect.height);
        layer.set_keyboard_interactivity(zwlr_layer_surface_v1::KeyboardInteractivity::None);
        layer.set_exclusive_zone(-1);
        surface.commit();
        state.overlays.push(Overlay {
            surface,
            layer,
            _viewport: viewport,
            buffer,
            _file: file,
            output_id,
            width: capture.output.rect.width,
            height: capture.output.rect.height,
            configured: false,
        });
    }
    loop {
        queue.blocking_dispatch(&mut state)?;
        if let Some(error) = state.error.take() {
            bail!(error);
        }
    }
}
