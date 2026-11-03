// #900-001 Tool Interface Body — parametric source.
// The gripper's body: it carries the two XL-320 servos (one in its channel), clamps to the arm's tool
// end with three M3 bolts and captive nuts in its lobes (specs/008.11 step 3), and holds the flange the
// roll stack bolts to.
//
//   config = "previous" — a faithful recreation of 900-001_ToolInterfaceBody.step, gated against
//                         ../Reference/meshes/900-ToolInterface/900-001_ToolInterfaceBody.stl, in that frame.
//   config = "revised"  — the same part with print fits on its fastener holes, nut traps and servo channel.
//
// SOURCE. 900-001_ToolInterfaceBody.step (Reference/, `TI1-100-001_ToolInterfaceBody`); the dimensions
// below are its surfaces'. No mesh of the part was ever published, so the reference mesh is the STEP
// tessellated by `scadmesh tessellate` at its default 0.01 mm chord tolerance: openscad-tools branch
// `step-tessellate`, commit 0f5bfc7 (not yet merged; the main build has no `tessellate`). The STEP's
// frame is the mesh's. The solid holds two sealed voids (V1, the STEP's BREP_WITH_VOIDS), which the
// mesh keeps; "previous" draws them so the gate compares like with like, and "revised" leaves them out,
// since they hold nothing and a slicer would only wall them.
//
// FRAME. The STEP's own: the hub's axis is Z through the origin, its underside at z -11.5 and its top at
// z 20; the channel runs along -X; the flange's axis is parallel to X through (y 0, z 4).
//
// A region split (mesh-to-scad rung 8). The feature IDs are those of 900-001_ToolInterfaceBody.view.json:
//
//     ID  feature              value
//     H1  hub                  revolved: R20 z -11.5 .. -2.5, 45 deg to R18.5 at z -1, R18.5 to z 12.5,
//                              the top cone r + z = 31 to R11 at z 20
//     L1  lobes ×3             at 0 and ±120 deg: end face 23.65 out, 5.8 wide, sides through (23.621,
//                              ±2.9) and (16.677, ±8.007), under the top cone, a 3.5 x 45 deg chamfer under
//                              the end; cut off at x -14.04 where they reach the channel
//     P1  lobe pockets ×3      12.75 .. 15.65 out, 5.8 wide, through; their rims rounded R0.6 onto the cone
//     N1  nut slots ×3         17.05 .. 19.55 out, 5.6 wide, from the underside to z 7 (M3 nuts)
//     B1  bolt holes ×3        Ø3 along each lobe's axis at z -1.25, 0.171 off it, P1 to the end face
//     C1  channel              x -38.04 .. -11.04, 28 wide, z -6.5 .. 20
//     S1  servo pocket         in C1 to x -14.04: 24 wide above z 1.159, a 0.5 ledge, 57 deg sides and R2
//                              corners down to a floor at z -5
//     W1  wall holes ×6        Ø4 across C1's walls at x -19.74, -25.74, -31.74, z 4
//     T1  bore slot            5.5 either side of y 0, from x -14.04 into the bore, the underside to z 7,
//                              a 45 deg gable to z 12.5 (11.898 where it passes under the rim, x < -11.04)
//     G1  tongue               over T1, |y| <= 5.5 at the top, 45 deg sides to the cone, x -11.04 to it
//     D1  bore                 Ø20 to z 14, rounded R5 into Ø10 through the top
//     F1  flange plate         x -41.74 .. -38.04: R19.5 about the flange axis, flats at |y| 15.5, top
//                              z 20, less the U-window (R9.5, open upward)
//     F2  flange ring          x -45.74 .. -41.74: F1's outline less a bayonet bore (R16.5, notches to R18
//                              at ±y and to R17.5 below, sides at 40 deg and R1 corners, open between
//                              |y| 12.5 above it); the ears at its top rounded and chamfered toward -X
//     M1  M2 holes ×4          Ø2.1 from F2's bore through to hex nut traps 4 AF in F1, 0.5 x 45 deg
//                              lead-ins on F1's +X face: at (y ±15.25, z 4) and (y ±6, z -9.201)
//     V1  voids ×2             sealed, about 0.38 x 0.65 x 6.25, beside the ±120 deg lobes' P1 side
//                              planes, x -5.75 .. -5.37 ("previous" only)
//
// FITS (revised). B1 and M1 are fastener clearances, N1 and M1's traps nut pockets: all at FIT_SLIP
// (B1 fit_bore(3) for the M3 bolts, N1 the M3 nut's 5.5 AF x 2.4, M1 fit_bore(2) and the M2 nut's 4 AF).
// S1 takes an XL-320 (C-102), a bought part: its section is ../c102_servo.scad's outline and pads,
// grown by FIT_PRESS. D1 and P1 take nothing the catalog sizes, so they stay as drawn.

