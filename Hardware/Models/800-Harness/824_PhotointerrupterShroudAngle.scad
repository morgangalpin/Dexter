// #824 Photointerrupter Shroud (Angle) — parametric source.
// Straddles the rim of J4's code disk and holds J4's emitter and detector
// facing each other across it. The 115 slots of J4 are cut into #730-002
// (Diff Body B)'s rim (specs/004 § Differential interface), so there is no
// disk part: the rim runs in the channel under this shroud's body. Two
// pegs stand below the shroud and locate it; their holes take #19 nails.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — the T-1 package seats opened by FIT_PRESS; see FITS.
//
// FRAME. The reference's own. The rim's axis is parallel to z, through
// (x 12.05, y 0); r below is the radius about it. The shroud is a band that
// wraps part-way round the rim on the -x side, symmetric about y = 0.
//
// Measured from the reference (scadmesh planes/slice/arcs/solid); feature IDs
// as in 824_PhotointerrupterShroudAngle.view.json:
//
//     ID  feature              value                                z span
//     L1  foot layer           inner r 29.95; outer a tangent-line
//                              polygon: R1 end rounds at (-16.18, +-12.59),
//                              tangent lines to (-22.955, +-12.229), 45 deg
//                              chamfers to (-23.96, +-11.0), flat x -23.96   0 .. 0.75
//     L2  outer cone           L1 cut by a 45 deg cone, r 32.64 to 31.65     0.75 .. 1.75
//     L3  rim wall             inner r 29.95, outer r 31.65, R1 ends         1.75 .. 2.5
//     L4  body, rim side       inner r 24.44, outer r 31.65; the tangent
//                              line goes on to (-14.388, +-13.983), flat
//                              y +-13.983, R2 inner corners at
//                              (-11.483, +-11.983)                           2.5 .. 4.25
//     L5  outer chamfer        as L4, outer r 31.65 to 29.9 at 45 deg        4.25 .. 6.0
//     L6  body, top            as L4, outer r 29.9                           6.0 .. 7.5
//     P1  pegs                 at (-20.581, +-4.0): 45 deg chamfer Ø3.0
//                              to Ø4.0, then Ø4.0                            -2.5 .. 0
//     N1  nail holes           Ø1.0 through each peg and the foot            -2.5 .. 1.1
//     B1  beam bores           at (-12.986, +-8.711) on r 26.5, along z; the
//                              frame's x points in at the rim's axis (the
//                              flat's normal is radial, at +-19.2 deg to x):
//                              radial slit 0.5 wide, 2.7 long             2.5 .. 3.053
//                              cone Ø2.7 to Ø2.82                         3.053 .. 3.248
//                              cone Ø2.82 to Ø2.94                        3.248 .. 3.371
//                              cone Ø2.94 to Ø3.0                         3.371 .. 3.5
//                              Ø3.0                                       3.5 .. 6.0
//                              Ø4.0 cut flat at 1.5 in                    6.0 .. 7.5
//
// CONSTRUCTION. Profile per layer along z, the rim's axis: each layer's whole
// x-y section (outline arcs about the axis) extruded over its z span; L2 and
// L5 are their section cut by a cone about the axis. The beam bores are cut
// once through every layer (../photo_shroud.scad, beam_bore), N1 along z.
//
// FITS (../print_fit.scad):
//   - B1 Ø3.0 holds a T-1 package body (../photo_shroud.scad, T1_BODY_D) line
//     to line, and its flat at 1.5 keys the flange's flat line to line. Both
//     are opened by FIT_PRESS in "revised": Ø3.1 and the flat at 1.55. The
//     Ø4.0 round of the counterbore is clearance round the flange
//     (photo_shroud.scad) and keeps its size. The aperture (slit, cone start
//     Ø2.7) is optics, not a fit.
//   - N1 Ø1.0 takes a #19 nail (Ø1.07): an intended drive fit, kept.
//   - P1 locates in holes of a mating part that is not modelled to this
//     size: kept at the reference (Ø4.0).

include <../print_fit.scad>
include <photo_shroud.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// 2D layer to draw alone, for outline checks; "part" draws the part
layer = "part"; // [part, l1, l2, l3, l4, l5, l6]

