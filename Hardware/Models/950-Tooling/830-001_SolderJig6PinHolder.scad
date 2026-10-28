// #830-001 Solder Jig — 6-pin holder — parametric source.
// Holds a 6-pin header (2.54 mm pitch) for soldering: each pin lies in a lead groove across the front
// block, and the side walls and the back bar frame the board (specs/007.2 § Tooling — solder jigs).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/950-Tooling/), in that mesh's frame.
//   config = "revised"  — the same part; see FITS.
//
// FRAME. The reference's own: z -1 .. 4, the back face on y 2.54 and the front face on y -13.46.
//
// CONSTRUCTION. A section in (x, z), extruded along +Y, in three layers:
//
//     front block   y -13.46 .. -9.46   F1 - 6 x G1
//     walls         y -9.46 .. -2.54    the two side walls W1
//     back          y -2.54 .. 2.54     W1 + the back bar B1
//
// `layer = "front"`, `"walls"` or `"back"` draws that section in 2D, for verification against the
// mesh's section across y (render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/slice/arcs/solid (sections across x, y and z):
//
//     ID  feature        value
//     F1  front block    |x| <= 9.15, z -1 .. 4
//     G1  lead grooves   6 on x = -6.48 + 2.54 k, down from z 4 to their round end at z 2.27
//                        (lead_groove.scad)
//     W1  side walls     |x| 7.75 .. 9.15, z -1 .. 4
//     B1  back bar       |x| <= 9.15, z -1 .. 1
//
// FITS: none drawn. The grooves hold a bought header's pins, a locating rest rather than a fit, so
// `revised` is `previous`.

include <../print_fit.scad>
include <lead_groove.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one section in 2D
layer = "part"; // [part, front, walls, back]

/* [Hidden] */
$fn = 48;
SEAM_LAP = 0.005;   // each layer runs this far into the next, so no two faces coincide

HALF_W  = 9.150;                   // F1, W1, B1
WALL_IN = 7.750;                   // W1's inner faces
Z       = [-1.000, 4.000];         // F1, W1
BAR_TOP = 1.000;                   // B1
Y       = [-13.460, -9.460, -2.540, 2.540];   // the layers' bounds
GROOVES = [6, -6.480, 2.540];      // G1: count, first centre, pitch
GROOVE_END = 2.270;

module walls_2d() for (s = [-1, 1]) scale([s, 1]) translate([WALL_IN, Z[0]]) square([HALF_W - WALL_IN, Z[1] - Z[0]]);

module front_2d()
    difference() {
        translate([-HALF_W, Z[0]]) square([2 * HALF_W, Z[1] - Z[0]]);
        for (k = [0 : GROOVES[0] - 1])
            translate([GROOVES[1] + k * GROOVES[2], Z[1]]) scale([1, -1]) lead_groove_2d(Z[1] - GROOVE_END);
    }

module back_2d() { walls_2d(); translate([-HALF_W, Z[0]]) square([2 * HALF_W, BAR_TOP - Z[0]]); }

// A section laid in the XZ plane and extruded along +Y from y0 to y1.
module run(y0, y1) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();

module solder_jig_6pin() {
    run(Y[0], Y[1] + SEAM_LAP) front_2d();
    run(Y[1], Y[2] + SEAM_LAP) walls_2d();
    run(Y[2], Y[3]) back_2d();
}

if (layer == "front") front_2d();
else if (layer == "walls") walls_2d();
else if (layer == "back") back_2d();
else solder_jig_6pin();
