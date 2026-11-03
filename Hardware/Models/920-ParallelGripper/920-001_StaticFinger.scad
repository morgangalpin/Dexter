// #920-001 Static Finger — parametric source.
// The gripper's fixed finger. It is pushed onto the Span Mount's strake column and strake (specs/008.11
// step 46), carries the gripper's MR128 pair on its hub (step 41), and guides the parallel finger's rack
// in its T-slot.
//
//   config = "previous" — a faithful recreation of 920-001_StaticFinger.step, gated against
//                         ../Reference/meshes/920-ParallelGripper/920-001_StaticFinger.stl, in that frame.
//   config = "revised"  — the same part with print fits on the MR128 seats, the strake slot, the
//                         Span Mount's column socket and the plate slot, its floor lowered and its plan
//                         squared to take the span XL-320's two bolts, as REVISED gives.
//
// SOURCE. 920-001_StaticFinger.step (Reference/, `ParallelStaticFinger`, 2020-03-12); the dimensions
// below are its surfaces' (scadmesh surfaces, and a dump of every face's loops). No mesh of the part was
// ever published; the reference mesh is the glTF body `TI1-420-001_ParallelGripperStationaryFinger` of
// dde/HDIMeterModel.gltf, exported in its own frame (`scadmesh gltf --node 115 --frame 115 --scale 1000`)
// and closed with `scadmesh repair` (six degenerate triangles dropped). Its frame is the STEP's, and its
// sections land on the STEP's surfaces.
//
// GATE. dist ±0.15, against the mesh with its design slit closed (Hardware/Models/README.md § Known
// defects): the 0.008 gap the STEP leaves where each tilted R10.561 cylinder is tangent to a plane face
// at ±130 deg about L1's axis, which this recreation does not draw. The recreation is within 0.111.
//
// FRAME. The STEP's own: the hub's axis along +Y through (x 14.139, z 17.5), the underside at z 10. The
// Span Mount stands in it turned -90 deg about Z and 1.5 lower (x = y_sm, y = -x_sm, z = z_sm + 1.5);
// the Dynamic Finger's is not this one, and its header gives the move between them.
//
// A region split (mesh-to-scad rung 8). The feature IDs are those of 920-001_StaticFinger.view.json:
//
//     ID  feature              value
//     P1  plan                 x from -12.561 (R10.561 corners about (-2, ±1.939)) on, y ±12.5
//     B1  base                 P1, y up to 12.492, z 10 .. 34.5; on +X a cylinder R17 about the hub
//     C1  shroud               a cone about the hub, R17 at y 12.188 to R7 at y 18.257 (58.75 deg)
//     R1  hash marks ×2        1 wide, 0.61 proud of C1 in y, at 35.4 deg and at -90 deg about the hub
//     F1  finger               x from the taper (x -2 at z 93.5, 9.54 deg) to 0, z 34 .. 93.5
//     L1  lug                  a ring about Y through (-12.5, 46.5): bore Ø21, outer R15.5, y ±1.939,
//                              its neck in plan concave R15 arcs about (-22.697, ±16.939)
//     L2  lug boss             on L1's +Y: a revolved flare out to y 12.5 (outer cone R15.53 .. R16.638,
//                              inner cone R10.739 .. R12.97, rounds R5, R3 and R5), trimmed toward F1 by
//                              two R10.561 cylinders tilted ±40 deg whose axes lie in y = 1.939, each
//                              on its own half; the tips' edges rounded R3 by a rolling ball
//     S1  column socket        the Span Mount's column and web, line to line, z 10 .. 24.2, 0.3 chamfer
//     S2  strake slot          5.5 x 2.4, z 24.2 up, a 45 deg roof over x < 0
//     S3  plate slot           y < -3.743 below z 28 (the Span Mount's upright plate), a tongue x ±5..5.617
//                              left in its notch, and y < -10.243 below z 29.5, the two ceilings
//                              joined at 45 deg back from the +X end x 23.139
//     U1  hub slot             x 7.639 .. 20.639 below the hub, round R6.5 over it, y -3.743 .. 2.757
//     K1  pinion pocket        x 1.389 .. 26.889 below the hub, R12.75 about it above, y 2.757 .. 10.757
//     T1  rack T-slot          along X: y 2.757 .. 9.757 z 24.7 .. 34.5, y 1.257 .. 11.257 z 30.75 .. 32.75
//     M1  MR128 seats          Ø12 at y 10.757 .. 13.507 and 14.007 .. 18.757, Ø11.2 between
//
// FITS (revised). M1 takes the MR128s (C-405, 12 OD), pressed: fit_bore(12, FIT_PRESS) = Ø12.1. S1, S2 and
// S3 are the shared socket on the Span Mount, ../900-ToolInterface/span_socket.scad's, which owns their
// sizes and fits; S2's 45 deg roof is this part's own.
//
// REVISED. The part is held to the Span Mount by the span XL-320's two M2 x 12 (S4). So that it covers them:
//
//     B1's plan is square, x from -13.1 (1.19 of wall outside S4's head bores), its corners R2. F1, L1 and L2
//       keep P1, so its corners end in a small ledge at z 34.5.
//     Its floor, z 10 in the feature table, stands at z 7.5: 1.95 under the lower head bore, and where B1's
//       R17 cylinder meets K1's side it leaves 1 of wall. S1F, the column's foot, is cut out of it.
//     S4 is span_socket.scad's: Ø2.3 through the plate, each head on a seat at y -1.093 at the end of a Ø4.1
//       bore in from the front face, 13.6 deep. The upper bore, z 21.45 .. 25.55, breaks 0.85 into T1's floor
//       (z 24.7) for y 2.757 .. 9.757, under the rack.
//
//     G1, the gear's guard: B1's R17 cylinder and C1 run on under the floor to the whole circle, z 0.5, and
//       stand round the Pinion Gear's teeth, which reach z 5.25. Their section stays out of a cylinder R11.8
//       about the roll axis, FIT_SLIP off the Span Mount's base plate, so the floor stays at z 7.5 there.
//
// K1 and U1 stay open at the bottom, as the Pinion Gear's Ø24.5 teeth go in from below, and nothing else in the
// part passes both them and its Ø12 boss. Under the floor K1 runs from side to side, y 2.757 .. 10.757: its R17
// walls would thin to nothing there, so they stop at the floor, 1 thick, and G1 stands either side of the slot.

