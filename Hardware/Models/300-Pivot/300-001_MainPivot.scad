// #300-001 Main Pivot — parametric source.
// J1's turning body: it stands on the upper 6810 in the Base Long and carries
// J2's axis across its top half. The J1 and J2 ends are one mounting pattern,
// a drum with windows, four strake slots and four Ø3 holes, turned 45°
// between them.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/300-Pivot/), in that mesh's
//                         frame.
//   config = "revised"  — the same part clearing what turns past it and what
//                         hangs on it: the drum's underside stands the running
//                         clearance above the Base Code Disc (#100-002), and
//                         the side faces, and D2 with them, stand the slip
//                         clearance back from the Pivot Skirt's collar
//                         (#100-003 O4) all the way up, but for a pad at each
//                         of its three screws (skirt_pads).
//
// FRAME. J1 on +Z through the origin, D1's face at z = 0, on the 6810's inner
// race. J2 parallel to +X at z J2_Z, the J2 end face at J2_END_X.
//
// FEATURES, by the IDs of 300-001_MainPivot.view.json, which labels each one
// on the mesh; every value is the constant named, measured with scadmesh
// slice/arcs/solid/planes/radial and fitted where a blend was involved.
//
//     D1  land                      LAND
//     D2  J1 drum                   J1_DRUM_D, up to BODY_Z[0]; tangent to the
//                                   side faces
//     D3  J1 windows                WINDOW, J1_WINDOW: strips on the diagonals
//     E1  J2 drum                   J2_DRUM_D, X_FACE .. J2_END_X
//     E2  J2 windows                WINDOW, J2_WINDOW
//     E3  flange                    FLANGE_D above the top face, FLANGE_X ..
//                                   X_FACE, filleted to the top all round and
//                                   its -X edge rounded, FLANGE_R; the round
//                                   fades out into the fillet (FLANGE_FADE)
//     B1  body                      APOTHEM, X_FACE, BODY_Z, CORNER_R
//     B2  45° faces                 the octagon on the -X half
//     B4  top                       TOP_R: R3 edges; the +X face's R2 all
//                                   round it
//     B5  chamfers                  CHAMFER: 45° floors on the ±Y edges at the
//                                   +X end, top and bottom, ending on the
//                                   vertical 45° wall x + |y| = CHAMFER[2];
//                                   CHAMFER_R on their edges, the wall's edges
//                                   per end_fillet/end_side_round/end_top_round
//                                   (they differ from chamfer to chamfer)
//     B6  flare                     CONE about J2, within the body's height,
//                                   filleted onto the sides (CONE_FILLET)
//     N1  all-thread notch          NOTCH, full height, its blends onto the
//                                   face above BODY_Z[0] and onto D2 below; its
//                                   top edge NOTCH_ROUND
//     S1  J1 strake slots           SLOT, SLOT_TIGHT at 180°, up to J1_SLOT_TOP
//     S2  J2 strake slots           SLOT on the diagonals, from J2_SLOT_X
//     H1  J1 bore                   BORE_D, through
//     H2  J2 cable hole             CABLE, into H1 through a passage
//                                   (CABLE_BOX), its edges rounded (CABLE_R)
//     H3  J2 key slot               KEY from KEY_X
//     H4  J1 holes                  PIN_D, J1_PIN
//     H5  J2 holes                  PIN_D from J2_PIN_X
//     H6  side holes at SIDE_Z[0]   SIDE_D, SIDE_DEPTH, with the TRAPS, TRAP_AF
//     H7  side holes at SIDE_Z[1]   SIDE_D, SIDE_DEPTH
//     H8  top holes                 TOP_HOLE, TOP_HOLES; the outer two's floors
//                                   rise at 45° (TOP_HOLE_SLOPE)
//
// CONSTRUCTION. A region split. The body is the outline swept with its top
// edges rounded (offset_sweep), the +X top edge given back square, and
// intersected with B5's rounded YZ section, which fills in beyond the end
// walls; the +X face is then rounded all round by that section swept to the
// face (x_face_round). The cone, the drums and the land are added, then the
// flange and the J2 drum. Where rounds and fillets meet, each is the rolling
// ball the reference was made with, lofted along its centre's path
// (vnf_vertex_array) as a fillet or a cutter, in the reference's order: the
// fillet or round that came first is the surface the next ball rolls on.
// Rounds that fade out have their setbacks measured by angle (FLANGE_FADE,
// NOTCH_ROUND). Every hole and slot is a primitive or extruded cutter.
//
// GATE. render.rs gates the previous config on dist ±0.15: hausdorff 0.115,
// volume the reference's to 0.005%.
//
// NOT ON CGAL. Under CGAL the swept and lofted blends leave non-planar faces and a mesh that is not
// a valid 2-manifold.
//
// FITS (../print_fit.scad), revised only:
//
//     drum underside, over the code disc     run: land_h()
//     side faces, from the skirt's collar    slip, all the way up, but for a
//                                            pad at each boss behind the
//                                            collar, which is a seat:
//                                            side_apothem(), skirt_pads()
//
// Every other face takes no clearance: the holes and nut traps keep the
// reference's sizes, every trap TRAP_AF.

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <../print_fit.scad>
use <../100-Base/100-002_BaseCodeDisc.scad>
use <../100-Base/100-003_PivotSkirt.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 180;
epsilon = 0.01;

