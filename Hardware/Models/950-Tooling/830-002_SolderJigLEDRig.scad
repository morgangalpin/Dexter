// #830-002 Solder Jig — LED rig — parametric source.
// Holds four LEDs for soldering, each lying in a pocket with its leads in two grooves across the lip
// and a window over its leads' ends (specs/007.2 § Tooling — solder jigs).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/950-Tooling/), in that mesh's frame.
//   config = "revised"  — the same part; see FITS.
//
// FRAME. The reference's own: the pockets open on z = 0 and the top face on z 6; the LEDs' axes run
// along y on x = 11.2 k, k = 0 .. 3.
//
// CONSTRUCTION. Three layers along y, each a section in (x, z) extruded once, the cells' features
// patterned at 11.2 within it:
//
//     lip     y -14.25 .. -10.25   z 1.5 .. 6, less two lead grooves G1 per cell
//     step    y -10.25 .. -5.25    z 3 .. 6, less each cell's window W1
//     body    y -5.25 .. 4.25      z 0 .. 6, less each cell's LED pocket P1 and flange slot F1
//
// P1 is the LED's own shape, a cylinder on a dome, swept down out through z = 0: the hull of a sphere
// and a cylinder at the dome and the same at the window. `layer = "lip"` or `"step"` draws that
// section in 2D, for verification against the mesh's section across y (render.rs --verify does this);
// the body's is checked by the dist gate.
//
// Measured from the reference with scadmesh planes/slice/arcs/solid (sections across x, y and z):
//
//     ID  feature        value
//     W1  windows        x ± 3.6 about each cell, y -10.25 .. -5.25, through
//     P1  LED pockets    Ø3.2: the axis on z 3.4, the dome's centre on y 0.15; open below the axis
//     F1  flange slots   x -2.1 .. the pocket, y -5.25 .. -2.75, up to z 5
//     G1  lead grooves   two per cell on x ± 1.225, up from the lip's underside to their round end
//                        at z 3.0 (lead_groove.scad)
//
// FITS: none drawn. The pockets and grooves are rests for a bought LED and its leads, not fits, so
// `revised` is `previous`.

include <../print_fit.scad>
include <lead_groove.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one section in 2D
layer = "part"; // [part, lip, step]

/* [Hidden] */
$fn = 96;
SEAM_LAP = 0.005;   // each layer runs this far into the next, so no two faces coincide

X       = [-5.600, 39.200];          // the block's ends
Y       = [-14.250, -10.250, -5.250, 4.250];   // the layers' bounds
TOP     = 6.000;
LIP_Z   = 1.500;
STEP_Z  = 3.000;
CELLS   = [4, 11.200];               // count, pitch, from x = 0
WINDOW  = 3.600;                     // W1's half-width
LED     = [1.600, 3.400, 0.150];     // P1: radius, axis z, dome centre y
FLANGE  = [-2.100, -0.300, -2.750, 5.000];   // F1: x from, x to (inside P1), y to, z top
LEADS   = 1.225;                     // G1's offset from the cell's axis

module cells() for (k = [0 : CELLS[0] - 1]) translate([k * CELLS[1], 0]) children();

module lip_2d()
    difference() {
        translate([X[0], LIP_Z]) square([X[1] - X[0], TOP - LIP_Z]);
        cells() for (s = [-1, 1]) translate([s * LEADS, LIP_Z]) lead_groove_2d(STEP_Z - LIP_Z);
    }

module step_2d()
    difference() {
        translate([X[0], STEP_Z]) square([X[1] - X[0], TOP - STEP_Z]);
        cells() translate([-WINDOW, STEP_Z - 1]) square([2 * WINDOW, TOP - STEP_Z + 2]);
    }

// One cell's LED pocket and flange slot, on x = 0, reaching past the body's -Y face into the window.
module pocket() {
    hull() for (y = [LED[2], Y[2] - 1]) translate([0, y, 0]) {
        translate([0, 0, LED[1]]) sphere(r = LED[0]);
        translate([0, 0, -1]) cylinder(r = LED[0], h = LED[1] + 1);
    }
    translate([FLANGE[0], Y[2] - 1, -1]) cube([FLANGE[1] - FLANGE[0], FLANGE[2] - Y[2] + 1, FLANGE[3] + 1]);
}

// A section laid in the XZ plane and extruded along +Y from y0 to y1.
module run(y0, y1) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();

module solder_jig_led() {
    run(Y[0], Y[1] + SEAM_LAP) lip_2d();
    run(Y[1], Y[2] + SEAM_LAP) step_2d();
    difference() {
        translate([X[0], Y[2], 0]) cube([X[1] - X[0], Y[3] - Y[2], TOP]);
        cells() pocket();
    }
}

if (layer == "lip") lip_2d();
else if (layer == "step") step_2d();
else solder_jig_led();