include <../print_fit.scad>
use <../900-ToolInterface/span_socket.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 144;
LAP = 0.005;
BIG = 100;

HUB      = span_axis();                 // the hub's axis (x, z), along Y
TOP      = 34.500;
CORNER   = [10.561, -2.000, 1.939];     // P1's corners: radius, centre x, centre ±y
SQUARED  = [-13.100, 2.000];            // B1's plan, revised: its -X face, its corners' radius
HALF_Y   = 12.500;
BASE_Y   = 12.492;                      // B1's +Y face
HUB_R    = 17.000;                      // B1's cylinder
SHROUD   = [12.188, 18.257, 7.000];     // C1: from y (at HUB_R), to y, end radius
RIB      = [0.500, 0.610, [35.4, -90]]; // R1: half-width, proud, angles
RIB_TOP  = 18.757;

FINGER_TOP = 93.500;
TAPER      = [-2.000, 0.16807];         // F1's -X face: x at the top, dx/dz
LUG        = [[-12.500, 46.500], 10.500, 15.500, 1.939];   // L1: centre (x, z), bore r, outer r, ±y
NECK       = [[-22.697, 16.939], 15.000];                  // L1's neck arcs: centre (x, ±y), r
NECK_END   = -10.551;                                       // where they meet P1's corners
BOSS_CYL   = [10.561, [-20.590, 39.711], [-0.643, 0.766]]; // L2's trimming cylinders (and mirror)


function taper_x(z) = TAPER[0] - (FINGER_TOP - z) * TAPER[1];
function floor_z(cfg) = cfg == "revised" ? 7.500 : 10.000;
// How far down C1 and, revised, G1 reach: the whole circle about the hub.
function circle_z(cfg) = cfg == "revised" ? HUB.y - HUB_R : floor_z(cfg);

// --- plans --------------------------------------------------------------------------------------

module plan_2d(y_max = HALF_Y) intersection() {
    union() {
        hull() for (s = [-1, 1]) translate([CORNER[1], s * CORNER[2]]) circle(r = CORNER[0], $fn = 288);
        translate([CORNER[1], -HALF_Y]) square([BIG, 2 * HALF_Y]);
    }
    translate([-BIG, -HALF_Y]) square([2 * BIG, HALF_Y + y_max]);
}

