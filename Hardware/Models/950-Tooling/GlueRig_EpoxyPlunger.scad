// GlueRig_EpoxyPlunger — the glue rigs' epoxy cartridge plunger — parametric source.
// Two rods, one per barrel of a 2:1 epoxy cartridge, joined by a head that is pushed to dispense; with
// the Epoxy Holder it serves all three spans (specs/007.2 § Tooling — glue rigs).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/950-Tooling/), in that mesh's frame.
//   config = "revised"  — the same part; see FITS.
//
// FRAME. The reference's own: the flat face on z = 0, the rods from y 0 to the head, the head from
// y 105 to 119.
//
// CONSTRUCTION. A region split, each region a 2D section extruded once:
//
//     rods   each rod's section in (x, z): its circle cut flat on z = 0, the two edges rounded R2 by
//            an opening; extruded along +Y from y 0 into the head
//     head   its plan in (x, y), extruded down from z 0 to the rods' depth
//
// `layer = "rods"` or `"head"` draws that section in 2D, for verification against the mesh's section
// (across y at 50, and across z at -9; render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/slice/arcs/solid:
//
//     ID  feature        value
//     R1  small rod      R7.848 about (x 4.999, z -1.647), cut on z = 0, edges R2
//     R2  large rod      R10.847 about (x 25.027, z -0.947), cut on z = 0, edges R2
//     H1  head           x -2.938 .. 39.062, y 105 .. 119, z -18.220 .. 0: two R10 lobes about
//                        (2.062, 109) and (31.710, 109) on a block to y 114.25, the whole width
//                        outboard of the lobes' centres, all clipped to the rectangle, whose far
//                        corners are R5
//     N1  thumb notch    R7.5 about (16.887, 118.307), between the lobes
//
// The faces at y 4.294, 10.588 and the like in scadmesh planes are tessellation bands of the rods.
//
// FITS: none drawn. The rods meet only the bought cartridge's pistons, whose dimensions the design
// record does not hold, so `revised` is `previous`.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one section in 2D
layer = "part"; // [part, rods, head]

/* [Hidden] */
$fn = 180;
HEAD_LAP = 1.000;   // the rods run this far into the head

RODS     = [[7.848, 4.999, -1.647], [10.847, 25.027, -0.947]];   // R1, R2: radius, x, z
ROD_EDGE = 2.000;
ROD_Y    = 105.000;                    // where the head starts
HEAD     = [[-2.938, 105.000], [39.062, 119.000]];   // H1: corners
HEAD_Z   = -18.220;
LOBE_R   = 10.000;
LOBES    = [[2.062, 109.000], [31.710, 109.000]];
BLOCK_Y  = 114.250;                    // the block between the lobes, up to the notch
CORNER_R = 5.000;
NOTCH    = [7.500, 16.887, 118.307];   // N1: radius, x, y

module rods_2d()
    for (r = RODS) offset(r = ROD_EDGE) offset(delta = -ROD_EDGE)
        intersection() {
            translate([r[1], r[2]]) circle(r = r[0]);
            translate([r[1] - 20, -20]) square([40, 20]);
        }

module head_2d()
    difference() {
        intersection() {
            hull() {
                translate(HEAD[0]) square([HEAD[1].x - HEAD[0].x, 0.01]);
                for (x = [HEAD[0].x + CORNER_R, HEAD[1].x - CORNER_R])
                    translate([x, HEAD[1].y - CORNER_R]) circle(r = CORNER_R);
            }
            union() {
                for (c = LOBES) translate(c) circle(r = LOBE_R);
                // outboard of each lobe's centre the head is the whole rectangle
                translate(HEAD[0] - [1, HEAD_LAP]) square([LOBES[0].x - HEAD[0].x + 1, 20]);
                translate([LOBES[1].x, HEAD[0].y - HEAD_LAP]) square([HEAD[1].x - LOBES[1].x + 1, 20]);
                translate(HEAD[0] - [1, HEAD_LAP]) square([HEAD[1].x - HEAD[0].x + 2, BLOCK_Y - HEAD[0].y + HEAD_LAP]);
            }
        }
        translate([NOTCH[1], NOTCH[2]]) circle(r = NOTCH[0]);
    }

module epoxy_plunger() {
    translate([0, ROD_Y + HEAD_LAP, 0]) rotate([90, 0, 0]) linear_extrude(ROD_Y + HEAD_LAP) rods_2d();
    translate([0, 0, HEAD_Z]) linear_extrude(-HEAD_Z) head_2d();
}

if (layer == "rods") rods_2d();
else if (layer == "head") head_2d();
else epoxy_plunger();
