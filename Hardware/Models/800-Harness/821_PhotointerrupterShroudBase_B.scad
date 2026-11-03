// #821 Photointerrupter Shroud (Base), plate (B) — parametric source.
// The plate the shroud's body, #821 A (821_PhotointerrupterShroudBase_A.scad),
// stands on: two screws through its counterbored holes fix it, the body is
// pinned to it by #19 nails through N1, and the optical board (C-703) stands
// on its top face behind the body.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — identical to "previous"; see FITS.
//
// FRAME. The reference's own, which is #821 A's: the plate from z 0 to its top
// face at z 7, where the body stands.
//
// Measured from the reference (scadmesh planes/slice/arcs/solid); feature IDs
// as in 821_PhotointerrupterShroudBase_B.view.json:
//
//     ID  feature        value                                      z span
//     P1  plate          the shared x span, y -8 .. 10.943          0 .. 7
//     R1  rabbet         the -y edge stands at y -6 below z 3.5     0 .. 3.5
//     H1  screw holes    at (15.533, 1.898) and (-8.462, 1.898):
//                        Ø3.5                                       0 .. 3.25
//                        45 deg cone to Ø6.0                        3.25 .. 4.5
//                        Ø6.0 (the -x one tangent to the -x face)   4.5 .. 7
//     N1  nail holes     through A and B                            through
//
// The x span and N1 are shroud_base.scad's, which #821 A shares.
//
// CONSTRUCTION. Profile per layer along z: the plate's outline below the
// rabbet and above it, each extruded; H1 (one revolved cutter each) and N1
// cut along z.
//
// FITS (../print_fit.scad): none is drawn. H1's Ø3.5 and Ø6.0 already clear
// an M3 screw (Ø3.0, head Ø5.5) by more than the slip fit, and N1's Ø1.5 a
// #19 nail (Ø1.07). So "revised" draws the reference, and
// probes-821-b-wide holds the holes open.

include <../print_fit.scad>
include <photo_shroud.scad>
include <shroud_base.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 96;
LAP      = 0.005;
PLATE_Y  = [-8.000, 10.943];
TOP      = 7.000;
RABBET   = [-6.000, 3.500];          // R1: the -y edge below, and its top
H1_AT    = [[15.533, 1.898], [-8.462, 1.898]];
H1       = [[-1.0, 3.25, 3.5, 3.5], [3.25, 4.5, 3.5, 6.0], [4.5, 8.0, 6.0, 6.0]];  // [z0, z1, d0, d1]

module slab(y0, z0, z1)
    translate([SHROUD_X[0], y0, z0]) cube([SHROUD_X[1] - SHROUD_X[0], PLATE_Y[1] - y0, z1 - z0]);

module plate() union() {
    slab(RABBET[0], 0, RABBET[1] + LAP);
    slab(PLATE_Y[0], RABBET[1], TOP);
}

// H1, one cutter: its runs of cylinders and cone, each lapped into the next.
module screw_hole(at) translate([at[0], at[1], 0])
    for (s = H1) translate([0, 0, s[0] - LAP]) cylinder(h = s[1] - s[0] + 2 * LAP, d1 = s[2], d2 = s[3]);

module shroud_base_b() difference() {
    plate();
    for (at = H1_AT) screw_hole(at);
    for (x = NAILS) stepped_hole([x, NAIL_Y], [[-1.0, TOP + 1.0, NAIL_D]], $fn = 48);
}

shroud_base_b();
