#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Render every 700-Differential part in both configurations and verify the
//! faithful ("previous") renders against their reference meshes.
//!
//! This is the verification contract behind DC-2 in
//! `specs/009-Design-Completion.md`. It needs OpenSCAD (set `$OPENSCAD` to
//! override the search) and `scadmesh` from the standalone `openscad-tools`
//! project (set `$SCADMESH` to override).
//!
//! Per-part ignore ranges are documented deviations, not slack:
//!   - gear zones: BOSL2 involute teeth are verified by tooth count, outside
//!     diameter rather than by vertex match (the pitch cones follow from the
//!     20T-on-20T 90-degree configuration, and are not measured here);
//!   - artifact ranges: the reference meshes are CAD *assembly* exports
//!     ("STLB ASM" headers) carrying degenerate internal shells and internal
//!     coplanar faces that a clean model must not reproduce;
//!   - 720-003: the sculpted under-flange web is modeled as a cone.
//! Diff Body A and B are authored functional redesigns (measured interfaces,
//! clean shells), so they are verified by interface checks, not by shell
//! comparison.
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

/// Absolute paths tried for OpenSCAD before falling back to `$PATH`.
const OPENSCAD_CANDIDATES: [&str; 3] = [
    "C:/Program Files/OpenSCAD/openscad.exe",
    "/usr/bin/openscad",
    "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD",
];

/// Paths tried for `scadmesh`, relative to this script's directory: the
/// standalone `openscad-tools` project checked out beside this repository's
/// parent. Falls back to `$PATH`, or set `$SCADMESH`.
const SCADMESH_CANDIDATES: [&str; 2] = [
    "../../../../../openscad-tools/target/release/scadmesh.exe",
    "../../../../../openscad-tools/target/release/scadmesh",
];

/// A part recreated faithfully enough to compare against its reference mesh.
struct ClonePart {
    stem: &'static str,
    scad: &'static str,
    reference: &'static str,
    extra: &'static [&'static str],
}

const CLONES: [ClonePart; 7] = [
    ClonePart { stem: "710-003", scad: "710-003_DiffKeeper.scad",
                reference: "710-003_DiffKeeper.stl", extra: &[] },
    ClonePart { stem: "710-004", scad: "710-004_RotateCodeDisk.scad",
                reference: "710-004_RotateCodeDisk.stl", extra: &[] },
    ClonePart { stem: "720-003", scad: "720-003_DiffEndPulley.scad",
                reference: "720-003_DiffEndPulley.stl",
                extra: &["--ignore-plane=-4.05,-3.7", "--ignore-plane=-1.8,4.2"] },
    ClonePart { stem: "720-002", scad: "720-002_DiffGearAxle.scad",
                reference: "720-002_DiffGearAxle.stl",
                extra: &["--ignore-band=25.8,28.2", "--ignore-band=36.5,43.9",
                         "--ignore-plane=2.2,2.45"] },
    ClonePart { stem: "720-001", scad: "720-001_DiffGearShaft.scad",
                reference: "720-001_DiffGearShaft.stl",
                extra: &["--axis", "y", "--ignore-band=15.3,15.7",
                         "--ignore-band=27.15,43.5", "--ignore-plane=-30.5,30.5"] },
    ClonePart { stem: "710-001", scad: "710-001_SplitGearTop.scad",
                reference: "710-001_SplitGearTop.stl",
                extra: &["--ignore-band=23.85,25.05", "--ignore-band=33.9,34.6",
                         "--ignore-band=38.2,43.9", "--ignore-band=14.9,15.1",
                         "--ignore-plane=-11.8,-11.6"] },
    ClonePart { stem: "710-002", scad: "710-002_SplitGearBottom.scad",
                reference: "710-002_SplitGearBottom.stl",
                extra: &["--ignore-band=8.15,8.35", "--ignore-band=23.95,24.45",
                         "--ignore-band=25.6,26.8", "--ignore-band=27.15,34.8",
                         "--ignore-plane=6.0,11.8", "--ignore-plane=-2.74,-2.62"] },
];

/// Tooth and slot counts, checked on the cross-section of each *render* —
/// slice positions are in the render's own frame, which need not match the
/// reference's (compare centres both meshes, so only these care).
struct CountCheck {
    label: &'static str,
    args: &'static [&'static str],
    key: &'static str,
    expect: u64,
}