// B1's plan, up to y_max: P1, or revised squared.
module base_plan_2d(cfg, y_max) if (cfg == "revised")
    offset(r = SQUARED[1]) offset(delta = -SQUARED[1]) translate([SQUARED[0], -HALF_Y]) square([2 * BIG, HALF_Y + y_max]);
else plan_2d(y_max);

// L1's neck: |y| <= 1.939 beyond the arcs' centre, widening along the concave R15 arcs to P1's edge.
module neck_2d() let(c = NECK[0], r = NECK[1]) difference() {
    translate([c.x - 10, -HALF_Y]) square([abs(c.x) + 10, 2 * HALF_Y]);
    for (s = [-1, 1]) translate([c.x, s * c.y]) circle(r = r, $fn = 288);
    for (s = [-1, 1]) translate([c.x - 20, s > 0 ? LUG[3] : -HALF_Y - 1]) square([20, HALF_Y + 1 - LUG[3]]);
}

// --- B1 base ------------------------------------------------------------------------------------

module along_y(y0, y1) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();

module base_side_2d(cfg) let(f = floor_z(cfg)) union() {
    translate([-BIG, f]) square([BIG + HUB.x, TOP - f]);
    intersection() { translate(HUB) circle(r = HUB_R, $fn = 288); translate([0, f]) square(BIG); }
}

// B1 stops at y 12.492 over its block and at 12.188 over its cylinder, where C1 takes over.
module base(cfg) let(f = floor_z(cfg)) intersection() {
    translate([0, 0, f]) linear_extrude(TOP - f) base_plan_2d(cfg, BASE_Y);
    along_y(-HALF_Y - 1, BASE_Y + 1) base_side_2d(cfg);
    union() {
        translate([-BIG, -BIG, 0]) cube([BIG + HUB.x, 2 * BIG, BIG]);
        translate([0, -BIG, 0]) cube([2 * BIG, BIG + SHROUD[0], BIG]);
    }
}

// G1, revised: B1's cylinder, under the floor, round the Span Mount's base plate.
MOUNT_ROOM = span_base_disc()[0] + FIT_SLIP;   // about the roll axis

module guard(cfg) let(f = floor_z(cfg), g = circle_z(cfg)) difference() {
    intersection() {
        along_y(-HALF_Y, SHROUD[0]) translate(HUB) circle(r = HUB_R, $fn = 288);
        translate([-BIG, -BIG, g - 1]) cube([2 * BIG, 2 * BIG, f - g + 1 + LAP]);
    }
    translate([0, 0, g - 2]) cylinder(r = MOUNT_ROOM, h = f - g + 3, $fn = 288);
}

// C1, the shroud: the cone about the hub, from R17 to R7, above circle_z().
function cone_r(y) = HUB_R + (SHROUD[0] - y) * (HUB_R - SHROUD[2]) / (SHROUD[1] - SHROUD[0]);

module about_hub() translate([HUB.x, 0, HUB.y]) rotate([-90, 0, 0]) children();   // its z is world y

module shroud(cfg) difference() {
    intersection() {
        about_hub() rotate_extrude($fn = 288) polygon([[0, SHROUD[0] - LAP], [HUB_R, SHROUD[0] - LAP],
            [SHROUD[2], SHROUD[1]], [0, SHROUD[1]]]);
        translate([-BIG, -BIG, circle_z(cfg)]) cube(2 * BIG);
    }
    if (cfg == "revised") translate([0, 0, circle_z(cfg) - 1]) cylinder(r = MOUNT_ROOM, h = floor_z(cfg) - circle_z(cfg) + 1, $fn = 288);
}

// R1: each a 1-wide strip about its radial line, C1 raised by 0.61 in y, up to y 18.757.
module ribs(cfg) intersection() {
    about_hub() rotate_extrude($fn = 288) polygon([[0, SHROUD[0] - LAP], [HUB_R, SHROUD[0] - LAP], [HUB_R, SHROUD[0] + RIB[1]],
        [cone_r(RIB_TOP - RIB[1]), RIB_TOP], [0, RIB_TOP]]);
    union() for (a = RIB[2]) translate([HUB.x, 0, HUB.y]) rotate([0, -a, 0])
        translate([0, -BIG / 2, -RIB[0]]) cube([BIG, BIG, 2 * RIB[0]]);
    translate([-BIG, -BIG, circle_z(cfg)]) cube(2 * BIG);
}

