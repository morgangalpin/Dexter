#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Render `110-004_BaseMountingPlate.scad`, emit its machining drawing, and
//! verify that it still bolts to the part it exists to bolt to.
//!
//! This is the verification contract behind DC-4 in
//! `specs/009-Design-Completion.md`. It needs OpenSCAD (set `$OPENSCAD` to
//! override the search) and `scadmesh` from the standalone `openscad-tools`
//! project (set `$SCADMESH` to override).
//!
//! The plate is authored, not recreated, so there is no reference mesh and
//! most of its geometry is a free choice. Exactly one thing about it is not:
//! the eight robot-side holes must line up with the mounting holes on
//! `110-001_BaseMountBottom.stl`. That mesh is therefore the reference, and
//! the centres are read off it here rather than copied from the spec — a
//! transcription this script trusted would be a transcription nothing checks.
//!
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! serde_json = "1"
//! ```

use anyhow::{Context, Result, bail};
use serde_json::Value;
use std::path::{Path, PathBuf};
use std::process::Command;

/// Absolute paths tried for OpenSCAD before falling back to `$PATH`. The
/// `.exe` rather than the `.com` wrapper is deliberate: this script reads
/// stdout and stderr apart, and only the `.exe` keeps them apart when
/// redirected to a pipe.
const OPENSCAD_CANDIDATES: [&str; 3] = [
    "C:/Program Files/OpenSCAD/openscad.exe",
    "/usr/bin/openscad",
    "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD",
];

const SCADMESH_CANDIDATES: [&str; 2] = [
    "../../../../../openscad-tools/target/release/scadmesh.exe",
    "../../../../../openscad-tools/target/release/scadmesh",
];

/// Plate geometry, from `specs/004-Mechanical-Architecture.md`.
const FOOTPRINT: f64 = 200.0;
const THICKNESS: f64 = 9.5;
const ROBOT_TAP: f64 = 4.2;
const BENCH_CLEAR: f64 = 6.6;

/// How far a hole centre may sit from where the reference part puts it. The
/// plate is tapped and the mount's holes are clearance, so the joint has real
/// slack -- but a tapped hole cannot be nudged on assembly, which is why this
/// is held far tighter than that slack. Both meshes are exports, so a few
/// hundredths of meshing noise has to be allowed.
const CENTRE_TOL: f64 = 0.05;

/// Diameter tolerance, against nominal.
const DIAM_TOL: f64 = 0.05;

fn tool(candidates: &[&str], env: &str, fallback: &str, dir: &Path) -> PathBuf {
    if let Ok(p) = std::env::var(env) {
        return PathBuf::from(p);
    }
    for c in candidates {
        let p = dir.join(c);
        if p.exists() {
            return p;
        }
        if Path::new(c).exists() {
            return PathBuf::from(c);
        }
    }
    PathBuf::from(fallback)
}

fn run(bin: &Path, args: &[&str]) -> Result<String> {
    let out = Command::new(bin)
        .args(args)
        .output()
        .with_context(|| format!("running {}", bin.display()))?;
    if !out.status.success() {
        bail!(
            "{} {:?} failed:\n{}",
            bin.display(),
            args,
            String::from_utf8_lossy(&out.stderr)
        );
    }
    Ok(String::from_utf8_lossy(&out.stdout).into_owned())
}

/// Loops on a z-section, as (centre, diameter, circle-fit rms).
fn section(scadmesh: &Path, mesh: &Path, at: f64) -> Result<Vec<([f64; 2], f64, f64)>> {
    let at = format!("--at={at}");
    let mesh = mesh.to_string_lossy().into_owned();
    let text = run(scadmesh, &[&"slice", &mesh, "--axis", "z", &at, "--json"])?;
    let v: Value = serde_json::from_str(&text).context("parsing slice JSON")?;
    let mut out = Vec::new();
    for l in v["loops"].as_array().context("no loops")? {
        let c = &l["circle"];
        out.push((
            [num(&c["center"][0]), num(&c["center"][1])],
            num(&c["radius"]) * 2.0,
            num(&c["rms"]),
        ));
    }
    Ok(out)
}

fn num(v: &Value) -> f64 {
    v.as_f64().unwrap_or(f64::NAN)
}

/// Round-trip a coordinate to kill export noise before sorting and printing.
fn tidy(p: [f64; 2]) -> [f64; 2] {
    [(p[0] * 1e3).round() / 1e3, (p[1] * 1e3).round() / 1e3]
}

fn sorted_centres(mut v: Vec<[f64; 2]>) -> Vec<[f64; 2]> {
    v.sort_by(|a, b| a.partial_cmp(b).unwrap());
    v
}

