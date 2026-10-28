// #911-001 Roll Body — parametric source.
// The roll axis's housing: two 6703 bearings pressed into its ring carry the Roll Driver, and its
// block bolts to the roll XL-320 (specs/008.11 steps 4, 8 and 22-23).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/900-ToolInterface/911-001_RollBody.stl), in that mesh's
//                         frame. There is no STEP or f3d of this part; the glTF's `TI1-200-001_RollBody
//                         v4` is another revision (36 x 46.5 where the STL is 33 x 45.5).
//   config = "revised"  — the same part with print fits on the bearing seats and the bolts' holes.
//
// FRAME. The reference's own: the roll axis on +Z through the origin, the ring from z 3.5 to 16.5, the
// block toward -Y.
//
// A region split (mesh-to-scad rung 8), with the windows' and the slot's rounds lofted by
// 100-Base/window_round.scad. Measured with scadmesh slice/arcs/planes/solid/pattern; the feature IDs are
// those of 911-001_RollBody.view.json:
//
//     ID  feature              value
//     R1  ring                 OD 33.0, z 3.5 .. 16.5
//     S1  bearing seats ×2     Ø23.0, z 3.5 .. 7.5 and 12.5 .. 16.5 (the 6703s, 4 wide)
//     S2  shoulder             Ø20.0, z 7.5 .. 12.5
//     W1  windows ×7           Ø4.0 on radial axes at z 10, on 10 + 40k deg for k = 0 .. 5 and on
//                              330 deg; edges rounded R1 on R1's outside and on S2
//     B1  block                x ±12.5, down to y -23.743, then chamfers onto R4 corners at
//                              (±6.917, -25.004) and the end y -29; z 0 .. 16.5, where below the
//                              ring (z < 3.5) it stops at y -16
//     E1  slot                 an ellipse 13.93 x 5.76 (semi-axes 6.965, 2.88) at (0, -17.25),
//                              through; its edges rounded R1.5 on B1's top (z 16.5) and underside
//                              (z 0), and on R1's underside (z 3.5) where it leaves it; below the
//                              ring, B1's edge y -16 meets it in vertical R1.5 rounds, which run up
//                              under R1's round and end below in R1.5 balls; that edge is rounded
//                              R1.5 onto B1's underside
//     F1  foot rim             z -2 .. 0: B1's outline less its 2 mm inward offset, up to y -16
//     P1  bosses ×3            Ø5.0, z -0.5 .. 0, under H1
//     H1  bolt holes ×3        Ø2.0 at (0, -24) and (±6, -24), through; counterbored Ø4.0 from
//                              z 13.5
//
// FITS (revised). S1 takes the 6703s (C-404, 17 x 23 x 4), pressed: fit_bore(23, FIT_PRESS) = Ø23.1.
// H1 takes the M2 x 12 bolts and its counterbores their heads (Ø3.8): fit_bore(2, FIT_SLIP) = Ø2.3 and
// fit_bore(3.8, FIT_SLIP) = Ø4.1. W1, E1, F1 and P1 keep the reference's sizes.

include <../print_fit.scad>
use <../100-Base/window_round.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or the block's 2D section above the ring's foot
layer = "part"; // [part, B1]

/* [Hidden] */
$fn = 144;
LAP = 0.005;               // regions overlap so Manifold joins them (no shared faces)
BIG = 60;

RING      = [16.500, 3.500, 16.500];   // R1: outer radius, bottom, top
SEAT      = [23.000, 7.500, 12.500];   // S1: diameter, inner ends of the two seats
SHOULDER  = 20.000;                    // S2

WINDOW    = [2.000, 10.000, 1.000];    // W1: radius, axis height, edge round
WINDOW_AT = [10, 50, 90, 130, 170, 210, 330];

BLOCK     = [12.500, -23.743, -16.000];      // B1: half-width, where its chamfers start, its edge below R1
BLOCK_CNR = [[6.917, -25.004], 4.000];       // B1's end corners, mirrored in x
SLOT      = [6.965, 2.880, -17.250];         // E1: semi-axes across (x) and along (y), centre y
SLOT_R    = 1.500;                           // E1's edge rounds
EDGE_R    = 1.500;                           // B1's edge rounds onto E1 below the ring

