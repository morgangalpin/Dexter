#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Render every 100-Base part recreated as `.scad`, gate the faithful
//! ("previous") renders on their reference meshes, probe each revised
//! render's print fits, and verify that the revised Base Stator Holder seats
//! C-201's circular spline.
//!
//! The Base Mounting Plate is authored rather than recreated and has its own
//! contract in `check.rs`; that script is run first rather than repeated here.
//!
//! Needs OpenSCAD, `scadmesh` and `rust-script`; see the `render-check` crate
//! for how the first two are found.
//!
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! render-check = { path = "../render-check" }
//! ```

use anyhow::Result;
use render_check::{
    check_fits, check_seat, dist_gate, outline_gate, render, run, Ctx, DistGate, Fit, FitProbe, OutlineGate, Tally,
};

const REF_DIR: &str = "../Reference/meshes/100-Base";

const DIST_GATES: [DistGate; 4] = [
    DistGate {
        stem: "100-001",
        scad: "100-001_BaseClamp.scad",
        reference: "100-001_BaseClamp.stl",
        tol: 0.15,
    },
    DistGate {
        stem: "100-002",
        scad: "100-002_BaseCodeDisc.scad",
        reference: "100-002_BaseCodeDisc.stl",
        tol: 0.15,
    },
    DistGate {
        stem: "100-003",
        scad: "100-003_PivotSkirt.scad",
        reference: "100-003_PivotSkirt.stl",
        tol: 0.15,
    },
    DistGate {
        stem: "110-002",
        scad: "110-002_BaseStatorHolder.scad",
        reference: "110-002_BaseStatorHolder.stl",
        tol: 0.15,
    },
];

/// The revised #100-001's print fits, on its bolt axis (x 41.125, z 7.5,
/// along Y): the M3 bolt's surface on B1's outer side between the split and
/// the nut, and the inner flats of B2's nut and B3's head, where the wall
/// behind them is whole.
const CLAMP_FITS: [FitProbe; 3] = [
    FitProbe { label: "B1 bolt hole", at: [42.625, 3.0, 7.5], toward: [-1.0, 0.0, 0.0], fit: Fit::Slip },
    FitProbe { label: "B2 nut trap", at: [38.375, 9.0, 7.5], toward: [1.0, 0.0, 0.0], fit: Fit::Slip },
    FitProbe { label: "B3 head counterbore", at: [38.375, -9.5, 7.5], toward: [1.0, 0.0, 0.0], fit: Fit::Slip },
];

/// #100-002 is drawn as two 2D profiles, each checked against the reference's
/// section mid-layer before the part is extruded. #100-003's skirt section is
/// checked across y just above the plug's crest, and its frame profile
/// across the flange, where the top face's sweep is a plain extrusion.
const OUTLINE_GATES: [OutlineGate; 4] = [
    OutlineGate {
        stem: "100-002",
        scad: "100-002_BaseCodeDisc.scad",
        reference: "100-002_BaseCodeDisc.stl",
        layer: "lower",
        axis: "z",
        at: 0.1,
        tol: 0.15,
    },
    OutlineGate {
        stem: "100-002",
        scad: "100-002_BaseCodeDisc.scad",
        reference: "100-002_BaseCodeDisc.stl",
        layer: "upper",
        axis: "z",
        at: 0.9,
        tol: 0.15,
    },
    OutlineGate {
        stem: "100-003",
        scad: "100-003_PivotSkirt.scad",
        reference: "100-003_PivotSkirt.stl",
        layer: "skirt",
        axis: "y",
        at: -4.0,
        tol: 0.15,
    },
    OutlineGate {
        stem: "100-003",
        scad: "100-003_PivotSkirt.scad",
        reference: "100-003_PivotSkirt.stl",
        layer: "frame",
        axis: "x",
        at: -20.0,
        tol: 0.15,
    },
];

/// The revised #100-003's print fits: H1's Ø3 screw holes at 0° and 45°,
/// mid-collar, on the M3 screw's surface on its +y side.
const SKIRT_FITS: [FitProbe; 2] = [
    FitProbe { label: "H1 screw hole, 0°", at: [34.0, 13.5, 0.0], toward: [0.0, -1.0, 0.0], fit: Fit::Slip },
    FitProbe { label: "H1 screw hole, 45°", at: [24.0416, 13.5, 24.0416], toward: [0.0, -1.0, 0.0], fit: Fit::Slip },
];

/// The revised #100-002's print fit: B1 on the Base Stator Holder's Ø65 body,
/// on +X between two notches, mid-height.
const DISC_FITS: [FitProbe; 1] = [
    FitProbe { label: "B1 bore", at: [32.5, 0.0, 0.9], toward: [-1.0, 0.0, 0.0], fit: Fit::Slip },
];

/// The revised #110-002's own print fits, on the all-thread hole at 30 deg
/// (r 35.54): the M3 rod's surface on the hole's outer side, and the M3 nut's
/// outer flat in its trap. The seat's fits are check_seat's.
const HOLDER_FITS: [FitProbe; 2] = [
    FitProbe { label: "all-thread hole", at: [32.0776, 18.52, 12.7], toward: [-0.866025, -0.5, 0.0], fit: Fit::Slip },
    FitProbe { label: "all-thread nut trap", at: [33.1601, 19.145, 15.0], toward: [-0.866025, -0.5, 0.0], fit: Fit::Slip },
];

/// The Base Mounting Plate's script, run as it is and judged by its exit
/// status.
fn check_plate(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let r = run("rust-script", &["check.rs"], &ctx.dir)?;
    for line in r.stdout.lines() {
        println!("  plate| {line}");
    }
    tally.record("100-Base/check.rs", r.ok);
    Ok(())
}

fn verify(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    check_plate(ctx, tally)?;
    for gate in &OUTLINE_GATES {
        outline_gate(gate, REF_DIR, ctx, tally)?;
    }
    for gate in &DIST_GATES {
        dist_gate(gate, REF_DIR, ctx, tally)?;
    }
    std::fs::create_dir_all(ctx.dir.join("out/revised"))?;
    render("100-001_BaseClamp.scad", "out/revised/100-001.stl", "revised", ctx, tally)?;
    check_fits("out/revised/100-001.stl", "100-001 (revised)", &CLAMP_FITS, ctx, tally)?;
    render("100-002_BaseCodeDisc.scad", "out/revised/100-002.stl", "revised", ctx, tally)?;
    check_fits("out/revised/100-002.stl", "100-002 (revised)", &DISC_FITS, ctx, tally)?;
    render("100-003_PivotSkirt.scad", "out/revised/100-003.stl", "revised", ctx, tally)?;
    check_fits("out/revised/100-003.stl", "100-003 (revised)", &SKIRT_FITS, ctx, tally)?;
    // The Base Stator Holder's recess opens toward +z.
    check_seat("110-002_BaseStatorHolder.scad", "110-002", 1.0, ctx, tally)?;
    check_fits("out/revised/110-002.stl", "110-002 (revised)", &HOLDER_FITS, ctx, tally)
}

fn main() -> Result<()> {
    let ctx = Ctx::for_script()?;
    let mut tally = Tally::default();
    verify(&ctx, &mut tally)?;
    tally.finish()
}
