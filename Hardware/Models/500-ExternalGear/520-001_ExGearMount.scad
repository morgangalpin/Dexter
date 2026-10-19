// #520-001 Ex Gear Mount — parametric source.
// The frame of the External Gear group. Its floor carries the Ex Gear Motor
// End Cap on four bosses, under the J3 drive; its column takes the arm's 1" CF
// square tube (#520-006) through a channel and holds the two Nut Holders the
// all-threads tie the Mount Top down with; and either side of it a box carries
// the angle and the rotate motors (008.8 steps 9–15).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/500-ExternalGear/), in that
//                         mesh's frame.
//   config = "revised"  — the same part with its print fits on the fasteners,
//                         the Nut Holders and the motors' pilots.
//
// FRAME. The reference's, which exgear_assembly.scad calls the group's: the
// floor's underside on z = 0, the drive axis on +Z through the origin. The
// column and the motor boxes stand on -x, the boxes either side of y = 0.
//
// CONSTRUCTION. A region split. Every plan outline below is drawn in 2D and
// extruded (profile per layer); the regions are unioned, then the cuts made.
//
//   FLOOR    z 0 .. 4, two layers: F1 disc and tongue, clipped behind by the
//            column's 45 deg slope, less H1, W1 under the lower layer, S1, and
//            M1's counterbores / holes. B1 bosses, each a cone, on top.
//   COLUMN   |y| <= 20: its side section in [x, z] (C2 back, C3 slant, C4 top
//            step) extruded across it, its plan (C1, R3 at the bore) extruded
//            up, and its underside (C5 slope and back's underside, R3 round at
//            the slope's foot, R3 fillet at its top) swept across with every edge
//            onto the sides rounded R3 by a ball (a Minkowski sum of the
//            underside shrunk by R3).
//   BRIDGE   z 54 .. 62, |y| <= 32.5, its R5 fillets into the column's sides
//            (a section in [y, z] extruded along x).
//   FRAME    plan layers: the U of P1 under the motor plates (z 54 .. 62), the
//            lower motor plates P2 (62 .. 70), the walls and back blocks (70 ..
//            93.5), the top plates P3 (93.5 .. 101).
//   FRONT    about the bore's axis, the bridge and the lower plates are turned
//            to the S profile FRONT_S (a revolved cutter): an R3 round under the
//            bridge, the bore's R38 to z 62, an S of two R3 arcs out to R41, and
//            an R3 round onto the plate's top. It cuts across the column's
//            corner too; the column is put back after.
//   BLENDS   two, mirrored, where the column's R3 corner meets what lies across
//            it, each in its own box: under the bridge (CORNER_ZONE) the column,
//            fillets and bridge are rounded R3 by a ball (an opening); at the
//            lower plate (PLATE_ZONE) the column and the S front are filleted R3
//            by a ball (a closing), then the plate's top round run on round the
//            fillet. The Minkowski sums are built from coarse pieces, in a window.
//   CUTS     K1 channel, W1, the C3 slant above z 65, the C6 grooves, N1 slots
//            and H2 holes.
//
// `layer` names a plan profile to draw in 2D, for verification against the
// mesh's section (scadmesh outline; render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/slice/arcs/solid and
// sections about the bore's axis. The feature IDs are those of
// 520-001_ExGearMount.view.json:
//
//     ID  feature                    value
//     F1  floor                      z 0 .. 4: the disc R38.0 about BORE_C, and a
//                                    tongue to -x between lines tangent to it at
//                                    (-18.537, +-33.529) through (-44.904, +-19.467)
//     H1  floor's hole               Ø22.0 on the drive axis
//     W1  wire channel               12.8 wide on y = 0, z 0 .. 2, from H1 out
//     S1  slots                      4, 12.8 x 3.3, r 21.0 .. 24.3, on 0 + 90k deg
//     M1  End Cap screw holes        4 at (+-15.5, +-15.5): Ø6.99 z 0 .. 2,
//                                    Ø3.196 up through the bosses
//     B1  bosses                     cones r 5.0 at z 4 to r 3.0 at z 6
//     C1  column                     |y| <= 20, R3 corners onto the bore's R38
//                                    about BORE_C
//     C2  column's back              x -70.384 from z 14.75
//     C3  slant                      (-70.384, 65.0) to (-57.901, 81.5)
//     C4  top                        z 81.5 to x -53.901, then z 77.5
//     C5  underside                  45 deg slope x + z = -43.904 from the floor's
//                                    foot (R3 round) to z 14.75 (R3 fillet)
//     C6  grooves                    1.0 deep on the column's sides, x -57.901 ..
//                                    -43.648, tapering out by x -41.826, z 75 up
//     K1  CF tube channel            29.0 x 29.0, z 26.755 .. 55.755, along x
//                                    from the back to the bore
//     D1  bridge                     z 54 .. 62, |y| <= 32.5, R5 fillets under it
//     P1  U under the plates         z 54 .. 62: back wall to x -66.346, side
//                                    walls |y| 74.5 .. 78.539, R3 corners
//     P2  lower motor plates         z 62 .. 70; front at x -24.346 and FRONT_S
//     P3  top motor plates           z 93.5 .. 101; inner edge tangent from the
//                                    back block's corner to R16 about the motor
//                                    hole, then tangent to R5.5 about the front M3
//     G1  motor holes                at (-45.346, +-53.5): Ø23.0 in P2; Ø18.0
//                                    z 93.5 .. 94 then Ø22.0 in P3
//     G2  motor screw holes          8 in P2 at x -60.846 / -29.846, y +-38 / +-69:
//                                    Ø2.994 z 62 .. 65, Ø6.99 above; Ø6.99 in P3
//     E1  walls                      |y| 72.539 .. 78.539, z 70 .. 93.5
//     E2  back blocks                x to -43.345, |y| 20 .. 26, z 70 .. 101
//     N1  Nut Holder slots           x -51.278 to the bore, |y| 6 .. 14,
//                                    z 65.5 .. 69.5
//     H2  all-thread holes           Ø2.995 at (-46.278, +-10), z 65 .. 77.5
//
// The reference's only miss is at the floor's tongue where it runs into the
// column's rounded corner (about (-47.5, +-18.2, 3.7)): a blend that fades out
// down the tongue, 0.21 off at most.
//
// FITS (../print_fit.scad), revised only:
//
//     M1, H2, G2's Ø3 part, on M3 screws and all-threads (Ø3.0)   slip
//     N1, on the Nut Holder's 8.0 width and its flat end (printed) slip
//     G1 in P3, on the motor's Ø22 pilot                          press
//
// Drawn wider than their class already, so kept: S1 (3.3 x 12.8 over the
// C-501 strake's 3.175 x 12.7, bonded: press), G1 in P2 (Ø23), the
// counterbores, N1's height (4.0 over the holder's 3.5), K1 (29.0 over
// #520-006's 28.753 outside, C-504's 1.032" bore and two .050" walls: 0.124
// per side, over the press clearance a bonded tube takes), and the bore (R38
// over the gear's 36.977, more than running).

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one plan profile in 2D
layer = "part"; // [part, floor_lower, frame_low, walls, top_lip, top]