// B1, B2 body: octagon on the -X half, square on the +X half
APOTHEM   = 32.500;                    // the side faces' ($side in the revised config)
X_FACE    = 35.500;
CORNER_R  = 3.000;                     // octagon corners; the +X face's are TOP_R[1], x_face_round()
BODY_Z    = [10.000, 64.000];
TOP_R     = [3.000, 2.000];            // B4 top edges, the +X face's edges
// N1 all-thread notch on +Y
NOTCH     = [35.560, 6.000, 2.100, 2.000];    // centre y, radius, blend radius, top edge round
// B5 chamfers at the +X end: y + z, y - z, and the end wall x + y
CHAMFER   = [90.533, 15.533, 53.033];
CHAMFER_R = 3.000;                     // B5's rounds and its one size of fillet
// The end wall's edges differ from chamfer to chamfer, [y side, top or bottom]:
// the floor fillet everywhere but at +Y on top, which instead rounds the
// end wall onto the side face; the top's end walls round onto the top face.
function end_fillet(s, e) = !(s > 0 && e > 0);
function end_side_round(s, e) = s > 0 && e > 0;
function end_top_round(s, e) = e > 0;
// B6 flare, E3 flange: a cone about J2
J2_Z      = 37.500;
CONE      = [34.000, tan(5)];          // radius at X_FACE (the flange's), fall per mm toward -X: 5° draft
CONE_FILLET = 1.000;                   // B6 onto the side face and the +X face's round
FLANGE_X  = 32.500;
FLANGE_R  = 1.500;                     // E3 edge round and its fillet to the top
FLANGE_D  = 68.000;                    // E3 above the top face
// J1 end (D1-D3) and J2 end (E1, E2)
LAND      = [55.000, 1.500];           // D1 Ø, height
J1_DRUM_D = 65.000;                    // D2, tangent to the side faces
J2_DRUM_D = 53.000;                    // E1
J2_END_X  = 55.000;
WINDOW    = [7.000, 15.420];           // half-width, start along the strip's axis
J1_WINDOW = [4.800, 8.200];            // D3, from the land's face
J2_WINDOW = [3.300, 6.700];            // E2, from the J2 end face
// S1, S2 strake slots
SLOT      = [22.797, 3.601, 13.000];   // centre radius, radial, tangential
SLOT_TIGHT = [22.797, 3.302, 12.700];  // S1 at 180°
J1_SLOT_TOP = 60.000;
J2_SLOT_X = -24.448;
// Holes
BORE_D    = 14.000;                    // H1
CABLE     = [-9.350, 45.016, 12.000, -1.000];  // H2: y, z, Ø, x start
CABLE_BOX = 3.000;                     // H2's box into H1 starts this far above H2's axis
CABLE_R   = [4.000, 1.000, 2.000, 2.000];  // its rounds: the -X face onto H1; onto H1, the box's top and bottom and the triangle's; the +X face onto H2
KEY       = [[-15.351, 45.015], [-7.914, 52.452], [7.643, 36.896], [0.206, 29.459]];  // H3, YZ
KEY_X     = 48.000;
PIN_D     = 3.000;                     // H4, H5
J1_PIN    = [21.920, 14.000];          // H4: circle radius, depth
J2_PIN_X  = 35.000;                    // H5 from here to the end face
SIDE_D    = 3.500;                     // H6, H7
SIDE_Z    = [15.000, 59.000];
SIDE_DEPTH = [4.000, 5.000];           // hex trap, hole, from the face
TRAP_AF   = 5.600;                     // H6 traps across flats: every one takes the same M3 nut
SIDE_Y_X  = [-8.462, 15.533];          // on the ±Y faces
// H6 traps: [face angle, x on a ±Y face (or undef), flats level]. The reference's
// -135° trap is 5.8 across flats, the rest TRAP_AF; it takes the same nut, so
// both configs draw it TRAP_AF.
TRAPS     = [[180, undef, true], [135, undef, false], [-135, undef, false],
             [-90, SIDE_Y_X[0], false], [-90, SIDE_Y_X[1], false]];
TOP_HOLE  = [2.000, 5.000];           // H8 Ø, depth
TOP_HOLES = [[30, 22], [30, -22], [-25, 0]];
TOP_HOLE_SLOPE = 22.181;               // the outer two's floors rise at 45° beyond this |y|

function cone_r(x) = CONE[0] - CONE[1] * (X_FACE - x);

// The side faces' apothem, and D2 with them: main_pivot() sets $side for the
// config. In the revised config the side faces stand back the slip clearance
// from the Pivot Skirt's collar (skirt_pads()).
$side = APOTHEM;
function side_apothem(cfg) = cfg == "revised" ? APOTHEM - fit_clearances(cfg)[0] : APOTHEM;
function drum_d() = J1_DRUM_D - 2 * (APOTHEM - $side);

// --- 2D outlines -------------------------------------------------------------
// B1/B2/N1, counter-clockwise from the -X face's lower end. N1 is the notch
// circle with a tangent blend arc at each end.
function arc_pts(c, r, a0, a1, n = 16) = [for (i = [0 : n]) c + r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];
// On the drum (drum = true) the blends run onto its circle instead of the face.
function notch_path(drum = false) = let (
    n = [0, NOTCH[0]], rb = NOTCH[2], R = drum_d() / 2,
    // the blend's centre: rb inside the face (or the drum), NOTCH[1] + rb from n
    cf = drum ? let (a = R - rb, b = NOTCH[1] + rb, yc = (a * a - b * b + n.y * n.y) / (2 * n.y)) [sqrt(a * a - yc * yc), yc]
              : [sqrt((NOTCH[1] + rb) ^ 2 - (NOTCH[0] - $side + rb) ^ 2), $side - rb],
    a0 = drum ? atan2(cf.y, cf.x) : 90,                // where the blend leaves the face
    t = atan2(n.y - cf.y, n.x - cf.x)                  // blend centre to notch centre
) concat(arc_pts(cf, rb, a0, t), list_tail(arc_pts(n, NOTCH[1], t - 180, -t, 48)), list_tail(arc_pts([-cf.x, cf.y], rb, 180 - t, 180 - a0)));
function body_path() = round_corners(
    let (a = $side, h = $side * tan(22.5)) [[-a, -h], [-h, -a], [X_FACE, -a], [X_FACE, a], [-h, a], [-a, h]],
    radius = [CORNER_R, CORNER_R, 0, 0, CORNER_R, CORNER_R], $fn = 64);