// --- F1 / L1 upper ------------------------------------------------------------------------------

module upper_side_2d() intersection() {
    translate([-BIG, 0]) square([BIG, FINGER_TOP]);
    union() {
        polygon([[0, TOP - 1], [0, FINGER_TOP], [TAPER[0], FINGER_TOP], [taper_x(TOP - 1), TOP - 1]]);
        translate(LUG[0]) circle(r = LUG[2], $fn = 288);
    }
}

module lug_bore() translate([LUG[0].x, 0, LUG[0].y]) rotate([-90, 0, 0]) translate([0, 0, -BIG / 2])
    cylinder(r = LUG[1], h = BIG, $fn = 288);

module upper() intersection() {
    linear_extrude(FINGER_TOP) union() {
        plan_2d();
        intersection() { neck_2d(); translate([-BIG, -BIG]) square([BIG + NECK_END, 2 * BIG]); }
    }
    along_y(-HALF_Y - 1, HALF_Y + 1) upper_side_2d();
}

// L2: the flare on L1's +Y side, revolved about L1's axis, kept between the two tilted cylinders.
// In (r, y) about L1's axis: L1's outer edge rounded R5 onto the outer cone, the cone to the end face
// y 12.5, a round R3 onto the inner cone, and the inner cone rounded R5 into the bore.
BOSS_OUTER_ROUND = [[20.500, 1.939], 5.000, 173.68];
BOSS_INNER_ROUND = [[15.500, 1.939], 5.000, 162.21];
BOSS_END_ROUND   = [[15.826, 9.500], 3.000, 162.21];
BOSS_PROFILE = concat(
    [[LUG[1], LUG[3] - LAP], [LUG[2], LUG[3] - LAP]],
    [for (i = [0 : 8]) let(a = 180 + (BOSS_OUTER_ROUND[2] - 180) * i / 8) BOSS_OUTER_ROUND[0] + BOSS_OUTER_ROUND[1] * [cos(a), sin(a)]],
    [[16.638, 12.500]],
    [for (i = [0 : 16]) let(a = 90 + (BOSS_END_ROUND[2] - 90) * i / 16) BOSS_END_ROUND[0] + BOSS_END_ROUND[1] * [cos(a), sin(a)]],
    [for (i = [0 : 12]) let(a = BOSS_INNER_ROUND[2] + (180 - BOSS_INNER_ROUND[2]) * i / 12) BOSS_INNER_ROUND[0] + BOSS_INNER_ROUND[1] * [cos(a), sin(a)]]);

module boss_cylinder(s) let(p = BOSS_CYL[1], d = BOSS_CYL[2])
    translate([p.x, LUG[3], s > 0 ? p.y : 2 * LUG[0].y - p.y])
        rotate([0, atan2(d.x, s * d.y), 0]) translate([0, 0, -BIG / 2]) cylinder(r = BOSS_CYL[0], h = BIG, $fn = 288);

// Each cylinder trims its own half, and only on F1's side of its axis: the one rising to the upper left
// bounds the boss above L1's axis, its mirror below. What it removes is the region on F1's side of the
// vertical plane through its axis, outside the cylinder.
module boss_trim(s) let(p = BOSS_CYL[1], d = BOSS_CYL[2], z0 = s > 0 ? p.y : 2 * LUG[0].y - p.y)
    intersection() {
        difference() {
            translate([p.x, 0, z0]) rotate([0, s * atan2(d.x, d.y), 0])         // the axis's plane, F1's side
                translate([0, -BIG / 2, -BIG / 2]) cube([BIG, BIG, BIG]);
            boss_cylinder(s);
        }
        translate([-BIG, -BIG, s > 0 ? LUG[0].y : LUG[0].y - BIG]) cube([2 * BIG, 2 * BIG, BIG]);
    }

module boss() difference() {
    translate([LUG[0].x, 0, LUG[0].y]) rotate([-90, 0, 0]) rotate_extrude($fn = 288) polygon(BOSS_PROFILE);
    boss_trim(1);
    boss_trim(-1);
}