/* [Hidden] */
$fn = 360;
epsilon = 0.01;
LAP = 0.005;
$mount_cfg = config;          // the configuration modules draw; ex_gear_mount(cfg) sets it

BORE_C   = [-0.655, 0];
BORE_R   = 38.000;
BACK_X   = -70.384;
FRONT_X  = -24.346;
SIDE_Y   = 78.539;
CORNER_R = 3.000;
SLOPE_K  = -43.904;          // slope plane: x + z = SLOPE_K
FLOOR_Z  = [0, 2, 4];
TONGUE   = [[-18.537, 33.529], [-44.904, 19.467]];   // tangent point, back corner at z 1
CENTRE_D = 22.000;
CHANNEL_W = 12.800;
SLOT     = [12.800, 3.300, 21.000];   // length, width, inner radius
MOTOR_SCREWS = [for (x = [-15.5, 15.5], y = [-15.5, 15.5]) [x, y]];
CBORE_D  = 6.990;
SCREW_D  = 3.196;
BOSS     = [5.000, 3.000, 4.000, 6.000];   // base r, top r, z0, z1

COL_W    = 20.000;           // column half-width
COL_BOT  = 14.750;
COL_SLANT = [[BACK_X, 65.000], [-57.901, 81.500]];
COL_TOP  = [77.500, 81.500, -53.901];
CHANNEL  = [14.500, 26.755, 55.755];   // CF tube channel: half-width, z0, z1
BRIDGE   = [54.000, 62.000, 32.500];   // z0, z1, half-width
FILLET_R = 5.000;

