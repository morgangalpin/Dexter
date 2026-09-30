#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Render every 600-StrainWave part recreated as `.scad`, gate the faithful
//! ("previous") renders on their reference meshes, and verify the "revised"
//! renders keep the faces the other joints rely on.
//!
//! #630-005 is used in J1, J2 and J3. Its revised shape is checked here at the
//! default hub_drop, which is what J1 and J2 print; J3's drop is set by
//! `../500-ExternalGear/exgear_assembly.scad`, and that group's script checks
//! the part at it.
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
use render_check::{dist_gate, probe, render, Ctx, DistGate, Tally};

const REF_DIR: &str = "../Reference/meshes/600-StrainWave";

const DIST_GATES: [DistGate; 1] = [DistGate {
    stem: "630-005",
    scad: "630-005_FlexSplineAttach.scad",
    reference: "630-005_FlexSplineAttach.stl",
    tol: 0.15,
}];

/// A point that must be material (`true`) or void (`false`) in a render.
struct Probe {
    label: &'static str,
    at: [f64; 3],
    solid: bool,
}

/// The revised #630-005 at the default hub_drop. The four counterbore floors
/// carry J1/J2's #6 washers at z 7.000; the land replaces the flare down to
/// the motor face, so r 25.1 is clear below the land where the flare was.
const ATTACH_REVISED: [Probe; 6] = [
    Probe { label: "counterbore floor at z 7.0 (material below)", at: [17.0, 17.0, 6.9], solid: true },
    Probe { label: "counterbore floor at z 7.0 (void above)", at: [17.0, 17.0, 7.1], solid: false },
    Probe { label: "hub face at z 9.0 (material below)", at: [12.0, 0.0, 8.9], solid: true },
    Probe { label: "hub face at z 9.0 (void above)", at: [12.0, 0.0, 9.1], solid: false },
    Probe { label: "land runs to the motor face at R25", at: [17.6, 17.6, -0.9], solid: true },
    Probe { label: "no flare beyond R25 below the land", at: [17.75, 17.75, -0.5], solid: false },
];

fn check_probes(stl: &str, part: &str, probes: &[Probe], ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let points: Vec<[f64; 3]> = probes.iter().map(|p| p.at).collect();
    for (p, inside) in probes.iter().zip(probe(stl, &points, ctx)?) {
        tally.record(&format!("{part} {}", p.label), inside == p.solid);
    }
    Ok(())
}

fn verify(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    for gate in &DIST_GATES {
        dist_gate(gate, REF_DIR, ctx, tally)?;
    }
    std::fs::create_dir_all(ctx.dir.join("out/revised"))?;
    let stl = "out/revised/630-005.stl";
    render("630-005_FlexSplineAttach.scad", stl, "revised", ctx, tally)?;
    check_probes(stl, "630-005 (revised)", &ATTACH_REVISED, ctx, tally)
}

fn main() -> Result<()> {
    let ctx = Ctx::for_script()?;
    let mut tally = Tally::default();
    verify(&ctx, &mut tally)?;
    tally.finish()
}