// N1's cutter: the notch's outline closed outside the face.
function notch_cutter_path(drum = false) = let (nt = notch_path(drum), e = nt[0].x + 1)
    concat(nt, [[-e, $side + 4], [e, $side + 4]]);

// D3/E2 windows: four strips on the diagonals, from WINDOW[1] out.
module windows_2d(turn) rotate(turn) for (a = [45 : 90 : 315]) rotate(a)
    translate([WINDOW[1], -WINDOW[0]]) square([40, 2 * WINDOW[0]]);

// S1/S2: slots on 0, 90, 180, 270 before `turn`; tight gives 180° its own size.
module slots_2d(turn, tight) rotate(turn) for (a = [0 : 90 : 270])
    let (s = (tight && a == 180) ? SLOT_TIGHT : SLOT) rotate(a)
        translate([s[0] - s[1] / 2, -s[2] / 2])
            square([s[1], s[2]]);

module pins_2d(turn) rotate(turn) for (a = [45 : 90 : 315]) rotate(a) translate([J1_PIN[0], 0]) circle(d = PIN_D, $fn = 48);

// --- Part --------------------------------------------------------------------
module body(cfg = config) {
    core();
    cone();
    for (m = [0, 1]) mirror([0, m, 0]) cone_fillet();
    // D1, D2
    cylinder(d = LAND[0], h = land_h(cfg) + epsilon);
    up(land_h(cfg)) cylinder(d = drum_d(), h = BODY_Z[0] - land_h(cfg) + epsilon);
}

// D1's height: in the revised config the drum's underside stands the running
// clearance above the code disc (#100-002), which lies on the Long's top
// face, level with D1's face, and turns past it.
function land_h(cfg) = cfg == "previous" ? LAND[1] : max(LAND[1], code_disc_height() + fit_clearances(cfg)[2]);

// E1, added after the +X face's edges are rounded.
module j2_drum() translate([X_FACE - epsilon, 0, J2_Z]) rotate([0, 90, 0]) cylinder(d = J2_DRUM_D, h = J2_END_X - X_FACE + epsilon);

// B1, B2, B4, B5: the outline swept with its top edges rounded, the +X top
// edge given back square, and the chamfers at the +X end; then the +X face
// rounded all round.
module core() difference() {
    core_square();
    x_face_round();
}
module core_square() intersection() {
    union() {
        up(BODY_Z[0]) offset_sweep(body_path(), height = BODY_Z[1] - BODY_Z[0], top = os_circle(r = TOP_R[0]), steps = 12);
        intersection() {
            along_y() translate([X_FACE - 2 * TOP_R[0], BODY_Z[1] - 2 * TOP_R[0]]) square(2 * TOP_R[0]);
            up(BODY_Z[0]) linear_extrude(BODY_Z[1] - BODY_Z[0]) polygon(body_path());
        }
    }
    union() {
        end_walls();
        along_x() polygon(chamfer_profile());
    }
}

// B4, B5: the +X face's edges, rounded TOP_R[1] all round: B5's section swept
// along x and rounded at the face. They stop at the J2 drum, which stands
// lower than the round near y = 0.
module x_face_round() difference() {
    translate([X_FACE - TOP_R[1] - epsilon, -50, 0]) cube([TOP_R[1] + 1, 100, 80]);
    rotate([90, 0, 90]) up(X_FACE - 2 * TOP_R[1]) offset_sweep(chamfer_profile(), height = 2 * TOP_R[1], top = os_circle(r = TOP_R[1]), steps = 16);
    j2_axis() up(X_FACE - 3) cylinder(d = J2_DRUM_D, h = 5);
}

// 2D in (x, z) extruded across y, and 2D in (y, z) extruded along x.
// B5's end walls, x + |y| = CHAMFER[2]: the space short of them, which the
// chamfers' sections fill beyond. Without a fillet onto the floor (+Y on top),
// the wall's edges onto the face and the side face are rounded on the walls'
// own solid, before the sections fill in under the floor: the corner's plan,
// its vertical edge rounded, swept with the face's edge rounded.
module end_walls() difference() {
    linear_extrude(80) polygon([[CHAMFER[2], 0], [-60, CHAMFER[2] + 60], [-60, -CHAMFER[2] - 60]]);
    for (s = [-1, 1], e = [-1, 1]) if (end_side_round(s, e) && end_top_round(s, e)) chamfer_mirror(s, e) let (
        a = $side, w = CHAMFER[2], zf = BODY_Z[1]
    ) difference() {
        translate([w - a - 3, a - 12, zf - 10]) cube([16, 13, 12]);
        up(zf - 10) offset_sweep(round_corners([[0, a - 20], [w - a + 20, a - 20], [w - a, a], [0, a]], radius = [0, 0, CHAMFER_R, 0], $fn = 64),
            height = 10, top = os_circle(r = CHAMFER_R), steps = 12);
    }
}

module along_y() rotate([90, 0, 0]) linear_extrude(80, center = true) children();
module along_x() rotate([90, 0, 90]) linear_extrude(80) children();

// B5 in (y, z): the chamfered section, its corners rounded, standing a
// hair outside the faces it shares with the swept outline.
function chamfer_profile() = let (
    h = 0.005, ys = $side + h, zb = BODY_Z[0] - h, zt = BODY_Z[1] + h,
    half = [[CHAMFER[1] + zb, zb], [ys, ys - CHAMFER[1]], [ys, CHAMFER[0] - ys], [CHAMFER[0] - zt, zt]],
    pts = concat(half, [for (i = [3 : -1 : 0]) [-half[i].x, half[i].y]])
) round_corners(pts, radius = CHAMFER_R, $fn = 64);

