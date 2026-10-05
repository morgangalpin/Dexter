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
use render_check::{check_fits, dist_gate, probe, render, Ctx, DistGate, Fit, FitProbe, Tally};

const REF_DIR: &str = "../Reference/meshes/600-StrainWave";

const DIST_GATES: [DistGate; 2] = [
    DistGate {
        stem: "630-005",
        scad: "630-005_FlexSplineAttach.scad",
        reference: "630-005_FlexSplineAttach.stl",
        tol: 0.15,
    },
    DistGate {
        stem: "630-006",
        scad: "630-006_FlexSplineCap.scad",
        reference: "630-006_FlexSplineCap.stl",
        tol: 0.15,
    },
];

/// A point that must be material (`true`) or void (`false`) in a render.
struct Probe {
    label: &'static str,
    at: [f64; 3],
    solid: bool,
}

/// The revised #630-005 at the default hub_drop. The four counterbore floors
/// carry J1/J2's #6 washers at z 7.000; the land replaces the flare down to
/// the motor face, so r 25.1 is clear below the land where the flare was.
/// C-201's hub stands on the flat hub face: the spigot fills its Ø11 bore and
/// a nub each of its Ø4.5 holes on Ø17, both 2.2 high, and the reference's
/// Ø19 recess and its hole circle on Ø12 are gone.
const ATTACH_REVISED: [Probe; 14] = [
    Probe { label: "counterbore floor at z 7.0 (material below)", at: [17.0, 17.0, 6.9], solid: true },
    Probe { label: "counterbore floor at z 7.0 (void above)", at: [17.0, 17.0, 7.1], solid: false },
    Probe { label: "hub face at z 9.0 (material below)", at: [12.0, 0.0, 8.9], solid: true },
    Probe { label: "hub face at z 9.0 (void above)", at: [12.0, 0.0, 9.1], solid: false },
    Probe { label: "land runs to the motor face at R25", at: [17.6, 17.6, -0.9], solid: true },
    Probe { label: "no flare beyond R25 below the land", at: [17.75, 17.75, -0.5], solid: false },
    Probe { label: "spigot wall at r 5.3, z 10.5", at: [0.0, 5.3, 10.5], solid: true },
    Probe { label: "spigot top at z 11.2 (void above)", at: [0.0, 4.5, 11.3], solid: false },
    Probe { label: "centre bore open through the spigot", at: [0.0, 0.0, 10.5], solid: false },
    Probe { label: "nub wall at r 10.4, z 10.5", at: [10.4, 0.0, 10.5], solid: true },
    Probe { label: "screw hole open through the nub", at: [8.5, 0.0, 10.5], solid: false },
    Probe { label: "screw hole open under the hub face", at: [8.5, 0.0, 6.0], solid: false },
    Probe { label: "hub face clear between the nubs", at: [7.361, 4.25, 9.1], solid: false },
    Probe { label: "no Ø19 recess under the hub face", at: [5.196, 3.0, 8.0], solid: true },
];

/// The revised #630-006: a Ø22 land bears on the hub, its Ø25 body 0.5 off
/// the cup's bottom, and the nut traps run 2.0 deep from the nut face.
const CAP_REVISED: [Probe; 6] = [
    Probe { label: "land at r 10.8 reaches the face at z 4.0", at: [9.353, 5.4, 3.9], solid: true },
    Probe { label: "land stops inside the hub's Ø22.5", at: [9.873, 5.7, 3.9], solid: false },
    Probe { label: "body at r 12.3 stops at z 3.5", at: [10.652, 6.15, 3.4], solid: true },
    Probe { label: "nut trap open to z 2.0", at: [10.3, 0.0, 1.9], solid: false },
    Probe { label: "nut trap floor at z 2.0", at: [10.3, 0.0, 2.1], solid: true },
    Probe { label: "screw hole open on Ø17", at: [8.5, 0.0, 3.0], solid: false },
];

/// The revised #630-005's print fits (../print_fit.scad), each probed from
/// its mate's nominal surface: the 6810's Ø50 bore, the motor's 42.292
/// square, the hub's Ø11 bore and Ø4.5 holes, and the M2 screw and head.
const ATTACH_FITS: [FitProbe; 6] = [
    FitProbe { label: "land in the 6810", at: [17.6777, 17.6777, 3.0], toward: [0.7071, 0.7071, 0.0], fit: Fit::Press },
    FitProbe { label: "lug on the motor", at: [10.0, 21.146, -3.0], toward: [0.0, -1.0, 0.0], fit: Fit::Press },
    FitProbe { label: "spigot in the hub's bore", at: [0.0, 5.5, 10.0], toward: [0.0, 1.0, 0.0], fit: Fit::Press },
    FitProbe { label: "nub in a hub hole", at: [10.75, 0.0, 10.0], toward: [1.0, 0.0, 0.0], fit: Fit::Press },
    FitProbe { label: "M2 hole", at: [9.5, 0.0, 6.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Slip },
    FitProbe { label: "M2 head pocket", at: [10.4, 0.0, 3.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Slip },
];

/// The revised #630-006's print fits: the M2 screw and the M2 nut's flat.
const CAP_FITS: [FitProbe; 2] = [
    FitProbe { label: "M2 hole", at: [9.5, 0.0, 3.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Slip },
    FitProbe { label: "M2 nut trap", at: [10.5, 0.0, 1.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Slip },
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
    check_probes(stl, "630-005 (revised)", &ATTACH_REVISED, ctx, tally)?;
    check_fits(stl, "630-005 (revised)", &ATTACH_FITS, ctx, tally)?;
    let stl = "out/revised/630-006.stl";
    render("630-006_FlexSplineCap.scad", stl, "revised", ctx, tally)?;
    check_probes(stl, "630-006 (revised)", &CAP_REVISED, ctx, tally)?;
    check_fits(stl, "630-006 (revised)", &CAP_FITS, ctx, tally)
}

fn main() -> Result<()> {
    let ctx = Ctx::for_script()?;
    let mut tally = Tally::default();
    verify(&ctx, &mut tally)?;
    tally.finish()
}