PLATE_LOW = [62.000, 65.000, 70.000];
POCKET_X = -66.346;
POCKET_Y = [32.500, 74.500];
WALL_IN  = 72.539;            // side walls' inner face above the lower plate
BLOCK    = [-43.345, 20.000, 26.000];  // back blocks: front x, y from, y to
TOP_PLATE = [93.500, 94.000, 101.000];
MOTOR_C  = [-45.346, 53.500];
MOTOR_HOLE = [23.000, 18.000, 22.000];   // lower plate, top plate lip, top plate
M3_POS   = [for (x = [-60.846, -29.846], y = [38.000, 69.000]) [x, y]];
M3_D     = [2.994, 6.990];
NUT_SLOT = [-51.278, 6.000, 14.000, 65.500, 69.500];
ROD_C    = [-46.278, 10.000];
ROD_D    = 2.995;
HULL_R   = 16.000;
WING_A   = -13.440;   // where the top plate's inner edge leaves the R16 about the motor hole
WING_R   = 5.500;     // the boss round the front M3 hole the edge runs onto
GROOVE   = [-57.901, -43.648, -41.826, 19.000, 75.000];   // column side groove: x0, x1, x taper end, y, z0
M3       = 3.000;             // the M3 screws' and all-threads' diameter
PILOT_D  = 22.000;            // the motors' pilot
HOLDER_W = 8.000;             // the Nut Holder's width

// The fitted sizes in the configuration being drawn.
function prev() = $mount_cfg == "previous";
function slip() = fit_clearances($mount_cfg)[0];
function press() = fit_clearances($mount_cfg)[1];
function screw_d() = prev() ? SCREW_D : fit_bore(M3, slip());
function m3_d() = prev() ? M3_D[0] : fit_bore(M3, slip());
function rod_d() = prev() ? ROD_D : fit_bore(M3, slip());
function pilot_d() = prev() ? MOTOR_HOLE[2] : fit_bore(PILOT_D, press());
function nut_slot_y() = let (c = (NUT_SLOT[1] + NUT_SLOT[2]) / 2, w = prev() ? NUT_SLOT[2] - NUT_SLOT[1] : HOLDER_W + 2 * slip())
    [c - w / 2, c + w / 2];
// The slot's back wall: the holder's flat end lands on NUT_SLOT[0] exactly.
function nut_slot_back() = prev() ? NUT_SLOT[0] : NUT_SLOT[0] - slip();

// For the assembly: the floor's top, the bosses' top, the Nut Holders' slot
// floor, the all-threads' axes, and M1's axes and counterbore floor.
function mount_floor_top() = FLOOR_Z[2];
function mount_boss_top() = BOSS[3];
function mount_nut_slot_z() = NUT_SLOT[3];
function mount_rod_axes() = [[ROD_C.x, ROD_C.y], [ROD_C.x, -ROD_C.y]];
function mount_screw_axes() = MOTOR_SCREWS;
function mount_cbore_floor() = FLOOR_Z[1];

module mirror_y() { children(); mirror([0, 1, 0]) children(); }
module bore_2d(r = BORE_R) translate(BORE_C) circle(r = r);

// --- Floor ------------------------------------------------------------------
module floor_outline_2d() {
    k = (TONGUE[0].y - TONGUE[1].y) / (TONGUE[0].x - TONGUE[1].x);
    far = [-70, TONGUE[1].y + k * (-70 - TONGUE[1].x)];
    union() {
        bore_2d();
        polygon([TONGUE[0], far, [far.x, -far.y], [TONGUE[0].x, -TONGUE[0].y]]);
    }
}

module slots_2d() for (a = [0 : 90 : 270]) rotate(a)
    translate([SLOT[2], -SLOT[0] / 2]) square([SLOT[1], SLOT[0]]);

module floor_lower_2d() difference() {
    floor_outline_2d();
    circle(d = CENTRE_D);
    translate([-80, -CHANNEL_W / 2]) square([80, CHANNEL_W]);
    slots_2d();
    for (p = MOTOR_SCREWS) translate(p) circle(d = CBORE_D, $fn = 96);
}