// B6, E3: the cone about J2 within the body's height, on the ±Y sides, and
// over the top the flange, its -X edge rounded and filleted to the top face
// all round.
module cone() difference() {
    intersection() {
        j2_axis() up(10) cylinder(r1 = cone_r(10), r2 = CONE[0], h = X_FACE - 10);
        translate([0, -50, BODY_Z[0]]) cube([X_FACE + epsilon, 100, BODY_Z[1] - BODY_Z[0]]);
    }
    // it came after x_face_round(), and stands only on the sides
    translate([0, TOP_R[1] - $side, 0]) cube([2 * X_FACE, 2 * ($side - TOP_R[1]), 2 * BODY_Z[1]]);
}

// B6's fillet onto the side face and, at the +X end, onto the face's round:
// a CONE_FILLET ball rolled between them, on +y. Its centre keeps
// CONE_FILLET off the cone and off the side (the face, then the round's
// cylinder about its axis), so it runs round the cone's edge on the side and
// out past the +X face at both ends, and is cut back to it.
module cone_fillet() intersection() {
    vnf_polyhedron(vnf_vertex_array([for (s = cone_fillet_stations()) cone_fillet_section(s[0], s[1], s[2])], col_wrap = true, caps = true));
    translate([0, -50, BODY_Z[0]]) cube([X_FACE, 100, BODY_Z[1] - BODY_Z[0]]);
}

// The ball's centre, on the cone offset by the ball at angle p about J2 from
// the top, at x; the side's normal there; the cone's.
function cone_fillet_station(x, p, ns) = let (r = cone_r(x) + CONE_FILLET)
    [[x, r * sin(p), J2_Z + r * cos(p)], ns, unit([-CONE[1], sin(p), cos(p)])];

function cone_fillet_stations(n = 24) = let (
    rho = CONE_FILLET, k = X_FACE - TOP_R[1], yk = $side - TOP_R[1],
    // on the round's cylinder at angle f from +x: the centre's x and y
    on_round = function(f, e) let (x = k + (TOP_R[1] + rho) * cos(f), y = yk + (TOP_R[1] + rho) * sin(f),
        p = asin(y / (cone_r(x) + rho))) cone_fillet_station(x, e > 0 ? p : 180 - p, [cos(f), sin(f), 0]),
    // on the face: the cone's radius there gives x
    p0 = asin(($side + rho) / (cone_r(k) + rho)),
    on_face = function(p) let (r = ($side + rho) / sin(p) - rho) cone_fillet_station(X_FACE - (CONE[0] - r) / CONE[1], p, [0, 1, 0])
) concat(
    [for (i = [0 : n]) on_round(90 * i / n, -1)],
    [for (i = [1 : 2 * n - 1]) on_face(180 - p0 - (180 - 2 * p0) * i / (2 * n))],
    [for (i = [n : -1 : 0]) on_round(90 * i / n, 1)]);

// The section square to the centre's path: the ball's arc from the side to
// the cone, closed 1 inside both.
function cone_fillet_section(c, ns, nc, k = 12) = let (
    rho = CONE_FILLET, a = acos(ns * nc)
) concat([for (i = [0 : k]) c - rho * (sin(a * (1 - i / k)) * ns + sin(a * i / k) * nc) / sin(a)],
    [c - (rho + 1) * nc, c - (rho + 1) * (ns + nc), c - (rho + 1) * ns]);

module flange() difference() {
    union() {
        intersection() {
            j2_axis() up(FLANGE_X) cylinder(d = FLANGE_D, h = X_FACE - FLANGE_X + epsilon, $fn = 360);
            // above the top face, and below it down through the +X face's round
            translate([0, -50, BODY_Z[1] - TOP_R[1]]) cube([X_FACE + epsilon, 100, 20]);
        }
        for (m = [0, 1]) mirror([0, m, 0]) flange_fillet();
    }
    flange_round();
}

module j2_axis() translate([0, 0, J2_Z]) rotate([0, 90, 0]) children();

// E3's fillet to the top, on +y: a FLANGE_R ball rolled between the flange,
// its -X edge still sharp, and the top, which is flat and then runs down the
// +X face's round. Its centre keeps FLANGE_R off both, so it runs along the
// -X face, round the edge and along the rim, at the top's offset. Lofted
// along that line from just short of y = 0, out past the +X face, and cut
// back to it.
module flange_fillet() intersection() {
    vnf_polyhedron(vnf_vertex_array([for (s = flange_fillet_stations()) reverse(flange_fillet_section(s[0], s[1]))],
        col_wrap = true, caps = true));
    translate([0, -50, 0]) cube([X_FACE, 100, 80]);
}

// The offset top's height over x, and the top's outward normal under a point.
function top_offset_z(x) = let (k = X_FACE - TOP_R[1]) x <= k ? BODY_Z[1] + FLANGE_R
    : BODY_Z[1] - TOP_R[1] + sqrt((TOP_R[1] + FLANGE_R) ^ 2 - (x - k) ^ 2);
function top_normal(p) = let (k = X_FACE - TOP_R[1]) p.x <= k ? [0, 0, 1] : unit([p.x - k, 0, p.z - BODY_Z[1] + TOP_R[1]]);

// The ball's centre, on side s of y = 0, and the flange's outward normal
// where the ball touches it: at x, r from J2, with that normal nf in (x, r).
function flange_fillet_station(x, r, nf, s = 1) = let (
    z = top_offset_z(x), y = s * sqrt(r * r - (z - J2_Z) ^ 2)
) [[x, y, z], [nf[0], 0, 0] + nf[1] * [0, y, z - J2_Z] / r];

function flange_fillet_stations(n = 24) = let (
    R = FLANGE_R, h = BODY_Z[1] + R - J2_Z, r = FLANGE_D / 2
) concat(
    [for (y = [-0.5, sqrt(r * r - h * h)]) flange_fillet_station(FLANGE_X - R, sqrt(y * y + h * h), [-1, 0], sign(y))],
    [for (i = [1 : n]) let (a = 90 * i / n) flange_fillet_station(FLANGE_X - R * cos(a), r + R * sin(a), [-cos(a), sin(a)])],
    [for (i = [1 : 2 * n]) flange_fillet_station(FLANGE_X + (X_FACE + R - 0.05 - FLANGE_X) * i / (2 * n), r + R, [0, 1])]);

