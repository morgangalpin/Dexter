#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Build the mesh cache `base_assembly.scad` imports, as BINARY STL.
//!
//! This is a viewing aid, not a verification step, and it renders nothing.
//! `render-all.rs` renders every 100-Base part in its revised config to
//! `out/revised/` and checks what it wrote; this script copies those renders
//! to `out/asm/` as binary STL through `scadmesh settle`, which is what makes
//! the assembly quick to open (700-Differential's `render-meshes.rs` measures
//! why: OpenSCAD's ASCII parser is the whole cost of an import). Re-rendering
//! here instead would cost the hour `render-all.rs` already spends.
//!
//! A cache older than its source would show a part that no longer exists, so
//! a part whose `.scad`, or any `.scad` beside it it may include, is newer
//! than its revised render stops the script: run `render-all.rs` first.
//!
//! Settling moves no geometry, and the script checks that rather than
//! asserting it: the enclosed volume is measured before and after.
//!
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! render-check = { path = "../render-check" }
//! ```

use anyhow::{Context, Result, bail};
use render_check::{sm_json, Ctx};
use std::path::Path;
use std::time::SystemTime;

const OUT_DIR: &str = "out/asm";
const RENDER_DIR: &str = "out/revised";

/// The ids `base_assembly.scad` imports, each `render-all.rs`'s revised
/// render of the part file that starts with that id.
const PARTS: [&str; 6] = ["100-001", "100-002", "100-003", "110-001", "110-002", "120-001"];

/// Volume, in mm³, below which two measurements of one part are the same
/// mesh: binary STL carries float32.
const VOLUME_EPS: f64 = 1.0e-2;

/// The newest modification time among the `.scad` files in `dir`: any of
/// them may be included by a part, so any of them can make a render stale.
fn newest_source(dir: &Path) -> Result<SystemTime> {
    let mut newest = SystemTime::UNIX_EPOCH;
    for entry in std::fs::read_dir(dir)? {
        let path = entry?.path();
        if path.extension().is_some_and(|e| e == "scad") && !path.ends_with("base_assembly.scad") {
            newest = newest.max(std::fs::metadata(&path)?.modified()?);
        }
    }
    Ok(newest)
}

/// The volume a mesh encloses, as `scadmesh info` measures it.
fn volume(ctx: &Ctx, path: &str) -> Result<f64> {
    let (_, json) = sm_json(&["info", path], ctx)?;
    json[0]["volume_mm3"].as_f64().with_context(|| format!("no volume reported for {path}"))
}

/// Settle one revised render into the cache, returning the line to print.
fn build(ctx: &Ctx, id: &str, sources: SystemTime) -> Result<String> {
    let src = format!("{RENDER_DIR}/{id}.stl");
    let out = format!("{OUT_DIR}/{id}.stl");
    let rendered = std::fs::metadata(ctx.dir.join(&src))
        .and_then(|m| m.modified())
        .with_context(|| format!("{src} is missing: run render-all.rs first"))?;
    if rendered < sources {
        bail!("{src} is older than the .scad sources beside it: run render-all.rs first");
    }
    let before = volume(ctx, &src)?;
    let (ok, _) = sm_json(&["settle", &src, "--out", &out], ctx)?;
    if !ok {
        bail!("scadmesh settle failed on {src}");
    }
    let after = volume(ctx, &out)?;
    if (after - before).abs() > VOLUME_EPS {
        bail!("{out} encloses {after} mm3 against {before} mm3 rendered; settling may not move geometry");
    }
    let bytes = std::fs::metadata(ctx.dir.join(&out))?.len();
    Ok(format!("{} KiB", bytes / 1024))
}

fn main() -> Result<()> {
    let ctx = Ctx::for_script()?;
    std::fs::create_dir_all(ctx.dir.join(OUT_DIR))?;
    let sources = newest_source(&ctx.dir)?;
    println!("Settling {} revised renders into {OUT_DIR}/ (binary STL)", PARTS.len());
    for id in PARTS {
        print!("  {id} ... ");
        use std::io::Write;
        std::io::stdout().flush().ok();
        println!("{}", build(&ctx, id, sources)?);
    }
    println!("Done. Build the view: scadmesh view base_assembly.view.json --out out/view");
    Ok(())
}
