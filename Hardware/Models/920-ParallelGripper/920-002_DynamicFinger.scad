// #920-002 Dynamic Finger — parametric source.
// The gripper's moving finger. Its rack slides along X in the Static Finger's T-slot (920-001's T1) and
// meshes with the 12-tooth Pinion Gear (#920-005) on the Static Finger's hub, so the servo's turn
// closes the two fingers' gripping faces together.
//
//   config = "previous" — a faithful recreation of 920-002_DynamicFinger.step, gated against
//                         ../Reference/meshes/920-ParallelGripper/920-002_DynamicFinger.stl, in that frame.
//   config = "revised"  — the same part with a slip fit on the rail's faces that bear in T1 and on the
//                         rack teeth's flanks.
//
// SOURCE. 920-002_DynamicFinger.step (Reference/, `ParallelDynamicFinger`, CAD ID
// TI1-420-002_ParallelGripperDynamicFinger, 2020-03-12); the dimensions below are its surfaces'
// (scadmesh surfaces, and a dump of every face's loops). The reference mesh is that STEP tessellated by
// `scadmesh tessellate`.
//
// GATE. dist ±0.15, against the mesh with its design slit closed (Hardware/Models/README.md § Known
// defects): the slit 920-001's STEP leaves at the root of its lug's boss, mirrored here, where each
// tilted R10.561 cylinder is tangent to a plane face through L1's axis at ±50 deg (the STEP's #1871 and
// #1866). This recreation does not draw it.
//
// FRAME. The STEP's own, which is not the Static Finger's: the rack runs along X with its pitch line at
// z 0, and the gripping face is the plane x -18.272. With the gripper closed (the two gripping faces
// meeting, without pads), the Static Finger's frame is this one moved by (+18.272, +3.257, +28); opening
// the gripper adds its travel to the x of that move. There the rack's pitch line lies at z 28, on the
// Pinion Gear's pitch circle (R10.5 about z 17.5); L1's axis lies on the Static Finger's L1 axis
// (z 46.5), mirrored in the gripping faces; and P1 spans the Static Finger's y ±12.5.
//
// A region split (mesh-to-scad rung 8). The feature IDs are those of 920-002_DynamicFinger.view.json:
//
//     ID  feature              value
//     P1  plan                 x from -18.272 (F1's face), y -15.757 .. 9.243, R10.561 corners about
//                              (-16.272, -5.196) and (-16.272, -1.318); above the underside z 7
//     F1  finger               x -18.272 to the taper (x -16.272 at z 65.5, 9.54 deg), up to z 65.5
//     L1  lug                  a ring about Y through (-5.772, 18.5): bore Ø21, outer R15.5,
//                              y -5.196 .. -1.318, its neck in plan concave R15 arcs about
//                              (4.425, -20.196) and (4.425, 13.682)
//     L2  lug boss             on L1's +Y: a revolved flare out to y 9.243 (outer cone 18.86 deg to
//                              R18.824, inner cone 30 deg, rounds R5, R3 and R5), trimmed toward F1 by
//                              two R10.561 cylinders tilted ±40 deg whose axes lie in y -1.318, each
//                              on its own half; the tips' edges rounded R3 by a rolling ball
//     W1  web                  the rack's neck under F1, z 6 .. 7: y -1 .. 7 at the underside,
//                              chamfered 45 deg to the rail's 0 .. 6; and a 45 deg flare, z 6 .. 7.8,
//                              filling the notch between L1's neck and P1's corner over the rail
//     R1  rail                 a T along X, x -63.952 .. 0.728: core y 0 .. 6, z 2 .. 6; tongues
//                              y -1.5 .. 7.5, z 3.25 .. 4.75
//     G1  rack teeth ×12       module 1.75, 20 deg, pitch line z 0, tips z -2, roots z 2; tooth 0's
//                              +X flank crosses the pitch line at x 0
//
// FITS (revised). R1 slides in T1, a printed part. The STEP leaves 0.5 a side across Y, at the core and
// at the tongues; the faces it draws line to line are the tongues' tops against T1's wide part's
// ceiling, R1's top against T1's ceiling under the Static Finger's F1 and L1, and W1's chamfers against
// T1's top edges. Revised lowers the first two by FIT_SLIP, over the rail beyond F1's face (W1 stands
// over T1's open top), and raises W1's chamfers so that they clear the edges by FIT_SLIP. G1 meshes with
// the Pinion Gear, also printed, which the STEPs draw with no backlash (each tooth half the pitch thick
// on the pitch line, both parts); revised sets each of G1's flanks back by FIT_SLIP along its normal,
// which leaves the gripper 0.32 of play along X and keeps the pinion as drawn. The gripping face takes a glued pad (specs/008-Assembly.md step 48), and L1's bore takes
// nothing: neither is a fit.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one 2D profile for the outline gates
layer = "part"; // [part, P1, S1, R1]