module floor_upper_2d() difference() {
    floor_outline_2d();
    circle(d = CENTRE_D);
    slots_2d();
    for (p = MOTOR_SCREWS) translate(p) circle(d = screw_d(), $fn = 96);
}

// The half-space in front of the slope, x + z >= SLOPE_K, as a prism, its edge
// on the underside rounded R3.
module front_of_slope() {
    rotate([90, 0, 0]) translate([0, 0, -100]) linear_extrude(200)
        offset(r = CORNER_R) offset(delta = -CORNER_R)
            polygon([[SLOPE_K - 30, 30], [SLOPE_K, 0], [100, 0], [100, 30]]);
}

module floor_part() {
    intersection() {
        union() {
            linear_extrude(FLOOR_Z[1] + LAP) floor_lower_2d();
            translate([0, 0, FLOOR_Z[1]]) linear_extrude(FLOOR_Z[2] - FLOOR_Z[1]) floor_upper_2d();
        }
        front_of_slope();
    }
}

module bosses() for (p = MOTOR_SCREWS) translate(p) difference() {
    translate([0, 0, BOSS[2] - LAP]) cylinder(r1 = BOSS[0], r2 = BOSS[1], h = BOSS[3] - BOSS[2] + LAP, $fn = 96);
    translate([0, 0, BOSS[2] - 1]) cylinder(d = screw_d(), h = 4, $fn = 96);
}

// --- Column -----------------------------------------------------------------
// Its side section, in [x, z].
module column_xz() {
    // the underside is underside_rounded()'s
    polygon([[-20, -1], [BACK_X, -1], COL_SLANT[0], COL_SLANT[1],
             [COL_TOP[2], COL_TOP[1]], [COL_TOP[2], COL_TOP[0]], [-20, COL_TOP[0]]]);
}

module column_plan_2d() {
    offset(r = CORNER_R) offset(delta = -CORNER_R) difference() {
        translate([BACK_X - 10, -COL_W]) square([60, 2 * COL_W]);
        bore_2d();
    }
}

// The column's underside in [x, z]: the floor's underside, the slope with its
// R3 round onto it, the R3 fillet into the back's underside at z 14.75. Open
// above and in front, so only the underside's edges are rounded below.
module underside_xz() {
    c = SLOPE_K - COL_BOT;
    offset(r = -CORNER_R) offset(r = CORNER_R)
        polygon([[20, 0], [SLOPE_K, 0], [c, COL_BOT], [BACK_X - 30, COL_BOT], [BACK_X - 30, 150], [20, 150]]);
}

// The underside swept across the column, its edges onto the column's sides
// rounded R3: a ball rolled round the underside shrunk by R3.
module underside_rounded() {
    minkowski() {
        rotate([90, 0, 0]) translate([0, 0, -(COL_W - CORNER_R)])
            linear_extrude(2 * (COL_W - CORNER_R)) offset(delta = -CORNER_R) underside_xz();
        // OpenSCAD's sphere has no ring on its equator: scaled so its widest
        // rings reach R3, the sides stand at y +-20
        scale(1 / cos(180 / 48)) sphere(r = CORNER_R, $fn = 48);
    }
}

module column() {
    intersection() {
        rotate([90, 0, 0]) translate([0, 0, -COL_W - 1]) linear_extrude(2 * COL_W + 2) column_xz();
        underside_rounded();
        translate([0, 0, -1]) linear_extrude(100) intersection() {
            column_plan_2d();
            translate([BACK_X, -COL_W - 1]) square([60, 2 * COL_W + 2]);
        }
    }
}

// The bridge under the motor plates and its R5 fillets into the column's sides, in [y, z].
module bridge_yz() {
    offset(r = -FILLET_R) offset(r = FILLET_R) union() {
        translate([-COL_W, COL_BOT]) square([2 * COL_W, BRIDGE[1] - COL_BOT]);
        translate([-BRIDGE[2], BRIDGE[0]]) square([2 * BRIDGE[2], BRIDGE[1] - BRIDGE[0]]);
    }
}

