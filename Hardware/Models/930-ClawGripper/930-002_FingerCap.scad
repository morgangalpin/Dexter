// #930-002 Finger Cap — parametric source.
// A plain washer-like disc: Ø11 × 4 with a Ø2 hole on its axis, for an M2 bolt into the Claw Finger's
// shaft end. Published as the legacy `920-003_FingerCap.stl`.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/930-ClawGripper/930-002_FingerCap.stl), in that mesh's
//                         frame. There is no STEP or f3d of this part.
//   config = "revised"  — the same disc with H1 opened to the M2 bolt's slip clearance.
//
// FRAME. The reference's own: the axis on +Z through the origin, the underside at z = 0.
//
// Measured from the reference with scadmesh planes/radial/slice. The feature IDs are those of
// 930-002_FingerCap.view.json:
//
//     ID  feature  value    z span
//     D1  disc     Ø11.000  0 .. 4
//     H1  hole     Ø2.000   through
//
// FITS (revised). H1 takes an M2 bolt: fit_bore(2, FIT_SLIP) = Ø2.300.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or its 2D section for the outline gate
layer = "part"; // [part, D1]

/* [Hidden] */
$fn = 144;

DISC   = [11.000, 4.000];   // diameter, height
BOLT_D = 2.000;             // M2, the reference's H1

module section_2d(cfg = config)
    let(c = fit_clearances(cfg))
    difference() {
        circle(d = DISC[0]);
        circle(d = fit_bore(BOLT_D, c[0]));
    }

module finger_cap(cfg = config) linear_extrude(DISC[1]) section_2d(cfg);

if (layer == "D1") section_2d();
else finger_cap();