/* [Hidden] */
$fn = 144;
LAP = 0.005;
BIG = 100;

FACE_X    = -18.272;                    // F1's gripping face
TOP       = 65.500;
UNDERSIDE = 7.000;
Y_SPAN    = [-15.757, 9.243];
TAPER     = [-16.272, 0.16807];         // F1's +X face: x at the top, dx/dz
CORNER    = [10.561, -16.272, [-5.196, -1.318]];          // P1's corners: radius, centre x, centres' y
LUG       = [[-5.772, 18.500], 10.500, 15.500, [-5.196, -1.318]];   // L1: axis (x, z), bore r, outer r, y span
NECK      = [4.425, [-20.196, 13.682], 15.000];           // L1's neck arcs: centre x, centres' y, r
NECK_END  = -7.721;                                        // where they meet P1's corners

function taper_x(z) = TAPER[0] + (TOP - z) * TAPER[1];

module along_x(x0, x1) translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children();   // 2D (y, z)
module along_y(y0, y1) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();    // 2D (x, z)

// --- P1 / F1 / L1 -------------------------------------------------------------------------------

// L1's neck: the ring's y span beyond the arcs' centres, widening along the concave R15 arcs to P1.
module neck_2d() difference() {
    translate([NECK_END, Y_SPAN[0]]) square([BIG, Y_SPAN[1] - Y_SPAN[0]]);
    for (y = NECK[1]) translate([NECK[0], y]) circle(r = NECK[2], $fn = 288);
    translate([NECK[0], LUG[3][1]]) square(BIG);
    translate([NECK[0], LUG[3][0] - BIG]) square(BIG);
}

module plan_2d() intersection() {
    union() {
        hull() for (y = CORNER[2]) translate([CORNER[1], y]) circle(r = CORNER[0], $fn = 288);
        translate([CORNER[1] - BIG, Y_SPAN[0]]) square([BIG, Y_SPAN[1] - Y_SPAN[0]]);
        neck_2d();
    }
    translate([FACE_X, Y_SPAN[0]]) square([BIG, Y_SPAN[1] - Y_SPAN[0]]);
}

// The side profile in (x, z): F1's taper, or L1's outer circle, from the face up.
module side_2d() intersection() {
    translate([FACE_X, 0]) square([BIG, TOP]);
    union() {
        polygon([[FACE_X, 0], [FACE_X, TOP], [TAPER[0], TOP], [taper_x(0), 0]]);
        translate(LUG[0]) circle(r = LUG[2], $fn = 288);
    }
}

module finger() intersection() {
    translate([0, 0, UNDERSIDE]) linear_extrude(TOP - UNDERSIDE) plan_2d();
    along_y(Y_SPAN[0] - 1, Y_SPAN[1] + 1) side_2d();
}

module lug_bore() translate([LUG[0].x, 0, LUG[0].y]) rotate([-90, 0, 0]) translate([0, 0, -BIG / 2])
    cylinder(r = LUG[1], h = BIG, $fn = 288);

// --- L2 -----------------------------------------------------------------------------------------

// L2's profile in (r, y) about L1's axis: L1's outer edge rounded R5 onto the outer cone, the cone to
// the end face, a round R3 onto the inner cone, and the inner cone rounded R5 into the bore. The inner
// cone is tangent to both rounds that bound it.
BOSS_Y      = [LUG[3][1], Y_SPAN[1]];
OUTER_ROUND = [[20.500, BOSS_Y[0]], 5.000];
OUTER_CONE  = 18.860;                                      // half-angle
END_ROUND   = [[17.556, BOSS_Y[1] - 3.000], 3.000];
INNER_ROUND = [[15.500, BOSS_Y[0]], 5.000];
INNER_CONE  = 30.000;                                      // half-angle