module bridge() {
    intersection() {
        rotate([90, 0, 90]) translate([0, 0, BACK_X]) linear_extrude(FRONT_X - BACK_X) bridge_yz();
        translate([0, 0, BRIDGE[0] - FILLET_R - 1]) linear_extrude(BRIDGE[1] - BRIDGE[0] + FILLET_R + 1) difference() {
            translate([BACK_X, -BRIDGE[2]]) square([FRONT_X - BACK_X, 2 * BRIDGE[2]]);
            bore_2d();
        }
    }
}

// --- Frame ------------------------------------------------------------------
module frame_rect_2d(y0, y1) {
    intersection() {
        offset(r = CORNER_R) offset(delta = -CORNER_R) translate([BACK_X, -SIDE_Y]) square([FRONT_X - BACK_X + 10, 2 * SIDE_Y]);
        translate([BACK_X - 1, -SIDE_Y - 1]) square([FRONT_X - BACK_X + 1, 2 * SIDE_Y + 2]);
    }
}

module frame_low_2d() difference() {   // z 54 .. 62
    frame_rect_2d();
    // each pocket, its corners at the back rounded (an opening of the pocket)
    mirror_y() offset(r = CORNER_R) offset(delta = -CORNER_R)
        translate([POCKET_X, POCKET_Y[0]]) square([FRONT_X - POCKET_X + 10, POCKET_Y[1] - POCKET_Y[0]]);
    bore_2d();
}

// The lower plates either side of the column, which carries on through them;
// each laps 0.1 into it. The front is front_s_cutter()'s, and the fillet onto
// the column plate_fillet()'s.
module plate_outline_2d() difference() {
    frame_rect_2d();
    bore_2d(BORE_R);
}

module m3_holes_2d(d) for (p = M3_POS) mirror_y() translate(p) circle(d = d, $fn = 96);
module motor_holes_2d(d) mirror_y() translate(MOTOR_C) circle(d = d);

module plate_lower_2d(upper) difference() {
    plate_outline_2d();
    motor_holes_2d(MOTOR_HOLE[0]);
    m3_holes_2d(upper ? M3_D[1] : m3_d());
}

// A back block on +y. Beside the column it laps 0.01 into it; above the column
// it stops at y 20.
module back_block_2d(lap = 0.01)
    translate([BACK_X - 1, BLOCK[1] - lap]) square([BLOCK[0] - BACK_X + 1, BLOCK[2] - BLOCK[1] + lap]);

module walls_2d() {   // z 70 .. 93.5
    intersection() {
        frame_rect_2d();
        mirror_y() union() {
            back_block_2d();
            translate([BACK_X - 1, WALL_IN]) square([FRONT_X - BACK_X + 2, 10]);
        }
    }
}

// The top plate on +y, beyond the back block: its inner edge is a line from
// the block's corner tangent to the R16 about the motor hole, that arc out to
// WING_A, a line from there tangent to the R5.5 about the front M3 hole, and
// that arc to the front face.
function tangent_from(p, c, r, side) = let (d = norm(p - c), a = atan2(p.y - c.y, p.x - c.x),
    b = acos(r / d)) c + r * [cos(a + side * b), sin(a + side * b)];
module top_plate_wing_2d() {
    p0 = [BLOCK[0], BLOCK[2]];
    m = MOTOR_C;
    s = M3_POS[3];   // (-29.846, 69)
    t1 = tangent_from(p0, m, HULL_R, 1);
    a1 = atan2(t1.y - m.y, t1.x - m.x);
    a2 = WING_A;
    q = m + HULL_R * [cos(a2), sin(a2)];
    t2 = tangent_from(q, s, WING_R, 1);
    b2 = atan2(t2.y - s.y, t2.x - s.x);
    polygon(concat([[BACK_X - 1, BLOCK[2] - LAP], p0],
                   arc_pts(m, HULL_R, a1, a2, 24),
                   arc_pts(s, WING_R, b2, 0, 12),
                   [[FRONT_X + 1, s.y], [FRONT_X + 1, SIDE_Y + 1], [BACK_X - 1, SIDE_Y + 1]]));
}

module top_plate_2d(lip) difference() {
    intersection() {
        frame_rect_2d();
        mirror_y() union() {
            back_block_2d(0);
            top_plate_wing_2d();
        }
    }
    motor_holes_2d(lip ? MOTOR_HOLE[1] : pilot_d());
    m3_holes_2d(M3_D[1]);
}