include <../print_fit.scad>
use <../c102_servo.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 240;
LAP = 0.005;
BIG = 100;

// --- placement helpers --------------------------------------------------------------------------

// A 2D shape in (y, z) swept along X from x0 to x1.
module along_x(x0, x1) translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children();
// A 2D shape in (x, z) swept along Y, centred on y 0.
module along_y(h = 2 * BIG) rotate([90, 0, 0]) linear_extrude(h, center = true) children();

// --- H1 hub and L1 lobes --------------------------------------------------------------------------

HUB   = [[0, -11.500], [20.000, -11.500], [20.000, -2.500], [18.500, -1.000], [18.500, 12.500],
         [11.000, 20.000], [0, 20.000]];
CONE  = 31.000;                         // the top cone: r + z = 31
BACK  = -14.040;                        // where the hub meets the channel
UNDER = -6.500;                         // the channel's underside

LOBES      = [0, 120, 240];
LOBE_END   = [23.650, 2.900];           // end face: distance out, half-width
LOBE_SIDE  = [[23.621, 2.900], [16.677, 8.007]];
LOBE_CHAMF = 31.650;                    // the chamfer under the end: u - z <= 31.65

function side_v(u) = let(p = LOBE_SIDE[0], q = LOBE_SIDE[1]) p[1] + (p[0] - u) * (q[1] - p[1]) / (p[0] - q[0]);

module lobe() let(e = LOBE_END, s = LOBE_SIDE[0][0]) intersection() {
    translate([0, 0, HUB[0][1]]) linear_extrude(HUB[6][1] - HUB[0][1])
        polygon([[e[0], -e[1]], [e[0], e[1]], [s, e[1]], [5, side_v(5)], [5, -side_v(5)], [s, -e[1]]]);
    along_y() polygon([[-BIG, -BIG], [LOBE_CHAMF - BIG, -BIG], [LOBE_CHAMF + BIG, BIG], [-BIG, BIG]]);
}

module top_cone() rotate_extrude() polygon([[0, -BIG], [CONE + BIG, -BIG], [0, CONE]]);

module hub() union() {
    intersection() {
        rotate_extrude() polygon(HUB);
        union() {
            translate([BACK, -BIG, -BIG]) cube(2 * BIG);
            translate([-BIG, -BIG, -BIG]) cube([2 * BIG, 2 * BIG, BIG + UNDER]);
        }
    }
    intersection() {
        for (a = LOBES) rotate(a) lobe();
        translate([BACK, -BIG, -BIG]) cube(2 * BIG);
        top_cone();
    }
}

// --- C1 channel and G1 tongue -----------------------------------------------------------------------

CHANNEL = [[-38.040, -11.040], 14.000, 20.000];      // x range, half-width, top
TONGUE  = [5.500, 25.500, 17.100];                    // top half-width, |y| + z bound, where it dives in

module channel() let(x = CHANNEL[0]) translate([x[0], -CHANNEL[1], UNDER])
    cube([x[1] - x[0], 2 * CHANNEL[1], CHANNEL[2] - UNDER]);

// G1 fills between the rim's x -11.04 face and the cone; its foot lies inside the hub.
module tongue() let(w = TONGUE[0], k = TONGUE[1], z0 = TONGUE[2]) along_x(CHANNEL[0][1] - LAP, -9.400)
    polygon([[z0 - k, z0], [-w, CHANNEL[2]], [w, CHANNEL[2]], [k - z0, z0]]);

