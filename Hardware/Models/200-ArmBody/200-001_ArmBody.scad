// #200-001 Arm Body — parametric source.
// L2's body at J2: a tube that takes the 6810s and the Pivot Stator Holder, with the L2 tube's socket
// in a box on each side, the four Stator Balancer slots, the belt directors' lug columns and the
// encoder flap (specs/004 § Arm, specs/008.5).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/200-ArmBody/), in that mesh's frame.
//   config = "revised"  — the same part, with the C column's lower plate filleted onto the +Y box as
//                         the D column's is, the -Y ear filleted onto its box as the +Y ear is, and
//                         the top and bottom edges of X1's sides rounded, and drawn at its print fits
//                         (below).
//
// FRAME. The reference's own: J2 on +Z through the origin, the bottom face at z = -7, the top at 91,
// the L2 tube's socket on ±Y and the lug columns on the +Y half.
//
// CONSTRUCTION, a region split (each region is drawn as 2D sections and extruded):
//   1. T1/P1, the tube with its four ears: arm_body_outline.scad's outline, full height.
//   2. X1, the boxes: the box section with its G1 fillets, extruded, cut by the C1 envelope, a cone
//      about Z top and bottom, so the chamfers come out as the cones they are. In revised, its top edge
//      is rounded (below).
//   3. W1, the windows: everything in the band but the boxes and the ±X pillars is cut away; the
//      pillars are the ears with their inner corners rounded R4 onto the bore.
//   4. F1, the encoder flap: a measured outline of tangent arcs, extruded.
//   5. The lug columns A-D: each plate is a 2D layer, extruded and unioned with the web between, and
//      each column's stepped hole is one revolved cutter, cut after (the lug sandwich).
//   6. N1, the collar: the outline grown 4.0 on the +Y half, flaring out at 45°.
//   7. Cuts: the bore (one revolved cutter), the slots, the socket, the tie holes and their nut traps.
//
// Measured from the reference with scadmesh slice/arcs/profile/solid/planes. The feature IDs are those
// of 200-001_ArmBody.view.json:
//
//     ID  feature                     value                                          z span
//     T1  tube                        R36.500 (arm_body_outline.scad)                -7 .. 91
//     P1  ears                        the K1 slots grown R4 (arm_body_outline.scad)  -7 .. 91
//     K1  Stator Balancer slots       10.000 x 4.000, r 33.516 .. 37.516             -7 .. 91
//     B1  bore                        Ø65.000                                        through
//     L1  lower ledge                 Ø56.000 (the 6810 seat below it, z -7 .. 0)    0 .. 4
//     L2  upper ledge                 Ø56.000, a 45° chamfer from Ø65 at z 44.5      49 .. 54
//     X1  boxes on ±Y                 |x| <= 20.000, face y ±48.533                  -7 .. 63.5
//     C1  box envelope                cones about Z: r <= z + 43.533, r <= 99.033 - z
//     G1  box fillets                 R5.000, the box walls onto T1
//     Q1  L2 tube socket              29.000 x 29.000, centre z 27.75, floor y ±37.516
//     M1  tie holes                   Ø2.000 along Y, x ±17.250, z 11.121 / 44.379  through
//     N2  nut traps                   hex 4.100 AF, corners on ±Z, on M1, the bore
//                                     out to y ±35.533
//     W1  windows                     between X1 and the ±X pillars                  14.5 .. 41
//     F1  encoder flap                outer edge R53.500 about Z, corners R7 on
//                                     r 46.5 at 139.6° and 162.3°, -X side radial
//                                     at 170.98°, +Y side tangent arcs (FLAP_ARCS)   -7 .. -1
//     H1  flap holes                  Ø3.000 x 2, counterbore Ø4.000 from z -2       -7 .. -1
//     H2  flap holes                  Ø1.000 x 2                                     -7 .. -1
//     A   lug column (-X)             plates z 55.75..60.25, 77.25..82.75, no web
//     B   lug column (+X)             plates z 65.75..70.25 (revised 65.05), 77.25..82.75, no web
//     C   lug column                  plates z 55.65..60.25, 68.25..72.35, web
//     D   idler column                plates z 55.65..60.25, 68.25..70.25, web
//     E1  post beside D, E2 beside C  the webs' outboard part, past the belt slot    60.25 .. 68.25
//     N1  collar                      the outline grown 4.000 on +Y, 45° flare       79.5 .. 84.5
//
// The lug columns. A and B are bosses R7.690 with a tab out to the tube whose top edge is tangent to
// the boss (y 22.335) and ends on a cylinder R11.370 at (±34.965, 33.705). C and D are bosses R7.990,
// each drawn as a hull: C's with an R4 circle at (-25.736, 42.941) whose tangent is the 45° edge
// x + y = 22.87, and the point where its other edge meets T1 at 135°; D's with the point where its
// right edge meets T1 at 45°, and its left edge, which runs down x = 16 to T1, with an R4 circle at
// (20, 45.549) filleted onto the left edge. The webs between the plates are the hulls less the belt
// slot y 42.547 .. 45.547 (which leaves E1 and E2 standing) and a clearance about the column, R8 at C
// and R11 at D. Each plate holds a Ø12 bearing pocket 3.5 deep from its outer face (4.5 on A and B's
// upper plates) and a Ø9 hole through the rest; D's upper plate has a Ø5 hole. `revised` opens A's lower
// pocket onto the face C's plate leaves over it, extends B's lower plate and pocket 0.7 down so its bearings stand as far
// apart as C's (16.7 between their outer faces, one Small Belt Director for both), and gives D's lower plate the same Ø5 hole as its upper.
//
// D's fill and the fillets. D's lower plate stands on a fill on the box (x 16..20, y to 42.4, from z 45,
// its +X end corner R2). The plate's x = 16 edge is relieved across the belt slot: a 45° line from
// the edge at z 57.65, then an R3.93 arc onto the underside, so the plate's end wall at y 42.4 stands
// to the arc, and the vertical edge where it meets x = 16 is rounded R1. Every concave edge between
// two of the bodies the column is made of is a fillet of that pair, R2. Each is a ball rolled along
// its edge and drawn as one skin of its section at stations along the edge (fillet_section), and the
// walls that one ball runs along without leaving the same floor are one skin, so no two skins meet at
// a corner:
//   - onto the box's cone: the x = 16 face, the corner round, the end wall and the fill's end round,
//     to the box's side;
//   - under the plate: from the x = 16 face round the corner round, along the end wall under the relief
//     (relief_at gives the floor there), round the end round, down the box's side and G1, and along
//     T1 to where the plate leaves it. Over the corner round's last 60° the floor's normal turns to the
//     face's own, so the fillet runs out where it meets the face, which is flush with the plate's edge
//     above.
// Both balls run round the corner round at R2, and meet on it as the reference's do. A section square to
// an edge that slopes along its wall touches the wall up the slope from its station, and beside the round
// that is past the round's start, off the wall. So near the corner each section is turned upright, into
// the vertical plane of the wall's normal (CORNER_EASE, upright_section). `revised` gives C the same fill
// and fillets, which `previous` leaves a 45° cone under C's plate. The fill's tip on the box's side is a
// 45° corner, rounded R0.5 (C_TIP), and the same upright sections run round it. A larger round pulls the
// tip in to where the fill stands less than a fillet's height above the cone, and the plate then
// overhangs the cone in a V.
//
// The +Y ear (P1) has its own fillet onto the box's cone, R1, along its whole outline: the R4 concave
// onto the tube, the R4 convex corner and the face (ear_fillet). The reference's -Y ear has none;
// `revised` gives it one, so the two ears match, and carries both ears' fillets on along the edge
// where the cone meets T1 (R2) to G1's tangent on T1.
//
// X1's side edges (revised). The top and bottom edges of each of the box's sides are rounded R2 by a ball
// rolled along them (box_round_cut). The front face keeps its edges sharp, as the reference's are, for
// whatever mounts on it, and each side's round ends flush on the face, so the face's four corners are
// rounded R2 and a plate on it rounds its corners to match. Along the bottom, and along the top on -Y, the
// round runs from G1 to the face; on G1 the edge meets T1, so the round (and at the top the ear's fillet
// along T1) fades to nothing over EXT_FADE to G1's tangent. On the top of +Y each side's round grows from
// nothing where the lug's fill leaves the box's side, where the edge turns into the concave one between
// the fill and the cone, to R2 short of the face.
//
// No skin ends in a cut face: each runs out where its faces meet tangent, fades to nothing where its
// edge turns from convex to concave (the ears' over EAR_TAPER, the -Y round and T1 fillets over
// EXT_FADE, the +Y side rounds along their sides), or ends on a wall it is flush with (X1's front face).
//
// The residuals, against the mesh with its one slit repaired (README § Known defects): `dist` is 0.46
// worst, where the x = 16 face's fillet leaves the tube, which the CAD blends and a ball's path does not.
// Sampled densely, the zone round D's corner peaks at 0.5, under the plate beside the fill's end round,
// and 98% of it is within 0.25. Elsewhere the worst is 0.37, at the foot of N1's flare.
//
// `layer = "<name>"` draws the part's section at one height, for the outline gates in render.json.
//
// FITS (../print_fit.scad), revised only, each at its mate's class:
//   press  B1's 6810 seats (Ø65.1): below L1, and from L2's top up through the collar, the way the upper
//          6810 is pressed in to L2 (008.5 step 1). The bore between the ledges stays Ø65. The Pivot
//          Stator Holder slides in above the upper 6810 and is drawn at the slip clearance to the
//          Ø65.1. The lug pockets on the MR128s (Ø12.1), Q1 on the
//          L2 tube (C-504, +0.05 per side)
//          the K1 slots on the Stator Balancers (4.0 x 10.0 round the 3.9 x 9.9 shank, as the reference has them:
//          a tapped-in press, though both are printed)
//   slip   D's Ø5 holes on the Idler Plug (Ø5.2), the
//          M1 tie holes (Ø2.3) and N2 nut traps (4.3 AF) on an M2 rod and nut
//   kept   the Ø9 holes, which are 0.5 per side to the Belt Directors' shanks, past the slip clearance
// Deferred: the flap's holes (H1, H2), whose fasteners the model does not yet place.

