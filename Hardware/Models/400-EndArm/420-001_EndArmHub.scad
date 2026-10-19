// #420-001 End Arm Hub — parametric source.
// The printed structure at the elbow: it carries the 6703 that the strake tube
// turns in (008.6 step 2), the four M3 all-thread rods threaded into it (008.7
// step 14), the New Belt Pulley's pegs in its back holes (step 8), the two belt
// channels of the internal stage, the End Arm Hub Cap in its open end (step
// 19), and the L3 tube (C-505) on its spigot and in the counterbore round it
// (007.1 § C-505).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/400-EndArm/), in that mesh's
//                         frame.
//   config = "revised"  — the same part with its print fits drawn (FITS).
//
// FRAME. The J3 axis is +Z through the origin, the plate holding the 6703 on
// top (z 4) and the cap's open end at the bottom (z -38). The spigot points
// along +X on z -25, the L3 tube's axis. The reference mesh is already in this
// frame (robot_assembly.scad § End Arm group places the group by it).
//
// CONSTRUCTION. Every feature but the spigot and the counterbore lies square
// to Z, so the body is a stack of 2D layers, each drawn whole and extruded
// once (the mesh-to-scad ladder's rung 1):
//
//     bottom plate  z -38 .. -30   outline - the cap's opening
//     wall          z -30 .. -2    outline - the cavity - the rod holes
//     top plate     z -2 .. 4      outline - the rod holes - the peg holes
//
// The cavity is the bore and the two belt channels, less the front block
// between them; the block's two back corners are rounded by an opening
// (rung 5). The 6703 seat, its chamfer and the lip under it are one revolved
// cutter (rung 4). The tube's counterbore is one 2D section in YZ, cut along
// X (rung 1 on the other axis). The spigot is its 20 x 20 R4 section extruded
// along X and joined to the body; its I-shaped bore is cut after the join, down
// to the counterbore's floor. `layer = "top"`,
// `"wall"` or `"bottom"` draws that layer's profile in 2D, and `"spigot"` the
// spigot's section in YZ, for verification against the mesh's sections
// (scadmesh outline; render.rs --verify does this).
//
// The reference is an export of two closed bodies (Models/README.md § Known
// defects). The first is the hub, solid to its face at x 28.5 behind the
// spigot. The second is the spigot: its tube from x 28.5 to the tip, and an
// I-shaped stub of its bore's section from x 26.5 to 28.5, wholly inside the
// hub. As a solid, the bore is therefore blind at x 28.5, and it is cut so
// here. The hub's face behind the spigot's wall and the stub's faces lie
// inside that solid, where no solid can have a surface, so `dist` from this
// reference to any render charges them up to 3.5. The dist gate is therefore
// held against a derived reference beside it,
// 420-001_EndArmHub.bodies-unioned.stl: each body extracted with
// `scadmesh segment --keep 0` and `--keep 1`, the two imported separately and
// unioned on Manifold (Models/README.md § Known defects records the recipe).
// The four section outlines still read the original.
//
// Measured from the reference with scadmesh planes/slice/arcs/solid along each
// axis. The feature IDs are those of 420-001_EndArmHub.view.json, which labels
// each one on the mesh:
//
//     ID  feature                     value
//     O1  outline                     R25.0 about the axis, tangent lines to the
//                                     front face x 32.5, y +-17.661; z -38 .. 4
//     S1  6703 seat                   Ø23.000, z -0.15 .. 4; a 45 deg chamfer to
//                                     Ø20.0 at z -1.65; lip Ø20.0 to z -2.0
//     P1  peg holes, 4 on the         Ø5.000 at r 14.500, z 0 .. 4
//         diagonals
//     H1  rod holes, 4 on the axes    Ø3.000 at r 15.250, z -30 .. 4; each
//                                     tangent to C1
//     C1  bore                        Ø27.500, z -30 .. -2
//     C2  belt channels, 2            |y| 11.0 .. 13.5, from C1 out through
//                                     the front face, z -30 .. -2
//     C3  front block                 |y| <= 11.0, from C1 to the front face;
//                                     its back corners R2.0, made against a
//                                     circle of r 13.5 before C1 was cut (the
//                                     tangent round against C1 left 0.30)
//     B1  cap opening                 Ø45.000, cut by a flat at x 19.500,
//                                     z -38 .. -30
//     T1  tube counterbore            22.0 x 22.0 square about the tube axis,
//                                     z -36 .. -14, from x 28.5 out through the
//                                     front face; from each channel's foot a
//                                     slope down to its bottom corner
//     T2  spigot                      20.0 x 20.0, R4.0 corners, about the tube
//                                     axis (z -25), from the counterbore's
//                                     floor at x 28.5 to the tip at 44.5
//     T3  spigot's bore               an I: slots 12.7 wide and 1.302 tall at
//                                     its top and bottom, joined by a waist
//                                     6.0 wide over z -22 .. -28 with 45 deg
//                                     tapers; from the tip to x 28.5
//
// FITS (../print_fit.scad), revised only:
//
//     S1, on the 6703's Ø23 OD                   press; its floor is a face contact
//     T2, in the C-505 tube's 20.07 bore         press
//     T1, round the C-505 tube's 22.0 OD         press
//     B1, round the End Arm Hub Cap's outline    slip (two printed parts)
//
// P1 takes the New Belt Pulley's pegs: their slip fit is drawn on the pegs
// (410-002), so the holes keep their size. H1 is tapped by the all-thread
// (008.7 step 14): it keeps the reference's size.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, one layer's 2D profile, or the spigot's section
layer = "part"; // [part, top, wall, bottom, spigot]

