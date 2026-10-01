#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Render every 100-Base part recreated as `.scad`, gate the faithful
//! ("previous") renders on their reference meshes, and verify that the
//! revised Base Stator Holder seats C-201's circular spline.
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
use render_check::{check_seat, dist_gate, run, Ctx, DistGate, Tally};

const REF_DIR: &str = "../Reference/meshes/100-Base";

const DIST_GATES: [DistGate; 1] = [DistGate {
    stem: "110-002",
    scad: "110-002_BaseStatorHolder.scad",
    reference: "110-002_BaseStatorHolder.stl",
    tol: 0.15,
}];

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
    for gate in &DIST_GATES {
        dist_gate(gate, REF_DIR, ctx, tally)?;
    }
    // The Base Stator Holder's recess opens toward +z.
    check_seat("110-002_BaseStatorHolder.scad", "110-002", 1.0, ctx, tally)
}

fn main() -> Result<()> {
    let ctx = Ctx::for_script()?;
    let mut tally = Tally::default();
    verify(&ctx, &mut tally)?;
    tally.finish()
}