/// The mount's eight mounting holes, read off the reference mesh at a height
/// inside its 10 mm flange. They are the only Ø6 loops on that section.
fn reference_pattern(scadmesh: &Path, mount: &Path) -> Result<Vec<[f64; 2]>> {
    let found: Vec<[f64; 2]> = section(scadmesh, mount, 0.5)?
        .into_iter()
        .filter(|(_, d, rms)| (*d - 6.0).abs() < DIAM_TOL && *rms < 0.05)
        .map(|(c, _, _)| tidy(c))
        .collect();
    if found.len() != 8 {
        bail!(
            "reference {} has {} mounting holes, expected 8 -- is this the bolted part?",
            mount.display(),
            found.len()
        );
    }
    Ok(sorted_centres(found))
}

/// Group the plate's own section into (tapped, clearance) centres.
fn plate_pattern(scadmesh: &Path, plate: &Path) -> Result<(Vec<[f64; 2]>, Vec<[f64; 2]>)> {
    let loops = section(scadmesh, plate, -THICKNESS / 2.0)?;
    let pick = |nominal: f64| -> Vec<[f64; 2]> {
        loops
            .iter()
            .filter(|(_, d, rms)| (*d - nominal).abs() < DIAM_TOL && *rms < 0.05)
            .map(|(c, _, _)| tidy(*c))
            .collect()
    };
    Ok((
        sorted_centres(pick(ROBOT_TAP)),
        sorted_centres(pick(BENCH_CLEAR)),
    ))
}

fn check_bbox(scadmesh: &Path, plate: &Path) -> Result<()> {
    let text = run(scadmesh, &["bbox", &plate.to_string_lossy(), "--json"])?;
    let v: Value = serde_json::from_str(&text)?;
    let want = [FOOTPRINT, FOOTPRINT, THICKNESS];
    for (i, axis) in ["x", "y", "z"].iter().enumerate() {
        let got = num(&v["size_mm"][i]);
        if (got - want[i]).abs() > 0.01 {
            bail!("plate {axis} is {got:.3} mm, expected {:.3}", want[i]);
        }
    }
    println!("  bbox      {FOOTPRINT} x {FOOTPRINT} x {THICKNESS} mm  ok");
    Ok(())
}

fn check_pattern(plate: &[[f64; 2]], reference: &[[f64; 2]]) -> Result<()> {
    if plate.len() != reference.len() {
        bail!(
            "plate has {} tapped holes, the mount has {}",
            plate.len(),
            reference.len()
        );
    }
    let mut worst = 0.0_f64;
    for (p, r) in plate.iter().zip(reference) {
        let d = ((p[0] - r[0]).powi(2) + (p[1] - r[1]).powi(2)).sqrt();
        if d > CENTRE_TOL {
            bail!("hole at ({:.3}, {:.3}) is {d:.3} mm from the mount's ({:.3}, {:.3})", p[0], p[1], r[0], r[1]);
        }
        worst = worst.max(d);
    }
    println!("  robot-side  {} holes, worst offset {worst:.3} mm  ok", plate.len());
    Ok(())
}

fn render(openscad: &Path, src: &Path, out: &Path, project: bool) -> Result<()> {
    let mut args = vec![
        "-o".to_string(),
        out.to_string_lossy().into_owned(),
        src.to_string_lossy().into_owned(),
    ];
    if project {
        args.insert(0, "PROJECT=1".to_string());
        args.insert(0, "-D".to_string());
    }
    let refs: Vec<&str> = args.iter().map(String::as_str).collect();
    run(openscad, &refs)?;
    println!("  rendered  {}", out.display());
    Ok(())
}

fn main() -> Result<()> {
    let dir = Path::new(file!())
        .parent()
        .unwrap_or(Path::new("."))
        .to_path_buf();
    let openscad = tool(&OPENSCAD_CANDIDATES, "OPENSCAD", "openscad", &dir);
    let scadmesh = tool(&SCADMESH_CANDIDATES, "SCADMESH", "scadmesh", &dir);

    let src = dir.join("110-004_BaseMountingPlate.scad");
    let out = dir.join("out");
    std::fs::create_dir_all(&out)?;
    let stl = out.join("110-004_BaseMountingPlate.stl");
    let dxf = out.join("110-004_BaseMountingPlate.dxf");
    let mount = dir.join("110-001_BaseMountBottom.stl");

    println!("#110-004 Base Mounting Plate");
    render(&openscad, &src, &stl, false)?;
    render(&openscad, &src, &dxf, true)?;
    check_bbox(&scadmesh, &stl)?;

    let reference = reference_pattern(&scadmesh, &mount)?;
    let (tapped, clearance) = plate_pattern(&scadmesh, &stl)?;
    check_pattern(&tapped, &reference)?;
    if clearance.len() != 4 {
        bail!("plate has {} work-surface holes, expected 4", clearance.len());
    }
    println!("  bench     {} holes  ok", clearance.len());
    println!("\nok");
    Ok(())
}