/* [Hidden] */
$fn = 96;
LAP     = 0.005;
AXIS    = [12.050, 0];                // the rim's axis, parallel to z
R_IN1   = 29.950;                     // L1, L3
R_IN2   = 24.440;                     // L4 .. L6
R_OUT   = 31.650;                     // L3, L4, L5 base
R_CONE  = 32.640;                     // L2 base
R_TOP   = 29.900;                     // L6
END_R1  = [-16.180, 12.590];          // L1 .. L3 end round centre (R1)
CORNER  = [-22.955, 12.229];          // L1 tangent line meets the chamfer
FLAT_X  = -23.960;                    // L1 flat; chamfer ends at y +-11.0
LINE_END = [-14.388, 13.983];         // L4 .. L6 tangent line meets the flat
R2_AT   = [-11.483, 11.983];          // L4 .. L6 inner corner round (R2)
Z       = [0, 0.75, 1.75, 2.5, 4.25, 6.0, 7.5];   // layer breaks
PEG_AT  = [-20.581, 4.0];
PEG_Z   = [-2.5, -2.0, 0];
NAIL_D  = 1.0;
BORE_AT = [-12.986, 8.711];
BEAM_SEATS = fit_clearances(config)[1];
BEAM    = [[2.4, 3.053, "slit", 2.7, 0.5],
           [3.053, 3.248, "cone", 2.7, 2.82],
           [3.248, 3.371, "cone", 2.82, 2.94],
           [3.371, 3.5, "cone", 2.94, fit_bore(T1_BODY_D, BEAM_SEATS)],
           [3.5, 6.0, "round", fit_bore(T1_BODY_D, BEAM_SEATS)],
           [6.0, 7.6, "flat", 4.0, 1.5 + BEAM_SEATS]];

module rim_circle(r) translate(AXIS) circle(r = r, $fn = 720);

// The tangent-line outline shared by L1 .. L3, before the rim is cut away.
module foot_2d() hull() {
    for (s = [-1, 1]) translate([END_R1[0], s * END_R1[1]]) circle(r = 1);
    polygon([[CORNER[0], CORNER.y], [CORNER[0], -CORNER.y],
             [FLAT_X, -11.0], [FLAT_X, 11.0]]);
}

module foot_section_2d(r_out) difference() {
    intersection() { foot_2d(); rim_circle(r_out); }
    rim_circle(R_IN1);
}

// L4 .. L6's section with outer radius r_out.
module body_section_2d(r_out) difference() {
    intersection() {
        hull() {
            for (s = [-1, 1]) translate([R2_AT[0], s * R2_AT.y]) circle(r = 2);
            polygon([[CORNER[0], CORNER.y], [CORNER[0], -CORNER.y],
                     [LINE_END[0], -LINE_END.y], [LINE_END[0], LINE_END.y]]);
        }
        rim_circle(r_out);
    }
    rim_circle(R_IN2);
}

// A layer's section, extruded over [z0, z1] and lapped into the layer above.
module slab(z0, z1, lap = LAP) translate([0, 0, z0]) linear_extrude(z1 - z0 + lap) children();

// A 45 degree cone about the rim's axis, r0 at z0 and r1 at z1.
module rim_cone(z0, z1, r0, r1) translate([AXIS[0], AXIS[1], z0]) cylinder(h = z1 - z0, r1 = r0, r2 = r1, $fn = 720);

module layers() {
    slab(Z[0], Z[1]) foot_section_2d(100);
    intersection() {
        slab(Z[1], Z[2]) foot_section_2d(100);
        rim_cone(Z[1] - 1, Z[2] + 1, R_CONE + 1, R_OUT - 1);
    }
    slab(Z[2], Z[3]) foot_section_2d(R_OUT);
    slab(Z[3], Z[4]) body_section_2d(R_OUT);
    intersection() {
        slab(Z[4], Z[5]) body_section_2d(100);
        rim_cone(Z[4] - 1, Z[5] + 1, R_OUT + 1, R_TOP - 1);
    }
    slab(Z[5], Z[6], 0) body_section_2d(R_TOP);
}

module pegs() for (s = [-1, 1]) translate([PEG_AT[0], s * PEG_AT.y, 0]) {
    translate([0, 0, PEG_Z[0]]) cylinder(h = PEG_Z[1] - PEG_Z[0] + LAP, d1 = 3.0, d2 = 4.0);
    translate([0, 0, PEG_Z[1]]) cylinder(h = PEG_Z[2] - PEG_Z[1] + LAP, d = 4.0);
}

// B1: each bore on its beam axis, turned so the frame's x points in at the
// rim's axis (the flat's normal), and its slit, long in x, lies radial.
module beams() for (s = [-1, 1]) {
    in = atan2(-s * BORE_AT.y, AXIS[0] - BORE_AT[0]);
    translate([BORE_AT[0], s * BORE_AT.y, 0]) rotate(in) beam_bore(BEAM, 90, $fn = 96);
}

module nails() for (s = [-1, 1])
    stepped_hole([PEG_AT[0], s * PEG_AT.y], [[PEG_Z[0] - 0.1, 1.1, NAIL_D]], $fn = 48);

module shroud_angle() difference() {
    union() { layers(); pegs(); }
    beams();
    nails();
}

if (layer == "l1") foot_section_2d(100);
else if (layer == "l2") foot_section_2d(R_CONE);
else if (layer == "l3") foot_section_2d(R_OUT);
else if (layer == "l4") body_section_2d(R_OUT);
else if (layer == "l5") body_section_2d(R_OUT);
else if (layer == "l6") body_section_2d(R_TOP);
else shroud_angle();