// L2's tips: where each trimming cylinder meets the inner cone, the edge is rounded R3 by a rolling
// ball (the STEP's B-spline faces). The ball's centre stands 3 inside the cylinder and 3 outside the
// cone; at each station y_c it is solved in the plane y = y_c, and the section is the ball's arc
// between its two contacts, closed past the edge. Stations run from where the cone begins to where the
// ball meets the end face (y_c 9.5); the round dies into L2's end round there.
TIP_R    = 3.000;
CONE_IN  = [12.189, 7.983, 0.31138];   // inner cone: r at y, half-angle (rad)
function deg(rad) = rad * 180 / PI;

// The ball's centre's radius about L1's axis at height yc: 3 off the inner cone, or, below where the
// ball leaves the cone, 3 inside the bore's R5 round (2 from that round's centre circle).
TIP_ON_CONE = 3.467 - TIP_R * sin(deg(CONE_IN[2]));
TIP_START   = 2.045;   // the STEP's round begins here; below it the tip's face meets the bore's round sharp
function tip_rc(yc) = let(a = deg(CONE_IN[2]), t = BOSS_INNER_ROUND[0], k = BOSS_INNER_ROUND[1] - TIP_R)
    yc >= TIP_ON_CONE ? CONE_IN[0] + (yc + TIP_R * sin(a) - CONE_IN[1]) * tan(a) + TIP_R * cos(a)
                      : t.x - sqrt(max(0, k * k - (yc - t.y) ^ 2));

function tip_ball(yc) = let(
    d = BOSS_CYL[2], p0 = [BOSS_CYL[1].x, 2 * LUG[0].y - BOSS_CYL[1].y],   // the lower tip's cylinder
    D = [d.x, -d.y], n = [-D.y, D.x],                                     // its axis in (x, z), and the
    h = sqrt(max(0, (BOSS_CYL[0] - TIP_R) ^ 2 - (yc - LUG[3]) ^ 2)),      // side the crescent lies on
    q0 = p0 + h * n,
    a = deg(CONE_IN[2]),
    rc = tip_rc(yc),
    w = q0 - LUG[0], bq = 2 * (w * D), cq = w * w - rc * rc,
    s1 = (-bq - sqrt(bq * bq - 4 * cq)) / 2, s2 = (-bq + sqrt(bq * bq - 4 * cq)) / 2,
    c1 = q0 + s1 * D, c2 = q0 + s2 * D,
    c = c1.y < c2.y ? c1 : c2
) [c.x, yc, c.y];

function unit(v) = v / norm(v);

function tip_section(yc, n = 12) = let(
    c = tip_ball(yc), d = BOSS_CYL[2], p0 = [BOSS_CYL[1].x, LUG[3], 2 * LUG[0].y - BOSS_CYL[1].y],
    D = [d.x, 0, -d.y],
    foot = p0 + ((c - p0) * D) * D,
    uA = unit(c - foot),                                                  // out of the cylinder's material
    a = deg(CONE_IN[2]), rh = unit([c.x - LUG[0].x, 0, c.z - LUG[0].y]),
    t = BOSS_INNER_ROUND[0], dr = tip_rc(yc) - t.x, dy = yc - t.y,
    uB = yc >= TIP_ON_CONE ? [-cos(a) * rh.x, sin(a), -cos(a) * rh.z]     // out of the cone's material,
                           : unit([dr * rh.x, dy, dr * rh.z]),            // or of the bore's R5 round's
    phi = acos(uA * uB),
    far = c + (TIP_R / cos(phi / 2) + 0.6) * unit(uA + uB)
) concat([for (i = [0 : n]) let(t = i / n) c + TIP_R * (sin((1 - t) * phi) * uA + sin(t * phi) * uB) / sin(phi)], [far]);