RIM       = [2.000, -2.000];                 // F1: wall, bottom z
BOSS      = [5.000, -0.500];                 // P1: diameter, bottom z
HOLES     = [[0, -24], [-6, -24], [6, -24]]; // H1
BOLT_D    = 2.000;                           // M2
HEAD_D    = 3.800;                           // M2 socket head
CBORE     = [4.000, 13.500];                 // H1's counterbore: the reference's diameter, floor z

// --- 2D ---------------------------------------------------------------------------------------------

module block_plan_2d(top = BIG) hull() {
    translate([-BLOCK.x, BLOCK.y]) square([2 * BLOCK.x, top - BLOCK.y]);
    for (s = [-1, 1]) translate([s * BLOCK_CNR[0].x, BLOCK_CNR[0].y]) circle(r = BLOCK_CNR[1]);
}

module slot_2d() translate([0, SLOT.z]) scale([SLOT.x, SLOT.y]) circle(r = 1, $fn = 240);

// B1 below the ring: up to y -16, less E1, the corners where E1 breaks the edge rounded.
module block_low_raw_2d() difference() { block_plan_2d(BLOCK.z); slot_2d(); }

module block_low_2d() let(near = [[-SLOT.x - 3, BLOCK.z - 3], [2 * SLOT.x + 6, 4]]) union() {
    difference() { block_low_raw_2d(); translate(near[0]) square(near[1]); }
    intersection() { offset(r = EDGE_R) offset(r = -EDGE_R) block_low_raw_2d(); translate(near[0]) square(near[1]); }
}

module rim_2d() difference() {
    block_plan_2d(BLOCK.z);
    offset(delta = -RIM.x) block_plan_2d(BLOCK.z + RIM.x + 1);
}

// --- solids -----------------------------------------------------------------------------------------

module ring_body() rotate_extrude() polygon([
    [SHOULDER / 2 - 1, RING.y], [RING.x, RING.y], [RING.x, RING.z], [SHOULDER / 2 - 1, RING.z]]);

module block_body() {
    translate([0, 0, -LAP]) linear_extrude(RING.y + 2 * LAP) block_low_2d();
    translate([0, 0, RING.y]) linear_extrude(RING.z - RING.y)
        difference() { block_plan_2d(0); circle(r = SHOULDER / 2); }
    translate([0, 0, RIM.y]) linear_extrude(-RIM.y + LAP) rim_2d();
}

// P1, added after E1's underside round, which stops on them.
module bosses(cfg) let(c = fit_clearances(cfg)) for (h = HOLES) translate([h.x, h.y, BOSS.y])
    difference() {
        cylinder(d = BOSS.x, h = -BOSS.y + LAP);
        translate([0, 0, -1]) cylinder(d = fit_bore(BOLT_D, c[0]), h = 3, $fn = 48);
    }

// --- cutters ----------------------------------------------------------------------------------------

module bore(cfg) let(c = fit_clearances(cfg), d = fit_bore(SEAT.x, c[1])) rotate_extrude() polygon([
    [0, RING.y - 1], [d / 2, RING.y - 1], [d / 2, SEAT.y], [SHOULDER / 2, SEAT.y],
    [SHOULDER / 2, SEAT.z], [d / 2, SEAT.z], [d / 2, RING.z + 1], [0, RING.z + 1]]);

W1 = [WINDOW.x, WINDOW.x, WINDOW.y, 0];

module windows() for (a = WINDOW_AT) rotate(a) {
    window_prism(W1, 0, RING.x + 5);
    window_round(W1, ["cyl", RING.x, 1], WINDOW.z);
    window_round(W1, ["cyl", SHOULDER / 2, -1], WINDOW.z);
}

// E1 in window_round's frame: its axis (the frame's x) along world z, across (y) along world x, and
// up (z) along world y.
E1 = [SLOT.x, SLOT.y, SLOT.z, 0];
SLOT_FRAME = [[0, 1, 0, 0], [0, 0, 1, 0], [1, 0, 0, 0], [0, 0, 0, 1]];