// The section square to the centre's path: the ball's arc from the top to the
// flange, closed inside both.
function flange_fillet_section(c, nf, n = 16) = let (
    nt = top_normal(c), f = acos(nt * nf)
) concat([for (i = [0 : n]) c - FLANGE_R * (sin(f * (1 - i / n)) * nt + sin(f * i / n) * nf) / sin(f)],
    [c - 1.5 * FLANGE_R * (nt + nf)]);

// E3's -X edge round, FLANGE_R, fades out as it comes down to the fillet:
// from FLANGE_FADE[0][0] either side of the top its section is a quarter
// ellipse, its setbacks [along x, in r] measured at each angle from the top.
FLANGE_FADE = [[31.0, 1.50, 1.50], [31.5, 1.52, 1.43], [32.0, 1.54, 1.33], [32.5, 1.58, 1.22], [33.0, 1.60, 1.08],
    [33.5, 1.62, 0.95], [34.0, 1.56, 0.85], [34.5, 1.56, 0.70], [35.0, 1.46, 0.58], [35.5, 1.35, 0.47],
    [36.0, 1.27, 0.35], [36.5, 1.14, 0.24], [37.0, 0.95, 0.15], [37.5, 0.78, 0.07], [38.0, 0.34, 0.03], [38.5, 0.02, 0.01]];
module flange_round() let (
    fade = [for (f = FLANGE_FADE) f[0]], a0 = fade[0], a1 = last(fade),
    angles = concat([for (a = [-a1 : 0.5 : -a0]) a], [for (i = [1 : 30]) -a0 + 2 * a0 * i / 31], [for (a = [a0 : 0.5 : a1]) a])
) vnf_polyhedron(vnf_vertex_array([for (a = angles) flange_round_section(a, abs(a) <= a0 ? [FLANGE_R, FLANGE_R]
    : [lookup(abs(a), [for (f = FLANGE_FADE) [f[0], f[1]]]), lookup(abs(a), [for (f = FLANGE_FADE) [f[0], f[2]]])])],
    col_wrap = true, caps = true));

// At angle a from the top about J2, what the round takes off the edge: the
// corner outside a quarter ellipse with setbacks s, and in front of the -X
// face, the fillet there as far out as the face now stands.
function flange_round_section(a, s, n = 12) = let (
    e = [FLANGE_X, FLANGE_D / 2],
    pts = concat([for (i = [0 : n]) let (t = 180 - 90 * i / n) e + [s[0] * (1 + cos(t)), s[1] * (sin(t) - 1)]],
        [e + [s[0], 0.2], e + [-FLANGE_R - 0.1, 0.2], e + [-FLANGE_R - 0.1, -s[1]]])
) [for (p = pts) [p.x, p.y * sin(a), J2_Z + p.y * cos(a)]];

module j1_cuts() {
    down(epsilon) {
        cylinder(d = BORE_D, h = BODY_Z[1] + 2 * epsilon);                       // H1
        linear_extrude(J1_SLOT_TOP + epsilon) slots_2d(0, true);                 // S1
        linear_extrude(J1_PIN[1] + epsilon) pins_2d(0);                          // H4
    }
    up(J1_WINDOW[0]) linear_extrude(J1_WINDOW[1] - J1_WINDOW[0]) windows_2d(0);  // D3
}

// The J2 end's cuts in a frame whose +Z is +X, origin on the end face.
module j2_frame() translate([J2_END_X, 0, J2_Z]) rotate([0, -90, 0]) children();

module j2_cuts() j2_frame() {
    down(epsilon) {
        linear_extrude(J2_END_X - J2_SLOT_X + epsilon) slots_2d(45, false);     // S2
        linear_extrude(J2_END_X - J2_PIN_X + epsilon) pins_2d(45);              // H5
    }
    up(J2_WINDOW[0]) linear_extrude(J2_WINDOW[1] - J2_WINDOW[0]) windows_2d(45); // E2
}

// H2 runs into H1 through a passage from its -X end to H1's +X tangent. In
// (y, z) the passage is the box from CABLE_BOX above H2's axis up to H1's,
// as tall as H2 there, and the triangle inscribed in H2 beyond it, which
// H2 holds wherever H2 runs; so the passage only shows it past H2's -X end.
// There its -X face is rounded onto H1 (CABLE_R[0]); the box's +X face is
// rounded onto H2 (CABLE_R[3]); and the edge it opens H1 along is rounded,
// CABLE_R[1] on the box's top and bottom, CABLE_R[2] on the triangle's.
function cable_h() = 2 * sqrt((CABLE[2] / 2) ^ 2 - CABLE_BOX ^ 2);
function cable_yz() = let (yb = CABLE[0] + CABLE_BOX, h = cable_h())
    [[1, CABLE[1] - h / 2], [yb, CABLE[1] - h / 2], [CABLE[0] - CABLE[2] / 2, CABLE[1]], [yb, CABLE[1] + h / 2], [1, CABLE[1] + h / 2]];
// The -X face's round's centre, and the +X face's.
function cable_c4() = [CABLE[3] - CABLE_R[0], -sqrt((BORE_D / 2 + CABLE_R[0]) ^ 2 - (CABLE[3] - CABLE_R[0]) ^ 2)];
function cable_c2() = [BORE_D / 2 + CABLE_R[3], CABLE[0] + CABLE_BOX + CABLE_R[3]];

