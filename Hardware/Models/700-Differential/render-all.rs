#!/bin/bash
//! 2>/dev/null; command -v rust-script >/dev/null 2>&1 || { echo "Error: Install rust-script with: cargo install rust-script" >&2; exit 1; }; exec rust-script "$0" "$@"
//! Render every 700-Differential part in both configurations, verify the
//! faithful ("previous") renders against their reference meshes, and verify
//! the "revised" renders against what DC-12 re-cut: tooth counts, stated
//! extents, and the pulley chamber's clearance.
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
//!
//! The two differential housings are held to a stricter contract than the
//! rest. `compare` matches extracted feature planes and diameters, so a body
//! can satisfy every mating interface while its shell is nothing like the
//! reference — which is exactly what happened when these two were authored as
//! functional redesigns: Body A passed its interface checks at 2.43x the
//! reference's material. They are therefore gated on `dist`, a two-sided
//! surface distance that measures the surfaces themselves and so catches a
//! missing feature or a wrong hole shape. See DIST_GATES.
//!
//! ```cargo
//! [dependencies]
//! anyhow = "1"
//! serde_json = "1"
//! render-check = { path = "../render-check" }
//! ```

use anyhow::{Context, Result};
use render_check::{check_fits, diagnostics, dist_gate, group_parts, render, run, sm_json, Ctx, DistGate, Fit, FitProbe, Tally};
use serde_json::Value;

/// Where the reference meshes live. They sit under `Reference/`, not beside
/// the `.scad` files, because for these nine parts the `.scad` is the source of
/// record and the mesh is only what it is measured against. The `reference`
/// fields below name the file; `ref_path` puts it there.
const REF_DIR: &str = "../Reference/meshes/700-Differential";

fn ref_path(name: &str) -> String {
    format!("{REF_DIR}/{name}")
}

/// A part recreated faithfully enough to compare against its reference mesh.
///
/// `tol` is per part, and it is not slack — it is the measured noise floor of
/// the comparison itself. `compare` matches extracted feature planes and
/// diameters by binning the REFERENCE's vertex radii, merging adjacent bins
/// into runs, taking each run's weighted mean and then finding the nearest
/// CANDIDATE vertex. On a densely sampled curved flank that measures vertex
/// SPACING rather than dimension, and the reference's own vertices need not sit
/// at their run's mean either. So the floor is measurable directly: run
/// `compare` on a reference against ITSELF, with that part's own flags, and see
/// what it reports.
///
///     710-001  0.0741      720-002  0.0395      710-004  0.0000
///     710-002  0.0647      710-003  0.0256
///     720-003  0.0442      720-001  0.0156
///
/// Six of the seven cannot reach 0.001 mm by construction, which is what these
/// all ran under until now: `sm_json` was called with no `--tol` and inherited
/// `compare`'s default. The seven failures that produced were not statements
/// about the models, and treating them as such is how the one real departure
/// among them — 720-001's 0.768 mm — sat unexamined among six phantoms. Each
/// `tol` below is the smallest round number clearing both that part's floor and
/// its remaining residual; the residual is named in the part's own comment, and
/// a part whose residual is a buried face carries an `--ignore-*` range for it
/// rather than a looser `tol`.
struct ClonePart {
    stem: &'static str,
    scad: &'static str,
    reference: &'static str,
    tol: f64,
    deviations: &'static [Deviation],
    extra: &'static [&'static str],
}

/// A check whose delta is a stated departure from the reference rather than an
/// error. The part is held to `delta`, within `dev_tol`, instead of to zero.
///
/// This is not `tol` under another name. Covering a deliberate 0.768 mm
/// departure by loosening the part's `tol` to 0.8 would loosen every other
/// check on that part by the same amount — and would still pass if the
/// departure silently disappeared. A deviation is two-sided: the number has to
/// still be there, and the checks around it stay at the part's own tolerance.
///
/// `compare` has no per-check tolerance and no `--ignore-bbox`, and a bounding
/// box cannot be masked with `--ignore-band` in any case, so the verdict for a
/// part with deviations is computed here from `checks[]` rather than taken from
/// `compare`'s exit status.
struct Deviation {
    check: &'static str,
    delta: f64,
    dev_tol: f64,
}

