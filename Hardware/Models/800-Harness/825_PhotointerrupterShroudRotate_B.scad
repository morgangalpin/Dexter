// #825 Photointerrupter Shroud (Rotate), top half (B) — parametric source.
// Holds the upper T-1 package of each of J5's two beams, over the code disk
// (#710-004, 100 slots). It sits on #825 A's tab with the 2 mm gap the disk
// runs in between them (z -8.5 to -6.5), pinned to A's wall by #19 nails.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — the print fit below drawn on the beam bores.
//
// FRAME. The reference's own, #825 A's: the disk turns about the z axis
// through the origin; B's underside is z -6.5 and its top z -1.0.
//
// Measured from the reference (scadmesh planes/slice/arcs/solid). The feature
// IDs are those of 825_PhotointerrupterShroudRotate_B.view.json:
//
//     ID  feature        value                                        z span
//     P1  block          the wedge outline of ../photo_shroud_rotate.scad
//                        (x -7.7 .. 7.511, y -30.191 .. -19.264, the
//                        back corners chamfered 1.5)                 -6.5 .. -1
//     B1  beam bore, at (-3.296, -23.013)
//     B2  beam bore, at (3.059, -23.048), each along z:
//                        slit 0.70 wide, laid radial, in an Ø3.0 circle
//                        (the aperture across the disk)              -6.5 .. -6.1
//                        Ø3.0 round, for the T-1 body                -6.1 .. -2.0
//                        Ø4.0 round counterbore, for its flange      -2.0 .. -1.0
//     N1  nail holes     Ø1.0 at (-2.095, -28.62), (1.905, -28.62)   through
//
// CONSTRUCTION. Profile per layer along z, of which there is one: P1's whole
// section, extruded; B1 and B2 are cut once through it with beam_bore
// (../photo_shroud.scad), N1 with stepped_hole. `layer` draws the 2D section
// of the part at z -4 (plan).
//
// FITS (../print_fit.scad), revised only, per side:
//
//     B1, B2 Ø3.0 run, the T-1 body (a bought Ø3.0)     press (Ø3.1)
//
// The Ø4.0 counterbore already clears the T-1's flange by more than the press
// fit, and the slit is an aperture, not a seat; both keep their size. N1's
// Ø1.0 is the intended drive fit of a #19 nail (Ø1.07) and keeps its size.
// probes-825-B-wide holds the counterbore, the slit and the nail hole open.

include <../print_fit.scad>
include <photo_shroud_rotate.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// 2D layer to draw alone, for outline checks; "part" draws the part
layer = "part"; // [part, plan]

/* [Hidden] */
$fn = 96;
BLOCK_Z = [-6.500, -1.000];          // P1
PLAN_AT = -4.000;                    // layer "plan": the part cut at this z
BODY_D  = T1_BODY_D;                 // B1, B2: the T-1 body (photo_shroud.scad)
SLIT    = 0.700;                     // aperture width
FLANGE_D = 4.000;                    // counterbore

function press(cfg) = fit_clearances(cfg)[1];

// B1 and B2's run of sections, from below the block to above it.
function bore_runs(cfg) = [
    [-7.5, -6.1, "slit", BODY_D, SLIT],
    [-6.1, -2.0, "round", fit_bore(BODY_D, press(cfg))],
    [-2.0,  0.0, "round", FLANGE_D]];

module shroud_rotate_b() difference() {
    translate([0, 0, BLOCK_Z[0]])
        linear_extrude(BLOCK_Z[1] - BLOCK_Z[0]) tab_plan_2d();
    beam_bores(bore_runs(config));
    nail_holes(-7.5, 0.0);
}

if (layer == "plan") projection(cut = true) translate([0, 0, -PLAN_AT]) shroud_rotate_b();
else shroud_rotate_b();
