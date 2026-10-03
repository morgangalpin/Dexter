#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Build the mesh cache `diff_assembly.scad` imports, as BINARY STL.
//!
//! This is a viewing aid, not a verification step: `render-all.rs` is what
//! measures the parts against their references, and the meshes it leaves in
//! `out/` are the ones its checks read. This script writes a second set, to
//! `out/asm/`, for one reason only — the assembly has to be quick to look at.
//!
//! WHY A SECOND SET, AND WHY BINARY. Rebuilding the nine parts from source
//! costs about 36 s per compile of `diff_assembly.scad`, which is a long wait
//! to turn a model around. Importing meshes should fix that and, with the
//! meshes as `render-all.rs` writes them, it does the opposite: those are
//! ASCII STL, and OpenSCAD's ASCII parser is the whole cost. Measured on
//! 730-002, the largest of the nine at 43374 facets:
//!
//!     ASCII, 8.3 MB     21.4 s to import
//!     binary, 2.2 MB     0.4 s to import
//!
//! so the assembly built from the ASCII set compiles in 84 s — worse than
//! building the parts from source — and from this binary set in about 2 s.
//! The normalised CSG tree falls from 1204 elements to 111 either way, which
//! is what makes an imported assembly cheap to ORBIT; binary is what makes it
//! cheap to OPEN as well.
//!
//! `render-all.rs`'s own output is deliberately left alone. Binary STL carries
//! float32, about seven significant digits, against the six OpenSCAD's ASCII
//! writer emits, so switching the harness over would move every measurement it
//! takes by a small amount in the direction of more precision. That may well be
//! an improvement and it is not this script's call to make: those numbers are
//! the DC-2 gate.
//!
//! EACH MESH IS MADE RENDERABLE AS IT IS WRITTEN. A mesh that imports and
//! previews cleanly can still be impossible to RENDER: F6 asks CGAL for a Nef
//! polyhedron, and CGAL takes only a surface it can walk. An exported mesh is
//! not always one. Tessellating an exact solid leaves vertices a few
//! nanometres apart where a blend reaches a face it is meant to meet exactly,
//! and leaves zero-thickness facet pairs where the CSG tree cuts two
//! coincident faces against each other. The render fails with "The given mesh
//! is not closed" and the message names no file.
//!
//! So each mesh goes through `scadmesh` as it is written, in three steps that
//! `openscad-tools` owns and documents:
//!
//!     settle    write the mesh as OpenSCAD's own importer will read it
//!     repair    fill the gaps that reveals, and drop what bounds nothing
//!     pinch     open any edge or vertex a surface still touches itself at
//!
//! `pinch` reports whether a builder can take the result, and this script
//! stops on the part that fails rather than leaving a cache that renders to a
//! silent gap. What each step did is reported per part: four of the nine have
//! vertices to settle, and 710-002 alone has gaps to fill and facets to drop.
//!
//! Nothing measurable moves, and the script checks rather than asserting it:
//! the enclosed volume is measured before and after, and a part whose volume
//! shifts at all is a failure. That is what makes MAX_SPAN safe to set as
//! loosely as it is.
//!
//! Both sets are build output and neither is tracked. Run this after editing
//! any part, or set `geometry = "scad"` in the assembly and skip it. The one
//! argument is the configuration, `revised` when omitted, as in
//! `diff_params.scad`; `./render-meshes.rs previous` builds the reference set.
//!
//! The parts it builds are the ones `parts.json` lists for that configuration,
//! the same list `render-all.rs` renders, so the two cannot drift apart. Each
//! part's id is the name `diff_assembly.scad` imports its mesh by.
//!
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! serde_json = "1"
//! render-check = { path = "../render-check" }
//! ```

use anyhow::{Context, Result, bail};
use render_check::{group_parts, run, sm_json, Ctx};

const OUT_DIR: &str = "out/asm";

/// Widest boundary loop, in mm, that `repair` may close here.
///
/// A gap the settling opens is a collapsed sliver: a strip as long as the
/// facets that ran along it and no width at all, so it is reported by its
/// LENGTH. The longest in this set is 2.507 mm, on 710-002. Three is the
/// allowance that closes it, and it is only safe because the volume check
/// below would catch a loop that was a real opening rather than a strip.
const MAX_SPAN: &str = "3";