const CLONES: [ClonePart; 7] = [
    // Residual 0.029 against a floor of 0.0256, both on radial-diam-8.58, the
    // upper fillet's ring. The 0.003 over the floor is rotational tessellation
    // and is demonstrable: rendered at $fn = 105, the reference's own export
    // setting, this part scores exactly the 0.026 floor. It is not rendered at
    // 105 — $fn belongs to diff_params.scad and the floor does not move — but
    // that is the measurement showing there is no dimension left to find.
    ClonePart { stem: "710-003", scad: "710-003_DiffKeeper.scad",
                reference: "710-003_DiffKeeper.stl", tol: 0.03,
                deviations: &[], extra: &[] },
    // The only part whose reference compares to itself exactly, so its 0.006 mm
    // was real — and it is bbox alone, every other check being under 6e-7. The
    // rim is a 105-gon whose top and bottom rings are staggered by half a
    // facet, giving 210 extreme positions at 0.857143 deg: x lands on one at
    // 52.500 and y falls midway, so 52.5 * (1 - cos(180/210)) = 0.0058747,
    // which is the measured delta to eight digits. 0.007, not the 0.006 that
    // would just clear it: a check that passes by 0.000125 mm is the same trap
    // as the 0.001 default, one edit to DISK_OD or $fn away from a failure that
    // says nothing. Nothing is lost by the margin — every other check on this
    // part comes in under 6e-7 mm, so the bbox term was never what gave this
    // comparison its teeth.
    //
    // `compare` has no --ignore-bbox and no per-check tolerance, so for a
    // bounding-box artifact a tolerance is the only lever there is.
    //
    // Its real defect was invisible here and worth remembering: the slot cuts
    // met the recess floor exactly on the plane z = 0.200, and CGAL does not
    // merge two voids that meet on a plane. That left a zero-thickness membrane
    // across every slot — 100 x 2.45 mm2 counted twice — which `compare` scored
    // identically to the sound part, because it changes no plane and no
    // diameter. Surface area caught it (3781 mm2 against the reference's 3291)
    // and `dist` charged 0.35 mm for it. When a cut has to land on a face, give
    // it a second cutter that crosses the face instead.
    ClonePart { stem: "710-004", scad: "710-004_RotateCodeDisk.scad",
                reference: "710-004_RotateCodeDisk.stl", tol: 0.007,
                deviations: &[], extra: &[] },
    // Residual 0.038 on radial-diam-23.68, the GT2 flank: at the default 0.05
    // bin the whole flank merges into one run of 8439 vertices whose mean falls
    // in a 0.058 mm gap in the model's flank sampling. The reference has no
    // vertex at its own run mean either, and scores 0.044 against itself.
    ClonePart { stem: "720-003", scad: "720-003_DiffEndPulley.scad",
                reference: "720-003_DiffEndPulley.stl", tol: 0.05,
                deviations: &[],
                extra: &["--ignore-plane=-4.05,-3.7", "--ignore-plane=-1.8,4.2"] },
    // The added band masks the reference's own bottom face: 1366 vertices at
    // z = 0.000000 forming a 27-gon on Ø17.000, of which 66 facets are exact
    // reversed duplicates over a 97-degree sector — a zero-thickness sheet, the
    // artifact class this file's header already names. It read 1.075 mm.
    ClonePart { stem: "720-002", scad: "720-002_DiffGearAxle.scad",
                reference: "720-002_DiffGearAxle.stl", tol: 0.10,
                deviations: &[],
                extra: &["--ignore-band=16.8,17.05",
                         "--ignore-band=25.8,28.2", "--ignore-band=36.5,43.9",
                         "--ignore-plane=2.2,2.45"] },
    // The only one of the seven whose 0.768 mm was a real departure rather than
    // a phantom of the tolerance — and it is deliberate. This part blunts its
    // tooth tips to the reference's LAND rather than to the reference's
    // diameter: on the shared crown's shallower tooth form the reference's
    // Ø43.500 would leave a 0.031 mm land, which is a sharp tip with a matching
    // number, so the wider blunt is cut instead and the OD comes out Ø0.785
    // under. See that file on the tip cut for why the blunt outranks the match.
    //
    // Pinned as a deviation rather than waved through by a loose `tol`, because
    // the departure has a value and re-typing the old diameter must fail this
    // check too. Both transverse dims carry it; the axial dim is unaffected.
    // 0.02 of drift is allowed: 0.768 rather than the OD's own 0.785 because
    // the gear's transverse extent is set by the land corners of the tooth
    // nearest the axis, which move with the flank tessellation. What remains
    // outside the deviation is 0.025 mm on radial-diam-23.76, the shared bevel
    // crown's flank, against a self-comparison floor of 0.016.
    //
    // The render is the solid, buildable shaft (`wall_holes` false) and the
    // reference carries twelve Ø0.2 holes on Ø15.5; the 15.3..15.7 band masks
    // that ring, so the part is gated in the state it is printed in.
    ClonePart { stem: "720-001", scad: "720-001_DiffGearShaft.scad",
                reference: "720-001_DiffGearShaft.stl", tol: 0.05,
                deviations: &[
                    Deviation { check: "bbox-dim0", delta: 0.768, dev_tol: 0.02 },
                    Deviation { check: "bbox-dim1", delta: 0.768, dev_tol: 0.02 },
                ],
                extra: &["--axis", "y", "--ignore-band=15.3,15.7",
                         "--ignore-band=27.15,43.5", "--ignore-plane=-30.5,30.5"] },
    // This reference is two overlapping closed solids, cage and bevel crown,
    // and neither can be stripped: `--keep 0` would delete the whole crown. The
    // four added ranges are its buried faces and mesher ladders — the crown's
    // back face at z 15.448 (which read 0.562 mm), the heel root Ø36.717 buried
    // inside the cage's Ø36.997, that same circle seen as a plane, and the
    // tooth-flank ladder over z 18.358..20.391. The band widened to 25.25
    // covers the Ø23->Ø28 fillet's ring ladder, whose self-noise alone is 0.074.
    ClonePart { stem: "710-001", scad: "710-001_SplitGearTop.scad",
                reference: "710-001_SplitGearTop.stl", tol: 0.06,
                deviations: &[],
                extra: &["--ignore-band=23.85,25.25", "--ignore-band=33.9,34.6",
                         "--ignore-band=36.5,36.8",
                         "--ignore-band=38.2,43.9", "--ignore-band=14.9,15.1",
                         "--ignore-plane=-11.8,-11.6", "--ignore-plane=3.65,3.85",
                         "--ignore-plane=6.10,6.25", "--ignore-plane=6.60,8.75"] },
    // Same story: the 1.500 mm was the crown solid's buried bottom edge at
    // z 18.500, a knife edge 2 mm inside the merged part's material, which no
    // correct model can carry a vertex on. The second added range is the
    // tessellation seam at z 17.250, where the Ø27 wall's outline drops from
    // 430 points to 308 with the diameter and area unchanged.
    ClonePart { stem: "710-002", scad: "710-002_SplitGearBottom.scad",
                reference: "710-002_SplitGearBottom.stl", tol: 0.10,
                deviations: &[],
                extra: &["--ignore-plane=1.45,1.70", "--ignore-plane=2.70,2.95",
                         "--ignore-band=8.15,8.35", "--ignore-band=23.95,24.45",
                         "--ignore-band=25.6,26.8", "--ignore-band=27.15,34.8",
                         "--ignore-plane=6.0,11.8", "--ignore-plane=-2.74,-2.62"] },
];