include <BOSL2/std.scad>
include <../print_fit.scad>
include <arm_body_outline.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or its section at one of the gated heights
layer = "part"; // [part, flap, body, window, plates, web, upper, top, none]

/* [Hidden] */
$fn = 180;
epsilon = 0.01;

Z          = [-7.000, 91.000];             // bottom, top
BORE_R     = 32.500;                        // B1
LEDGE_R    = 28.000;                        // L1, L2
L1         = [0.000, 4.000];
L2         = [44.500, 49.000, 54.000];      // chamfer start, underside, top
WINDOW     = [14.500, 41.000];
BOX        = [20.000, 48.533];              // half-width, face
BOX_CONE   = [43.533, 99.033];              // r = z + [0], r = [1] - z
BOX_FILLET = 5.000;                         // G1
SOCKET     = [14.500, 13.250, 42.250, 37.516];  // Q1 half-width, z bottom, z top, floor
TIE        = [17.250, [11.121, 44.379], 2.000];  // M1 x, z's, diameter
NUT        = [4.100, 35.533];               // N2 across flats, outer end
SLOT_Y_FLOOR = -5.250;                      // K1 on ±Y stops here; ±X runs the full height

FLAP_Z     = [-7.000, -1.000];
FLAP_OUTER = 53.500;
FLAP_SIDE  = 170.980;                       // the -X side's angle
// The +Y side and the corners, each [centre, radius, from, to] in degrees, in order.
FLAP_ARCS  = [
    [[-22.103, 36.167],  7.034,  -89.06, -128.91],   // fillet onto T1
    [[-13.538, 45.009], 19.323, -132.20, -142.04],
    [[-44.139, 21.125], 19.497,   37.99,   47.68],
    [[-35.430, 30.108],  7.005,   50.89,  139.60],   // corner
    [[  0.000,  0.000], FLAP_OUTER, 139.64, 162.32],
    [[-44.299, 14.125],  7.003,  162.36, FLAP_SIDE + 90]];  // corner, to the radial side
FLAP_HOLES = [[-36.620, 26.141], [-40.086, 20.443]];   // H1
FLAP_PINS  = [[-38.118, 33.882], [-48.632, 15.362]];   // H2
FLAP_HOLE  = [3.000, 4.000, -2.000];        // H1, its counterbore, the counterbore's floor
FLAP_PIN   = 1.000;                         // H2

COL_A = [-40.638, 14.634];
COL_B = [ 40.638, 14.634];
COL_C = [-33.029, 38.547];
COL_D = [ 34.968, 51.546];
AB_BOSS  = 7.690;
CD_BOSS  = 7.990;
AB_TAB_CUT = [[34.965, 33.705], 11.370];    // the cylinder A and B's tabs end on (x mirrors)
C_Q      = [[-25.736, 42.941], 4.000];
C_EDGE   = 22.870;                          // C's 45° edge, x + y
C_TUBE   = 135;                             // where C's other edge meets T1
D_Q      = [[20.000, 45.549], 4.000];
D_LEFT   = [16.000, 46.170];                // D's left edge runs down x = 16 from here
D_TUBE   = 45;                              // where D's right edge meets T1
D_Q_FILLET = [6.000, 4.000];                // lower plate, upper plate
D_TUBE_FILLET = 2.000;
D_FILL   = [16.000, 20.000, 45.000, 42.400, 2.000];  // under D's lower plate the box runs up to it:
                                            //   x [0]..[1], y to [3], from z [2]; its +X end corner R[4]
