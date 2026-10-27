// #800-006 PCB Bracket — parametric source.
// Two per robot. Each is epoxied to the C-504 1 inch (25.4) square carbon fibre
// tube; the Motor Control Board bolts to its end blocks with M3 x 20 bolts
// through the PCB spacers (008.10 steps 4 to 6).
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — the print fit below drawn on the M3 pilots.
//
// FRAME. The reference's own: the opening's centre on the origin, the arms
// reaching out along +x, z 0 .. 8.
//
// Measured from the reference (scadmesh arcs at z = 1, the owner of the
// outline; slice along x for the holes). The feature IDs are those of
// 800-006_PCBBracket.view.json, which labels each one on the mesh:
//
//     ID  feature                    value                          z span
//     O1  outline, one plan profile  ring x -18 .. 18, y -18 .. 18, R2
//                                    corners; arms out to x 18 .. 19  0 .. 8
//     W1  opening for the tube       x -14 .. 14, y -14 .. 14, R2 corners
//                                    (open on +x between the arms)    0 .. 8
//     E1  end block, -y              x 11 .. 19, y -28.5 .. -20.5, R1 outer
//                                    corners, R5 blend into the ring
//     E2  end block, +y              x 14 .. 19, y 20.5 .. 28.5, R1 outer
//                                    corners, R4 blend into the ring
//     H1  bolt holes, along x        Ø3.0 at y = +-24.75, z = 4.0,
//                                    through each block
//
// The inner flanks of the arms are R1 at the blocks, an R3.2 and R1 blend
// on the -y side, and an R4 corner on the +y side; the arcs below are the
// arcs scadmesh read, in order round the outline.
//
// CONSTRUCTION. The plan profile, drawn whole as one polygon of lines and arcs,
// extruded 8.0; the H1 cutters, which lie off the layer plane, cut across the
// blocks. `layer = "plate"` draws the profile in 2D, for verification against
// the mesh's section (scadmesh outline).
//
// FITS (../print_fit.scad), revised only, per side:
//
//     H1 holes, the M3 bolts' pilots      tap (Ø2.6)
//
// The 28 x 28 opening clears the 25.4 tube by 1.3 per side because the tube
// is bonded, wider than the press fit, so it keeps its size.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or its plan profile
layer = "part"; // [part, plate]

/* [Hidden] */
$fn = 48;

HEIGHT   = 8.0;
HOLE_D   = fit_pin(3.0, fit_clearances(config)[3]);  // H1, the M3 bolt's pilot
HOLE_Y   = 24.75;
HOLE_Z   = 4.0;
HOLE_X   = [9, 20];              // the cutter's span, past both faces of the blocks

// Points of the arc about c, radius r, from angle a0 to a1 (degrees), ends included.
function arc(c, r, a0, a1) =
    let (n = max(3, ceil(abs(a1 - a0) / 4)))
    [for (i = [0 : n]) let (a = a0 + (a1 - a0) * i / n) c + r * [cos(a), sin(a)]];

// [centre, radius, from, to] for each arc, in order clockwise round the outline.
ARCS = [
    [[12, -27.5], 1, -90, -180],             // E1 outer corner
    [[6, -23], 5, 0, 90],                    // E1 blend into the ring
    [[-16, -16], 2, -90, -180],              // ring corner
    [[-16, 16], 2, 180, 90],                 // ring corner
    [[9.988, 22.016], 4.016, -90, 4.6],      // E2 blend into the ring
    [[15, 27.5], 1, 180, 90],                // E2 outer corner
    [[18, 27.5], 1, 90, 0],                  // E2 outer corner
    [[19, 19.5], 1, 90, 180],                // E2 inner corner
    [[4.055, 18.763], 13.964, 3.025, -5.76], // arm's end face
    [[14, 18], 4, -9.2, -90],                // opening's +y corner
    [[-12, 12], 2, 90, 180],                 // opening corner
    [[-12, -12], 2, 180, 270],               // opening corner
    [[10, -19], 5, 90, 0],                   // opening's -y blend
    [[18.196, -19.238], 3.204, 175.74, 189.4],
    [[16, -19.5], 1, 195.3, 270],
    [[18, -21.5], 1, 90, 0],                 // E1 inner corner
    [[18, -27.5], 1, 0, -90]                 // E1 outer corner
];

function profile_points() = [for (a = ARCS) each arc(a[0], a[1], a[2], a[3])];

module profile_2d() polygon(profile_points());

// One bolt hole, across a block along x.
module bolt_hole(y)
    translate([HOLE_X[0], y, HOLE_Z]) rotate([0, 90, 0])
        cylinder(d = HOLE_D, h = HOLE_X[1] - HOLE_X[0]);

module pcb_bracket()
    difference() {
        linear_extrude(HEIGHT) profile_2d();
        for (s = [-1, 1]) bolt_hole(s * HOLE_Y);
    }

if (layer == "plate") profile_2d();
else pcb_bracket();