module frame() {
    translate([0, 0, BRIDGE[0]]) linear_extrude(BRIDGE[1] - BRIDGE[0] + LAP) frame_low_2d();
    translate([0, 0, PLATE_LOW[0]]) linear_extrude(PLATE_LOW[1] - PLATE_LOW[0] + LAP) plate_lower_2d(false);
    translate([0, 0, PLATE_LOW[1]]) linear_extrude(PLATE_LOW[2] - PLATE_LOW[1] + LAP) plate_lower_2d(true);
    translate([0, 0, PLATE_LOW[2]]) linear_extrude(TOP_PLATE[0] - PLATE_LOW[2] + LAP) walls_2d();
    translate([0, 0, TOP_PLATE[0]]) linear_extrude(TOP_PLATE[1] - TOP_PLATE[0] + LAP) top_plate_2d(true);
    translate([0, 0, TOP_PLATE[1]]) linear_extrude(TOP_PLATE[2] - TOP_PLATE[1]) top_plate_2d(false);
}

// --- Cuts -------------------------------------------------------------------
module slant_cut() {
    rotate([90, 0, 0]) translate([0, 0, -COL_W]) linear_extrude(2 * COL_W)
        polygon([[BACK_X - 5, COL_SLANT[0].y - (COL_SLANT[1].y - COL_SLANT[0].y) / (COL_SLANT[1].x - COL_SLANT[0].x) * 5],
                 COL_SLANT[0], COL_SLANT[1], [COL_SLANT[1].x, 120], [BACK_X - 5, 120]]);
}

module column_groove() mirror_y()
    translate([0, 0, GROOVE[4]]) linear_extrude(20)
        polygon([[GROOVE[0], GROOVE[3]], [GROOVE[1], GROOVE[3]], [GROOVE[2], COL_W], [GROOVE[0], COL_W]]);

// The front of the bridge and the lower motor plates, about the bore's axis, as
// [r, z]: R3 round under the bridge, the bore's R38 up to the plate, an S of
// two R3 arcs out to the plate's R41 face, and an R3 round onto its top.
function arc_pts(c, r, a0, a1, n = 16) = [for (i = [0 : n]) c + r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];
FRONT_S = [[41.000, 57.000], [41.000, 62.000], [37.920, 67.230], [44.000, 67.000]];   // arc centres
module front_s_cutter() {
    s1 = FRONT_S[1]; s2 = FRONT_S[2];
    // the convex R3 about s1 meets the concave R3 about s2 on the line between them
    a12 = atan2(s2.y - s1.y, s2.x - s1.x);
    a21 = a12 - 180;
    p = concat(
        [[0, BRIDGE[0] - LAP], [FRONT_S[0].x, BRIDGE[0] - LAP]],
        arc_pts(FRONT_S[0], CORNER_R, -90, -180),
        arc_pts(s1, CORNER_R, 180, a12),
        arc_pts(s2, CORNER_R, a21, atan2(FRONT_S[3].y - s2.y, FRONT_S[3].x - CORNER_R - s2.x)),
        arc_pts(FRONT_S[3], CORNER_R, 180, 90),
        [[FRONT_S[3].x + 1, PLATE_LOW[2] + 0.05], [FRONT_S[3].x + 1, PLATE_LOW[2] + 1], [0, PLATE_LOW[2] + 1]]);
    difference() {
        translate(BORE_C) rotate_extrude() polygon(p);
        mirror_y() corner_zone();
    }
}

module cuts() {
    // the CF tube channel
    translate([BACK_X - 5, -CHANNEL[0], CHANNEL[1]]) cube([40, 2 * CHANNEL[0], CHANNEL[2] - CHANNEL[1]]);
    // the wire channel under the floor
    translate([-80, -CHANNEL_W / 2, -1]) cube([80, CHANNEL_W, FLOOR_Z[1] + 1]);
    slant_cut();
    column_groove();
    // nut holder slots and the all-thread holes above them
    mirror_y() translate([nut_slot_back(), nut_slot_y()[0], NUT_SLOT[3]])
        cube([30, nut_slot_y()[1] - nut_slot_y()[0], NUT_SLOT[4] - NUT_SLOT[3]]);
    mirror_y() translate([ROD_C.x, ROD_C.y, PLATE_LOW[1]]) cylinder(d = rod_d(), h = 20, $fn = 96);
}