module cable_cuts() {
    h = cable_h();
    yb = CABLE[0] + CABLE_BOX;
    up(CABLE[1] - h / 2) translate([CABLE[3], yb, 0]) cube([BORE_D / 2 - CABLE[3], -yb, h]);
    intersection() {
        down(1) linear_extrude(BODY_Z[1] + 2) cable_r4_2d();
        rotate([90, 0, 90]) linear_extrude(40, center = true) polygon(cable_yz());
    }
    up(CABLE[1] - h / 2) linear_extrude(h) difference() {
        translate([BORE_D / 2 - epsilon, yb]) square(CABLE_R[3] + epsilon);
        translate(cable_c2()) circle(r = CABLE_R[3], $fn = 64);
    }
    for (e = [-1, 1]) cable_round(e);
    translate([CABLE[3], CABLE[0], CABLE[1]]) rotate([0, 90, 0]) cylinder(d = CABLE[2], h = J2_END_X - CABLE[3] + epsilon);  // H2
    translate([KEY_X, 0, 0]) rotate([90, 0, 90]) linear_extrude(J2_END_X - KEY_X + epsilon) polygon(KEY);                    // H3
}

// What the -X face's round takes off, in plan: from the face round to H1,
// closed inside H1.
module cable_r4_2d() let (
    c = cable_c4(), a = atan2(-c.y, -c.x),
    arc = [for (i = [0 : 32]) c + CABLE_R[0] * [cos(a * i / 32), sin(a * i / 32)]]
) polygon(concat([[CABLE[3] + epsilon, c.y], [CABLE[3] + epsilon, 0], 0.9 * last(arc)], reverse(arc)));

// The passage in plan.
module cable_plan() {
    yb = CABLE[0] + CABLE_BOX;
    translate([CABLE[3], CABLE[0] - CABLE[2] / 2]) square([BORE_D / 2 - CABLE[3], CABLE[2] / 2 - CABLE[0]]);
    cable_r4_2d();
    difference() {
        translate([BORE_D / 2 - epsilon, yb]) square(CABLE_R[3] + epsilon);
        translate(cable_c2()) circle(r = CABLE_R[3], $fn = 64);
    }
}

// How far the passage's floor and roof stand from H2's axis at y: the box's
// plane, or the triangle's (sloped), each taken whole. The round onto H1 came
// before H2, which takes it off wherever H2 runs lower, so this is the
// passage's own floor.
function cable_floor(y, sloped) = cable_h() / 2 - (sloped ? (CABLE[0] + CABLE_BOX - y) * tan(30) : 0);

// A ball rolled round H1 beyond the passage's floor (e = -1) or roof (e = 1),
// within the passage's plan: in the plane through J1 at each angle it touches
// H1 and the floor where it meets H1, and what it takes off runs from H1 round to where it
// touches the floor. In that plane w is the distance from H2's axis.
module cable_round(e) intersection() {
    let (
        r = BORE_D / 2, yb = CABLE[0] + CABLE_BOX, a0 = atan2(cable_c4().y, cable_c4().x) + 0.5,
        sections = [for (a = [a0 : 1 : -0.5]) let (
            u = [cos(a), sin(a)], sloped = r * u.y < yb, R = sloped ? CABLE_R[2] : CABLE_R[1],
            fl = [for (i = [0 : 100]) let (s = r + 2 * R * i / 100) [s, cable_floor(s * u.y, sloped)]],
            lift = function(q) q[1] + sqrt(max(0, R * R - (q[0] - r - R) ^ 2)),
            cw = max([for (q = fl) lift(q)]),
            k = [for (q = fl) if (lift(q) >= cw - 1e-9) q][0],
            f = let (b = atan2(k[1] - cw, k[0] - r - R)) b < 0 ? b + 360 : b,    // 180 at H1, 270 square under the centre
            pts = concat([[r - 0.5, cw], [r, cw]], [for (j = [1 : 12]) [r + R + R * cos(180 + (f - 180) * j / 12), cw + R * sin(180 + (f - 180) * j / 12)]],
                [[k[0], k[1] - 0.5], [r - 0.5, k[1] - 0.5]])
        ) [for (q = e > 0 ? reverse(pts) : pts) [q[0] * u.x, q[0] * u.y, CABLE[1] + e * q[1]]]]
    ) vnf_polyhedron(vnf_vertex_array(sections, col_wrap = true, caps = true));
    down(1) linear_extrude(BODY_Z[1] + 2) cable_plan();
}

// A point on the face at angle a (and, on a ±Y face, at x), where a hole enters.
function side_face_point(a, x) = is_undef(x) ? APOTHEM * [cos(a), sin(a)] : [x, APOTHEM * sign(sin(a))];

// Into the face at angle a: local +X is outward, the hole runs to -X.
module on_face(a, x, z) translate([each side_face_point(a, x), z]) rotate(a) children();

module side_holes() {
    faces = concat([[180, undef], [135, undef], [-135, undef]], [for (x = SIDE_Y_X, a = [-90, 90]) [a, x]]);
    for (z = SIDE_Z, f = faces) on_face(f[0], f[1], z) translate([-SIDE_DEPTH[1], 0, 0])
        rotate([0, 90, 0]) cylinder(d = SIDE_D, h = SIDE_DEPTH[1] + 1, $fn = 48);
    for (t = TRAPS) on_face(t[0], t[1], SIDE_Z[0]) translate([-SIDE_DEPTH[0], 0, 0]) rotate([0, 90, 0])
        linear_extrude(SIDE_DEPTH[0] + 1) rotate(t[2] ? 30 : 0) circle(d = TRAP_AF / cos(30), $fn = 6);
    for (p = TOP_HOLES) render() intersection() {
        translate([p.x, p.y, BODY_Z[1] - TOP_HOLE[1]]) cylinder(d = TOP_HOLE[0], h = TOP_HOLE[1] + 1, $fn = 32);
        if (p.y != 0) along_x() polygon([[0, BODY_Z[1] - TOP_HOLE[1]], [sign(p.y) * TOP_HOLE_SLOPE, BODY_Z[1] - TOP_HOLE[1]],
            [sign(p.y) * 40, BODY_Z[1] - TOP_HOLE[1] + 40 - TOP_HOLE_SLOPE], [sign(p.y) * 40, 80], [0, 80]]);
        else cube([200, 200, 200], center = true);
    }
}