// The lower tip's round (s = 1), or the upper's (s = -1, mirrored in z = 46.5): the corner between the
// two contacts and the point past the edge, hulled station to station, less the ball hulled station to
// station. (A lofted polyhedron of the same sections would not convert to Manifold inside a boolean.)
module tip_round(s = 1) let(
    y_end = LUG[3] + BOSS_CYL[0] - TIP_R - 0.001,
    ys = concat([for (i = [0 : 5]) TIP_START + (TIP_ON_CONE - TIP_START) * i / 6],
                [for (i = [0 : 24]) TIP_ON_CONE + (y_end - TIP_ON_CONE) * i / 24]),
    balls = [for (y = ys) tip_ball(y)],
    secs = [for (y = ys) let(t = tip_section(y)) [t[0], t[len(t) - 2], t[len(t) - 1]]],
    k = len(ys))
    translate([0, 0, s > 0 ? 0 : 2 * LUG[0].y]) mirror([0, 0, s > 0 ? 0 : 1]) difference() {
        union() for (i = [0 : k - 2]) hull() for (p = concat(secs[i], secs[i + 1], i == k - 2 ? [for (q = secs[i + 1]) q + [0, 1.5, 0]] : []))
            translate(p) cube(0.01, center = true);
        for (i = [0 : k - 2]) hull() for (c = [balls[i], balls[i + 1]]) translate(c) sphere(r = TIP_R, $fn = 48);
    }

module body(cfg) union() {
    base(cfg);
    if (cfg == "revised") guard(cfg);
    shroud(cfg);
    ribs(cfg);
    upper();
    difference() { boss(); tip_round(1); tip_round(-1); }   // the rounds are L2's own
}

// --- cutters ------------------------------------------------------------------------------------

module along_x(x0, x1) translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children();   // 2D (y, z)

// S1, S3 and, revised, S1F and S4 are span_socket.scad's: S3 from this part's floor, and S1 from z 10, the
// reference's floor, as its entry's chamfer clears the top of S1F, the column's foot, there.
SOCKET_Z = 10.000;

// S2: the strake's slot, span_socket.scad's section, open through B1's top over x > 0, roofed at 45 deg
// over x < 0.
ROOF        = [34.000, 36.750];    // the roof's z at x = -2.75 and at x = 0
EDGE_CHAMFER = 0.500;              // the floor's edges about S3 and U1

module strake_slot(cfg) let(w = span_strake_w(cfg), top = span_column_top())
    along_y(-w.y / 2, w.y / 2) polygon([[-w.x / 2, top - LAP], [w.x / 2, top - LAP],
        [w.x / 2, TOP + 1], [0, TOP + 1], [0, ROOF[1] + (w.x - span_strake_ref_w().x) / 2],
        [-w.x / 2, ROOF[0]]]);

// U1: the hub's slot, from the floor up round the hub, from V1's +X face.
U_SLOT = [6.500, span_plate_face(), 2.757];   // half-width (= its round's radius), y span

module hub_slot(cfg) let(f = circle_z(cfg)) along_y(U_SLOT[1] - 1, U_SLOT[2]) union() {
    translate([HUB.x - U_SLOT[0], f - 1]) square([2 * U_SLOT[0], HUB.y - f + 1]);
    translate(HUB) circle(r = U_SLOT[0]);
}

// The floor's 0.5 x 45 deg chamfers: along S3's +Y edge either side of U1, along S3's +X end, and up
// U1's two sides; revised, on -X of U1 alone, as G1 takes the floor on its +X.
// The two along S3 meet in a mitre on the vertical plane through its corner at 45 deg.
module mitre(p, side) let(k = p[2] - p[0])
    linear_extrude(3 * BIG, center = true) polygon(side > 0 ? [[k - BIG, -BIG], [k + BIG, BIG], [-BIG, BIG]]
                                                              : [[k - BIG, -BIG], [k + BIG, BIG], [BIG, -BIG]]);

module floor_chamfers(cfg) let(e = EDGE_CHAMFER, p = span_plate_slot_at(cfg), f = floor_z(cfg), plus = cfg != "revised") {
    for (x = concat([[4.0, HUB.x - U_SLOT[0]]], plus ? [[HUB.x + U_SLOT[0], p[2] + e]] : [])) intersection() {
        along_x(x[0], x[1]) polygon([[p[0] - 1, f - 1], [p[0] + e + 1, f - 1], [p[0], f + e]]);
        mitre(p, 1);
    }
    if (plus) intersection() {
        along_y(-BIG, p[0] + e) polygon([[p[2] - 1, f - 1], [p[2] + e + 1, f - 1], [p[2], f + e]]);
        mitre(p, -1);
    }
    along_y(U_SLOT[1] - 1, U_SLOT[2]) for (s = plus ? [-1, 1] : [-1]) let(x = HUB.x + s * U_SLOT[0])
        polygon([[x - s, f - 1], [x + s * (e + 1), f - 1], [x, f + e]]);
}