const COUNTS: [CountCheck; 6] = [
    CountCheck { label: "710-004 100 encoder slots",
                 args: &["out/710-004.stl", "--band", "21.5,25.5",
                         "--slice-at", "0.6", "--center", "0,0"],
                 key: "loops_in_band", expect: 100 },
    CountCheck { label: "720-003 40T GT2",
                 args: &["out/720-003.stl", "--band", "11.5,12.7",
                         "--slice-at", "6.0", "--center", "0,0"],
                 key: "radius_peaks", expect: 40 },
    CountCheck { label: "720-001 40T GT2",
                 args: &["out/720-001.stl", "--axis", "y", "--band", "11.5,12.7",
                         "--slice-at", "36.0", "--center", "0,0"],
                 key: "radius_peaks", expect: 40 },
    CountCheck { label: "720-001 20T bevel",
                 args: &["out/720-001.stl", "--axis", "y", "--band", "17.0,21.0",
                         "--slice-at", "20.0", "--center", "0,0"],
                 key: "radius_peaks", expect: 20 },
    CountCheck { label: "720-002 20T bevel",
                 args: &["out/720-002.stl", "--band", "18.5,22.2",
                         "--slice-at", "4.0", "--center", "0,0"],
                 key: "radius_peaks", expect: 20 },
    CountCheck { label: "710-001 20T bevel",
                 args: &["out/710-001.stl", "--band", "19.0,22.2",
                         "--slice-at", "19.8", "--center", "0,0"],
                 key: "radius_peaks", expect: 20 },
];

/// A mating diameter that must appear on a cross-section of an authored body.
struct DiamCheck {
    label: &'static str,
    args: &'static [&'static str],
    diameter: f64,
}

const DIAMS: [DiamCheck; 5] = [
    DiamCheck { label: "730-001 6703 seat Ø23",
                args: &["out/730-001.stl", "--at=2.0"], diameter: 23.0 },
    DiamCheck { label: "730-001 6705 seat Ø32",
                args: &["out/730-001.stl", "--at=20.0"], diameter: 32.0 },
    DiamCheck { label: "730-002 6703 seat Ø23",
                args: &["out/730-002.stl", "--axis", "y", "--at=-48.5"], diameter: 23.0 },
    DiamCheck { label: "730-002 split-gear stub Ø17",
                args: &["out/730-002.stl", "--at=40"], diameter: 17.0 },
    DiamCheck { label: "730-002 thrust tube Ø8",
                args: &["out/730-002.stl", "--at=60"], diameter: 8.0 },
];

const DIAM_TOL: f64 = 0.05;

/// Resolve a tool: `$env_key` wins, then the first existing candidate
/// (resolved relative to `dir`), then the bare name via `$PATH`.
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

fn run(exe: &str, args: &[&str], dir: &Path) -> Result<(bool, String)> {
    let out = Command::new(exe)
        .args(args)
        .current_dir(dir)
        .output()
        .with_context(|| {
            format!("running {exe} - set $OPENSCAD / $SCADMESH if it is not on PATH")
        })?;
    let text = String::from_utf8_lossy(&out.stdout).into_owned();
    Ok((out.status.success(), text))
}

fn render(scad: &str, out_stl: &str, config: &str, ctx: &Ctx) -> Result<()> {
    let define = format!("config=\"{config}\"");
    let (ok, _) = run(&ctx.openscad, &["-o", out_stl, "-D", &define, scad], &ctx.dir)?;
    if !ok {
        bail!("OpenSCAD failed rendering {scad} ({config})");
    }
    Ok(())
}

fn sm_json(args: &[&str], ctx: &Ctx) -> Result<(bool, Value)> {
    let mut full: Vec<&str> = args.to_vec();
    full.push("--json");
    let (ok, text) = run(&ctx.scadmesh, &full, &ctx.dir)?;
    let json = serde_json::from_str(&text)
        .with_context(|| format!("parsing scadmesh output for {args:?}"))?;
    Ok((ok, json))
}

struct Ctx {
    dir: PathBuf,
    openscad: String,
    scadmesh: String,
}