// The concave corners the reference fills where a plate or web meets the tube or an ear, each
// [point near it, radius, half-width of the window it applies in].
LUG_FILLETS = [[[27.00, 26.50], 2.00, 2.5], [[15.30, 33.80], 1.00, 1.5], [[-11.70, 34.60], 1.00, 1.5]];
// And on the lower plates alone, the pinhole between C's hull and A's tab piece where both meet T1,
// which the reference's slit (README § Known defects) has closed.
PINHOLE_FILLET = [[-25.70, 25.70], 0.30, 0.45];
// Across the belt slot, D's lower plate's edge on x = 16 is cut back: 45° from z [0] on the edge to
// [1], then round R[3] about [2] onto the underside.
D_RELIEF = [57.650, [16.840, 56.800], [19.600, 59.580], 3.930];
// The vertical edge where D's x = 16 face meets the end wall of its fill and of its relieved plate is
// rounded: radius, from z.
D_CORNER = [1.000, 50.000];
BELT_SLOT = [42.547, 45.547];               // y span through the webs
WEB_CLEAR = [8.000, 11.000];                // about C, about D
// The web corners the reference rounds, each [point near it, radius, half-width of the window it
// applies in]; its other corners are sharp. Two are where the clearance about C runs out along an
// edge nearly tangent to it, so the round ends the sliver between them.
WEB_ROUNDS = [[[-25.10, 41.85], 1.00, 1.5], [[35.80, 40.00], 1.00, 1.8], [[24.55, 46.20], 1.00, 1.5],
              [[-35.00, 30.40], 0.28, 2.0], [[-31.40, 46.30], 0.50, 2.5]];
C_BOSS   = [55.650, 57.650, 9.920];         // below z [1], C's lower plate is a 45° cone about C,
                                            //   R[2] at z [0]

// Plate z spans, and each column's hole as [z, radius] steps from the bottom up.
PLATES = [
    // column, z bottom, z top
    ["A", 55.750, 60.250], ["A", 77.250, 82.750],
    ["B", 65.750, 70.250], ["B", 77.250, 82.750],
    ["C", 55.650, 60.250], ["C", 68.250, 72.350],
    ["D", 55.650, 60.250], ["D", 68.250, 70.250]];
A_OPEN_Z = 55.650;                          // revised: A's pocket opens at C's lower plate face
B_OPEN_Z = 65.050;                          // revised: B's lower plate and pocket open here, so B's bearings stand as far apart as C's
WEB_Z  = [60.250, 68.250];                  // C's and D's webs
HOLES = [
    ["A", COL_A, [[55.750, 6.0], [59.250, 4.5], [60.250, 6.0], [77.250, 4.5], [78.250, 6.0], [84.500, 6.0]]],
    ["B", COL_B, [[65.750, 6.0], [69.250, 4.5], [70.250, 6.0], [77.250, 4.5], [78.250, 6.0], [84.500, 6.0]]],
    ["C", COL_C, [[55.650, 6.0], [59.150, 4.5], [60.250, 6.0], [68.250, 4.5], [68.850, 6.0], [72.350, 6.0]]],
    ["D", COL_D, [[55.650, 6.0], [59.150, 4.5], [60.250, 6.0], [68.250, 2.5], [70.250, 2.5]]]];
// `revised` changes two columns' steps. A's pocket opens at C's lower plate face, which `revised` draws
// over it; cut from A's own face, a 0.1 mm skin would close the pocket on -Z, and the bearing could not be
// pressed in from there as it is at B and C. D's lower plate takes the upper plate's Ø5 hole through,
// replacing its Ø12 pocket and Ø9 hole, so the Idler Plug passes through both plates and its head stands
// on the upper one.
function column_steps(h, cfg) =
    cfg == "previous" ? h[2]
  : h[0] == "A" ? concat([[A_OPEN_Z, h[2][0][1]]], [for (i = [1 : len(h[2]) - 1]) h[2][i]])
  : h[0] == "B" ? concat([[B_OPEN_Z, h[2][0][1]], [B_OPEN_Z + h[2][1][0] - h[2][0][0], h[2][1][1]]], [for (i = [2 : len(h[2]) - 1]) h[2][i]])
  : h[0] == "D" ? concat([[h[2][0][0], h[2][3][1]]], [for (i = [2 : len(h[2]) - 1]) h[2][i]])
  : h[2];

// The fits (print_fit.scad): the Ø12 pockets are the MR128s' seats at the press clearance, and D's Ø5 holes
// take the Idler Plug's tube (Ø4.9, the MR85's bore at the press clearance) at the slip clearance. The
// Ø9 holes keep their 0.5 per side to the Belt Directors' Ø8 shanks, past the slip clearance, and the web's
// R6 about D is not a seat. `previous` draws every clearance as zero, so its steps are the reference's.
function slip(cfg)  = fit_clearances(cfg)[0];
function press(cfg) = fit_clearances(cfg)[1];
POCKET_D = 12.000;                          // the MR128's outer race
PLUG_D   = 5.000;                           // the MR85's bore, which the Idler Plug's tube takes
function pocket_r(cfg)   = fit_bore(POCKET_D, press(cfg)) / 2;
function plug_hole_r(cfg) = fit_bore(fit_pin(PLUG_D, press(cfg)), slip(cfg)) / 2;
function hole_steps(h, cfg) = [for (s = column_steps(h, cfg))
    [s[0], s[1] == 6.0 && h[0] != "D" ? pocket_r(cfg) : s[1] == 2.5 ? plug_hole_r(cfg) : s[1]]];

COLLAR   = [79.500, 83.500, 84.500, 4.000];  // flare start, flare end, top, growth

// --- Helpers -----------------------------------------------------------------------------------
module closing(r) offset(r = -r) offset(delta = r) children();
module opening(r) offset(r = r) offset(r = -r) children();
function arc_pts(c, r, a0, a1, n = 24) = [for (i = [0 : n]) c + r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];
function tube_pt(a) = ARM_BODY_R * [cos(a), sin(a)];

// --- T1/P1, X1, W1 -----------------------------------------------------------------------------
module boxes_2d() for (s = [-1, 1]) translate([-BOX[0], s > 0 ? 0 : -BOX[1]]) square([2 * BOX[0], BOX[1]]);

module box_section_2d() closing(BOX_FILLET) union() { circle(r = ARM_BODY_R); boxes_2d(); }

module envelope()
    rotate_extrude() polygon([[0, Z[0] - 1], [Z[0] - 1 + BOX_CONE[0], Z[0] - 1],
        [(BOX_CONE[0] + BOX_CONE[1]) / 2, (BOX_CONE[1] - BOX_CONE[0]) / 2],
        [0, BOX_CONE[1]]]);

// Revised only: the top and bottom edges of X1's sides are rounded BOX_ROUND by a ball rolled along each,
// cut as a skin of its sections (round_section) at stations [plan point, outward normal, radius]. The front
// face (y = ±BOX[1]) keeps its own edges sharp: each side's round runs on past the face, into the air, and
// ends flush on it, which leaves the face's corners rounded BOX_ROUND for a plate on it to match. Along the
// bottom, and along the top on -Y, the round runs from G1 to the face; on G1 the edge runs into T1, and so
// does the round, which ends inside the tube. On the top of +Y each side's round grows from nothing where the
// lug's fill leaves the box's side to BOX_ROUND short of the face: there the convex edge turns into the
// concave one between the fill and the cone, and neither blend has any size where they meet.
BOX_ROUND = 2.000;
// A convex edge's round, as the material it takes: the ball's centre, inside, at r from both faces, and
// the arc between where it touches them, closed past the edge E. na and nb are the faces' normals into the air.
function round_section(E, na, nb, r) =
    let(c = E - unit3(na + nb) * r / cos(acos(na * nb) / 2))
    concat([E + FILLET_IN * (na + nb), c + (r + FILLET_IN) * nb],
           [for (i = [0 : FILLET_ARC]) c + r * unit3(nb + (na - nb) * i / FILLET_ARC)],
           [c + (r + FILLET_IN) * na]);