// The column's front corner where its R5 fillets run under the bridge: the
// column, fillets and bridge rounded R3 where they meet the bore, as a ball
// rolled round them (their erosion by R3, dilated again). Built in the box
// CORNER_ZONE on +y, which the rest of the part leaves to it.
CORNER_ZONE = [[-42, 12, 45], [-20, 27, BRIDGE[1]]];
module corner_eroded() {
    intersection() {
        rotate([90, 0, 90]) translate([0, 0, -100]) linear_extrude(200)
            offset(delta = -CORNER_R) offset(r = -FILLET_R) offset(r = FILLET_R) union() {
                translate([-COL_W, -10]) square([2 * COL_W, 120]);
                translate([-BRIDGE[2], BRIDGE[0]]) square([2 * BRIDGE[2], 60]);
            }
        translate([0, 0, -10]) linear_extrude(130) difference() {
            translate([-100, -100]) square(200);
            bore_2d(BORE_R + CORNER_R);
        }
        translate(CORNER_ZONE[0] - [4, 4, 4]) cube(CORNER_ZONE[1] - CORNER_ZONE[0] + [8, 8, 8]);
    }
}
module corner_blend() {
    intersection() {
        minkowski() { corner_eroded(); sphere(r = CORNER_R, $fn = 48); }
        translate(CORNER_ZONE[0]) cube(CORNER_ZONE[1] - CORNER_ZONE[0]);
    }
}
module corner_zone() translate(CORNER_ZONE[0]) cube(CORNER_ZONE[1] - CORNER_ZONE[0]);

// The body before its holes: the regions, the under-bridge corners, and the
// front of the bridge and the lower plates turned to their S profile.
// The S profile runs across the column's corner too, so it cuts everything but
// the column, which is put back after.
module shaped_body() {
    union() {
        difference() {
            union() {
                difference() {
                    union() {
                        floor_part();
                        bosses();
                        bridge();
                        frame();
                    }
                    mirror_y() corner_zone();
                }
                mirror_y() corner_blend();
            }
            front_s_cutter();
        }
        difference() { column(); mirror_y() corner_zone(); }
    }
}

// Where the lower plate's S-profiled front meets the column's R3 corner, the
// two are filleted R3 by a ball rolled between them: a closing (dilation by
// R3, then erosion by R3, the erosion as the complement's dilation) of the
// pieces that meet there, drawn coarse for the Minkowski sums and only in a
// window round the box PLATE_ZONE on +y, which the rest of the part leaves to it.
PLATE_ZONE = [[-42, 12, PLATE_LOW[0]], [-26, 27, PLATE_LOW[2] + LAP]];   // up past the plate's lap
module plate_zone() translate(PLATE_ZONE[0]) cube(PLATE_ZONE[1] - PLATE_ZONE[0]);

module plate_zone_pieces() {
    fn = 96;
    // the column: R38 face, R3 corner, side y 20, up past the plate
    translate([0, 0, BRIDGE[1] - 8]) linear_extrude(PLATE_LOW[2] + 16 - BRIDGE[1])
        offset(r = CORNER_R, $fn = 24) offset(delta = -CORNER_R) difference() {
            translate([-60, -10]) square([50, 10 + COL_W]);
            translate(BORE_C) circle(r = BORE_R, $fn = fn);
        }
    // the bridge below the plate, R38 face across
    translate([0, 0, BRIDGE[1] - 8]) linear_extrude(8 + LAP) difference() {
        translate([-60, -10]) square([50, 50]);
        translate(BORE_C) circle(r = BORE_R, $fn = fn);
    }
    // the plate, its front turned to the S profile across the column's corner too
    intersection() {
        translate(BORE_C) rotate_extrude($fn = fn) polygon(concat(
            [[60, PLATE_LOW[0]]],
            [for (i = [0 : 32]) let (z = PLATE_LOW[0] + (PLATE_LOW[2] - PLATE_LOW[0]) * i / 32) [s_radius(z), z]],
            [[60, PLATE_LOW[2]]]));
        translate([-60, -10, PLATE_LOW[0] - 1]) cube([50, 50, 20]);
    }
}