/* [Hidden] */
$fn = 180;
epsilon = 0.01;

OUTLINE    = [25.000, 32.500, 17.661];   // O1: back radius, front face x, front face's half-width
Z          = [-38.000, -30.000, -2.000, 4.000];   // bottom, cavity's floor, plate's underside, top
SEAT       = [23.000, -0.150, 20.000, -1.650];    // S1: Ø, its floor z, lip Ø, the chamfer's foot z
PEG_HOLE   = [14.500, 5.000, 0.000];     // P1: centre radius, Ø, floor z
ROD_HOLE   = [15.250, 3.000];            // H1: centre radius, Ø
BORE_R     = 13.750;                     // C1
CHANNEL    = [11.000, 13.500];           // C2: inner and outer |y|
BLOCK_R    = 2.000;                      // C3's back corners
BLOCK_BACK = 13.500;                     // C3: the circle its rounds were made against
CAP        = [45.000, 19.500];           // B1: Ø, flat x
TUBE       = [-25.000, 28.500, 22.000, -36.000, -14.000];
                                         // T1: axis z, counterbore floor x, width, bottom z, top z
SPIGOT     = [26.500, 44.500, 20.000, 4.000];     // T2: start x (inside the hub, where the
                                                  //     reference's second body starts), tip x,
                                                  //     width, corner R
SPIGOT_BORE = [12.700, 6.350, 1.302, 6.000, 3.000];
                                         // T3: slot width, slot's inner |z|, slot height,
                                         //     waist width, waist half-height
ROD_FN     = 48;                         // H1's facets
C505       = [20.070, 22.000];           // the tube's ID and OD
BEARING_OD = 23.000;                     // 6703
LAP        = 0.005;                      // layers lap this far into each other

FITS = fit_clearances(config);
function seat_d()      = max(SEAT[0], fit_bore(BEARING_OD, FITS[1]));
function spigot_w()    = min(SPIGOT[2], fit_pin(C505[0], FITS[1]));
function counterbore() = max(TUBE[2], fit_bore(C505[1], FITS[1]));
function cap_grow()    = (fit_bore(CAP[0], FITS[0]) - CAP[0]) / 2;

module outline_2d() {
    hull() {
        circle(r = OUTLINE[0]);
        translate([OUTLINE[1] - epsilon, -OUTLINE[2]]) square([epsilon, 2 * OUTLINE[2]]);
    }
}

module on_axes()      for (a = [0 : 90 : 270]) rotate(a) children();
module on_diagonals() for (a = [45 : 90 : 315]) rotate(a) children();

// H1. Each hole is tangent to C1, as the reference's are; drawn so, the two
// polygons would share a vertex and the wall would pinch to a line there,
// which is how the reference mesh came to be repaired. Each hole's polygon is
// turned half a facet, so that a flat, not a vertex, faces the bore, and a
// film of 0.003 stays between them.
module rod_holes_2d()
    on_axes() translate([ROD_HOLE[0], 0]) rotate(180 / ROD_FN) circle(d = ROD_HOLE[1], $fn = ROD_FN);

// C3: the block between the channels, from inside the bore to past the front
// face. Its back corners were rounded against a circle of BLOCK_BACK, inside
// the bore, and the bore cut afterwards, so each round meets the bore at a
// corner rather than running into it.
module block_2d() {
    difference() {
        offset(r = BLOCK_R) offset(r = -BLOCK_R) difference() {
            translate([0, -CHANNEL[0]]) square([OUTLINE[1] + 5, 2 * CHANNEL[0]]);
            circle(r = BLOCK_BACK);
        }
        circle(r = BORE_R);
    }
}