function with_r(st, r) = [for (s = st) [s[0], s[1], r]];
// On -Y the round fades to nothing over the ear fillet's EXT_FADE to G1's tangent on T1, where that fillet does.
function g1_faded(st) = [for (s = st) let(t = g1_centre(sign(s[0].x)) * ARM_BODY_R / (ARM_BODY_R + BOX_FILLET))
    [s[0], s[1], BOX_ROUND * max(0.025, smooth01(norm(s[0] - t) / EXT_FADE))]];
// The +Y box's side s from where its lug's fill leaves it, y_end, the round growing to BOX_ROUND at y0.
function side_taper_stations(s, y_end, n = 16) = let(y0 = BOX[1] - BOX_ROUND)
    [for (i = [0 : n]) let(y = y_end + (y0 - y_end) * i / n) [[s * BOX[0], y], [s, 0], BOX_ROUND * max(0.025, smooth01(i / n))]];
// The box's side s on +Y or -Y, ending 1 past the face.
function box_side_stations(s, plus_y) = let(t = atan2(g1_centre(1).y, g1_centre(1).x), y1 = BOX[1] + 1,
        past = [[[s * BOX[0], y1], [s, 0], BOX_ROUND]])
    plus_y ? concat(side_taper_stations(s, s < 0 ? c_tip_centre().y : D_FILL[3] - D_FILL[4]), past)
           : concat(g1_faded(reverse(side_to_tube_stations(s, y1, s < 0 ? 180 - t + 3 : t - 3))), past);
module box_round_cut() for (m = [0, 1], sx = [-1, 1]) mirror([0, m, 0]) {
    fillet_skin([for (s = box_side_stations(sx, m == 0)) let(p = s[0])
        round_section([p.x, p.y, cone_z(p)], [s[1].x, s[1].y, 0], cone_n(p), s[2])]);
    fillet_skin([for (s = box_side_stations(sx, false)) let(p = s[0])
        round_section([p.x, p.y, base_z(p)], [s[1].x, s[1].y, 0], base_n(p), s[2])]);
}

module pillars_2d() for (a = [0, 180]) rotate(a) opening(ARM_BODY_EAR[2]) difference() { arm_body_ear_2d(); circle(r = BORE_R); }

module window_cut()
    translate([0, 0, WINDOW[0]]) linear_extrude(WINDOW[1] - WINDOW[0])
        difference() { circle(r = 2 * BOX[1]); boxes_2d(); pillars_2d(); circle(r = BORE_R - 1); }

// --- F1 ----------------------------------------------------------------------------------------
module flap_2d()
    difference() {
        polygon(concat(
            [for (a = FLAP_ARCS) each arc_pts(a[0], a[1], a[2], a[3])],
            [tube_pt(FLAP_SIDE) * 0.9, [-20, 20]]));
        for (h = FLAP_HOLES) translate(h) circle(d = FLAP_HOLE[0], $fn = 48);
        for (h = FLAP_PINS) translate(h) circle(d = FLAP_PIN, $fn = 48);
    }

module flap()
    difference() {
        translate([0, 0, FLAP_Z[0]]) linear_extrude(FLAP_Z[1] - FLAP_Z[0]) flap_2d();
        for (h = FLAP_HOLES) translate([h[0], h[1], FLAP_HOLE[2]]) cylinder(d = FLAP_HOLE[1], h = FLAP_Z[1] - FLAP_HOLE[2] + epsilon, $fn = 48);
    }

// --- Lug columns -------------------------------------------------------------------------------
function col(n) = n == "A" ? COL_A : n == "B" ? COL_B : n == "C" ? COL_C : COL_D;

// A or B, drawn for A and mirrored for B: the boss; its tab in to the tube, under the boss's tangent
// y = c.y + AB_BOSS; and the piece under AB_TAB_CUT's arc, which runs until it meets a line through
// the tube: on A from the tube at 135° (T1) out to the arc, on B (mirrored here) from the tube at
// 135.8°, where its end blends in; or, where the plate meets the next column's (bound "C" or "D"),
// from T1 along that column's edge. ab_plate_2d is drawn on -X.
AB_TAB_END = [[[-25.810, 25.810], [-27.030, 25.515]], [[-26.130, 25.480], [-28.290, 24.500]]];
module ab_plate_2d(c, bound = "") mirror([c[0] > 0 ? 1 : 0, 0])
    let(a = [-abs(c[0]), c[1]], k = [-AB_TAB_CUT[0][0], AB_TAB_CUT[0][1]], t = tube_pt(C_TUBE),
        ends = AB_TAB_END[c[0] > 0 ? 1 : 0],
        t0 = bound == "" ? ends[0] : t,
        e = bound == "C" ? t + [-0.888, 0.459] : bound == "D" ? t + [-0.5965, 0.8027] : ends[1],
        d = (e - t0) / norm(e - t0))
    union() {
        translate(a) circle(r = AB_BOSS);
        translate([a[0], a[1] - AB_BOSS]) square([-a[0] - 20, 2 * AB_BOSS]);
        intersection() {
            difference() {
                translate([k[0], a[1] + AB_BOSS - epsilon]) square([t[0] - k[0], k[1] - a[1] - AB_BOSS]);
                translate(k) circle(r = AB_TAB_CUT[1]);
            }
            polygon([t0 - 100 * d, t0 + 100 * d, t0 + 100 * d - [0, 100], t0 - 100 * d - [0, 100]]);
        }
    }

module c_hull_2d()
    hull() {
        translate(COL_C) circle(r = CD_BOSS);
        translate(C_Q[0]) circle(r = C_Q[1]);
        translate(tube_pt(C_TUBE)) square(0.01, center = true);
        translate([-4, C_EDGE + 4]) square(0.01, center = true);
    }

module d_hull_2d(fillet)
    closing(fillet) union() {
        hull() {
            translate(COL_D) circle(r = CD_BOSS);
            translate(tube_pt(D_TUBE)) square(0.01, center = true);
            translate([D_LEFT[0], 28]) square(0.01, center = true);
            translate(D_LEFT) square(0.01, center = true);
        }
        translate(D_Q[0]) circle(r = D_Q[1]);
        translate([D_LEFT[0], 28]) square([D_Q[0][0] - D_LEFT[0], D_Q[0][1] - 28]);
    }

module plate_2d(n, z0)
    if (n == "A") ab_plate_2d(COL_A);
    else if (n == "B") ab_plate_2d(COL_B, z0 < WEB_Z[1] ? "D" : "");
    else fill_at(z0 < WEB_Z[0] ? concat(LUG_FILLETS, [PINHOLE_FILLET]) : LUG_FILLETS) union() {
        arm_body_outline_2d();
        if (n == "C") { c_hull_2d(); if (z0 < WEB_Z[0]) ab_plate_2d(COL_A, "C"); }
        else d_hull_2d(z0 < WEB_Z[0] ? D_Q_FILLET[0] : D_Q_FILLET[1]);
    }