/// Volume, in mm³, below which two measurements of one part are the same
/// mesh. Binary STL carries float32, so a part of this size reports its
/// volume to about six figures and the last one is noise.
const VOLUME_EPS: f64 = 1.0e-3;

/// Render one part. The mesh is exported in the part file's own top-level
/// orientation, which for 720-001, 720-003 and 720-004 is not the module's
/// frame; the assembly's `part()` undoes each, and says so there.
fn render(ctx: &Ctx, scad: &str, out: &str, config: &str) -> Result<()> {
    let define = format!("config=\"{config}\"");
    let r = run(&ctx.openscad,
                &["-o", out, "--export-format=binstl", "-D", &define, scad],
                &ctx.dir)?;
    if !r.ok {
        bail!("OpenSCAD failed rendering {scad}:\n{}", r.stderr.trim_end());
    }
    Ok(())
}

/// The volume a mesh encloses, as `scadmesh info` measures it.
fn volume(ctx: &Ctx, path: &str) -> Result<f64> {
    let (_, json) = sm_json(&["info", path], ctx)?;
    json[0]["volume_mm3"]
        .as_f64()
        .with_context(|| format!("no volume reported for {path}"))
}

/// Settle, repair and pinch one mesh in place, returning what each step did.
/// `pinch` says through its exit code whether a builder can take the result.
///
/// The steps take their own defaults for the vertex lattice and the weld
/// tolerance, which are the same 1e-6 mm OpenSCAD itself uses.
fn solidify(ctx: &Ctx, path: &str) -> Result<Vec<String>> {
    let mut notes = Vec::new();
    let (_, s) = sm_json(&["settle", path, "--out", path], ctx)?;
    let (_, r) = sm_json(&["repair", path, "--max-span", MAX_SPAN, "--out", path],
                         ctx)?;
    let (ok, p) = sm_json(&["pinch", path, "--out", path], ctx)?;
    let contacts = p["contacts"].as_array().map_or(0, |a| a.len()) as u64;
    for (n, label) in [(s["merged"].as_u64().unwrap_or(0), "vertices settled"),
                       (r["filled"].as_u64().unwrap_or(0), "gaps filled"),
                       (r["dropped"].as_u64().unwrap_or(0), "facets dropped"),
                       (contacts, "contacts opened")] {
        if n > 0 {
            notes.push(format!("{n} {label}"));
        }
    }
    if !ok {
        bail!("{path} is still not a solid a renderer will take: {}",
              serde_json::to_string(&p)?);
    }
    Ok(notes)
}

/// Build one part's mesh and make it renderable, returning the line to print.
fn build(ctx: &Ctx, id: &str, scad: &str, config: &str) -> Result<String> {
    let out = format!("{OUT_DIR}/{id}.stl");
    render(ctx, scad, &out, config)?;
    let before = volume(ctx, &out)?;
    let notes = solidify(ctx, &out)?;
    let after = volume(ctx, &out)?;
    if (after - before).abs() > VOLUME_EPS {
        bail!("{out} enclosed {before} mm3 as rendered and {after} mm3 once \
               made renderable; nothing here may move geometry");
    }
    let bytes = std::fs::metadata(ctx.dir.join(&out))?.len();
    Ok(format!("{} KiB{}{}", bytes / 1024,
               if notes.is_empty() { "" } else { "  " }, notes.join(", ")))
}

fn main() -> Result<()> {
    let ctx = Ctx::for_script()?;
    let config = std::env::args().nth(1).unwrap_or_else(|| "revised".into());
    std::fs::create_dir_all(ctx.dir.join(OUT_DIR))?;

    let parts = group_parts(&ctx, &config)?;
    println!("Rendering {} parts to {OUT_DIR}/ ({config}, binary STL)",
             parts.len());
    for (id, scad) in &parts {
        print!("  {id} ... ");
        use std::io::Write;
        std::io::stdout().flush().ok();
        println!("{}", build(&ctx, id, scad, &config)?);
    }
    println!("Done. Open diff_assembly.scad with geometry = \"stl\".");
    Ok(())
}