// The points of a round [centre, r] from angle a0 to a1.
function arc(round, a0, a1, n) = [for (i = [0 : n]) let(a = a0 + (a1 - a0) * i / n) round[0] + round[1] * [cos(a), sin(a)]];

OUTER_FOOT = OUTER_ROUND[0] + OUTER_ROUND[1] * [-cos(OUTER_CONE), sin(OUTER_CONE)];
BOSS_PROFILE = concat(
    [[LUG[1], BOSS_Y[0] - LAP], [LUG[2], BOSS_Y[0] - LAP]],
    arc(OUTER_ROUND, 180, 180 - OUTER_CONE, 8),
    [[OUTER_FOOT.x + (BOSS_Y[1] - OUTER_FOOT.y) * tan(OUTER_CONE), BOSS_Y[1]]],
    arc(END_ROUND, 90, 180 - INNER_CONE, 16),
    arc(INNER_ROUND, 180 - INNER_CONE, 180, 12));

module about_lug() translate([LUG[0].x, 0, LUG[0].y]) rotate([-90, 0, 0]) children();   // its z is world y

// The trimming cylinders: each axis lies in y BOSS_Y[0], tilted TRIM[2] from +Z toward +X (the upper
// half's, through TRIM[1]) or mirrored in L1's axis (the lower half's).
TRIM = [10.561, [2.318, 11.711], 40.000];

module lower_half() translate([0, 0, LUG[0].y]) mirror([0, 0, 1]) translate([0, 0, -LUG[0].y]) children();

// The upper half's trim: on F1's side of the plane through its axis (and Y), outside the cylinder.
module trim() intersection() {
    translate([TRIM[1].x, BOSS_Y[0], TRIM[1].y]) rotate([0, TRIM[2], 0]) difference() {
        translate([-BIG, -BIG / 2, -BIG / 2]) cube(BIG);
        cylinder(r = TRIM[0], h = 2 * BIG, center = true, $fn = 288);
    }
    translate([-BIG, -BIG, LUG[0].y]) cube(2 * BIG);
}

// L2's tips: where each trimming cylinder meets the inner cone, the edge is rounded R3 by a rolling
// ball. The ball's centre stands 3 inside the cylinder and 3 outside the cone; at each station y_c it
// is solved in the plane y = y_c, and the section is the corner between its two contacts, closed past
// the edge. Stations run from where the STEP's round begins to where the ball meets the end face; the
// round dies into L2's end round there. Below where the ball leaves the cone, it rolls on the bore's
// R5 round instead (3 inside it: 2 from that round's centre circle).
TIP_R      = 3.000;
TIP_START  = -1.212;
CONE_FOOT  = INNER_ROUND[0] + INNER_ROUND[1] * [-cos(INNER_CONE), sin(INNER_CONE)];   // r, y
TIP_ON_CONE = CONE_FOOT.y - TIP_R * sin(INNER_CONE);
TIP_END    = BOSS_Y[0] + TRIM[0] - TIP_R - 0.001;
TRIM_AXIS  = [sin(TRIM[2]), cos(TRIM[2])];                 // (x, z)
TRIM_SIDE  = [-cos(TRIM[2]), sin(TRIM[2])];                // toward F1, normal to the axis

function unit(v) = v / norm(v);
function cone_r(y) = CONE_FOOT.x + (y - CONE_FOOT.y) * tan(INNER_CONE);

function tip_rc(yc) = let(a = INNER_CONE, t = INNER_ROUND[0], k = INNER_ROUND[1] - TIP_R)
    yc >= TIP_ON_CONE ? cone_r(yc + TIP_R * sin(a)) + TIP_R * cos(a)
                      : t.x - sqrt(max(0, k * k - (yc - t.y) ^ 2));

