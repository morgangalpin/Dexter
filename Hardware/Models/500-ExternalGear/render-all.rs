#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Render every 500-ExternalGear part recreated as `.scad`, gate the faithful
//! ("previous") renders on their reference meshes, and verify that J3's stack
//! closes: `exgear_assembly.scad` evaluates with every assert holding, the
//! revised Stator Holder seats C-201's spline and clears every part around
//! it, and the #630-005 it asks J3 to print has its hub face where the
//! assembly put it.
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
use render_check::{check_seat, clash_free, dist_gate, echoed, probe, render, render_with, run, sm_json, Ctx,
                   DistGate, Tally};

const REF_DIR: &str = "../Reference/meshes/500-ExternalGear";

const DIST_GATES: [DistGate; 2] = [
    DistGate {
        stem: "511-001",
        scad: "511-001_ExGearMotorEndCap.scad",
        reference: "511-001_ExGearMotorEndCap.stl",
        tol: 0.15,
    },
    DistGate {
        stem: "511-002",
        scad: "511-002_ExGearStatorHolder.scad",
        reference: "511-002_ExGearStatorHolder.stl",
        tol: 0.15,
    },
];

/// The parts the Stator Holder sits among, each rendered against it.
const STATOR_NEIGHBOURS: [&str; 5] = ["attach", "circular_spline", "bearing_top", "bearing_upper", "flexspline"];

/// Holder heights (its own frame) at which its spigot must fill the gear's
/// socket exactly: two in the keys, one in their end chamfers.
const SPIGOT_SECTIONS: [f64; 3] = [6.0, 9.0, 11.0];

/// Section-area agreement, mm², between the spigot and the socket: 0.01 mm of
/// mean offset over their ≈230 mm outline. Faceting alone accounts for ≈1 mm²
/// (the holder's R32.5 in 144 segments against the gear mesh's fewer); a
/// holder off its seat by the chamfer's 1.6 mm differs by over 100 mm².
const FIT_TOL: f64 = 2.3;

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

/// The two loop areas of a section, largest first.
fn loop_areas(stl: &str, axis: &str, at: f64, ctx: &Ctx) -> Result<Vec<f64>> {
    let at = format!("--at={at}");
    let (_, json) = sm_json(&["slice", stl, "--axis", axis, &at], ctx)?;
    let mut areas: Vec<f64> = json["loops"].as_array().context("slice emitted no loops")?
        .iter().filter_map(|l| l["area"].as_f64()).map(f64::abs).collect();
    areas.sort_by(|a, b| b.total_cmp(a));
    Ok(areas)
}

/// The Stator Holder against the External Gear. CGAL cannot take this pair:
/// the keys fit the slots line to line, and a boolean over coincident faces
/// fails and returns an operand. The fit is checked instead where it is
/// made: in each shared plane below the gear's end, the spigot's outline
/// (the holder's outer loop) must be the socket's (the gear's inner loop).
/// Above the gear's end the holder has nothing the gear could reach.
fn check_gear_fit(on_gear: f64, ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    for z in SPIGOT_SECTIONS {
        let spigot = loop_areas("out/revised/511-002.stl", "z", z, ctx)?[0];
        let socket = loop_areas("510-001_ExternalGear.stl", "x", on_gear - z, ctx)?[1];
        tally.record(
            &format!("stator spigot fills the gear's socket at holder z {z} ({spigot:.2} vs {socket:.2} mm2)"),
            (spigot - socket).abs() < FIT_TOL,
        );
    }
    Ok(())
}

/// The echo log of `exgear_assembly.scad`, from an echo export, which
/// evaluates every assert without meshing anything.
fn assembly_echo(ctx: &Ctx, tally: &mut Tally) -> Result<Option<String>> {
    let Ok(_) = render_with("exgear_assembly.scad", "out/assembly.echo", &[], ctx, tally) else {
        tally.record("exgear_assembly.scad asserts hold", false);
        return Ok(None);
    };
    tally.record("exgear_assembly.scad asserts hold", true);
    Ok(Some(std::fs::read_to_string(ctx.dir.join("out/assembly.echo"))?))
}

/// The Stator Holder among its neighbours, then J3's Attach at the drop the
/// assembly asks for: the hub face where the part says it is, and the
/// counterbore floors left at z 7.000.
fn check_assembly(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let Some(log) = assembly_echo(ctx, tally)? else { return Ok(()) };
    check_gear_fit(echoed_number(&log, "stator_on_gear")?, ctx, tally)?;
    for other in STATOR_NEIGHBOURS {
        clash_free("exgear_assembly.scad", "stator", other, ctx, tally)?;
    }
    let drop = echoed_number(&log, "j3_hub_drop")?;
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
    // The revised Stator Holder's recess opens toward -z.
    check_seat("511-002_ExGearStatorHolder.scad", "511-002", -1.0, ctx, tally)?;
    check_assembly(ctx, tally)
}

fn main() -> Result<()> {
    let ctx = Ctx::for_script()?;
    let mut tally = Tally::default();
    verify(&ctx, &mut tally)?;
    tally.finish()
}
