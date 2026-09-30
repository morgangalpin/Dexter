#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Render every 500-ExternalGear part recreated as `.scad`, gate the faithful
//! ("previous") renders on their reference meshes, and verify that J3's stack
//! closes: `exgear_assembly.scad` evaluates with every assert holding, and the
//! #630-005 it asks J3 to print has its hub face where the assembly put it.
//!
//! J3's Flex Spline Attach belongs to 600-StrainWave, whose own script gates
//! it; that script is run first rather than repeated here.
//!
//! Needs OpenSCAD, `scadmesh` and `rust-script`; see the `render-check` crate
//! for how the first two are found.
//!
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! render-check = { path = "../render-check" }
//! ```

use anyhow::{Context, Result};
use render_check::{dist_gate, echoed, probe, render, render_with, run, Ctx, DistGate, Tally};

const REF_DIR: &str = "../Reference/meshes/500-ExternalGear";

const DIST_GATES: [DistGate; 1] = [DistGate {
    stem: "511-001",
    scad: "511-001_ExGearMotorEndCap.scad",
    reference: "511-001_ExGearMotorEndCap.stl",
    tol: 0.15,
}];

/// A point that must be material (`true`) or void (`false`), at a height
/// offset from a face whose height the check computes.
struct Probe {
    label: String,
    at: [f64; 3],
    solid: bool,
}

/// A face at height `face`, looking up (+z) or down: material 0.1 behind it and
/// void 0.1 in front of it.
fn probe_face(stl: &str, part: &str, [x, y]: [f64; 2], face: f64, up: bool, name: &str,
              ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let (behind, front) = if up { ("below", "above") } else { ("above", "below") };
    let d = if up { 0.1 } else { -0.1 };
    let probes = [
        Probe { label: format!("material {behind}"), at: [x, y, face - d], solid: true },
        Probe { label: format!("void {front}"), at: [x, y, face + d], solid: false },
    ];
    let points: Vec<[f64; 3]> = probes.iter().map(|p| p.at).collect();
    for (p, inside) in probes.iter().zip(probe(stl, &points, ctx)?) {
        tally.record(&format!("{part} {name} at z {face:.3} ({})", p.label), inside == p.solid);
    }
    Ok(())
}

/// The 600-StrainWave script, run as it is and judged by its exit status.
fn check_strain_wave(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let r = run("rust-script", &["../600-StrainWave/render-all.rs"], &ctx.dir)?;
    for line in r.stdout.lines() {
        println!("  600| {line}");
    }
    tally.record("600-StrainWave/render-all.rs", r.ok);
    Ok(())
}

/// A number a render echoed as `ECHO: <name> = <value>`.
fn echoed_number(stderr: &str, name: &str) -> Result<f64> {
    let text = echoed(stderr, &format!("{name} = ")).with_context(|| format!("{name} not echoed"))?;
    Ok(text.parse()?)
}

/// The revised End Cap: its seat where the part says it is, read in the motor
/// square clear of the bore, the channel and the nut traps. The seat faces the
/// motor, which lies below it in the part's frame.
fn check_end_cap(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let stl = "out/revised/511-001.stl";
    let r = render("511-001_ExGearMotorEndCap.scad", stl, "revised", ctx, tally)?;
    let seat = echoed_number(&r.stderr, "end_cap_seat")?;
    probe_face(stl, "511-001 (revised)", [0.0, -16.0], seat, false, "seat", ctx, tally)
}

/// The drop `exgear_assembly.scad` asks J3's Attach to print with, read off
/// an echo export, which evaluates every assert without meshing anything.
fn assembly_drop(ctx: &Ctx, tally: &mut Tally) -> Result<Option<f64>> {
    let Ok(_) = render_with("exgear_assembly.scad", "out/assembly.echo", &[], ctx, tally) else {
        tally.record("exgear_assembly.scad asserts hold", false);
        return Ok(None);
    };
    tally.record("exgear_assembly.scad asserts hold", true);
    let log = std::fs::read_to_string(ctx.dir.join("out/assembly.echo"))?;
    Ok(Some(echoed_number(&log, "j3_hub_drop")?))
}

/// J3's Attach at the assembly's drop: the hub face where the part says it
/// is, and the counterbore floors left at z 7.000.
fn check_assembly(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let Some(drop) = assembly_drop(ctx, tally)? else { return Ok(()) };
    let stl = "out/revised/630-005-j3.stl";
    let define = format!("hub_drop={drop}");
    let r = render_with("../600-StrainWave/630-005_FlexSplineAttach.scad", stl,
                        &["config=\"revised\"", &define], ctx, tally)?;
    let face = echoed_number(&r.stderr, "attach_hub_face")?;
    probe_face(stl, "630-005 (J3)", [12.0, 0.0], face, true, "hub face", ctx, tally)?;
    probe_face(stl, "630-005 (J3)", [17.0, 17.0], 7.0, true, "counterbore floor", ctx, tally)
}

fn verify(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    check_strain_wave(ctx, tally)?;
    for gate in &DIST_GATES {
        dist_gate(gate, REF_DIR, ctx, tally)?;
    }
    std::fs::create_dir_all(ctx.dir.join("out/revised"))?;
    check_end_cap(ctx, tally)?;
    check_assembly(ctx, tally)
}

fn main() -> Result<()> {
    let ctx = Ctx::for_script()?;
    let mut tally = Tally::default();
    verify(&ctx, &mut tally)?;
    tally.finish()
}