// K1: the pinion's pocket, a U (the floor up to the hub, a round over it) growing at 45 deg from
// R10.457 at y 2.757 to R12.75 at y 5.05, then straight to y 10.757; capped at z 30.
POCKET = [[2.757, 10.457], [5.050, 12.750], 10.757, 30.000];

module pocket_u(r, t, f) translate([0, t, 0]) rotate([-90, 0, 0]) mirror([0, 1, 0]) linear_extrude(0.01) union() {
    translate([HUB.x - r, f - 1]) square([2 * r, HUB.y - f + 1]);
    translate(HUB) circle(r = r);
}

module pocket(cfg) let(f = floor_z(cfg)) {
    intersection() {
        union() {
            hull() { pocket_u(POCKET[0][1], POCKET[0][0], f); pocket_u(POCKET[1][1], POCKET[1][0] - 0.01, f); }
            along_y(POCKET[1][0] - LAP, POCKET[2]) union() {
                translate([HUB.x - POCKET[1][1], f - 1]) square([2 * POCKET[1][1], HUB.y - f + 1]);
                translate(HUB) circle(r = POCKET[1][1]);
            }
        }
        translate([-BIG, -BIG, 0]) cube([2 * BIG, 2 * BIG, POCKET[3]]);
    }
    // Under the floor the gear's slot is open from side to side, between G1's two faces.
    if (cfg == "revised") translate([-BIG, POCKET[0][0], circle_z(cfg) - 1]) cube([2 * BIG, POCKET[2] - POCKET[0][0], f - circle_z(cfg) + 1]);
}

// T1: the rack's T-slot along X. Its upper part is open through B1's top over x >= 0, and stops at
// z 34 under F1 and L1.
T_SLOT = [[2.757, 9.757], [1.257, 11.257], 24.700, 30.750, 32.750, 34.000];

module t_slot() let(n = T_SLOT[0], w = T_SLOT[1]) {
    along_x(-BIG, BIG) polygon([[n[0], T_SLOT[2]], [n[1], T_SLOT[2]], [n[1], T_SLOT[3]], [w[1], T_SLOT[3]],
        [w[1], T_SLOT[4]], [n[1], T_SLOT[4]], [n[1], T_SLOT[5]], [n[0], T_SLOT[5]], [n[0], T_SLOT[4]],
        [w[0], T_SLOT[4]], [w[0], T_SLOT[3]], [n[0], T_SLOT[3]]]);
    along_x(0, BIG) translate([n[0], T_SLOT[5] - LAP]) square([n[1] - n[0], 2]);
}

// M1: the MR128 seats either side of their Ø11.2 shoulder.
SEATS = [12.000, 11.200, [10.757, 13.507], [14.007, 18.757]];

module seats(cfg) let(d = fit_bore(SEATS[0], fit_clearances(cfg)[1])) {
    along_y(SEATS[2][0] - 1, SEATS[2][1]) translate(HUB) circle(d = d);
    along_y(SEATS[2][1] - LAP, SEATS[3][0] + LAP) translate(HUB) circle(d = SEATS[1]);
    along_y(SEATS[3][0], SEATS[3][1] + 1) translate(HUB) circle(d = d);
}

// B1's top edge on +Y, chamfered 0.5 x 45 deg.
module top_chamfer() along_x(0, 20) polygon([[BASE_Y - 0.5, TOP + 1], [BASE_Y - 0.5 - 1, TOP + 1],
    [BASE_Y - 0.5, TOP], [BASE_Y + 1, TOP - 1.5], [BASE_Y + 1, TOP + 1]]);

module static_finger(cfg = config) difference() {
    body(cfg);
    lug_bore();
    span_column_socket(cfg, SOCKET_Z);
    if (cfg == "revised") {
        span_column_foot(cfg);
        span_bolt_holes(cfg, BASE_Y + 1);
    }
    strake_slot(cfg);
    span_plate_slot(cfg, circle_z(cfg));
    hub_slot(cfg);
    floor_chamfers(cfg);
    pocket(cfg);
    t_slot();
    seats(cfg);
    top_chamfer();
}

static_finger();