// B5's chamfer on side s (+1 or -1 in y) and end e (+1 top, -1 bottom): its
// floor plane through q with normal f (both in the +y, +z quadrant before the
// mirrors), the end wall x + y = CHAMFER[2].
function chamfer_floor(e) = e > 0 ? [CHAMFER[0], [0, 1, 1] / sqrt(2)] : [CHAMFER[1], [0, 1, -1] / sqrt(2)];
module chamfer_mirror(s, e) mirror([0, s < 0 ? 1 : 0, 0]) children();

// The fillet the end wall meets the floor with: a CHAMFER_R ball rolled
// between the wall and the floor as the profile leaves it, rounded onto the
// side face and, where the face's round came first (the bottom), onto the
// face. On the top the fillet came first: it runs straight out through the
// face, which chamfer_chain_round() then rounds.
module chamfer_fillets() for (s = [-1, 1], e = [-1, 1]) if (end_fillet(s, e)) chamfer_mirror(s, e) intersection() {
    // the sections wind the other way about the path on the top
    vnf_polyhedron(vnf_vertex_array([for (st = chamfer_fillet_stations(e, !end_top_round(s, e)))
            let (p = chamfer_fillet_section(st[0], st[1])) e > 0 ? reverse(p) : p],
        col_wrap = true, caps = true));
    translate([0, -$side, BODY_Z[0]]) cube([X_FACE, 2 * $side, BODY_Z[1] - BODY_Z[0]]);
}

// The ball's centre and the floor's normal under it, from the face to past
// the side face: the centre stands CHAMFER_R off the wall, and off the floor
// profile, which is a line rounded CHAMFER_R about an axis at each end.
function chamfer_fillet_stations(e, face_first) = let (
    R = CHAMFER_R, f = chamfer_floor(e)[1], fc = chamfer_floor(e)[0] / sqrt(2),
    zf = e > 0 ? BODY_Z[1] : BODY_Z[0], xy = CHAMFER[2] + R * sqrt(2),
    side = [$side - R, (fc - R - f.y * ($side - R)) / f.z],           // the rounds' axes in (y, z)
    face = [(fc - R - f.z * (zf - e * R)) / f.y, zf - e * R],
    st = function(a, n) let (c = a + 2 * R * [n.y, n.z]) [[xy - c.x, c.x, c.y], n]
) concat(
    face_first ? [for (b = [0 : 3 : 45]) st(face, [0, sin(b), e * cos(b)])]
               : [st(face + [-e * 3 * f.z, 3 * f.y] / 1, f)],            // out past the face along the floor
    [for (b = [45 : -3 : 0]) st(side, [0, cos(b), e * sin(b)])]);

// The section square to the centre's path: the ball's arc from the wall to the
// floor, closed 1 inside both.
function chamfer_fillet_section(c, n, k = 16) = let (
    R = CHAMFER_R, w = [1, 1, 0] / sqrt(2), a = acos(w * n)
) concat([for (i = [0 : k]) c - R * (sin(a * (1 - i / k)) * w + sin(a * i / k) * n) / sin(a)],
    [c - (R + 1) * n, c - (R + 1) * (n + w), c - (R + 1) * w]);

// The chamfer's convex edges the profile does not reach, where the floor's
// fillet runs into the face: chamfer_chain_round().
module chamfer_rounds() for (s = [-1, 1], e = [-1, 1]) chamfer_mirror(s, e) let (
    zf = e > 0 ? BODY_Z[1] : BODY_Z[0],
    face = [0, 0, e]
) {
    if (end_fillet(s, e) && end_top_round(s, e)) chamfer_chain_round(e, face, e * zf, true);
}

// Where the floor's fillet runs into a rounded face, the fillet comes first:
// the face's edge is then one chain, the floor, the fillet and the end wall in
// turn, and a CHAMFER_R ball rolls along it. The face is the top or bottom
// (normal t, at t·p = off), whose chain runs on along the end wall where
// end_top_round() rounds it and otherwise stops at the wall, or the side
// face, whose chain stops at the wall. The ball's centre stands CHAMFER_R in
// from the face and 2 CHAMFER_R from the fillet's axis (the fillet is a
// CHAMFER_R ball rolled between floor and wall), so it runs along the floor,
// round the axis and along the wall. The cutter is lofted along that line,
// from beyond the fillet on the floor to the wall, or out past the side face
// along it.
module chamfer_chain_round(e, t, off, wall_too) let (
    R = CHAMFER_R, f = chamfer_floor(e)[1], w = [1, 1, 0] / sqrt(2), g = f * w, a = acos(g),
    // the fillet's axis: CHAMFER_R off floor and wall into the void
    fc = chamfer_floor(e)[0] / sqrt(2) + R, wc = CHAMFER[2] / sqrt(2) + R,
    p0 = ((fc - g * wc) * f + (wc - g * fc) * w) / (1 - g * g), d = unit(cross(f, w)),
    centre = function(u) let (tau = (off - R - t * p0 + 2 * R * (t * u)) / (t * d)) p0 + tau * d - 2 * R * u,
    c0 = centre(f), c1 = centre(w),
    stations = concat(
        [for (k = [4 : -1 : 1]) [c0 + [k, 0, 0], f]],
        [for (i = [0 : 24]) let (u = (sin(a * (1 - i / 24)) * f + sin(a * i / 24) * w) / sin(a)) [centre(u), u]],
        wall_too ? [for (k = [1 : 4]) [c1 + k * ($side + 1 - c1.y) / 4 * [-1, 1, 0], w]] : []),
    // the sections wind one way about the path on the top, the other way on
    // the bottom and side
    flip = cross(t, f).x > 0
) vnf_polyhedron(vnf_vertex_array([for (s = stations) let (p = chain_round_section(s[0], s[1], t)) flip ? reverse(p) : p],
    col_wrap = true, caps = true));