/// Body B joins this table when it is rebuilt as a faithful recreation.
const DIST_GATES: [DistGate; 1] = [DistGate {
    stem: "730-001",
    scad: "730-001_DiffBodyA.scad",
    reference: "730-001_DiffBodyA.stl",
    tol: 0.15,
}];

/// Tooth and slot counts, checked on the cross-section of each *render* —
/// slice positions are in the render's own frame, which need not match the
/// reference's (compare centres both meshes, so only these care).
struct CountCheck {
    label: &'static str,
    args: &'static [&'static str],
    key: &'static str,
    expect: u64,
}

const COUNTS: [CountCheck; 7] = [
    // `--center=-21,21`, not `--center -21,21`. Body B's axes both sit at -21,
    // and a negative value in the spaced form is read as a flag: clap sees
    // `-2` and exits 2 before the check runs. That aborted the whole script
    // here, because the usage text it printed is not JSON.
    CountCheck { label: "730-002 115 encoder slots",
                 args: &["out/730-002.stl", "--axis", "x", "--band", "24.5,28.8",
                         "--slice-at", "46.35", "--center=-21,21"],
                 key: "loops_in_band", expect: 115 },
    CountCheck { label: "710-004 100 encoder slots",
                 args: &["out/710-004.stl", "--band", "21.5,25.5",
                         "--slice-at", "0.6", "--center", "0,0"],
                 key: "loops_in_band", expect: 100 },
    // 23.5, not 6.0. These stations are in the RENDER's own frame, and this
    // part is authored in its reference's coordinates — it spans z 17.500 to
    // 27.750, so 6.0 sections empty air 11.5 mm below it and can only ever
    // report 0 peaks. It reported 0 for two years and was read as a missing
    // tooth ring; the reference mesh reports 0 there too, which is the check
    // that settles which side is wrong. 23.5 is the part-local 6.0 the station
    // was written for, plus the part's own base: it finds 40 on both meshes,
    // and the reference gives 40 at every station from 20.0 to 27.0.
    CountCheck { label: "720-003 40T GT2",
                 args: &["out/720-003.stl", "--band", "11.5,12.7",
                         "--slice-at", "23.5", "--center", "0,0"],
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

const DIAMS: [DiamCheck; 6] = [
    DiamCheck { label: "730-001 6703 seat Ø23",
                args: &["out/730-001.stl", "--at=2.0"], diameter: 23.0 },
    DiamCheck { label: "730-001 6705 seat Ø32",
                args: &["out/730-001.stl", "--at=20.0"], diameter: 32.0 },
    // Body B's shaft bore is on X, the J4 axis — not on Y. The former y =
    // −48.5 station sampled the mating rim and could never have found a seat.
    DiamCheck { label: "730-002 6703 seat Ø23",
                args: &["out/730-002.stl", "--axis", "x", "--at=12.0"], diameter: 23.0 },
    DiamCheck { label: "730-002 shaft land Ø17.5",
                args: &["out/730-002.stl", "--axis", "x", "--at=17.0"], diameter: 17.5 },
    DiamCheck { label: "730-002 split-gear stub Ø17",
                args: &["out/730-002.stl", "--at=40"], diameter: 17.0 },
    DiamCheck { label: "730-002 thrust tube Ø8",
                args: &["out/730-002.stl", "--at=60"], diameter: 8.0 },
];

const DIAM_TOL: f64 = 0.05;

/// The revised configuration renders to `out/revised/` every part this group's
/// `parts.json` lists for it, and these two besides: the External pulleys are
/// 400-EndArm's parts, but they are the elbow half of the same DC-12 train, so
/// they are verified here too.
const EXTERNAL_PARTS: [(&str, &str); 2] = [
    ("430-001", "../400-EndArm/430-001_ExternalOuterPulley.scad"),
    ("430-002", "../400-EndArm/430-002_ExternalInnerPulley.scad"),
];

// The print fits of the revised renders (../print_fit.scad), each probed from
// its mate's nominal surface in the part's own frame. A bought mate (a
// bearing, or a strake, rod or tube bonded in) is a press fit; a printed mate
// or a fastener's clearance is a slip fit.
const SPLIT_TOP_FITS: [FitProbe; 4] = [
    FitProbe { label: "MR128 seat", at: [4.2426, 4.2426, 1.0], toward: [-0.7071, -0.7071, 0.0], fit: Fit::Press },
    FitProbe { label: "6703 pocket", at: [8.1317, 8.1317, 6.0], toward: [-0.7071, -0.7071, 0.0], fit: Fit::Press },
    FitProbe { label: "strake slot's side", at: [2.794, 14.25, 3.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Press },
    FitProbe { label: "strake slot's outer face", at: [0.0, 15.4185, 3.0], toward: [0.0, -1.0, 0.0], fit: Fit::Press },
];
const SPLIT_BOTTOM_FITS: [FitProbe; 3] = [
    FitProbe { label: "Ø17 stub in the 6703", at: [6.0104, 6.0104, 6.0], toward: [0.7071, 0.7071, 0.0], fit: Fit::Press },
    FitProbe { label: "MR128 seat", at: [4.2426, 4.2426, 15.0], toward: [-0.7071, -0.7071, 0.0], fit: Fit::Press },
    FitProbe { label: "crown's 6703 bore", at: [8.1317, 8.1317, 21.5], toward: [-0.7071, -0.7071, 0.0], fit: Fit::Press },
];
const KEEPER_FITS: [FitProbe; 1] = [
    FitProbe { label: "bore on the Ø8 tube", at: [4.0, 0.0, 1.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Slip },
];
// 720-001 is exported turned onto +Y: its own (x, y, z) lies at (x, z, -y).
const SHAFT_FITS: [FitProbe; 3] = [
    FitProbe { label: "front 6703 journal", at: [8.5, 0.0, 0.0], toward: [1.0, 0.0, 0.0], fit: Fit::Press },
    FitProbe { label: "front MR128 seat", at: [6.0, -8.5, 0.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Press },
    FitProbe { label: "6705's Ø25", at: [0.0, 31.0, -12.5], toward: [0.0, 0.0, -1.0], fit: Fit::Press },
];
const AXLE_FITS: [FitProbe; 2] = [
    FitProbe { label: "MR85 seat", at: [4.0, 0.0, 0.75], toward: [-1.0, 0.0, 0.0], fit: Fit::Press },
    FitProbe { label: "CF rod bore", at: [4.0, 0.0, 7.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Press },
];
const END_PULLEY_FITS: [FitProbe; 1] = [
    FitProbe { label: "CF rod bore, between the glue lobes", at: [4.0, 0.0, 22.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Press },
];
const BODY_A_FITS: [FitProbe; 3] = [
    FitProbe { label: "6703 seat", at: [0.0, 11.5, 2.5], toward: [0.0, -1.0, 0.0], fit: Fit::Press },
    FitProbe { label: "6705 seat", at: [0.0, 16.0, 19.5], toward: [0.0, -1.0, 0.0], fit: Fit::Press },
    FitProbe { label: "arm spigot in the L3 tube", at: [-45.0, 10.035, 11.0], toward: [0.0, 1.0, 0.0], fit: Fit::Press },
];
// Body B's J4 tunnel runs along X at (y, z) = (-21, 21); its column along Z
// at (x, y) = (21, -21).
const BODY_B_FITS: [FitProbe; 3] = [
    FitProbe { label: "-X 6703 seat", at: [11.0, -21.0, 32.5], toward: [0.0, 0.0, -1.0], fit: Fit::Press },
    FitProbe { label: "column's 6703 journal", at: [29.5, -21.0, 38.0], toward: [1.0, 0.0, 0.0], fit: Fit::Press },
    FitProbe { label: "Ø8 tube in the MR128s", at: [25.0, -21.0, 55.0], toward: [1.0, 0.0, 0.0], fit: Fit::Press },
];
// The outer External pulley's hub: the Ø8 rod, and the M3 nut (5.5 across
// flats) in the slot on 180 deg, whose 5.5 runs along Y.
const OUTER_PULLEY_FITS: [FitProbe; 2] = [
    FitProbe { label: "Ø8 rod bore", at: [4.0, 0.0, 28.0], toward: [-1.0, 0.0, 0.0], fit: Fit::Press },
    FitProbe { label: "set-screw nut slot", at: [-6.4, 2.75, 24.0], toward: [0.0, -1.0, 0.0], fit: Fit::Slip },
];
const REVISED_FITS: [(&str, &[FitProbe]); 9] = [
    ("430-001", &OUTER_PULLEY_FITS),
    ("710-001", &SPLIT_TOP_FITS),
    ("710-002", &SPLIT_BOTTOM_FITS),
    ("710-003", &KEEPER_FITS),
    ("720-001", &SHAFT_FITS),
    ("720-002", &AXLE_FITS),
    ("720-003", &END_PULLEY_FITS),
    ("730-001", &BODY_A_FITS),
    ("730-002", &BODY_B_FITS),
];

/// The DC-12 tooth counts, on the revised renders: 16T -> 108T at the elbow
/// and 40T -> 80T at the wrist. The shaft's band stays 40T as the spline
/// #720-004 is keyed on. 430-001 is sectioned clear of its access holes.
const REVISED_COUNTS: [CountCheck; 6] = [
    CountCheck { label: "430-001 108T GT2 (revised)",
                 args: &["out/revised/430-001.stl", "--band", "33.0,34.3",
                         "--slice-at", "28.5", "--center", "0,0"],
                 key: "radius_peaks", expect: 108 },
    CountCheck { label: "430-002 108T GT2 (revised)",
                 args: &["out/revised/430-002.stl", "--band", "33.0,34.3",
                         "--slice-at", "24.0", "--center", "0,0"],
                 key: "radius_peaks", expect: 108 },
    CountCheck { label: "720-003 80T GT2 (revised)",
                 args: &["out/revised/720-003.stl", "--band", "24.3,25.3",
                         "--slice-at", "23.5", "--center", "0,0"],
                 key: "radius_peaks", expect: 80 },
    CountCheck { label: "720-004 80T GT2 (revised)",
                 args: &["out/revised/720-004.stl", "--band", "24.3,25.3",
                         "--slice-at", "4.0", "--center", "0,0"],
                 key: "radius_peaks", expect: 80 },
    CountCheck { label: "720-004 40T spline bore (revised)",
                 args: &["out/revised/720-004.stl", "--band", "11.5,12.8",
                         "--slice-at", "4.0", "--center", "0,0"],
                 key: "radius_peaks", expect: 40 },
    CountCheck { label: "720-001 40T band (revised)",
                 args: &["out/revised/720-001.stl", "--axis", "y", "--band", "11.5,12.7",
                         "--slice-at", "36.0", "--center", "0,0"],
                 key: "radius_peaks", expect: 40 },
];

/// A part that states its own extent for the assemblies to read: the file
/// echoes `<name> = [[min], [max]]`, and the render's bounding box must agree.
/// This is what keeps `robot_assembly.scad`'s envelope assert on Body A, and
/// `diff_assembly.scad`'s End Pulley clearance, measuring the parts themselves.
const EXTENTS: [(&str, &str, &str); 2] = [
    ("730-001", "730-001_DiffBodyA.scad", "body_a_box"),
    ("720-003", "720-003_DiffEndPulley.scad", "end_pulley_box_ref"),
];

const EXTENT_TOL: f64 = 0.02;

/// Pairs of parts that must not overlap as they sit, rendered as their
/// intersection from source. The ring sits inside Body A's chamber, where no
/// extent check can reach. Body B against each crown that turns in it is the
/// running clearance 730-002's TOE CLEARANCE keeps; the Split Gear Top is
/// listed beside the Bottom, which carries the toe, because both halves sweep
/// the same zone. Two bearing sets are listed against a part they seat in;
/// both render empty with their shoulders on the races. The other bearing
/// pairs return the face where a shoulder meets a race, at zero thickness,
/// which this check cannot tell from an overlap, so they are not listed.
const INTERFERENCE: [(&str, &str); 7] = [
    ("730-001", "720-004"),
    ("730-002", "720-002"),
    ("730-002", "720-001"),
    ("730-002", "710-002"),
    ("730-002", "710-001"),
    ("brg_body_a", "730-001"),
    ("brg_body_b", "710-002"),
];

fn check_clones(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    for part in &CLONES {
        let out_stl = format!("out/{}.stl", part.stem);
        render(part.scad, &out_stl, "previous", ctx, tally)?;
        let reference = ref_path(part.reference);
        let tol = part.tol.to_string();
        let mut args = vec!["compare", out_stl.as_str(), reference.as_str(),
                            "--tol", tol.as_str()];
        args.extend_from_slice(part.extra);
        // `compare`'s own exit status and `worst_delta` cannot know which
        // departures are stated, so a part with deviations is judged from the
        // per-check array instead. Every check is still read; none is dropped.
        let (_, report) = sm_json(&args, ctx)?;
        let checks = report["checks"].as_array()
            .with_context(|| format!("compare emitted no checks for {}", part.stem))?;
        let mut worst = 0.0_f64;
        let mut ok = true;
        for check in checks {
            let name = check["name"].as_str().unwrap_or_default();
            let delta = check["delta"].as_f64().unwrap_or(f64::NAN);
            match part.deviations.iter().find(|d| d.check == name) {
                Some(dev) => {
                    let off = (delta - dev.delta).abs();
                    let held = off <= dev.dev_tol;
                    tally.record(
                        &format!("{} {name} holds its stated {:.3} mm departure \
                                  (got {delta:.3}, off {off:.3} mm, tol {} mm)",
                                 part.stem, dev.delta, dev.dev_tol),
                        held,
                    );
                    ok &= held;
                }
                None => {
                    worst = worst.max(delta);
                    ok &= delta <= part.tol;
                }
            }
        }
        tally.record(
            &format!("{} vs reference (worst {worst:.3} mm, tol {tol} mm)", part.stem),
            ok,
        );
    }
    Ok(())
}

/// Render each gated housing and measure its surface against the reference.
/// The render is left at `out/<stem>.stl` for the interface checks to reuse.
fn check_dist_gates(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    for gate in &DIST_GATES {
        dist_gate(gate, REF_DIR, ctx, tally)?;
    }
    Ok(())
}

fn check_counts(ctx: &Ctx, tally: &mut Tally, counts: &[CountCheck]) -> Result<()> {
    for c in counts {
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

/// Mating diameters on the housings. 730-001 is already rendered by its
/// distance gate; these remain as a direct statement of the interfaces the
/// rest of the assembly depends on, in terms a reader can check by eye.
fn check_bodies(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    render("730-002_DiffBodyB.scad", "out/730-002.stl", "previous", ctx, tally)?;
    for c in &DIAMS {
        let mut args = vec!["slice"];
        args.extend_from_slice(c.args);
        let (_, json) = sm_json(&args, ctx)?;
        tally.record(c.label, has_diameter(&json, c.diameter));
    }
    Ok(())
}

/// The assembly is exported to CSG rather than STL: that evaluates every
/// parameter and assertion in `diff_assembly.scad` (the L4 split, the axis
/// intersection) in seconds, where meshing the union
/// of nine parts — three of them involute bevel gears — takes minutes and
/// checks nothing extra. Render it to STL by hand when you want to look at
/// it: `openscad -o out/assembly.stl -D config='"revised"' diff_assembly.scad`.
fn check_assembly(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    for config in ["previous", "revised"] {
        let out_csg = format!("out/assembly-{config}.csg");
        let ok = render("diff_assembly.scad", &out_csg, config, ctx, tally).is_ok();
        tally.record(&format!("assembly parameters and assertions ({config})"), ok);
        // The arm composition, which holds Body A to the forearm skin.
        let out_csg = format!("out/robot-{config}.csg");
        let ok = render("../robot_assembly.scad", &out_csg, config, ctx, tally).is_ok();
        tally.record(&format!("robot assembly parameters and assertions ({config})"), ok);
    }
    Ok(())
}

/// Every part in the revised configuration, then the DC-12 counts on them.
fn check_revised(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    std::fs::create_dir_all(ctx.dir.join("out/revised"))?;
    let parts = group_parts(ctx, "revised")?;
    let own = parts.iter().map(|(id, scad)| (id.as_str(), scad.as_str()));
    for (id, scad) in own.chain(EXTERNAL_PARTS) {
        render(scad, &format!("out/revised/{id}.stl"), "revised", ctx, tally)?;
    }
    for (id, probes) in REVISED_FITS {
        check_fits(&format!("out/revised/{id}.stl"), &format!("{id} (revised)"), probes, ctx, tally)?;
    }
    check_counts(ctx, tally, &REVISED_COUNTS)
}

/// Read `<name> = [[..], [..]]` off OpenSCAD's echo output.
fn echoed_box(stderr: &str, name: &str) -> Option<Value> {
    let tag = format!("ECHO: {name} = ");
    let line = stderr.lines().find_map(|l| l.trim().strip_prefix(tag.as_str()))?;
    serde_json::from_str(line).ok()
}

fn box_agrees(stated: &Value, bbox: &Value) -> bool {
    (0..3).all(|i| {
        let near = |a: &Value, b: &Value| match (a.as_f64(), b.as_f64()) {
            (Some(a), Some(b)) => (a - b).abs() <= EXTENT_TOL,
            _ => false,
        };
        near(&stated[0][i], &bbox["min"][i]) && near(&stated[1][i], &bbox["max"][i])
    })
}

/// Each part's stated extent against its render, in both configurations. The
/// echo comes from a CSG export, which evaluates the file in seconds.
fn check_extents(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    for config in ["previous", "revised"] {
        let dir = if config == "previous" { "out" } else { "out/revised" };
        let define = format!("config=\"{config}\"");
        for (id, scad, name) in &EXTENTS {
            let out_csg = format!("{dir}/{id}-extent.csg");
            let r = run(&ctx.openscad, &["-o", &out_csg, "-D", &define, scad], &ctx.dir)?;
            let stated = echoed_box(&r.stderr, name);
            let (_, bbox) = sm_json(&["bbox", &format!("{dir}/{id}.stl")], ctx)?;
            tally.record(
                &format!("{id} stated extent {name} matches its render ({config}): {}",
                         stated.as_ref().map_or("not echoed".into(), |s| s.to_string())),
                stated.is_some_and(|s| box_agrees(&s, &bbox)),
            );
        }
    }
    Ok(())
}

/// Renders `args` and reports whether the result is clean: only if OpenSCAD
/// reports the top level object empty and says nothing else.
fn renders_empty(args: &[&str], ctx: &Ctx) -> Result<bool> {
    let r = run(&ctx.openscad, args, &ctx.dir)?;
    let complaints = diagnostics(&r.stderr);
    let empty = complaints.len() == 1 && complaints[0].contains("top level object is empty");
    if !empty {
        for line in &complaints {
            println!("      {line}");
        }
    }
    Ok(empty)
}

/// Each pair's overlap, rendered from source.
fn check_interference(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    for (a, b) in &INTERFERENCE {
        let pair = format!("interference=[\"{a}\",\"{b}\"]");
        let out = format!("out/revised/interference-{a}-{b}.stl");
        let empty = renders_empty(&["-o", &out, "-D", "config=\"revised\"",
                                    "-D", "geometry=\"scad\"", "-D", &pair,
                                    "diff_assembly.scad"], ctx)?;
        tally.record(&format!("{a} and {b} do not overlap (revised)"), empty);
    }
    Ok(())
}

/// Body B against the volume the three crowns' teeth sweep, grown by just
/// under the running clearance. Where the interference pairs show only that
/// Body B and the gears do not touch, this shows the clearance itself. See
/// 730-002's TOE CLEARANCE.
fn check_keepout(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    let empty = renders_empty(&["-o", "out/revised/keepout-730-002.stl",
                                "-D", "config=\"revised\"", "-D", "keepout_check=true",
                                "730-002_DiffBodyB.scad"], ctx)?;
    tally.record("730-002 keeps the running clearance off the three crowns' teeth (revised)",
                 empty);
    Ok(())
}

/// Order matters: everything `check_counts` measures has to have been rendered
/// by an earlier step. Body B is rendered by `check_bodies`, so that has to
/// come first — run the other way round, the slot count was read off whatever
/// `out/730-002.stl` a previous run had left behind, which is a stale mesh on
/// every run that follows an edit and no mesh at all on a clean checkout.
fn verify(ctx: &Ctx, tally: &mut Tally) -> Result<()> {
    check_clones(ctx, tally)?;
    check_dist_gates(ctx, tally)?;
    check_bodies(ctx, tally)?;
    check_counts(ctx, tally, &COUNTS)?;
    check_assembly(ctx, tally)?;
    check_revised(ctx, tally)?;
    check_extents(ctx, tally)?;
    check_interference(ctx, tally)?;
    check_keepout(ctx, tally)
}

fn main() -> Result<()> {
    let ctx = Ctx::for_script()?;
    let mut tally = Tally::default();
    verify(&ctx, &mut tally)?;
    tally.finish()
}