module ball() sphere(r = CORNER_R, $fn = 24);

// Morphology inside the box [lo, hi]: each step works in a box one ball
// diameter smaller, so the box's own faces never reach the result in the zone.
module dilated(lo, hi) intersection() { minkowski() { children(); ball(); } translate(lo) cube(hi - lo); }
module eroded(lo, hi) difference() {
    translate(lo) cube(hi - lo);
    dilated(lo - [1, 1, 1], hi + [1, 1, 1]) difference() { translate(lo - [1, 1, 1]) cube(hi - lo + [2, 2, 2]); children(); }
}

// The closing fills the corner with the fillet.
module plate_closing() {
    g = 7;
    lo = PLATE_ZONE[0] - [g, g, g];
    hi = PLATE_ZONE[1] + [g, g, g];
    eroded(lo + [3, 3, 3], hi - [3, 3, 3])
        dilated(lo, hi) intersection() { plate_zone_pieces(); translate(lo) cube(hi - lo); }
}

// The plate's R3 top round then runs on round the fillet: above TOP_ROUND_Z,
// where the S profile stands upright, the section there is shrunk by a ball
// rolled along its edge (the section eroded by R3 and swept by the ball), and
// the column, which carries on up, is put back.
TOP_ROUND_Z = FRONT_S[3].y;
module plate_blend() {
    h = PLATE_LOW[2] - TOP_ROUND_Z;
    intersection() {
        union() {
            intersection() {
                plate_closing();
                translate([-100, -100, PLATE_LOW[0] - 10]) cube([200, 200, TOP_ROUND_Z - PLATE_LOW[0] + 10 + LAP]);
            }
            intersection() {
                minkowski() {
                    translate([0, 0, TOP_ROUND_Z - LAP / 2]) linear_extrude(LAP)
                        offset(delta = -CORNER_R) projection(cut = true) translate([0, 0, -TOP_ROUND_Z]) plate_closing();
                    ball();
                }
                translate([-100, -100, TOP_ROUND_Z]) cube([200, 200, h + 5]);
            }
            intersection() {
                plate_zone_pieces();
                translate([-100, -100, TOP_ROUND_Z]) cube([200, COL_W + 100, h + 5]);
            }
        }
        // lapped past the box the rest of the part leaves, so no face is shared
        translate(PLATE_ZONE[0] - [LAP, LAP, LAP]) cube(PLATE_ZONE[1] - PLATE_ZONE[0] + 2 * [LAP, LAP, LAP]);
    }
}

// The S profile's radius about the bore's axis at height z, on 62 .. 70.
function s_radius(z) = let (s1 = FRONT_S[1], s2 = FRONT_S[2], s3 = FRONT_S[3],
    za = s1.y + CORNER_R * sin(atan2(s2.y - s1.y, s2.x - s1.x)))
    z <= za ? s1.x - sqrt(max(0, CORNER_R * CORNER_R - (z - s1.y) * (z - s1.y)))
  : z <= s3.y ? s2.x + sqrt(max(0, CORNER_R * CORNER_R - (z - s2.y) * (z - s2.y)))
  : s3.x - sqrt(max(0, CORNER_R * CORNER_R - (z - s3.y) * (z - s3.y)));

module ex_gear_mount(cfg = config) {
    $mount_cfg = cfg;
    difference() {
        union() {
            difference() { shaped_body(); mirror_y() plate_zone(); }
            mirror_y() plate_blend();
        }
        cuts();
    }
}

// The plan profiles the outline gates read, each as the part's section at a
// height inside its layer: the floor's lower layer at z 1, behind which the
// slope stands at x -44.904; P1 at z 59; the walls and back blocks at z 87,
// where the grooves have taken the blocks' laps; P3's lip and the plate above.
module layer_2d(l) {
    if (l == "floor_lower") intersection() { floor_lower_2d(); translate([SLOPE_K - 1, -100]) square(200); }
    else if (l == "frame_low") frame_low_2d();
    else if (l == "walls") difference() { walls_2d(); translate([-100, -COL_W]) square([200, 2 * COL_W]); }
    else if (l == "top_lip") top_plate_2d(true);
    else if (l == "top") top_plate_2d(false);
}

if (layer == "part") ex_gear_mount(config);
else layer_2d(layer);