// What a CHAMFER_R ball centred at c takes off the edge between the face
// (normal t) and the side it touches (normal u): the ball's arc from one to
// the other, closed 1 beyond both: along the fillet, a line tangent to the
// side would run back into it.
function chain_round_section(c, u, t, n = 16) = let (
    R = CHAMFER_R, f = acos(t * u)
) concat([for (i = [0 : n]) c + R * (sin(f * (1 - i / n)) * t + sin(f * i / n) * u) / sin(f)],
    [c + (R + 1) * u, c + (R + 1) * (t + u), c + (R + 1) * t]);

// N1 straight through the body; the drum's part blends onto the drum.
module notch_cut() {
    up(BODY_Z[0]) linear_extrude(BODY_Z[1] - BODY_Z[0] + 1) polygon(notch_cutter_path());
    down(epsilon) linear_extrude(BODY_Z[0] + 2 * epsilon) polygon(notch_cutter_path(true));
}

// N1's top edge: the face's TOP_R[0] round runs on round the blends and
// closes to NOTCH[3] on the circle. Its section square to the edge is a
// quarter ellipse, its setbacks [across the top, down the wall] measured
// at each angle: about the +x blend's centre from the face, then about the
// circle's centre from the blend. Lofted from the face round the blend, the
// circle and the other blend back to the face.
NOTCH_ROUND = [[[90, 3.00, 3.00], [100, 3.04, 2.94], [110, 3.04, 2.84], [120, 3.04, 2.69], [130, 3.05, 2.42], [135, 3.08, 2.27]],
               [[-41.5, 2.64, 2.09], [-42.5, 2.43, 2.11], [-45, 2.16, 2.13], [-47, 2.07, 2.08], [-50, 2.06, 2.04], [-55, 2.00, 2.00]]];
module notch_round() let (
    n = [0, NOTCH[0]], rb = NOTCH[2],
    cf = [sqrt((NOTCH[1] + rb) ^ 2 - (NOTCH[0] - $side + rb) ^ 2), $side - rb],
    t = atan2(n.y - cf.y, n.x - cf.x),                     // the blend meets the circle
    ends = [3.12, 2.09],                                    // the setbacks there
    s = function(table, a) [lookup(a, [for (r = table) [r[0], r[1]]]), lookup(a, [for (r = table) [r[0], r[2]]])],
    bt = concat(NOTCH_ROUND[0], [[t, each ends]]),
    ct = reverse(concat([[t - 180, each ends]], NOTCH_ROUND[1], [[-90, NOTCH[3], NOTCH[3]]])),
    // stations on the +x half, from the face to x = 0
    half = concat(
        [for (i = [0 : 20]) let (a = 90 + (t - 90) * i / 20, u = [cos(a), sin(a)]) [cf + rb * u, u, s(bt, a), rb - 0.05]],
        [for (a = [t - 181 : -1 : -89]) let (u = [cos(a), sin(a)]) [n + NOTCH[1] * u, -u, s(ct, a), 100]]),
    mx = function(st) [[-st[0].x, st[0].y], [-st[1].x, st[1].y], st[2], st[3]]
) vnf_polyhedron(vnf_vertex_array([for (st = concat(half, [[n - NOTCH[1] * [0, 1], [0, 1], [NOTCH[3], NOTCH[3]], 100]],
    [for (i = [len(half) - 1 : -1 : 0]) mx(half[i])])) reverse(notch_round_section(st[0], st[1], st[2], st[3]))], col_wrap = true, caps = true));

// At the top edge's point w, with v square to the wall into the void: what the
// round takes off, outside a quarter ellipse with setbacks d, and no further
// than reach in from the wall.
function notch_round_section(w, v, d, reach, k = 16) = let (
    p = function(s, h) let (q = w + max(s, -reach) * v) [q.x, q.y, BODY_Z[1] + h]
) concat([for (i = [0 : k]) p(-d[0] + d[0] * cos(90 * i / k), -d[1] + d[1] * sin(90 * i / k))],
    [p(-d[0], 1), p(1, 1), p(1, -d[1])]);

module main_pivot(cfg = config) {
    $side = side_apothem(cfg);
    difference() {
        union() {
            difference() {
                union() {
                    body(cfg);
                    chamfer_fillets();
                    if (cfg == "revised") skirt_pads(fit_clearances(cfg)[0]);
                }
                chamfer_rounds();
                notch_cut();
                notch_round();
            }
            flange();
            j2_drum();
        }
        j1_cuts();
        j2_cuts();
        cable_cuts();
        side_holes();
    }
}

// The Pivot Skirt's collar (#100-003 O4) stands on the side faces, its screw
// bosses (H1) behind it at the screws, SIDE_Z[0] on 180° and ±135°, and the
// spacers round the screws flush with it below; the skirt hangs on those
// screws, so its y is the bosses' there. In the revised config the side faces
// stand back the slip clearance (side_apothem()), all the way up, but for a
// pad where each boss backs the collar's face, which the screw draws onto the
// pivot. The spacers bear on little more than the nut traps' edges, so they
// take the clearance. The skirt is open across the +X face.
function skirt_z(y) = y - skirt_boss()[0] + SIDE_Z[0];
module skirt_pads(c) let (b = skirt_boss(), z0 = skirt_z(skirt_collar_y()[0]))
    for (a = [180, 135, -135]) on_face(a, undef, SIDE_Z[0]) intersection() {
        translate([-c - 0.05, 0, 0]) rotate([0, 90, 0]) cylinder(d = b[1], h = c + 0.05, $fn = 64);
        translate([-2, -b[1], z0 - SIDE_Z[0]]) cube([4, 2 * b[1], b[1]]);
    }

main_pivot();
