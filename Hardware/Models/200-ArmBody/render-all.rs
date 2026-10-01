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
use render_check::{check_seat, dist_gate, Ctx, DistGate, Tally};

const REF_DIR: &str = "../Reference/meshes/200-ArmBody";

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
    check_seat("200-002_PivotStatorHolder.scad", "200-002", -1.0, ctx, tally)
}

fn main() -> Result<()> {
    let ctx = Ctx::for_script()?;
    let mut tally = Tally::default();
    verify(&ctx, &mut tally)?;
    tally.finish()
}