// --- F1 flange plate and F2 ring ------------------------------------------------------------------

FLANGE  = [[0, 4.000], 19.500, 15.500, 20.000];      // axis (y, z), radius, flats at |y|, top
PLATE_X = [-41.740, -38.040];
RING_X  = [-45.740, -41.740];
WINDOW  = 9.500;                                      // F1's U-window radius
BAYONET = [16.500, 12.500, [18.000, 14.850, 0.766, 0.643], [17.500, 14.660, 0.903, 0.429], 1.000];
EAR     = [[-42.119, 18.500], [-44.240, 16.379], 1.500];   // F2's ear rounds (x, z), radius

// R19.5 about the axis, squared off above it to |y| 15.5, cut at the top.
module flange_2d() intersection() {
    union() {
        translate(FLANGE[0]) circle(r = FLANGE[1]);
        translate([-FLANGE[2], FLANGE[0].y]) square([2 * FLANGE[2], BIG]);
    }
    translate([-BIG, -BIG]) square([2 * BIG, BIG + FLANGE[3]]);
}

module window_2d() translate(FLANGE[0]) { circle(r = WINDOW); translate([-WINDOW, 0]) square([2 * WINDOW, BIG]); }

// F2's bore about the flange axis: R16.5, open above between |y| 12.5, a notch at each side out to R18
// between faces n.(|y|, |z|) = 14.85, and one below out to R17.5 between n.(|y|, -z) = 14.66; the
// notches' outer corners R1.
module bayonet_2d() let(b = BAYONET, s = b[2], d = b[3]) translate(FLANGE[0])
    offset(r = b[4], $fn = 96) offset(delta = -b[4]) union() {
        circle(r = b[0]);
        translate([-b[1], 0]) square([2 * b[1], BIG]);
        intersection() {
            circle(r = s[0]);
            polygon([[0, -4.1], [(s[1] - 4.1 * s[3]) / s[2], -4.1], [s[1] / s[2], 0],
                [(s[1] - 4.1 * s[3]) / s[2], 4.1], [0, 4.1]]);
        }
        mirror([1, 0]) intersection() {
            circle(r = s[0]);
            polygon([[0, -4.1], [(s[1] - 4.1 * s[3]) / s[2], -4.1], [s[1] / s[2], 0],
                [(s[1] - 4.1 * s[3]) / s[2], 4.1], [0, 4.1]]);
        }
        intersection() {
            circle(r = d[0]);
            polygon([[-(d[1] - 12 * d[3]) / d[2], -12], [(d[1] - 12 * d[3]) / d[2], -12],
                [(d[1] - 20 * d[3]) / d[2], -20], [-(d[1] - 20 * d[3]) / d[2], -20]]);
        }
    }

// F2's ears, seen along Y: flat to x -42.119, R1.5, 45 deg, R1.5 into the -X face at z 16.379.
module ear_2d() hull() {
    for (c = [EAR[0], EAR[1]]) translate(c) circle(r = EAR[2], $fn = 96);
    translate([RING_X[0], -BIG]) square([RING_X[1] - RING_X[0] + LAP, BIG]);
    translate([RING_X[1], FLANGE[3] - LAP]) square(LAP);
}

module flange() {
    along_x(PLATE_X[0] - LAP, PLATE_X[1]) difference() { flange_2d(); window_2d(); }
    intersection() {
        along_x(RING_X[0], RING_X[1]) difference() { flange_2d(); bayonet_2d(); }
        along_y() ear_2d();
    }
}

// --- cuts ---------------------------------------------------------------------------------------

// S1: the servo pocket's section across X, grown by c.
POCKET = [[12.000, 1.159], [11.572, 0.500], [10.500, 0.500], [10.500, -1.150], [8.591, -4.089]];
FLOOR  = [[6.914, -3.000], 2.000];      // the R2 corners' centre (|y|, z), radius

