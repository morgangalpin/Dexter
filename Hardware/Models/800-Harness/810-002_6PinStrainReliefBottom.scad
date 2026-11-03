// #810-002 6-Pin Strain Relief (Bottom) — parametric source.
// The lower half of the clamp that grips the C-708 6-pin cable's wires. Its
// comb stands up to meet the Top's comb (#810-001) face to face, and its two
// rails carry the Top's plate.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — identical to "previous"; see FITS.
//
// FRAME. The reference's own: x along the comb, the plate's underside at
// z = 1.1, the comb's mating face at y = -11.46.
//
// Measured from the reference (scadmesh), feature IDs as in
// 810-002_6PinStrainReliefBottom.view.json:
//
//     ID  feature   value
//     P1  plate     x +-8.55, y -11.46 .. -4.46, z 1.1 .. 1.5; the
//                   rails' feet carry on to y -2.46, leaving a notch
//                   x +-7.75, y -4.46 .. -2.46 at the back
//     K1  comb      y -11.46 .. -9.46; teeth stand to tips at z 4.0; six
//                   grooves fall to a floor at z 2.27 (the section is
//                   strain_relief_comb.scad's)
//     R1  rails     x 7.75 .. 8.55 and -8.55 .. -7.75, y -9.46 .. -2.46,
//                   z 1.1 .. 4.0
//
// The measured groove pattern centre is -0.109; the shared design value is
// -0.120 (strain_relief_comb.scad).
//
// CONSTRUCTION. Rung 1, region split: the plate cuboid joined to the comb's
// section extruded 2.0 along y and to the two rails, lapped by 0.005.
//
// FITS: none. The Top's plate seats on the rails at z 4.0 and the two combs
// meet face to face at y -11.46 (seats, exempt); the grooves grip the wires.
// "revised" therefore equals "previous".

include <strain_relief_comb.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 48;
LAP      = 0.005;
PLATE_Y  = [-11.46, -4.46];
PLATE_Z  = [1.1, 1.5];
TIP_Z    = 4.0;
FLOOR_Z  = 2.27;
RAIL_X   = [7.75, 8.55];
RAIL_Y   = [-9.46, -2.46];
RAIL_TOP = 4.0;
BAND_DN  = 0.2;     // the comb's band runs this far up from the plate's underside

module plate()
    translate([-COMB_HALF, PLATE_Y[0], PLATE_Z[0]])
        cube([2 * COMB_HALF, PLATE_Y[1] - PLATE_Y[0], PLATE_Z[1] - PLATE_Z[0]]);

module comb()
    translate([0, PLATE_Y[0] + COMB_T, 0]) rotate([90, 0, 0])
        linear_extrude(COMB_T) comb_section_2d(TIP_Z, FLOOR_Z, PLATE_Z[0] + BAND_DN);

module rail(side)
    translate([side > 0 ? RAIL_X[0] : -RAIL_X[1], RAIL_Y[0] - LAP, PLATE_Z[0]])
        cube([RAIL_X[1] - RAIL_X[0], RAIL_Y[1] - RAIL_Y[0] + LAP, RAIL_TOP - PLATE_Z[0]]);

module strain_relief_bottom() union() { plate(); comb(); rail(1); rail(-1); }

strain_relief_bottom();