function tip_ball(yc) = let(
    h = sqrt(max(0, (TRIM[0] - TIP_R) ^ 2 - (yc - BOSS_Y[0]) ^ 2)),
    q0 = TRIM[1] + h * TRIM_SIDE,
    rc = tip_rc(yc),
    w = q0 - LUG[0], bq = 2 * (w * TRIM_AXIS), cq = w * w - rc * rc,
    c = q0 + (-bq + sqrt(bq * bq - 4 * cq)) / 2 * TRIM_AXIS   // the root above L1's axis
) [c.x, yc, c.y];

// The contact on the cylinder, the contact on the cone (or round), and the point past the edge.
function tip_section(yc) = let(
    c = tip_ball(yc), p0 = [TRIM[1].x, BOSS_Y[0], TRIM[1].y], D = [TRIM_AXIS.x, 0, TRIM_AXIS.y],
    uA = unit(c - (p0 + ((c - p0) * D) * D)),
    a = INNER_CONE, rh = unit([c.x - LUG[0].x, 0, c.z - LUG[0].y]),
    t = INNER_ROUND[0], dr = tip_rc(yc) - t.x, dy = yc - t.y,
    uB = yc >= TIP_ON_CONE ? [-cos(a) * rh.x, sin(a), -cos(a) * rh.z] : unit([dr * rh.x, dy, dr * rh.z]),
    phi = acos(uA * uB)
) [c + TIP_R * uA, c + TIP_R * uB, c + (TIP_R / cos(phi / 2) + 0.6) * unit(uA + uB)];

// The upper tip's round: the corner hulled station to station, less the ball hulled station to station.
module tip_round() let(
    ys = concat([for (i = [0 : 5]) TIP_START + (TIP_ON_CONE - TIP_START) * i / 6],
                [for (i = [0 : 24]) TIP_ON_CONE + (TIP_END - TIP_ON_CONE) * i / 24]),
    balls = [for (y = ys) tip_ball(y)],
    secs = [for (y = ys) tip_section(y)],
    k = len(ys))
    difference() {
        union() for (i = [0 : k - 2]) hull() for (p = concat(secs[i], secs[i + 1], i == k - 2 ? [for (q = secs[i + 1]) q + [0, 1.5, 0]] : []))
            translate(p) cube(0.01, center = true);
        for (i = [0 : k - 2]) hull() for (c = [balls[i], balls[i + 1]]) translate(c) sphere(r = TIP_R, $fn = 48);
    }

module boss() difference() {
    intersection() {
        about_lug() rotate_extrude($fn = 288) polygon(BOSS_PROFILE);
        translate([-BIG, -BIG, UNDERSIDE]) cube(2 * BIG);
    }
    trim();
    lower_half() trim();
}

// The rounds cut L1's neck too, where its R15 arc rises above the ring's face beside the tips, but
// not within the bore's R5 round, where the STEP's rounds begin on the neck's face.
module tip_rounds() { tip_round(); lower_half() tip_round(); }

module finger_and_boss() union() {
    difference() { boss(); tip_rounds(); }
    difference() {
        finger();
        difference() {
            tip_rounds();
            about_lug() translate([0, 0, BOSS_Y[0] - 1]) cylinder(r = CONE_FOOT.x, h = 2, $fn = 288);
        }
    }
}

// --- W1 / R1 / G1 -------------------------------------------------------------------------------

RAIL      = [[0.000, 6.000], [-1.500, 7.500], [3.250, 4.750], 6.000];   // core y, tongues y, tongues z, top
RACK      = [1.750, 20.000, 12, 2.000, 0.000];   // module, pressure angle, teeth, addendum = dedendum, x where tooth 0's +X flank crosses the pitch line
PITCH     = PI * RACK[0];
FLANK_DX  = RACK[3] * tan(RACK[1]);              // a flank's run from the pitch line to a tip or root
RACK_X    = [RACK[4] - (RACK[2] - 0.5) * PITCH - FLANK_DX, RACK[4] + FLANK_DX];
WEB       = [[-1.000, 7.000], 7.800];            // the chamfers' y at the underside, the flare's top

// The faces that bear in T1, for a config: the tongues' top, R1's top beyond F1's face, and how far
// W1's chamfers rise (each 45 deg, so they stand off T1's edges by the slip clearance).
function bearing(cfg) = let(c = fit_clearances(cfg)[0]) [RAIL[2][1] - c, RAIL[3] - c, c * sqrt(2)];