function arc(c, r, a0, a1, n = 24, i0 = 0) = [for (i = [i0 : n]) let(a = a0 + (a1 - a0) * i / n) c + r * [cos(a), sin(a)]];
// The R2 corner on the side s, from just past the 57 deg side's foot to the floor.
function corner(s) = let(c = FLOOR[0], p = POCKET[4], a0 = atan2(p.y - c.y, p.x - c.x))
    [for (q = arc(c, FLOOR[1], a0, -90, 24, 1)) [s * q.x, q.y]];

module servo_pocket_2d(c) offset(delta = c) polygon(concat(
    [[POCKET[0].x, BIG]], POCKET, corner(1),
    [for (q = reverse(corner(-1))) q], [for (i = [len(POCKET) - 1 : -1 : 0]) [-POCKET[i].x, POCKET[i].y]],
    [[-POCKET[0].x, BIG]]));
function reverse(v) = [for (i = [len(v) - 1 : -1 : 0]) v[i]];

// Revised, from the servo itself (../c102_servo.scad): its axis on the flange's and its near end down,
// so its (x, y) is this section's (y, FLANGE's z - z). Its outline, and above the ledge where its
// pads' near edges stand, the pads' width with the reference's lead-in chamfer onto them.
LEAD_IN = [0.428, 0.659];   // the chamfer from the ledge's outer corner up to the pads' width: in, up
module servo_section_2d() let(w = c102_case_dims()[0] + c102_pads()[0], ledge = FLANGE[0].y - c102_pads()[1][0][1]) union() {
    translate([0, FLANGE[0].y]) mirror([0, 1]) c102_outline_2d();
    polygon([[w - LEAD_IN[0], ledge], [w, ledge + LEAD_IN[1]], [w, BIG], [-w, BIG], [-w, ledge + LEAD_IN[1]],
             [LEAD_IN[0] - w, ledge]]);
}

module servo_pocket(cfg) let(c = fit_clearances(cfg)[1]) along_x(CHANNEL[0][0], BACK)
    if (cfg == "revised") offset(delta = c) servo_section_2d();
    else servo_pocket_2d(c);

// T1: the bore slot, and its gable truncated under the rim.
SLOT = [5.500, 7.000, 12.500, 11.898];

module slot_2d() polygon([[-SLOT[0], -BIG], [SLOT[0], -BIG], [SLOT[0], SLOT[1]], [0, SLOT[2]], [-SLOT[0], SLOT[1]]]);

module bore_slot() {
    along_x(CHANNEL[0][1], 0) slot_2d();
    along_x(BACK, CHANNEL[0][1] + LAP) intersection() { slot_2d(); translate([-BIG, -BIG]) square([2 * BIG, BIG + SLOT[3]]); }
}

// D1: Ø20 to z 14, a quarter round R5 into Ø10 to the top.
BORE = [10.000, 14.000, 5.000];

module bore() rotate_extrude() polygon(concat([[0, -BIG], [BORE[0], -BIG]],
    arc([BORE[0] - BORE[2], BORE[1]], BORE[2], 0, 90, 48), [[BORE[0] - BORE[2], BIG], [0, BIG]]));

// W1: the walls' holes.
WALL_HOLES = [[-19.740, -25.740, -31.740], 4.000, 4.000];

module wall_holes() for (x = WALL_HOLES[0]) translate([x, 0, WALL_HOLES[2]]) rotate([90, 0, 0])
    cylinder(d = WALL_HOLES[1], h = 2 * BIG, center = true);

// P1, N1, B1 in a lobe's frame (u out along it, v across, z up).
POCKET_U = [12.750, 15.650, 2.900];
NUT      = [18.300, 2.400, 5.500, [2.500, 5.600]];   // centre u, M3 nut thickness, AF, reference slot
NUT_TOP  = 7.000;
BOLT     = [3.000, 0.171, -1.250, 3.000];             // reference Ø, v, z, M3 nominal

function nut_slot(cfg) = cfg == "revised"
    ? let(c = fit_clearances(cfg)[0]) [NUT[1] + 2 * c, NUT[2] + 2 * c] : NUT[3];