// Fills the concave corners of the children near each point only.
module fill_at(fills) {
    children();
    for (c = fills) intersection() { closing(c[1]) children(); translate(c[0]) square(2 * c[2], center = true); }
}

// Rounds the convex corners of the children near each point only, leaving the rest sharp.
module round_at(rounds) {
    difference() { children(); for (c = rounds) translate(c[0]) square(2 * c[2], center = true); }
    for (c = rounds) intersection() { opening(c[1]) children(); translate(c[0]) square(2 * c[2], center = true); }
}

module web_2d()
    round_at(WEB_ROUNDS) difference() {
        fill_at(LUG_FILLETS) union() { arm_body_outline_2d(); c_hull_2d(); d_hull_2d(D_Q_FILLET[0]); }
        translate([-60, BELT_SLOT[0]]) square([120, BELT_SLOT[1] - BELT_SLOT[0]]);
        translate(COL_C) circle(r = WEB_CLEAR[0]);
        translate(COL_D) circle(r = WEB_CLEAR[1]);
    }

// In previous, C's lower plate stands on a cone about C below z C_BOSS[1]; revised draws it whole,
// on a fill and fillets onto the box as D's is.
module lugs(cfg) {
    for (p = PLATES) let(z0 = cfg == "previous" && p[0] == "C" && p[1] == C_BOSS[0] ? C_BOSS[1]
        : cfg == "revised" && p[0] == "B" && p[1] == PLATES[2][1] ? B_OPEN_Z : p[1])
        translate([0, 0, z0]) linear_extrude(p[2] - z0) plate_2d(p[0], p[1]);
    if (cfg == "previous") intersection() {
        translate([0, 0, C_BOSS[0]]) linear_extrude(C_BOSS[1] - C_BOSS[0] + epsilon) c_hull_2d();
        translate([COL_C[0], COL_C[1], C_BOSS[0]])
            cylinder(r1 = C_BOSS[2], r2 = C_BOSS[2] + C_BOSS[1] - C_BOSS[0] + epsilon, h = C_BOSS[1] - C_BOSS[0] + epsilon);
    }
    translate([0, 0, WEB_Z[0] - epsilon]) linear_extrude(WEB_Z[1] - WEB_Z[0] + 2 * epsilon) web_2d();
}

// The fill under D's lower plate, on the box: x [0]..[1], y to [3], its +X end corner R[4].
module d_fill_2d()
    hull() {
        translate([D_FILL[0], 0]) square([D_FILL[1] - D_FILL[0], D_FILL[3] - D_FILL[4]]);
        translate([D_FILL[0], 0]) square([epsilon, D_FILL[3]]);
        translate([D_FILL[1] - D_FILL[4], D_FILL[3] - D_FILL[4]]) circle(r = D_FILL[4], $fn = 48);
    }

// Revised only: C's fill on the box, the part of its lower plate over the box's slab, its tip on the box's
// side rounded C_TIP (below).
module c_lower_2d() union() { c_hull_2d(); ab_plate_2d(COL_A, "C"); }
module c_fill_2d() round_at([[C_TIP_PT, C_TIP, 4]])
    intersection() { c_lower_2d(); translate([-BOX[0], 0]) square([BOX[0], 2 * BOX[1]]); }

// --- Fillets of a lug onto the box's cone, the tube and each other -------------------------------------
// A fillet is the ball of radius FILLET_R that rolls in a concave edge between two faces. It is drawn as
// a skin of its section at stations along the edge. At a station the edge point E and the two faces'
// normals into the air, na and nb, fix the ball's centre, the two points it touches and the arc between
// them (fillet_section). The section's corner and the points either side of it are pushed a little into
// the bodies so that the fillet unions with them without coincident faces.
FILLET_R = 2.000;
FILLET_ARC = 24;                             // segments in the arc
FILLET_IN = 0.020;                           // overlap into the bodies

function unit3(v) = v / norm(v);
function fillet_section(E, na, nb, r) =
    let(c = E + unit3(na + nb) * r / cos(acos(na * nb) / 2))
    concat([E - FILLET_IN * (na + nb), c - (r + FILLET_IN) * na],
           [for (i = [0 : FILLET_ARC]) c - r * unit3(na + (nb - na) * i / FILLET_ARC)],
           [c - (r + FILLET_IN) * nb]);

// The sections, all of one length, joined end to end and capped, as one solid (BOSL2's vertex array).
// The faces are turned to face outward whichever way the stations run.
module fillet_skin(sections) let(vnf = vnf_vertex_array(sections, col_wrap = true, caps = true))
    vnf_polyhedron(vnf_volume(vnf) < 0 ? vnf_reverse_faces(vnf) : vnf, convexity = 4);

// The box's top cone, r = BOX_CONE[1] - z, and its normal into the air, at the plan point p.
function cone_z(p) = BOX_CONE[1] - norm(p);
function cone_n(p) = [p.x, p.y, norm(p)] / (norm(p) * sqrt(2));
// The box's bottom cone, r = z + BOX_CONE[0], and its normal into the air.
function base_z(p) = norm(p) - BOX_CONE[0];
function base_n(p) = [p.x, p.y, -norm(p)] / (norm(p) * sqrt(2));

// Stations, each [plan point, outward normal], along a lug's wall, in the order the walls run: D's
// x = D_FILL[0] face from the tube; its corner round R[0] of D_CORNER; the fill's end wall; the fill's
// end round R[4]; and the box's side x = D_FILL[1], which it follows back to the tube.
function tube_y(x, inside = 0) = sqrt(pow(ARM_BODY_R - inside, 2) - x * x);
FACE_IN = 0.5;                               // how far inside the tube the face fillet starts

function d_face_stations(n = 44) = let(y0 = tube_y(D_FILL[0], FACE_IN), y1 = D_FILL[3] - D_CORNER[0])
    [for (i = [0 : n - 1]) [[D_FILL[0], y0 + (y1 - y0) * i / n], [-1, 0]]];
function d_corner_stations(n = 16) = let(r = D_CORNER[0], c = [D_FILL[0] + r, D_FILL[3] - r])
    [for (i = [0 : n]) let(a = 90 * i / n) [c + r * [-cos(a), sin(a)], [-cos(a), sin(a)]]];
function d_end_stations(n = 3) = let(x0 = D_FILL[0] + D_CORNER[0], x1 = D_FILL[1] - D_FILL[4])
    [for (i = [1 : n - 1]) [[x0 + (x1 - x0) * i / n, D_FILL[3]], [0, 1]]];
// Both fillets run round the corner round at FILLET_R. A section square to an edge that slopes along its wall
// touches the wall up the slope from its station, and near the round that is past the round's start, off the
// wall. So within CORNER_EASE of the sharp corner v the section's plane is turned upright, by l from 0 to 1 on
// the round (whose points lie within r0 of v), from square to the edge to the vertical plane of the wall's
// normal, and the section is the circle in that plane tangent to both faces' traces (upright_section). On the
// round each section then touches the wall at its own station.
CORNER_EASE = 4.5;
function corner_l(p, v = [D_FILL[0], D_FILL[3]], r0 = D_CORNER[0]) = 1 - smooth01((norm(p - v) - r0) / (CORNER_EASE - D_CORNER[0]));
function in_plane(n, e) = unit3(n - (n * e) * e);
function upright_section(E, nw, nf, r, l) =
    let(t = [-nw.y, nw.x, 0], g = unit3(cross(nw, nf)), e = unit3((g * t < 0 ? -g : g) * (1 - l) + t * l))
    fillet_section(E, in_plane(nw, e), in_plane(nf, e), r);
