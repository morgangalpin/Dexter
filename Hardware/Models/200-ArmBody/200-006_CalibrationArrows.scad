// #200-006 Calibration Arrows — parametric source.
// A pointer clamped on a 5 mm D shaft by an M3 set screw, its arrow and post marking the shaft's angle
// against the joint's index for calibration. The build takes two.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/200-ArmBody/), in that mesh's frame.
//   config = "revised"  — the same part. Its fits wait for the arm body's assembly (below).
//
// FRAME. The reference's own: the shaft's axis on +Z through the origin, the underside at z = -1,
// the arrow pointing along -X.
//
// Measured from the reference with scadmesh profile/slice/arcs/solid. The feature IDs are those of
// 200-006_CalibrationArrows.view.json:
//
//     ID  feature           value                                         z span
//     D1  hub               Ø20.000                                       -1 .. 4.5
//     C1  cup               45 deg cone from Ø20 at z 4.5 to Ø30, then    4.5 .. 10.5
//                           a Ø30 flange from z 9.5
//     C2  recess            Ø15.000 with its floor at z 5, a 45 deg cone  5 .. 10.5
//                           from z 7.5 out to Ø21 at the top
//     A1  arm               10.000 wide on y = 0, out to x -26, then a    -1 .. 3
//                           45 deg point to x -31
//     A3  arm chamfers      2 x 2 at 45 deg on both long top edges, from  1 .. 3
//                           the hub to where they meet the point
//     A2  pointer post      arrowhead: tip (-31, 0), barbs (-29.414,      -1 .. 8
//                           ±1.586), heel x -28 1.000 either side
//     H1  D-bore            Ø5.000, its flat at x 2.000                   through to C2
//     N1  nut slot          x 3.750 .. 6.250, y ±2.750                    through to C2
//     S1  set-screw hole    Ø3.000 along +X, centre z 2.5, from the axis  -
//                           out through D1
//
// The derived volume closes on the mesh's 4192.6 mm³ (render.json's dist gate holds the shape).
//
// `layer = "base"` draws the 2D section at z 0 (A1, A2, D1 less H1 and N1), for the outline gate in
// render.json.
//
// FITS, deferred: H1 on the D shaft, N1 on the M3 nut and S1 on the set screw are settled with the
// arm body's assembly (armbody_assembly), so revised draws none yet.

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or the 2D section at z 0
layer = "part"; // [part, base]

/* [Hidden] */
$fn = 144;
epsilon = 0.01;

BOTTOM    = -1.000;
HUB       = [10.000, 4.500];                  // D1 radius, top of the cylinder
CUP       = [15.000, 9.500, 10.500];          // C1 flange radius, its underside, the top
RECESS    = [7.500, 5.000, 7.500];            // C2 radius, floor, start of its cone
ARM       = [5.000, -26.000, -31.000, 3.000]; // A1 half-width, end of the flats, point, top
ARM_CHAMFER = 2.000;                          // A3
POST      = [[-31.000, 0], [-29.414, 1.586], [-28.000, 1.000],
             [-28.000, -1.000], [-29.414, -1.586]];
POST_TOP  = 8.000;
BORE      = [5.000, 2.000];                   // H1 diameter, the flat's x
NUT       = [3.750, 6.250, 2.750];            // N1 x from, x to, half-width
SCREW     = [3.000, 2.500];                   // S1 diameter, centre z

// --- 2D sections ---------------------------------------------------------------
module arm_2d()
    polygon([[0, -ARM[0]], [ARM[1], -ARM[0]], [ARM[2], 0], [ARM[1], ARM[0]], [0, ARM[0]]]);

module bore_2d()
    intersection() { circle(d = BORE[0]); translate([-BORE[0], -BORE[0]]) square([BORE[0] + BORE[1], 2 * BORE[0]]); }

module nut_2d() translate([NUT[0], -NUT[2]]) square([NUT[1] - NUT[0], 2 * NUT[2]]);

module base_2d()
    difference() {
        union() { circle(r = HUB[0]); arm_2d(); polygon(POST); }
        bore_2d();
        nut_2d();
    }

// --- Part ------------------------------------------------------------------------
// A1 with its A3 chamfers: the plan outline extruded, cut by the chamfered (y, z) section run along X.
// The point's faces stay square, so the chamfers end where they meet them.
module arm()
    intersection() {
        translate([0, 0, BOTTOM]) linear_extrude(ARM[3] - BOTTOM) arm_2d();
        rotate([90, 0, 90]) translate([0, 0, ARM[2] - 1]) linear_extrude(-ARM[2] + 1)
            polygon([[-ARM[0], BOTTOM - 1], [ARM[0], BOTTOM - 1], [ARM[0], ARM[3] - ARM_CHAMFER],
                     [ARM[0] - ARM_CHAMFER, ARM[3]], [-ARM[0] + ARM_CHAMFER, ARM[3]],
                     [-ARM[0], ARM[3] - ARM_CHAMFER]]);
    }

// D1, C1 and C2 as one revolved profile, in (r, z).
module hub_and_cup()
    rotate_extrude() polygon([
        [0, BOTTOM], [HUB[0], BOTTOM], [HUB[0], HUB[1]], [CUP[0], HUB[1] + CUP[0] - HUB[0]],
        [CUP[0], CUP[2]], [RECESS[0] + CUP[2] - RECESS[2], CUP[2]], [RECESS[0], RECESS[2]],
        [RECESS[0], RECESS[1]], [0, RECESS[1]]]);

module calibration_arrows(cfg = config)
    difference() {
        union() {
            hub_and_cup();
            arm();
            translate([0, 0, BOTTOM]) linear_extrude(POST_TOP - BOTTOM) polygon(POST);
        }
        translate([0, 0, BOTTOM - epsilon]) linear_extrude(RECESS[1] - BOTTOM + 2 * epsilon) { bore_2d(); nut_2d(); }
        translate([0, 0, SCREW[1]]) rotate([0, 90, 0]) cylinder(d = SCREW[0], h = HUB[0] + 1, $fn = 48);
    }

if (layer == "base") base_2d();
else calibration_arrows();
