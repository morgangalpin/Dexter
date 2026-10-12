#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Render every 300-Pivot part recreated as `.scad`, gate the faithful
//! ("previous") renders on their reference meshes, and verify the "revised"
//! renders keep the clearances they were revised for.
//!
//! #300-001 renders on OpenSCAD's Manifold engine only: under CGAL its
//! swept and lofted blends leave non-planar faces and a mesh that is not a
//! valid 2-manifold. #311-001 renders on CGAL, as #511-001 does: under
//! Manifold the wire channel's lofted blend leaves an open seam and specks.
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
use render_check::{check_fits, dist_gate, probe, render_binary, Ctx, DistGate, Fit, FitProbe, Tally};

const REF_DIR: &str = "../Reference/meshes/300-Pivot";

const PIVOT_GATE: DistGate = DistGate {
    stem: "300-001",
    scad: "300-001_MainPivot.scad",
    reference: "300-001_MainPivot.stl",
    tol: 0.15,
};

const END_CAP_GATE: DistGate = DistGate {
    stem: "311-001",
    scad: "311-001_MotorEndCapBase.scad",
    reference: "311-001_MotorEndCapBase.stl",
    tol: 0.15,
};

/// A point that must be material (`true`) or void (`false`) in a render.
struct Probe {
    label: &'static str,
    at: [f64; 3],
    solid: bool,
}

/// The revised #300-001. The drum's underside stands the running clearance
/// (0.5) above the 1.6-thick code disc, at z 2.1, outside the Ø55 land, which
/// is unchanged. The side faces stand back the slip clearance (0.15) from the
/// skirt's collar all the way up, but keep a pad where each of the three
/// bosses backs the collar's face, Ø11.9 about the screw at z 15 on 180° and
/// ±135°, above the collar's chamfer (z 15.94); the +X face is unchanged.
const PIVOT_REVISED: [Probe; 12] = [
    Probe { label: "drum underside clear of the code disc (z 2.0, r 29.5)", at: [0.0, -29.5, 2.0], solid: false },
    Probe { label: "drum underside at z 2.1 (material above)", at: [0.0, -29.5, 2.2], solid: true },
    Probe { label: "land unchanged at r 27", at: [0.0, -27.0, 1.8], solid: true },
    Probe { label: "pad under the 180° boss", at: [-32.45, 4.0, 17.0], solid: true },
    Probe { label: "pad under the 135° boss", at: [-22.945, 22.945, 19.0], solid: true },
    Probe { label: "-X face trimmed beside its nut trap, below the collar", at: [-32.45, 3.5, 13.0], solid: false },
    Probe { label: "-X face stands back above the collar", at: [-32.45, -8.0, 26.0], solid: false },
    Probe { label: "-X face stands back below the spacers", at: [-32.45, -8.0, 11.0], solid: false },
    Probe { label: "-X face stands back up to its top round", at: [-32.45, -8.0, 60.0], solid: false },
    Probe { label: "-X face stands at the slip clearance", at: [-32.30, -8.0, 40.0], solid: true },
    Probe { label: "+X face unchanged beside the collar", at: [35.45, 0.0, 19.0], solid: true },
    Probe { label: "+Y face trimmed beside the bosses", at: [10.0, 32.45, 19.0], solid: false },
];