function d_round_stations(n = 12) = let(r = D_FILL[4], c = [D_FILL[1] - r, D_FILL[3] - r])
    [for (i = [0 : n]) let(a = 90 * i / n) [c + r * [sin(a), cos(a)], [sin(a), cos(a)]]];
// The stations of a run along a wall, each [plan point, outward normal]: a straight run from p0 to p1,
// and an arc about c from angle a0 to a1, convex (s = 1, its normals away from c) or concave (s = -1).
// Each leaves out its first station, which the run before it ends on.
function run_stations(p0, p1, nrm, n) = [for (i = [1 : n]) [p0 + (p1 - p0) * i / n, nrm]];
function arc_stations(c, r, a0, a1, n, s = 1) =
    [for (i = [1 : n]) let(a = a0 + (a1 - a0) * i / n) [c + r * [cos(a), sin(a)], s * [cos(a), sin(a)]]];
// G1's centre on the side s; its tangent on T1 is at the centre's own angle about the axis.
function g1_centre(s) = let(x = BOX[0] + BOX_FILLET) [s * x, sqrt(pow(ARM_BODY_R + BOX_FILLET, 2) - x * x)];
// The box's side from y0, G1, and T1 out to angle a1 about the axis: the walls under a lug's plate
// beyond its fill, on the side s.
function side_to_tube_stations(s, y0, a1) = let(g = g1_centre(s), t = atan2(g.y, g.x))
    concat(run_stations([s * BOX[0], y0], [s * BOX[0], g.y], [s, 0], 12),
           arc_stations(g, BOX_FILLET, s > 0 ? 180 : 0, s > 0 ? t + 180 : t - 180, 12, -1),
           arc_stations([0, 0], ARM_BODY_R, t, a1, 24));

// The plate's underside across the belt slot at x, as [z, its normal into the air in x and z]: the
// relief's 45° line, its arc, and past the arc the underside itself.
function relief_at(x) = let(p1 = D_RELIEF[1], p2 = [D_FILL[0], D_RELIEF[0]], c = D_RELIEF[2], r = D_RELIEF[3],
        d = (p2 - p1) / norm(p2 - p1))
    x <= p1.x ? [p1.y + (x - p1.x) * d.y / d.x, [-d.y, d.x]]
  : x < c.x  ? let(a = -acos((x - c.x) / r)) [c.y + r * sin(a), [cos(a), sin(a)]]
  : [C_BOSS[0], [0, -1]];

// D's walls under its plate, in one skin: from the x = D_FILL[0] face round the corner round, along the end
// wall under the relief, round the end round, down the box's side and G1, and along T1 to where the
// plate leaves it. Each station is [plan point, outward normal, w]. On the corner round the floor's normal
// turns, with w, from the relief's to the face's own, so the fillet runs out where it meets the face,
// which is flush with the plate's edge above it.
RUNOUT_ARC = 60;                             // the turn takes the round's last RUNOUT_ARC degrees, to the face
FACE_RUNOUT = 0.03;                          // what is left of the floor's turn at the face, so no section is empty
function d_under_stations() =
    let(c1 = [D_FILL[0] + D_CORNER[0], D_FILL[3] - D_CORNER[0]], c2 = [D_FILL[1] - D_FILL[4], D_FILL[3] - D_FILL[4]])
    [for (s = concat([[c1 + D_CORNER[0] * [-1, 0], [-1, 0]]],
                     arc_stations(c1, D_CORNER[0], 180, 90, 18),
                     run_stations([c1.x, D_FILL[3]], [c2.x, D_FILL[3]], [0, 1], 4),
                     arc_stations(c2, D_FILL[4], 90, 0, 12),
                     side_to_tube_stations(1, c2.y, D_TUBE - 5)))
        let(a = atan2(s[1].y, s[1].x)) [s[0], s[1], s[0].x < c1.x ? max(FACE_RUNOUT, smooth01((180 - a) / RUNOUT_ARC)) : 1]];
function under_sections(st, floor, l = function(p) 0) = [for (s = st) let(p = s[0], f = floor(p.x), nf = [f[1].x, 0, f[1].y], nw = [s[1].x, s[1].y, 0])
    upright_section([p.x, p.y, f[0]], nw, unit3(nw + (nf - nw) * s[2]), FILLET_R, l(p))];
function smooth01(u) = let(v = min(1, max(0, u))) v * v * (3 - 2 * v);

// A wall onto the cone at a list of stations, turned upright by l (corner_l).
function cone_sections(st, l = function(p) 0) = [for (s = st) let(p = s[0], nw = [s[1].x, s[1].y, 0])
    upright_section([p.x, p.y, cone_z(p)], nw, cone_n(p), FILLET_R, l(p))];

// The plan of a lug's lower plate, through the height its fillets hang and climb in.
module plate_room(n) translate([0, 0, C_BOSS[0] - 2 * FILLET_R]) linear_extrude(D_RELIEF[0] - C_BOSS[0] + 3 * FILLET_R) plate_2d(n, C_BOSS[0]);

module d_fillets() {
    // the face, the corner round, the end wall and the end round onto the cone, in one skin, which stops
    // at the box's side
    intersection() {
        fillet_skin(cone_sections(concat(d_face_stations(), d_corner_stations(), d_end_stations(), d_round_stations()), function(p) corner_l(p)));
        translate([-100, -100, 0]) cube([100 + BOX[0], 200, 100]);
    }
    // the walls under the plate onto its underside and the relief, in one skin, which the plate's edge stops
    intersection() {
        fillet_skin(under_sections(d_under_stations(), function(x) relief_at(x), function(p) corner_l(p)));
        plate_room("D");
    }
}

// Revised only: C's fill stands on the box as D's does, its tip on the box's side rounded C_TIP, with the
// same fillets onto the cone and onto the plate's underside.
C_TIP = 0.500;
C_TIP_PT = [-BOX[0], C_EDGE + BOX[0]];        // the sharp tip, whose angle is 45°
function c_tip_centre() = let(u = unit3([1 / sqrt(2), -1 - 1 / sqrt(2), 0]))
    [C_TIP_PT.x + u.x * C_TIP / sin(22.5), C_TIP_PT.y + u.y * C_TIP / sin(22.5)];
function c_tip_l(p) = corner_l(p, C_TIP_PT, C_TIP / tan(22.5));
// C's 45° edge, x + y = C_EDGE, from the tube to the tip round, round it and a little way down the box's side.
function c_edge_stations(n = 24) = let(c = C_EDGE, rho = ARM_BODY_R - FACE_IN, k = c_tip_centre(),
        x0 = (c - sqrt(2 * rho * rho - c * c)) / 2, x1 = k.x + C_TIP * cos(45))
    concat([[[x0, c - x0], [1, 1] / sqrt(2)]], run_stations([x0, c - x0], [x1, c - x1], [1, 1] / sqrt(2), n),
           arc_stations(k, C_TIP, 45, 180, 24), run_stations([-BOX[0], k.y], [-BOX[0], k.y - 1], [-1, 0], 2));
