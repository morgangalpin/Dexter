// #810-001 6-Pin Strain Relief (Top) — parametric source.
// The upper half of the clamp that grips the C-708 6-pin cable's wires. Its
// plate seats on the Bottom's rails (#810-002) and its comb hangs down to meet
// the Bottom's comb face to face.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — identical to "previous"; see FITS.
//
// FRAME. The reference's own: x along the comb, the plate's top at z = 4.4, the
// comb's outer face at y = -13.46, the mating face at y = -11.46.
//
// Measured from the reference (scadmesh), feature IDs as in
// 810-001_6PinStrainReliefTop.view.json:
//
//     ID  feature   value
//     P1  plate     x +-8.55, y -13.46 .. -2.46, z 4.0 .. 4.4
//     K1  comb      y -13.46 .. -11.46; full material z 3.37 .. 4.0, teeth
//                   hang to tips at z 1.1; six grooves rise to a ceiling at
//                   z 3.37 (the section is strain_relief_comb.scad's)
//
// The measured groove pattern centre is -0.131; the shared design value is
// -0.120 (strain_relief_comb.scad).
//
// CONSTRUCTION. Rung 1, region split: the plate cuboid joined to the comb's
// section extruded 2.0 along y, lapped by 0.005.
//
// FITS: none. The plate seats on the Bottom's rails at z 4.0 and the two combs
// meet face to face at y -11.46 (seats, exempt); the grooves grip the wires.
// "revised" therefore equals "previous".

include <strain_relief_comb.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 48;
PLATE_Y = [-13.46, -2.46];
PLATE_Z = [4.0, 4.4];
TIP_Z   = 1.1;
CEIL_Z  = 3.37;
BAND_UP = 0.2;     // the comb's band runs this far up into the plate

module plate()
    translate([-COMB_HALF, PLATE_Y[0], PLATE_Z[0]])
        cube([2 * COMB_HALF, PLATE_Y[1] - PLATE_Y[0], PLATE_Z[1] - PLATE_Z[0]]);

module comb()
    translate([0, PLATE_Y[0] + COMB_T, 0]) rotate([90, 0, 0])
        linear_extrude(COMB_T) comb_section_2d(TIP_Z, CEIL_Z, PLATE_Z[0] + BAND_UP);

module strain_relief_top() union() { plate(); comb(); }

strain_relief_top();