/// The revised #300-001's slip fits under the skirt's collar, each from the
/// collar's inner face (apothem 32.5), clear of the pads.
const PIVOT_FITS: [FitProbe; 4] = [
    FitProbe { label: "-X face under the collar", at: [-32.5, -8.0, 19.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Slip },
    FitProbe { label: "+Y face under the collar", at: [10.0, 32.5, 19.0], toward: [0.0, 1.0, 0.0], fit: Fit::Slip },
    FitProbe { label: "-Y face under the collar", at: [0.0, -32.5, 19.0], toward: [0.0, -1.0, 0.0], fit: Fit::Slip },
    FitProbe { label: "135° face under the collar", at: [-22.981, 22.981, 22.0], toward: [-0.7071, 0.7071, 0.0], fit: Fit::Slip },
];

/// The revised #311-001: the root fillets trimmed off the lugs' faces, the
/// channel's sides rounded into the bore (the point lies 0.06 inside the sharp
/// edge, 0.9 above the seat at z -1.65), the channel stopped at the lug's
/// corner, and the step left as drawn.
const END_CAP_REVISED: [Probe; 8] = [
    Probe { label: "no root fillet on a lug's face", at: [21.1, 10.0, -1.8], solid: false },
    Probe { label: "wire channel open at +X", at: [15.0, 0.0, -1.0], solid: false },
    Probe { label: "channel's side rounded into the bore", at: [9.56, 6.06, -0.75], solid: false },
    Probe { label: "lug's corner standing under the channel", at: [21.7, 6.45, -1.6], solid: true },
    Probe { label: "top face at z 10.5 (material below)", at: [0.0, -20.0, 10.4], solid: true },
    Probe { label: "ring at r 26 below the land's foot", at: [18.38, 18.38, 3.4], solid: true },
    Probe { label: "no ring at r 26 above the land's foot", at: [18.38, 18.38, 3.6], solid: false },
    Probe { label: "lug down to z -6.7", at: [23.5, 10.0, -6.6], solid: true },
];

/// The revised #311-001's print fits: the 6810's Ø50 bore over the land, the
/// motor's 42.292 square on a lug, the motor's rear face under the seat, and
/// the M3 screw in the motor hole on 45 deg (centre 15.5, 15.5).
const END_CAP_FITS: [FitProbe; 4] = [
    FitProbe { label: "land in the 6810", at: [17.6777, 17.6777, 7.0], toward: [0.7071, 0.7071, 0.0], fit: Fit::Press },
    FitProbe { label: "lug on the motor", at: [21.146, 10.0, -4.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Press },
    FitProbe { label: "seat on the motor's rear", at: [15.0, 8.0, -1.7], toward: [0.0, 0.0, -1.0], fit: Fit::Press },
    FitProbe { label: "M3 hole", at: [16.5607, 16.5607, 4.0], toward: [-0.7071, -0.7071, 0.0], fit: Fit::Slip },
];

fn check_probes(stl: &str, part: &str, probes: &[Probe], ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let points: Vec<[f64; 3]> = probes.iter().map(|p| p.at).collect();
    for (p, inside) in probes.iter().zip(probe(stl, &points, ctx)?) {
        tally.record(&format!("{part} {}", p.label), inside == p.solid);
    }
    Ok(())
}

fn check_pivot(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let ctx = &ctx.manifold();
    dist_gate(&PIVOT_GATE, REF_DIR, ctx, tally)?;
    let stl = "out/revised/300-001.stl";
    render_binary("300-001_MainPivot.scad", stl, &["config=\"revised\""], ctx, tally)?;
    check_probes(stl, "300-001 (revised)", &PIVOT_REVISED, ctx, tally)?;
    check_fits(stl, "300-001 (revised)", &PIVOT_FITS, ctx, tally)
}

fn check_end_cap(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    dist_gate(&END_CAP_GATE, REF_DIR, ctx, tally)?;
    let stl = "out/revised/311-001.stl";
    render_binary("311-001_MotorEndCapBase.scad", stl, &["config=\"revised\""], ctx, tally)?;
    check_probes(stl, "311-001 (revised)", &END_CAP_REVISED, ctx, tally)?;
    check_fits(stl, "311-001 (revised)", &END_CAP_FITS, ctx, tally)
}

fn main() -> Result<()> {
    let ctx = Ctx::for_script()?;
    let mut tally = Tally::default();
    std::fs::create_dir_all(ctx.dir.join("out/revised"))?;
    check_end_cap(&ctx, &mut tally)?;
    check_pivot(&ctx, &mut tally)?;
    tally.finish()
}
