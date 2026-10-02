#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Render every 200-ArmBody part recreated as `.scad`, gate the faithful
//! ("previous") renders on their reference meshes, and verify that the
//! revised Pivot Stator Holder seats C-201's circular spline.
//!
//! Needs OpenSCAD and `scadmesh`; see the `render-check` crate for how they
//! are found.
//!
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! render-check = { path = "../render-check" }
//! ```

use anyhow::Result;
use render_check::{check_fits, check_seat, dist_gate, Ctx, DistGate, Fit, FitProbe, Tally};

const REF_DIR: &str = "../Reference/meshes/200-ArmBody";

/// The revised #200-002's own print fits: its Ø65 body in the Arm Body's Ø65
/// bore, probed at 45 deg, clear of the flange's ears, and the +X ear slot on
/// a Stator Balancer's 3.9 x 9.9 shank, centred at r 35.516. The seat's fits
/// are check_seat's.
const HOLDER_FITS: [FitProbe; 3] = [
    FitProbe { label: "body in the Arm Body", at: [22.9810, 22.9810, 8.0], toward: [0.7071, 0.7071, 0.0], fit: Fit::Slip },
    FitProbe { label: "ear slot's outer face", at: [37.466, 0.0, 1.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Slip },
    FitProbe { label: "ear slot's side", at: [35.516, 4.95, 1.0], toward: [0.0, -1.0, 0.0], fit: Fit::Slip },
];

const DIST_GATES: [DistGate; 1] = [DistGate {
    stem: "200-002",
    scad: "200-002_PivotStatorHolder.scad",
    reference: "200-002_PivotStatorHolder.stl",
    tol: 0.15,
}];

fn verify(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    for gate in &DIST_GATES {
        dist_gate(gate, REF_DIR, ctx, tally)?;
    }
    // The Pivot Stator Holder's recess opens toward -z.
    check_seat("200-002_PivotStatorHolder.scad", "200-002", -1.0, ctx, tally)?;
    check_fits("out/revised/200-002.stl", "200-002 (revised)", &HOLDER_FITS, ctx, tally)
}

fn main() -> Result<()> {
    let ctx = Ctx::for_script()?;
    let mut tally = Tally::default();
    verify(&ctx, &mut tally)?;
    tally.finish()
}