module lobe_cuts(cfg) let(p = POCKET_U, n = nut_slot(cfg),
        d = cfg == "revised" ? fit_bore(BOLT[3], fit_clearances(cfg)[0]) : BOLT[0]) {
    translate([p[0], -p[2], -BIG]) cube([p[1] - p[0], 2 * p[2], 2 * BIG]);
    translate([NUT[0] - n[0] / 2, -n[1] / 2, -BIG]) cube([n[0], n[1], BIG + NUT_TOP]);
    translate([p[1] - LAP, BOLT[1], BOLT[2]]) rotate([0, 90, 0]) cylinder(d = d, h = BIG, $fn = 96);
}

// P1's rims; where the ears' rims reach the channel's rim (x -11.04) its face stands instead.
module rims() intersection() {
    for (a = LOBES) rotate(a) rim_round();
    translate([CHANNEL[0][1], -BIG, -BIG]) cube(2 * BIG);
}

// P1's rim: each wall's top edge rounded R0.6 onto the cone by a rolling ball, the stations' corner
// wedges less the balls' sweep. Along a wall its own round cuts; beyond a corner, where the material
// wraps round the pocket, only what both walls' rounds (run on past it) would cut is cut, which leaves
// the short steps the STEP shows on the walls' planes there.
RIM = [0.600, 0.400, 1.200];            // radius, station spacing, run past the corners

function ball(w, m) = let(h = w + RIM[0] * m) [h.x, h.y, CONE - RIM[0] * sqrt(2) - norm(h)];
function on_cone(w, m) = let(c = ball(w, m), h = [c.x, c.y] / norm([c.x, c.y]))
    c + RIM[0] / sqrt(2) * [h.x, h.y, 1];
function wedge(w, m) = let(c = ball(w, m), e = [w.x, w.y, CONE - norm(w)])
    [e + 0.05 * [-m.x, -m.y, 1], [w.x - 0.01 * m.x, w.y - 0.01 * m.y, c.z - 0.01], on_cone(w, m) + [0, 0, 0.01]];

// The convex hull of points, each a 0.01 mm cube (a polyhedron hull leaves debris on Manifold).
module dots(pts) hull() for (p = pts) translate(p) cube(0.01, center = true);

module rolled(w0, w1, m) let(n = ceil(norm(w1 - w0) / RIM[1])) for (i = [0 : n - 1])
    let(a = w0 + (w1 - w0) * i / n, b = w0 + (w1 - w0) * (i + 1) / n) difference() {
        dots(concat(wedge(a, m), wedge(b, m)));
        hull() for (q = [a, b]) translate(ball(q, m)) sphere(r = RIM[0], $fn = 32);
    }

function dir(w) = (w[1] - w[0]) / norm(w[1] - w[0]);

// A wall [from, to, material normal]'s round, run on past both its corners.
module wall_round(w) let(d = dir(w)) rolled(w[0] - RIM[2] * d, w[1] + RIM[2] * d, w[2]);

module prism(pts) translate([0, 0, -BIG]) linear_extrude(2 * BIG) polygon(pts);

// Walls in order round the pocket, each with its material normal.
function rim_walls() = let(p = POCKET_U, a = [p[0], -p[2]], b = [p[0], p[2]], c = [p[1], p[2]], d = [p[1], -p[2]])
    [[a, b, [-1, 0]], [b, c, [0, 1]], [c, d, [1, 0]], [d, a, [0, -1]]];

module rim_round() let(ws = rim_walls()) for (i = [0 : 3]) let(w = ws[i], v = ws[(i + 1) % 4], c = w[1],
        d = dir(w), e = dir(v)) {
    intersection() {                                                 // along the wall
        wall_round(w);
        prism([w[0] - 3 * w[2], w[0] + 3 * w[2], w[1] + 3 * w[2], w[1] - 3 * w[2]]);
    }
    intersection() {                                                 // round the corner after it
        wall_round(w);
        wall_round(v);
        prism([c, c + 3 * d, c + 3 * d - 3 * e, c - 3 * e]);
    }
}