// Under the plate: round the tip, down the box's side and G1, and along T1 past A's tab.
function c_under_stations() = let(k = c_tip_centre())
    [for (s = concat([[k + C_TIP * [1, 1] / sqrt(2), [1, 1] / sqrt(2)]], arc_stations(k, C_TIP, 45, 180, 24),
                     side_to_tube_stations(-1, k.y, 150))) [s[0], s[1], 1]];
module c_fillets() {
    intersection() {
        fillet_skin(cone_sections(c_edge_stations(), function(p) c_tip_l(p)));
        translate([-BOX[0], -100, 0]) cube([100, 200, 100]);
    }
    intersection() {
        fillet_skin(under_sections(c_under_stations(), function(x) [C_BOSS[0], [0, -1]], function(p) c_tip_l(p)));
        plate_room("C");
    }
}

module lug_fillets(n) if (n == "D") d_fillets(); else c_fillets();

// P1's ear on +Y stands out of the box's cone, and the reference rounds the edge between them R1 along
// the ear's whole outline: the concave R4 onto the tube, the convex R4 corner and the face. `revised`
// carries the fillet on along the edge where the cone meets T1, out to where the box's G1 fillet takes
// the tube over, on both ears; that stretch is EXT_R, and the fillet eases from it to EAR_R across the
// concave R4. `side` is the ear's x sign; the stations, each [plan point, normal, radius], run from
// the tube to the face's middle, and ear_fillet draws both sides as one skin. The face needs stations of
// its own: the cone bows up 0.3 above a straight line between the corners, which would bury the fillet.
EAR_R = 1.000;                               // the ear fillet's radius
EXT_R = 2.000;                               // and along the cone's edge with the tube
EXT_FADE = 4 * EXT_R;                        // the length over which it fades out toward G1
// It stops at G1's tangent on T1, where X1's round (box_round_cut) runs into the tube, both fading to
// nothing over EXT_FADE to the same point.
function ext_end() = atan2(g1_centre(1).y, g1_centre(1).x);
function ear_path(s, ext, n = 10, m = 14, k = 24, f = 12) =
    let(R = ARM_BODY_EAR[2], h = ARM_BODY_EAR[1] + R, cx = h + R, cy = sqrt(pow(ARM_BODY_R + R, 2) - cx * cx),
        v = [ARM_BODY_EAR[1], ARM_BODY_EAR[0]], c = [cx, cy],
        a0 = atan2(-cy, -cx), a1 = atan2(v.y - cy, v.x - cx), b0 = atan2(cy - v.y, cx - v.x),
        t0 = atan2(c.y * ARM_BODY_R / (ARM_BODY_R + R), c.x * ARM_BODY_R / (ARM_BODY_R + R)))
    concat(
        ext ? [for (i = [0 : k - 1]) let(e = ext_end(), th = e + (t0 - e) * i / k)
            [[s * ARM_BODY_R * cos(th), ARM_BODY_R * sin(th)], [s * cos(th), sin(th)],
             EXT_R * max(0.025, smooth01((th - e) * PI / 180 * ARM_BODY_R / EXT_FADE))]] : [],
        [for (i = [0 : n]) let(a = a0 + (a1 - a0) * i / n, u = i / n)
            [[s * (c.x + R * cos(a)), c.y + R * sin(a)], [s * -cos(a), -sin(a)],
             ext ? EXT_R + (EAR_R - EXT_R) * u * u * (3 - 2 * u) : EAR_R]],
        [for (i = [1 : m]) let(b = b0 + (90 - b0) * i / m)
            [[s * (v.x + R * cos(b)), v.y + R * sin(b)], [s * cos(b), sin(b)], EAR_R]],
        with_r(run_stations([s * v.x, v.y + R], [0, v.y + R], [0, 1], f), EAR_R));
function ear_stations(ext) = let(l = ear_path(-1, ext), r = ear_path(1, ext))
    concat(l, [for (i = [len(r) - 2 : -1 : 0]) r[i]]);
// Without the run along T1, the ball's radius grows from nothing over the first stations at each end, so
// that the fillet fades out into the edge where the cone meets the tube, which the reference leaves sharp.
EAR_TAPER = 3;                               // stations over which the fillet grows from nothing
function ear_sections(ext, taper = EAR_TAPER) = let(st = ear_stations(ext), k = len(st))
    [for (i = [0 : k - 1]) let(p = st[i][0], t = min(i, k - 1 - i, taper) / taper,
                               r = max(0.05, st[i][2] * (ext ? 1 : t * t * (3 - 2 * t))))
        fillet_section([p.x, p.y, cone_z(p)], [st[i][1].x, st[i][1].y, 0], cone_n(p), r)];
module ear_fillet(s, ext = false) mirror([0, s < 0 ? 1 : 0, 0]) fillet_skin(ear_sections(ext));

// The corner round's cutter: the corner's plan beyond the round, where the end wall stands, which is
// below the relief's underside.
module d_corner_cut() let(r = D_CORNER[0], c = [D_FILL[0] + D_CORNER[0], D_FILL[3] - D_CORNER[0]])
    difference() { intersection() {
        translate([0, 0, D_CORNER[1]]) linear_extrude(D_RELIEF[0] - D_CORNER[1] + 1)
            difference() { translate([D_FILL[0] - epsilon, c[1]]) square([r + epsilon, r + epsilon]); translate(c) circle(r = r, $fn = 48); }
        translate([0, D_FILL[3] + 1, 0]) rotate([90, 0, 0]) linear_extrude(2) mirror([0, 0])
            polygon(concat(
                [[D_FILL[0] - 1, D_CORNER[1]], [D_RELIEF[2][0], D_CORNER[1]]],
                arc_pts([D_RELIEF[2][0], D_RELIEF[2][1]], D_RELIEF[3], -90, -135, 12),
                [[D_FILL[0], D_RELIEF[0]], [D_FILL[0] - 1, D_RELIEF[0] + 1]]));
    }
    envelope(); }

module d_relief_cut()
    translate([0, D_FILL[3], 0]) rotate([-90, 0, 0]) linear_extrude(15) mirror([0, 1]) polygon(concat(
        [[D_FILL[0] - 1, C_BOSS[0] - 1], [D_RELIEF[2][0], C_BOSS[0] - 1]],
        arc_pts(D_RELIEF[2], D_RELIEF[3], -90, -135, 12),
        [[D_FILL[0], D_RELIEF[0]], [D_FILL[0] - 1, D_RELIEF[0] + 1]]));

module lug_hole_cuts(cfg)
    for (h = HOLES) let(s = hole_steps(h, cfg), n = len(s)) translate(h[1])
        rotate_extrude($fn = 96) polygon(concat(
            [[0, s[0][0] - epsilon]],
            [for (i = [0 : n - 2]) each [[s[i][1], i == 0 ? s[0][0] - epsilon : s[i][0]], [s[i][1], s[i + 1][0]]]],
            [[s[n - 1][1], s[n - 1][0] + epsilon], [0, s[n - 1][0] + epsilon]]));

