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
//! Both sets are build output and neither is tracked. Run this after editing
//! any part, or set `geometry = "scad"` in the assembly and skip it.
//!
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! ```

use anyhow::{Context, Result, bail};
use std::path::{Path, PathBuf};
use std::process::Command;

/// Absolute paths tried for OpenSCAD before falling back to `$PATH`. The `.exe`
/// rather than the `.com` wrapper, for the reason `render-all.rs` records: this
/// script reads the two streams apart.
const OPENSCAD_CANDIDATES: [&str; 3] = [
    "C:/Program Files/OpenSCAD/openscad.exe",
    "/usr/bin/openscad",
    "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD",
];

/// The nine printed parts, and the id `diff_assembly.scad` imports each by.
/// The ids are the part numbers without the descriptive tail, matching what
/// `render-all.rs` already names its own output.
const PARTS: [(&str, &str); 9] = [
    ("710-001", "710-001_SplitGearTop.scad"),
    ("710-002", "710-002_SplitGearBottom.scad"),
    ("710-003", "710-003_DiffKeeper.scad"),
    ("710-004", "710-004_RotateCodeDisk.scad"),
    ("720-001", "720-001_DiffGearShaft.scad"),
    ("720-002", "720-002_DiffGearAxle.scad"),
    ("720-003", "720-003_DiffEndPulley.scad"),
    ("730-001", "730-001_DiffBodyA.scad"),
    ("730-002", "730-002_DiffBodyB.scad"),
];

const OUT_DIR: &str = "out/asm";

fn tool(env_key: &str, candidates: &[&str], name: &str, dir: &Path) -> String {
    if let Ok(v) = std::env::var(env_key) {
        return v;
    }
    for c in candidates {
        let path = dir.join(c);
        if path.exists() {
            return path.to_string_lossy().into_owned();
        }
    }
    name.to_string()
}

fn script_dir() -> Result<PathBuf> {
    let base = std::env::var("RUST_SCRIPT_BASE_PATH")
        .context("RUST_SCRIPT_BASE_PATH unset - run this file as a rust-script")?;
    Ok(PathBuf::from(base))
}

/// Render one part. The mesh is exported in the part file's own top-level
/// orientation, which for two of the nine is not the module's frame; the
/// assembly's `part()` undoes both, and says so there.
fn render(openscad: &str, dir: &Path, scad: &str, out: &str,
          config: &str) -> Result<()> {
    let define = format!("config=\"{config}\"");
    let r = Command::new(openscad)
        .args(["-o", out, "--export-format=binstl", "-D", &define, scad])
        .current_dir(dir)
        .output()
        .with_context(|| format!("running OpenSCAD on {scad}"))?;
    if !r.status.success() {
        bail!("OpenSCAD failed rendering {scad}:\n{}",
              String::from_utf8_lossy(&r.stderr).trim_end());
    }
    Ok(())
}

fn main() -> Result<()> {
    let dir = script_dir()?;
    let openscad = tool("OPENSCAD", &OPENSCAD_CANDIDATES, "openscad", &dir);
    let config = std::env::args().nth(1).unwrap_or_else(|| "previous".into());
    std::fs::create_dir_all(dir.join(OUT_DIR))?;

    println!("Rendering {} parts to {OUT_DIR}/ ({config}, binary STL)",
             PARTS.len());
    for (id, scad) in &PARTS {
        let out = format!("{OUT_DIR}/{id}.stl");
        print!("  {id} ... ");
        use std::io::Write;
        std::io::stdout().flush().ok();
        render(&openscad, &dir, scad, &out, &config)?;
        let bytes = std::fs::metadata(dir.join(&out))?.len();
        println!("{} KiB", bytes / 1024);
    }
    println!("Done. Open diff_assembly.scad with geometry = \"stl\".");
    Ok(())
}