module rail_2d(cfg = config) let(b = bearing(cfg)) union() {
    translate([RAIL[0][0], RACK[3]]) square([RAIL[0][1] - RAIL[0][0], b[1] - RACK[3]]);
    translate([RAIL[1][0], RAIL[2][0]]) square([RAIL[1][1] - RAIL[1][0], b[0] - RAIL[2][0]]);
}

// G1 in (x, z): each tooth from its root (with the bar) to its tip, tooth 0 at +X, each flank set back
// along its normal by the slip clearance (a run of c / cos 20 deg along X).
module teeth_2d(cfg = config) for (k = [0 : RACK[2] - 1])
    let(x = RACK[4] - PITCH / 4 - k * PITCH, w = PITCH / 4 - FLANK_DX - fit_clearances(cfg)[0] / cos(RACK[1]))
    polygon([[x - w, -RACK[3]], [x + w, -RACK[3]], [x + w + 2 * FLANK_DX, RACK[3] + LAP], [x - w - 2 * FLANK_DX, RACK[3] + LAP]]);

module rack(cfg) {
    along_x(RACK_X[0], RACK_X[1]) rail_2d(cfg);
    along_y(RAIL[0][0], RAIL[0][1]) teeth_2d(cfg);
    // Under W1 (over T1's open top) the core keeps its full height.
    translate([FACE_X, RAIL[0][0], RACK[3]]) cube([RACK_X[1] - FACE_X, RAIL[0][1] - RAIL[0][0], RAIL[3] - RACK[3]]);
}

// W1: the trapezoid under P1 (chamfered from y -1 .. 7 at the underside to the core's width), and the
// flare: within the core's width, P1 grown 45 deg downward from z 7.8 about P1's +Y corner and L1's
// +Y neck arc. Both reach into the rail, so a lowered rail top still meets them.
module web(cfg) let(d = bearing(cfg)[2], w = WEB[0], r = RAIL[0], z0 = RAIL[3], dz = WEB[1] - z0 + 1) {
    intersection() {
        along_x(FACE_X - 1, RACK_X[1] + BIG) polygon([[w[0] + d, UNDERSIDE + LAP], [w[0] + d, UNDERSIDE],
            [r[0], z0 + d], [r[0], z0 - 1], [r[1], z0 - 1], [r[1], z0 + d], [w[1] - d, UNDERSIDE], [w[1] - d, UNDERSIDE + LAP]]);
        translate([0, 0, z0 - 1]) linear_extrude(UNDERSIDE - z0 + 1 + LAP) plan_2d();
    }
    intersection() {
        translate([FACE_X, r[0], z0 - 1]) cube([RACK_X[1] - FACE_X, r[1] - r[0], dz]);
        translate([0, 0, z0 - 1]) union() {
            translate([CORNER[1], CORNER[2][1], 0]) cylinder(h = dz, r1 = CORNER[0] + dz, r2 = CORNER[0], $fn = 288);
            difference() {
                translate([-BIG, -BIG, -LAP]) cube([2 * BIG, 2 * BIG, dz + 2 * LAP]);
                translate([NECK[0], NECK[1][1], -2 * LAP]) cylinder(h = dz + 4 * LAP, r1 = NECK[2] - dz, r2 = NECK[2], $fn = 288);
            }
        }
    }
}

// --- the part -----------------------------------------------------------------------------------

module dynamic_finger(cfg = config) difference() {
    union() {
        finger_and_boss();
        web(cfg);
        rack(cfg);
    }
    lug_bore();
}

// P1's section at PLAN_Z, where F1's taper bounds it; L1's section at its mid-plane.
PLAN_Z = 40.000;

if (layer == "P1") intersection() { plan_2d(); translate([FACE_X - 1, -BIG / 2]) square([taper_x(PLAN_Z) - FACE_X + 1, BIG]); }
else if (layer == "S1") difference() {
    intersection() { side_2d(); translate([-BIG, UNDERSIDE]) square([2 * BIG, BIG]); }
    translate(LUG[0]) circle(r = LUG[1], $fn = 288);
}
else if (layer == "R1") rail_2d();
else dynamic_finger();
