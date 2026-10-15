// #210-002 Belt Director Pulley — parametric source.
// A 26-tooth GT2 idler between two flanges, which turns on an MR85 on the Idler Plug in the Arm Body's
// D column and routes a wrist belt (specs/007 § Arm Body, specs/008.5 step 9).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/200-ArmBody/), in that mesh's frame.
//   config = "revised"  — the same part. Its fits wait for the arm body's assembly (below).
//
// FRAME. The reference's own: the axis on +Z through the origin, the part from z -8.136 to -0.744,
// a tooth's tip centred on +X.
//
// Measured from the reference with scadmesh profile/slice/arcs/teeth. The feature IDs are those of
// 210-002_BeltDirectorPulley.view.json:
//
//     ID  feature                 value                                  z span
//     F2  lower flange            Ø17.313                                -8.136 .. -7.623
//     T1  teeth                   26T, gt2_teeth_rounded_2d: tip Ø16.053, -7.623 .. -1.257
//                                 groove bottom Ø14.478, grooves R0.61
//                                 on 6.923 deg + k * 360/26
//     F1  upper flange            Ø17.313                                -1.257 .. -0.744
//     B1  bore                    Ø8.000                                 through
//
// The flanges' inner faces read Ø17.305, 0.004 inside their outer faces: tessellation, not a draft.
// The z rows at -6.524, -5.425, -4.326, -3.227 and -2.128 are the teeth's facet rows, not faces.
//
// `layer = "teeth"` or `"flange"` draws that layer's 2D profile, for the outline gate in render.json.
//
// FITS, deferred: B1 on the MR85's Ø8 outer race, and T1 against the belt and the pulleys it routes
// between, are settled with the arm body's assembly (armbody_assembly), so revised draws none yet.

include <../gt2_pulley.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D profile
layer = "part"; // [part, teeth, flange]

/* [Hidden] */
$fn = 180;
epsilon = 0.01;

TEETH    = 26;
TIP_D    = 16.053;
FLANGE_D = 17.313;
BORE_D   = 8.000;
Z        = [-8.136, -7.623, -1.257, -0.744];   // F2 bottom, F2 top, F1 bottom, F1 top

// --- 2D profiles -------------------------------------------------------------
module teeth_2d()
    difference() {
        rotate(180 / TEETH) gt2_teeth_rounded_2d(TEETH, TIP_D);
        circle(d = BORE_D);
    }

module flange_2d() difference() { circle(d = FLANGE_D); circle(d = BORE_D); }

// --- Part ----------------------------------------------------------------------
module belt_director_pulley(cfg = config) {
    translate([0, 0, Z[0]]) linear_extrude(Z[1] - Z[0] + epsilon) flange_2d();
    translate([0, 0, Z[1]]) linear_extrude(Z[2] - Z[1]) teeth_2d();
    translate([0, 0, Z[2] - epsilon]) linear_extrude(Z[3] - Z[2] + epsilon) flange_2d();
}

if (layer == "teeth") teeth_2d();
else if (layer == "flange") flange_2d();
else belt_director_pulley();