module slot() {
    multmatrix(SLOT_FRAME) {
        window_prism(E1, RIM.y - 1, RING.z + 1, 240);
        window_round(E1, ["plane", RING.z, 1], SLOT_R, 240);
    }
    // on B1's underside, kept off the bosses P1 below it
    intersection() {
        multmatrix(SLOT_FRAME) window_round(E1, ["plane", 0, -1], SLOT_R, 240);
        translate([-BIG, -BIG, -LAP]) cube([2 * BIG, 2 * BIG, BIG]);
    }
    // where E1 leaves R1's underside, above B1's edge; at B1's edge it runs on up the edge's rounds
    // (the slivers they take off B1's corners), which it bounds there
    intersection() {
        multmatrix(SLOT_FRAME) window_round(E1, ["plane", RING.y, -1], SLOT_R, 240);
        union() {
            translate([-BIG, BLOCK.z, 0]) cube([2 * BIG, BIG, BIG]);
            linear_extrude(RING.y + SLOT_R + 1) offset(delta = 0.05) union() {
                difference() { block_low_raw_2d(); block_low_2d(); }
                slot_2d();
            }
        }
    }
}

// B1's edge y -16 rounded R1.5 where it meets its underside, inside F1.
module edge_round() let(r = EDGE_R, w = BLOCK.x - RIM.x)
    translate([-w, 0, 0]) rotate([90, 0, 90]) linear_extrude(2 * w)
        difference() {
            translate([BLOCK.z - r, -1]) square([r + 1, r + 1]);
            translate([BLOCK.z - r, r]) circle(r = r, $fn = 72);
        }

// Where E1 breaks B1's edge below the ring, the edge's vertical round R1.5 (on axis c) meets the
// underside's rounds, and its foot is a ball of R1.5 on c. The ball is the material left in the
// wedge from c between the round's two tangent points, below the ball's centre.
function slot_pt(psi) = [SLOT.x * sin(psi), SLOT.z + SLOT.y * cos(psi)];
function slot_nrm(psi) = let(n = [sin(psi) / SLOT.x, cos(psi) / SLOT.y]) n / norm(n);
function slot_ball(psi) = slot_pt(psi) + EDGE_R * slot_nrm(psi);
// The psi in [lo, hi] on +X whose ball centre stands EDGE_R below B1's edge, by bisection.
function corner_psi(lo = 0, hi = 180, n = 50) = let(m = (lo + hi) / 2)
    n == 0 ? m : slot_ball(m).y > BLOCK.z - EDGE_R ? corner_psi(m, hi, n - 1) : corner_psi(lo, m, n - 1);

module corner_domes() let(psi = corner_psi(), c = slot_ball(psi), p = slot_pt(psi), r = EDGE_R)
    for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0]) difference() {
        translate([0, 0, -1]) linear_extrude(r + 1)
            polygon([c, c + 3 * [0, 1], c + 3 * (p - c) / r + 3 * [0, 1], c + 3 * (p - c) / r]);
        translate([c.x, c.y, r]) sphere(r = r, $fn = 72);
    }

module bolt_holes(cfg) let(c = fit_clearances(cfg)) for (h = HOLES) translate([h.x, h.y, 0]) {
    translate([0, 0, RIM.y - 1]) cylinder(d = fit_bore(BOLT_D, c[0]), h = RING.z - RIM.y + 2, $fn = 48);
    translate([0, 0, CBORE.y]) cylinder(d = cfg == "previous" ? CBORE.x : fit_bore(HEAD_D, c[0]), h = RING.z - CBORE.y + 1, $fn = 72);
}

module roll_body(cfg = config) union() {
    difference() {
        union() { ring_body(); block_body(); }
        bore(cfg);
        windows();
        slot();
        edge_round();
        corner_domes();
        bolt_holes(cfg);
    }
    bosses(cfg);
}

if (layer == "B1") difference() { block_low_2d(); for (h = HOLES) translate(h) circle(d = BOLT_D, $fn = 48); }
else roll_body();