// M1: the M2 holes and their hex nut traps, a 0.5 x 45 deg lead-in on F1's +X face.
M2_HOLES = [[[15.250, 4.000], 0], [[-15.250, 4.000], 0], [[6.000, -9.201], 24.150], [[-6.000, -9.201], -24.150]];
M2       = [2.100, 2.000, 4.000, 0.500, -40.040, -37.091];   // reference Ø, M2 nominal, nut AF, lead-in, trap x

function hex_r(af) = af / sqrt(3);

module hex_2d(af, a) rotate(a) circle(r = hex_r(af), $fn = 6);

module m2_traps(cfg) let(c = fit_clearances(cfg)[0], rev = cfg == "revised",
        d = rev ? fit_bore(M2[1], c) : M2[0], af = rev ? M2[2] + 2 * c : M2[2]) for (h = M2_HOLES)
        let(side = abs(h[0].x) > 10) {
    along_x(RING_X[1] - 1, M2[4] + LAP) translate(h[0]) circle(d = d, $fn = 96);
    // The side traps run on into the channel's walls, and their lead-ins skip the two edges that
    // run into them; the lower traps' lead-ins stop at the channel's underside.
    along_x(M2[4], side ? M2[5] : PLATE_X[1]) translate(h[0]) hex_2d(af, h[1]);
    if (side) intersection() {
        lead_in(h, af);
        along_x(-BIG, BIG) translate(h[0]) scale([sign(h[0].x), 1]) let(r = hex_r(af), t = 10)
            polygon([[-r, 0], [-r + t / sqrt(3), t], [t, t], [t, -t], [-r + t / sqrt(3), -t]]);
    } else difference() {
        lead_in(h, af);
        translate([-BIG, -CHANNEL[1], UNDER]) cube([2 * BIG, 2 * CHANNEL[1], BIG]);
    }
}

module lead_in(h, af) hull() {
    along_x(PLATE_X[1] - M2[3], PLATE_X[1] - M2[3] + LAP) translate(h[0]) hex_2d(af, h[1]);
    along_x(PLATE_X[1] - LAP, PLATE_X[1]) translate(h[0]) hex_2d(af + 2 * M2[3], h[1]);
}

// V1: the STEP's two voids, sealed in the ears beside P1's side planes extended past the outer wall:
// each two steps in x, from y -15.6 / -15.75 to the plane, a 45 deg floor, to z 9.05 / 9.2 (shown on
// -Y; the +Y one is its mirror).
VOIDS = [[[-5.568, -5.368], -15.600, -12.150, 9.050], [[-5.745, -5.568], -15.750, -12.362, 9.200]];
VOID_PLANE = [[0.866, -0.500], 2.900];  // n.(x, y) >= 2.9

module voids() { void_pair(); mirror([0, 1, 0]) void_pair(); }

module void_pair() for (v = VOIDS) intersection() {
    along_x(v[0][0], v[0][1]) polygon([[v[1], v[3]], [v[1], v[2] - v[1]], [v[1] + 2, v[2] - v[1] - 2], [v[1] + 2, v[3]]]);
    translate([0, 0, -BIG]) linear_extrude(2 * BIG) let(n = VOID_PLANE[0], k = VOID_PLANE[1])
        polygon([[k * n.x - BIG * n.y, k * n.y + BIG * n.x], [k * n.x + BIG * n.y, k * n.y - BIG * n.x],
            [(k + 5) * n.x + BIG * n.y, (k + 5) * n.y - BIG * n.x], [(k + 5) * n.x - BIG * n.y, (k + 5) * n.y + BIG * n.x]]);
}

// --- the part -----------------------------------------------------------------------------------

module tool_interface_body(cfg = config) difference() {
    union() {
        hub();
        channel();
        tongue();
        flange();
    }
    servo_pocket(cfg);
    bore_slot();
    bore();
    wall_holes();
    for (a = LOBES) rotate(a) lobe_cuts(cfg);
    rims();
    m2_traps(cfg);
    if (cfg == "previous") voids();
}

tool_interface_body();