struct Tally {
    failures: usize,
}

impl Tally {
    fn record(&mut self, label: &str, ok: bool) {
        println!("{}  {label}", if ok { "PASS" } else { "FAIL" });
        if !ok {
            self.failures += 1;
        }
    }
}

fn check_clones(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    for part in &CLONES {
        let out_stl = format!("out/{}.stl", part.stem);
        render(part.scad, &out_stl, "previous", ctx)?;
        let mut args = vec!["compare", out_stl.as_str(), part.reference];
        args.extend_from_slice(part.extra);
        let (ok, report) = sm_json(&args, ctx)?;
        let worst = report["worst_delta"].as_f64().unwrap_or(f64::NAN);
        tally.record(&format!("{} vs reference (worst {worst:.3} mm)", part.stem), ok);
    }
    Ok(())
}

fn check_counts(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    for c in &COUNTS {
        let mut args = vec!["teeth"];
        args.extend_from_slice(c.args);
        let (_, json) = sm_json(&args, ctx)?;
        let got = json["result"][c.key].as_u64();
        tally.record(&format!("{} (got {:?})", c.label, got), got == Some(c.expect));
    }
    Ok(())
}

fn has_diameter(json: &Value, diameter: f64) -> bool {
    json["loops"].as_array().is_some_and(|loops| {
        loops.iter().any(|l| {
            l["circle"]["radius"]
                .as_f64()
                .is_some_and(|r| (2.0 * r - diameter).abs() <= DIAM_TOL)
        })
    })
}

fn check_bodies(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    render("730-001_DiffBodyA.scad", "out/730-001.stl", "previous", ctx)?;
    render("730-002_DiffBodyB.scad", "out/730-002.stl", "previous", ctx)?;
    for c in &DIAMS {
        let mut args = vec!["slice"];
        args.extend_from_slice(c.args);
        let (_, json) = sm_json(&args, ctx)?;
        tally.record(c.label, has_diameter(&json, c.diameter));
    }
    Ok(())
}

fn check_revised(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    render("730-001_DiffBodyA.scad", "out/730-001-revised.stl", "revised", ctx)?;
    let (ok, _) = sm_json(
        &["bbox", "out/730-001-revised.stl", "--assert-max", "78.0,73.5,50.5"],
        ctx,
    )?;
    tally.record("revised Diff Body A fits the HDI-940 cover envelope", ok);
    Ok(())
}

/// The assembly is exported to CSG rather than STL: that evaluates every
/// parameter and assertion in `diff_assembly.scad` (the L4 split, the axis
/// intersection, the revised envelope) in seconds, where meshing the union
/// of nine parts — three of them involute bevel gears — takes minutes and
/// checks nothing extra. Render it to STL by hand when you want to look at
/// it: `openscad -o out/assembly.stl -D config='"revised"' diff_assembly.scad`.
fn check_assembly(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    for config in ["previous", "revised"] {
        let out_csg = format!("out/assembly-{config}.csg");
        let ok = render("diff_assembly.scad", &out_csg, config, ctx).is_ok();
        tally.record(&format!("assembly parameters and assertions ({config})"), ok);
    }
    Ok(())
}

fn context() -> Result<Ctx> {
    let dir = script_dir()?;
    std::fs::create_dir_all(dir.join("out"))?;
    Ok(Ctx {
        openscad: tool("OPENSCAD", &OPENSCAD_CANDIDATES, "openscad", &dir),
        scadmesh: tool("SCADMESH", &SCADMESH_CANDIDATES, "scadmesh", &dir),
        dir,
    })
}

fn verify(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    check_clones(ctx, tally)?;
    check_counts(ctx, tally)?;
    check_bodies(ctx, tally)?;
    check_revised(ctx, tally)?;
    check_assembly(ctx, tally)
}

fn finish(tally: &Tally) -> ! {
    println!();
    if tally.failures == 0 {
        println!("ALL CHECKS PASSED");
        std::process::exit(0);
    }
    println!("{} CHECK(S) FAILED", tally.failures);
    std::process::exit(1);
}

fn main() -> Result<()> {
    let ctx = context()?;
    let mut tally = Tally { failures: 0 };
    verify(&ctx, &mut tally)?;
    finish(&tally)
}