// --- N1 ----------------------------------------------------------------------------------------
// The +Y half above the ±X ears' top edges.
COLLAR_FROM = ARM_BODY_EAR[1] + ARM_BODY_EAR[2];
module collar_base_2d() intersection() { arm_body_outline_2d(); translate([-60, COLLAR_FROM]) square([120, 60]); }

module collar() intersection() {
    translate([-60, COLLAR_FROM, COLLAR[0] - 1]) cube([120, 60, COLLAR[2] - COLLAR[0] + 2]);
    union() { collar_flare(); collar_top(); }
}

module collar_flare()
    translate([0, 0, COLLAR[0]]) minkowski() {
        linear_extrude(epsilon) collar_base_2d();
        cylinder(r1 = 0, r2 = COLLAR[3], h = COLLAR[1] - COLLAR[0], $fn = 32);
    }

module collar_top() translate([0, 0, COLLAR[1]]) linear_extrude(COLLAR[2] - COLLAR[1]) offset(r = COLLAR[3]) collar_base_2d();

// --- Cuts --------------------------------------------------------------------------------------
// The fits, in `revised`: the 6810s' seats below L1 and from L2's top up (B1; the Pivot Stator Holder's
// body is drawn at the slip clearance to the upper one), the K1 slots on the Stator Balancers' 3.9 x 9.9
// shanks at the press clearance (a tapped-in press: the reference's 4.0 x 10.0 already is that), Q1 on the 1" CF tube (C-504) at the press clearance, and the tie
// holes and nut traps at the slip clearance to an M2 rod and nut (4.0 AF).
BEARING_6810_D = 65.000;
BALANCER      = [3.900, 9.900];             // #200-003's shank, radial depth by width
M2_NUT_AF     = 4.000;
function seat_r(cfg)  = fit_bore(BEARING_6810_D, press(cfg)) / 2;
// K1 is drawn 4.0 x 10.0 round a 3.9 x 9.9 shank, which is the press clearance already: grown only if that is ever less.
function slot_grow(cfg) = let(g = max(0, (fit_bore(BALANCER[0], press(cfg)) - ARM_BODY_SLOT[1] + ARM_BODY_SLOT[0]) / 2,
                                 (fit_bore(BALANCER[1], press(cfg)) - 2 * ARM_BODY_SLOT[2]) / 2)) round(g * 1e6) / 1e6;

module bore_cut(cfg)
    rotate_extrude() polygon([
        [0, Z[0] - 1], [seat_r(cfg), Z[0] - 1], [seat_r(cfg), L1[0]], [LEDGE_R, L1[0]], [LEDGE_R, L1[1]],
        [BORE_R, L1[1]], [BORE_R, L2[0]], [LEDGE_R, L2[1]], [LEDGE_R, L2[2]], [seat_r(cfg), L2[2]],
        [seat_r(cfg), Z[1] + 1], [0, Z[1] + 1]]);

module slot_cut(cfg) {
    translate([0, 0, Z[0] - 1]) linear_extrude(Z[1] - Z[0] + 2) intersection() { offset(delta = slot_grow(cfg)) arm_body_slots_2d(); square([2 * BOX[1], BOX[1]], center = true); }
    translate([0, 0, SLOT_Y_FLOOR]) linear_extrude(Z[1] - SLOT_Y_FLOOR + 1) difference() { offset(delta = slot_grow(cfg)) arm_body_slots_2d(); square([2 * BOX[1], BOX[1]], center = true); }
}

module socket_cut(cfg)
    let(g = press(cfg))
    for (s = [-1, 1]) translate([-SOCKET[0] - g, s > 0 ? SOCKET[3] : -BOX[1] - 1, SOCKET[1] - g])
        cube([2 * (SOCKET[0] + g), BOX[1] - SOCKET[3] + 1, SOCKET[2] - SOCKET[1] + 2 * g]);

module tie_cuts(cfg)
    for (x = [-TIE[0], TIE[0]], z = TIE[1]) {
        translate([x, 0, z]) rotate([90, 0, 0]) cylinder(d = fit_bore(TIE[2], slip(cfg)), h = 2 * BOX[1] + 4, center = true, $fn = 48);
        for (s = [-1, 1]) translate([x, 0, z]) rotate([s * -90, 0, 0]) rotate([0, 0, 30 + 90 * (1 - s)])
            cylinder(d = (cfg == "previous" ? NUT[0] : fit_bore(M2_NUT_AF, slip(cfg))) / cos(30), h = NUT[1], $fn = 6);
    }

// --- Part --------------------------------------------------------------------------------------
// Below the C1 bottom cone, inside the boxes' slab: the ±Y ears stop on the cone as the boxes do.
module under_cone()
    intersection() {
        translate([-BOX[0], -2 * BOX[1], Z[0] - 1]) cube([2 * BOX[0], 4 * BOX[1], 20]);
        rotate_extrude() polygon([[Z[0] - epsilon + BOX_CONE[0], Z[0] - epsilon], [2 * BOX[1], Z[0] - epsilon],
                                  [2 * BOX[1], 2 * BOX[1] - BOX_CONE[0]]]);
    }

// X1: the box section within the C1 envelope, and in revised with its sides' top and bottom edges rounded.
module box(cfg)
    difference() {
        intersection() { translate([0, 0, Z[0]]) linear_extrude(Z[1] - Z[0]) box_section_2d(); envelope(); }
        if (cfg == "revised") box_round_cut();
    }

module body(cfg) {
    difference() {
        union() {
            difference() { translate([0, 0, Z[0]]) linear_extrude(Z[1] - Z[0]) arm_body_outline_2d(); under_cone(); }
            box(cfg);
            flap();
            lugs(cfg);
            collar();
            translate([0, 0, D_FILL[2]]) linear_extrude(C_BOSS[0] - D_FILL[2] + epsilon) d_fill_2d();
            if (cfg == "revised") translate([0, 0, D_FILL[2]]) linear_extrude(C_BOSS[0] - D_FILL[2] + epsilon) c_fill_2d();
        }
        d_relief_cut();
        d_corner_cut();
    }
    // The fillets are computed from the body above, and the outline gates below z 50 or above z 63.6
    // need none of them.
    if (layer == "part" || layer == "plates") {
        lug_fillets("D");
        if (cfg == "revised") lug_fillets("C");
        ear_fillet(1, cfg == "revised");
        if (cfg == "revised") ear_fillet(-1, true);
    }
}

module arm_body(cfg = config)
    difference() {
        body(cfg);
        window_cut();
        bore_cut(cfg);
        slot_cut(cfg);
        socket_cut(cfg);
        tie_cuts(cfg);
        lug_hole_cuts(cfg);
    }

LAYERS = [["flap", -4.0], ["body", 50.0], ["window", 30.0], ["plates", 58.0], ["web", 64.0], ["upper", 71.5], ["top", 88.0]];
function layer_z(n) = [for (l = LAYERS) if (l[0] == n) l[1]][0];

if (layer == "part") arm_body();
else if (layer != "none") projection(cut = true) translate([0, 0, -layer_z(layer)]) arm_body();