// C1 and C2, less C3.
module cavity_2d() {
    difference() {
        union() {
            circle(r = BORE_R);
            translate([0, -CHANNEL[1]]) square([OUTLINE[1] + 5, 2 * CHANNEL[1]]);
        }
        block_2d();
    }
}

// The top plate's section. `full` adds the seat and the peg holes, which do
// not run through the whole plate and are cut in 3D; the gate's section at
// z 2 has them.
module top_2d(full = false) {
    difference() {
        outline_2d();
        rod_holes_2d();
        if (full) {
            on_diagonals() translate([PEG_HOLE[0], 0]) circle(d = PEG_HOLE[1], $fn = 60);
            circle(d = seat_d());
        }
    }
}

module wall_2d() difference() { outline_2d(); cavity_2d(); rod_holes_2d(); }

// B1, grown all round by the slip clearance in revised.
module cap_opening_2d() {
    g = cap_grow();
    intersection() {
        circle(d = CAP[0] + 2 * g);
        translate([-50, -50]) square([50 + CAP[1] + g, 100]);
    }
}

module bottom_2d() difference() { outline_2d(); cap_opening_2d(); }

// S1 as one revolved cutter, from the cavity up through the top face.
module seat_cutter() {
    rs = seat_d() / 2;
    rl = SEAT[2] / 2;
    rotate_extrude() polygon([[0, Z[2] - 1], [rl, Z[2] - 1], [rl, SEAT[3]],
                              [rs, SEAT[3] + rs - rl], [rs, Z[3] + 1], [0, Z[3] + 1]]);
}

// The spigot's section in YZ, about the tube axis, as [y, z - axis].
module spigot_2d() {
    w = spigot_w();
    offset(r = SPIGOT[3]) offset(delta = -SPIGOT[3]) square(w, center = true);
}

// T3, symmetric about both axes: the quarter from the slot's outer edge in to
// the waist, mirrored.
module spigot_bore_2d() {
    s = SPIGOT_BORE;
    q = [[s[0] / 2, s[1] + s[2]], [s[0] / 2, s[1]], [s[3] / 2, s[4]]];
    polygon(concat(q, [for (i = [2 : -1 : 0]) [q[i].x, -q[i].y]],
                   [for (p = q) [-p.x, -p.y]], [for (i = [2 : -1 : 0]) [-q[i].x, q[i].y]]));
}

// T1's section in YZ, as [y, z]: the square about the tube axis, grown by
// its fit, and the slope from each channel's foot down to the square's bottom
// corner. Above the channels' foot the cavity is already open, so the
// section runs up the channels' outer walls to the square's top.
module counterbore_2d() {
    c = counterbore() / 2;
    g = (counterbore() - TUBE[2]) / 2;
    polygon([[-c, TUBE[3] - g], [c, TUBE[3] - g], [CHANNEL[1], Z[1]], [CHANNEL[1], TUBE[4] + g],
             [-CHANNEL[1], TUBE[4] + g], [-CHANNEL[1], Z[1]]]);
}

// Extrude a YZ section along +X from x0 to x1.
module along_x(x0, x1) translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children();

module end_arm_hub() {
    difference() {
        union() {
            difference() {
                union() {
                    translate([0, 0, Z[0]]) linear_extrude(Z[1] - Z[0] + LAP) bottom_2d();
                    translate([0, 0, Z[1]]) linear_extrude(Z[2] - Z[1] + LAP) wall_2d();
                    translate([0, 0, Z[2]]) linear_extrude(Z[3] - Z[2]) top_2d();
                }
                seat_cutter();
                on_diagonals() translate([PEG_HOLE[0], 0, PEG_HOLE[2]])
                    cylinder(d = PEG_HOLE[1], h = Z[3] - PEG_HOLE[2] + 1, $fn = 60);
                along_x(TUBE[1], OUTLINE[1] + 1) counterbore_2d();
            }
            along_x(SPIGOT[0], SPIGOT[1]) translate([0, TUBE[0]]) spigot_2d();
        }
        along_x(TUBE[1], SPIGOT[1] + 1) translate([0, TUBE[0]]) spigot_bore_2d();
    }
}

if (layer == "top") top_2d(true);
else if (layer == "wall") wall_2d();
else if (layer == "bottom") bottom_2d();
else if (layer == "spigot") translate([0, TUBE[0]]) difference() { spigot_2d(); spigot_bore_2d(); }
else end_arm_hub();
