// #823 Photointerrupter Shroud (End Arm) — parametric source.
//
// A half shell about the J3 (end arm) axis, z, with the reader for its code
// disk: the disk runs in the rim's inner groove (z 18 .. 22.5), and the two
// T-1 beams cross it along z on r 35 at 18.06 and -16.05 deg, through the
// block on the front. The frame is the reference's: the axis on z, the
// split plane x = 0, the half at x >= 0.
//
// CONSTRUCTION (measured from the reference with scadmesh; the numbers are
// the constants below, each with its feature ID). A region split:
//   S1  the shell: its outer profile (r 33.496, the R20 flare, the bulge R3
//       and the rim's 45 deg chamfer) revolved over the half;
//   F1  the front skin, r 40 over +-41 deg, its ends S-curves of R5 (convex
//       on r 35, concave on r 38.5) down to the shell, extruded;
//   F2  the pillars: the concave R5 rolled up the shell's flare (lofted);
//   B1  the block: the slab y -15.71 .. 17.03 cut by a 10 deg cone from
//       r 40 (z -2.97) to r 44, lofted between convex plans with R2 corners,
//       R2 fillets into the skin, R3 posts at its feet on the rim;
//   H1  the bosses on the rim at +-45 deg, R3.75 with Ø2.5 holes
//       countersunk to Ø3.5, and their R2.5 fillets onto the rim (lofted);
//   E1  the beads along the split edges, R1.5;
// less the voids: the inside (r 32.8, the 45 deg chamfer, the groove with
// its lip, the rim's r 32.5), the front's walls seen from inside (kidney
// recesses, the block's r 32.5, the keyhole's groove), the window under the
// block (R1 all round), the pocket in the block (radial walls, 45 deg
// floor, the beam tubes R3.75 left standing), the beams (Ø4.3 / Ø3.2, the
// rim's 0.6 radial aperture, Ø4.3 at the top), the keyhole (Ø4.5 at z 11.68,
// slot 3.0, its R2 rounds into the pocket), and the notch B5 on the block's
// +y side at the top.
//
// GATE (scadmesh dist, both directions): 0.578 mm, held at 0.6 and not 0.15
// (render.json says so too). The reference is the mesh as repaired in place
// (README § Known defects): a skin of the shell left inside the pocket is
// cut away. What stays over 0.15 is blends drawn approximately, each a
// rolling ball or a loft where the CAD's blend is not one: the +y block
// fillet beside its post (0.58), the bosses' fillet feet (0.53), the
// pillars' tops (0.51), the notch B5 (0.41), the block's corners where its
// side face is short (z -2 .. 6, 0.45), the window's sides (0.46), the
// groove's foot over the pocket (r 39.0 straight from z 19 where the R3 is
// drawn, 0.44), the beads' R0.8 (0.28).
//
// FITS: none drawn. The beam bores (Ø3.2 round a Ø3.0 T-1 body, Ø4.3 round
// its flange) already clear their mates by more than the press fit, so
// `revised` keeps them, as #821's.

include <BOSL2/std.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
piece = "";
use_pillars = true;

/* [Hidden] */
$fn = 360;
LAP = 0.005;

function arc_pts(c, r, a0, a1, n = 16) = [for (i = [0 : n]) c + r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];
function ang(c, p) = atan2(p.y - c.y, p.x - c.x);
function arc_to(c, p0, p1, n = 16, ccw = true) = let (
    a0 = ang(c, p0), a1r = ang(c, p1),
    a1 = ccw ? (a1r < a0 ? a1r + 360 : a1r) : (a1r > a0 ? a1r - 360 : a1r))
    arc_pts(c, norm(p0 - c), a0, a1, n);
function arc_s(c, p0, p1, n = 16) = let (
    a0 = ang(c, p0), d = ang(c, p1) - a0, dd = d > 180 ? d - 360 : (d < -180 ? d + 360 : d))
    arc_pts(c, norm(p0 - c), a0, a0 + dd, n);
function outward(vnf) = vnf_volume(vnf) < 0 ? vnf_reverse_faces(vnf) : vnf;
function mirror_y(path) = [for (i = [len(path) - 1 : -1 : 0]) [path[i].x, -path[i].y]];
function pol(r, a) = r * [cos(a), sin(a)];
O = [0, 0];

// S1, the shell's outer meridional profile [r, z], measured at 65 deg,
// closed to the axis (the inside is cut by the voids).
SHELL_OUT = concat(
    [[20, -29.000], [33.496, -29.000], [33.496, 3.244]],
    arc_to([53.519, 3.235], [33.496, 3.244], [38.912, 16.930], 24, false),
    [[40.801, 18.354]],
    arc_to([38.990, 20.750], [40.801, 18.354], [40.748, 23.186], 16, true),
    arc_to([42.009, 24.757], [40.748, 23.186], [40.082, 24.166], 8, false),
    arc_to([37.266, 23.320], [40.082, 24.166], [39.336, 25.411], 8, true),
    [[34.245, 30.500], [20, 30.500]]);

// The inner void's profile above the front's walls: the 45 deg chamfer, the
// disk's groove and its lip, and the rim's bore.
INNER = concat(
    [[0, 12.0], [32.797, 12.0], [32.797, 12.797], [38.121, 18.121]],
    arc_to([36.000, 20.250], [38.121, 18.121], [39.000, 20.250], 12, true),
    [[39.000, 22.000]],
    arc_to([38.500, 22.000], [39.000, 22.000], [38.500, 22.500], 6, true),
    [[32.497, 22.500], [32.497, 31.000], [0, 31.000]]);

module shell_out() rotate(-90) rotate_extrude(angle = 180, $fn = 720) polygon(SHELL_OUT);
module inner_void() rotate_extrude($fn = 720) polygon(INNER);

// F1, the front skin's plan: r 40 between two S-curves of R5 down to the
// shell's r 33.5, each a convex R5 (centre r 35) tangent to a concave R5
// (centre r 38.5); measured at z -10.
SKIN_R = 40.0;
SKIN_C = [[[26.346, -23.046], [21.623, -31.862]], [[26.440, 22.930], [21.753, 31.775]]];
function skin_end(cc, s) = let (
    c1 = cc[0], c2 = cc[1], m = (c1 + c2) / 2,
    t1 = c1 * SKIN_R / norm(c1), t2 = c2 * 33.496 / norm(c2))
    concat(arc_s(c2, t2, m, 16), arc_s(c1, m, t1, 16));
// (Past the fillets it steps 0.3 inside the shell's r 33.496, so no face of
// it lies on the shell's.)
SKIN_PATH = concat(
    [pol(30, -70), pol(33.2, -70)],
    arc_s(O, pol(33.2, -70), SKIN_C[0][1] * 33.2 / norm(SKIN_C[0][1]), 8),
    skin_end(SKIN_C[0]),
    arc_s(O, SKIN_C[0][0] * SKIN_R / norm(SKIN_C[0][0]), SKIN_C[1][0] * SKIN_R / norm(SKIN_C[1][0]), 96),
    reverse(skin_end(SKIN_C[1])),
    [SKIN_C[1][1] * 33.2 / norm(SKIN_C[1][1])],
    arc_s(O, SKIN_C[1][1] * 33.2 / norm(SKIN_C[1][1]), pol(33.2, 70), 8),
    [pol(30, 70)],
    arc_s(O, pol(30, 70), pol(30, -70), 48));
module skin() translate([0, 0, -29]) linear_extrude(29 + 18.5) polygon(SKIN_PATH);

// F2, the pillars: where the shell flares out (z > 3.24), the R5 fillet
// between each skin end's R5 column and the shell rolls up the flare. Its
// ball's centre stays 10 from the column's axis and on the shell profile's
// offset by 5; each station is the ball's arc between its two contacts and
// the corner beyond them, lofted.
PIL_R = 5;
// Stations' span: 0 is the flare's foot and 1 its top; past 1 each unit
// runs 0.8 of the line, so 2.5 carries the ball on past the line's end,
// where the pillar dies into the rim's bulge.
PIL_T = [0.05, 2.5];
FLARE_C = [53.519, 3.235];
FLARE_END = 136.85;                     // where the flare's R20 arc meets the line
LINE_P = [[38.912, 16.930], [40.801, 18.354]];
LINE_N = let (u = unit(LINE_P[1] - LINE_P[0])) [u.y, -u.x];
// Ball centre and shell contact in [r, z], by station t in [0, 2].
function pil_rz(t) = t <= 1
    ? let (phi = 180 + (FLARE_END - 180) * t)
        [FLARE_C + 15 * [cos(phi), sin(phi)], FLARE_C + 20 * [cos(phi), sin(phi)]]
    : let (p = LINE_P[0] + (t - 1) * 0.8 * (LINE_P[1] - LINE_P[0]))
        [p + PIL_R * LINE_N, p];
function slerp3(a, b, t) = let (w = acos(max(-1, min(1, a * b))))
    w < 0.01 ? a : (sin((1 - t) * w) * a + sin(t * w) * b) / sin(w);
function pil_section(c1, sgn, t) = let (
    rz = pil_rz(t), rc = rz[0][0], zc = rz[0][1],
    r1 = norm(c1), th1 = atan2(c1.y, c1.x),
    d = acos((rc * rc + r1 * r1 - 4 * PIL_R * PIL_R) / (2 * rc * r1)),
    th = th1 + sgn * d,
    c = [rc * cos(th), rc * sin(th), zc],
    ecol = concat(c1 + PIL_R * unit([c.x, c.y] - c1), zc),
    esh = [rz[1][0] * cos(th), rz[1][0] * sin(th), rz[1][1]],
    a = unit(ecol - c), b = unit(esh - c),
    g = acos(max(-1, min(1, a * b))),
    k = c + unit(a + b) * (PIL_R / cos(g / 2) + 1.5))
    concat([k], [for (i = [0 : 8]) c + PIL_R * slerp3(a, b, i / 8)]);
module pillars() for (s = [0, 1]) vnf_polyhedron(outward(vnf_vertex_array(
    [for (i = [0 : 20]) pil_section(SKIN_C[s][0], s == 0 ? -1 : 1, PIL_T[0] + (PIL_T[1] - PIL_T[0]) * i / 20)],
    col_wrap = true, caps = true)));

// B1, the block: the slab between its side faces, cut by its envelope (the
// skin's r 40 turning through a 10 deg cone up to r 44).
BLOCK_Y = [-15.710, 17.030];
CONE_T = tan(10);
BLOCK_ENV = [[30, -8], [40, -8], [40, -2.97], [44, -2.97 + 4 / CONE_T], [44, 30.5], [30, 30.5]];
BLOCK_CORNER = 2.0;                  // R2 on its vertical edges, R2 into the skin
function block_r(z) = min(44, max(40, 40 + CONE_T * (z + 2.97)));
// The block's plan at z: the slab cut by the envelope's circle, its corners R2.
module block_2d(z) offset(r = BLOCK_CORNER) offset(delta = -BLOCK_CORNER) intersection() {
    circle(r = block_r(z), $fn = 720);
    translate([20, BLOCK_Y[0]]) square([30, BLOCK_Y[1] - BLOCK_Y[0]]);
}
BLOCK_Z = [-3.5, -2.97, -1, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, -2.97 + 4 / CONE_T, 30.5];
// The block, lofted between its plans (each convex, so a hull is the loft).
module block_loft() for (i = [0 : len(BLOCK_Z) - 2]) hull() {
    translate([0, 0, BLOCK_Z[i]]) linear_extrude(0.01) block_2d(BLOCK_Z[i]);
    translate([0, 0, BLOCK_Z[i + 1] - 0.01]) linear_extrude(0.01) block_2d(BLOCK_Z[i + 1]);
}
// The fillets R2 where the block's sides meet the skin's r 40, kept inside
// the block's envelope.
module block_fillet_2d() for (s = [0, 1]) let (
    ys = BLOCK_Y[s], d = s == 0 ? -1 : 1, rf = BLOCK_CORNER,
    c = [sqrt((SKIN_R + rf)^2 - (ys + d * rf)^2), ys + d * rf],
    p = [sqrt(SKIN_R^2 - ys^2), ys])
    polygon(concat([p - [1, 0], [c.x, ys]], arc_s(c, [c.x, ys], c * SKIN_R / norm(c), 16), [p - [1, 0]]));
// B3, the posts R3 at the foot of the block's sides on the rim, the side
// fillets tangent to them; z 22 .. 30.5.
BLOCK_POSTS = [[34.505, -14.210], [35.190, 14.550]];
POST_R = 3.0;
module block() {
    block_loft();
    for (p = BLOCK_POSTS) translate([each p, 22]) cylinder(r = POST_R, h = 8.5, $fn = 96);
    intersection() {
        translate([0, 0, -8]) linear_extrude(38.5) block_fillet_2d();
        rotate(-60) rotate_extrude(angle = 120, $fn = 720) polygon(BLOCK_ENV);
    }
}

// V1, the front's walls seen from inside (z -29 .. 18.3), the -y half,
// measured at z 1: the shell's r 32.8, the kidney recess (R3.2 ends on
// r 35.09, floor r 38.3), its blends onto the block's r 32.5, and the
// keyhole's groove (R3 on r 34.25).
VOID_HALF = concat(
    [O, [0, -32.800]],
    arc_s(O, [0, -32.800], [22.076, -24.259], 48),
    arc_s([22.448, -26.391], [22.076, -24.259], [23.905, -24.776], 8),
    arc_s([36.222, -8.689], [23.905, -24.776], [25.013, -25.566], 4),
    arc_s([26.656, -22.815], [25.013, -25.566], [29.245, -24.701], 16),
    [[32.686, -19.943]],
    arc_s([29.936, -18.301], [32.686, -19.943], [31.822, -15.711], 16),
    arc_s([39.530, -3.923], [31.822, -15.711], [30.498, -14.722], 4),
    arc_s([31.772, -13.448], [30.498, -14.722], [30.100, -12.777], 8),
    [[29.917, -12.699]],
    arc_s(O, [29.917, -12.699], [32.316, -3.597], 24),
    arc_s([33.280, -3.886], [32.316, -3.597], [33.615, -2.928], 6),
    arc_to([34.250, 0], [33.615, -2.928], [37.250, 0], 16, true));
module void_mid() translate([0, 0, -30]) linear_extrude(48.3)
    union() { polygon(VOID_HALF); mirror([0, 1]) polygon(VOID_HALF); }

// W1, the window under the block: r < 38 between radial sides at +-23 deg,
// up to z -3, every edge R1.
module window() minkowski() {
    translate([0, 0, -31]) linear_extrude(27)
        offset(delta = -1) polygon(concat([O], arc_pts(O, 38, -23, 23, 48)));
    sphere(r = 1, $fn = 24);
}

// P1, the pocket in the block: radial walls at -9.9 and 11.9 deg, its floor
// a 45 deg chamfer from r 32.5 at z 3 out to r 39.5, up into the groove.
POCKET = concat([[30, 3 - 3], [32.5, 3], [39.080, 9.580]],
    arc_to([37.986, 10.628], [39.080, 9.580], [39.500, 10.628], 6, true),
    [[39.500, 19.000], [30, 19.000]]);
module pocket() rotate(-9.9) rotate_extrude(angle = 21.8, $fn = 720) polygon(POCKET);

// B2, the beams: on r 35 at 18.06 and -16.05 deg. Each bore is Ø4.3 up to
// z 8, Ø3.2 to the groove; in the rim Ø3.2 from the lip to z 27.5 and Ø4.3
// above. Round each, inside the pocket, a tube R3.75 stands.
BEAM_R = 35.0;
BEAM_A = [18.06, -16.05];
TUBE_R = 3.75;
BEAM_RUN = [[-5, 8, 4.3], [8, 18.5, 3.2], [23.8, 27.5, 3.2], [27.5, 31.5, 4.3]];
BEAM_SLIT = [22.0, 23.8, 3.2, 0.6];   // the aperture: z0, z1, circle Ø, width (radial)
module beam_bores() for (a = BEAM_A) translate(pol(BEAM_R, a)) {
    for (s = BEAM_RUN) translate([0, 0, s[0] - LAP]) cylinder(d = s[2], h = s[1] - s[0] + 2 * LAP, $fn = 96);
    translate([0, 0, BEAM_SLIT[0]]) linear_extrude(BEAM_SLIT[1] - BEAM_SLIT[0] + LAP) intersection() {
        circle(d = BEAM_SLIT[2], $fn = 96);
        rotate(a) square([2 * BEAM_SLIT[2], BEAM_SLIT[3]], center = true);
    }
}
module tubes() for (a = BEAM_A) translate([each pol(BEAM_R, a), -1]) cylinder(r = TUBE_R, h = 25, $fn = 96);

// P1, the pocket: radial walls at -9.9 and 11.9 deg out to r 39.5, and
// between the tubes inside r 35; the tubes stand in it.
module pocket_cut() difference() {
    union() {
        pocket();
        intersection() {
            rotate(BEAM_A[1]) rotate_extrude(angle = BEAM_A[0] - BEAM_A[1], $fn = 720) polygon(POCKET);
            cylinder(r = BEAM_R, h = 40, center = true);
        }
    }
    tubes();
}

// K1, the keyhole through the block's front: a Ø4.5 hole along x at
// (y 0.708, z 11.68), and a slot 3.0 wide from it up through the top. Up to
// the pocket's top (z 19) the slot runs straight in to the pocket; in the
// rim above, its inner end is R1.5 at x 40.495.
KEY = [0.708, 11.680, 4.500, 3.000, 40.495];
KEY_TOP = 19.0;                        // the pocket's top, where the slot's R1.5 end begins
module keyhole() {
    translate([30, KEY[0], KEY[1]]) rotate([0, 90, 0]) cylinder(d = KEY[2], h = 20, $fn = 64);
    translate([0, KEY[0], KEY[1]]) linear_extrude(KEY_TOP - KEY[1] + LAP)
        translate([38, -KEY[3] / 2]) square([13, KEY[3]]);
    translate([0, KEY[0], KEY_TOP]) linear_extrude(12) hull() {
        translate([KEY[4], 0]) circle(d = KEY[3], $fn = 48);
        translate([50, -KEY[3] / 2]) square([1, KEY[3]]);
    }
    // R2 rounds where the slot's sides leave the pocket's wall (r 39.5),
    // cut in the block only: they stop at the shell's outer surface.
    difference() { key_rounds(); shell_out(); }
}
// They run from the hole's lower edge (z 10.5) to the pocket's top; each
// starts a little inside the slot so that no face of it lies on the slot's.
KEY_ROUND_Z = 10.5;
module key_rounds() {
    translate([0, 0, KEY_ROUND_Z]) linear_extrude(KEY_TOP - KEY_ROUND_Z) for (s = [-1, 1]) let (
        ys = KEY[0] + s * KEY[3] / 2, yi = ys - s * 0.05, c = [sqrt(41.5^2 - (ys + s * 2)^2), ys + s * 2],
        p = [sqrt(39.5^2 - ys^2), ys])
        polygon(concat([[p.x - 0.5, yi], [c.x, yi]], arc_s(c, [c.x, ys], c * 39.5 / 41.5, 12),
                       [c * 39.3 / 41.5]));
}

// H1, the bosses on the rim at +-45 deg: R3.75 on r 36.25, Ø2.5 holes.
BOSS = [36.250, 3.750, 2.500];
module bosses() for (a = [45, -45]) translate([each pol(BOSS[0], a), 22]) cylinder(r = BOSS[1], h = 8.5, $fn = 96);

// H2, each boss's fillet onto the rim's outside: a ball of radius rf rolled
// round the boss, rf from its side, resting on the rim's profile (the bulge
// R3, the R3 round above it and the 45 deg chamfer, each offset by rf). It
// runs up through the top (z 30.5), which cuts it, so on the top face it
// reads as a concave round between the boss and the chamfer's edge.
BOSS_F = 2.5;
RIM_TOP = 30.5;
function rim_off_z(r, rf) = max(
    abs(r - 38.990) <= 3 + rf ? 20.750 + sqrt((3 + rf)^2 - (r - 38.990)^2) : -99,
    abs(r - 37.266) <= 3 + rf ? 23.320 + sqrt((3 + rf)^2 - (r - 37.266)^2) : -99,
    64.745 + rf * sqrt(2) - r);
// The rim profile's outward normal under a ball centre at [r, z].
function rim_normal(r, z, rf) = let (
    n1 = [r - 38.990, z - 20.750], n2 = [r - 37.266, z - 23.320], ro = 3 + rf)
    abs(norm(n1) - ro) < 0.01 ? n1 / ro : abs(norm(n2) - ro) < 0.01 ? n2 / ro : [1, 1] / sqrt(2);
// One station: the ball's arc between its two contacts, and the corner
// beyond them, inside the material.
function cyl_section(axis, rc, rf, psi) = let (
    d = [cos(psi), sin(psi)], pxy = axis + (rc + rf) * d,
    rp = norm(pxy), zc = rim_off_z(rp, rf), c = [pxy.x, pxy.y, zc],
    n = rim_normal(rp, zc, rf), u = pxy / rp,
    eb = c - rf * [d.x, d.y, 0], er = c - rf * [n[0] * u.x, n[0] * u.y, n[1]],
    a = unit(eb - c), b = unit(er - c), g = acos(max(-1, min(1, a * b))),
    k = c + unit(a + b) * (rf / cos(g / 2) + 0.8))
    concat([k], [for (i = [0 : 8]) c + rf * slerp3(a, b, i / 8)]);
// The fillet over the directions psis (degrees, in order) that keep the
// ball under the top.
module cyl_fillet(axis, rc, rf, psis) let (
    span = [for (p = psis) let (pxy = axis + (rc + rf) * [cos(p), sin(p)])
            if (rim_off_z(norm(pxy), rf) < RIM_TOP + rf - 0.2) p])
    vnf_polyhedron(outward(vnf_vertex_array([for (psi = span) cyl_section(axis, rc, rf, psi)],
                                            col_wrap = true, caps = true)));
// Cut at the top, a hair under it so that no face lies on the rim's.
module under_top() intersection() {
    children();
    cylinder(r = 50, h = 2 * (RIM_TOP - LAP), center = true);
}
module boss_fillets() under_top()
    for (s = [1, -1]) cyl_fillet(pol(BOSS[0], 45 * s), BOSS[1], BOSS_F, [for (p = [-170 : 2 : 170]) 45 * s + p]);
// B5, the notch on the block's +y side where it rises past the rim's
// chamfer: between the chamfer's edge and the +y post the side is cut back
// in a V whose tip runs down the chamfer at 45 deg, from (30.55, 15.85) at
// the top to nothing at z 27.5. Measured plans [z, [x, y] ...], lofted.
NOTCH = [[27.5, [[32.8, 17.5], [33.3, 17.5], [33.0, 17.0]]],
         [28.5, [[31.9, 17.5], [33.4, 17.5], [32.4, 16.5]]],
         [29.5, [[30.7, 17.5], [33.4, 17.5], [31.3, 16.0]]],
         [30.3, [[30.0, 17.5], [33.3, 17.5], [30.55, 15.85]]],
         [31.0, [[29.6, 17.5], [33.3, 17.5], [30.2, 15.6]]]];
module notch() for (i = [0 : len(NOTCH) - 2]) hull() {
    translate([0, 0, NOTCH[i][0]]) linear_extrude(0.01) polygon(NOTCH[i][1]);
    translate([0, 0, NOTCH[i + 1][0] - 0.01]) linear_extrude(0.01) polygon(NOTCH[i + 1][1]);
}
// The holes, Ø2.5 with a 90 deg countersink to Ø3.5 at the top.
BOSS_CSK = 3.5;
module boss_holes() for (a = [45, -45]) translate(pol(BOSS[0], a)) {
    translate([0, 0, 22.5]) cylinder(d = BOSS[2], h = 9, $fn = 48);
    translate([0, 0, RIM_TOP - (BOSS_CSK - BOSS[2]) / 2])
        cylinder(d1 = BOSS[2], d2 = BOSS_CSK + 2 * LAP, h = (BOSS_CSK - BOSS[2]) / 2 + LAP, $fn = 48);
}

// E1, the beads along the split edges: R1.5 on (1.5, +-34.3) and the flange
// x 0 .. 3 back to the shell, R0.8 into it; z -29 .. 12.5.
module bead_2d() for (s = [1, -1]) {
    translate([1.5, s * 34.3]) circle(r = 1.5, $fn = 48);
    translate([0, s > 0 ? 32.8 : -34.3]) square([3, 1.5]);
}
module beads() translate([0, 0, -29]) linear_extrude(41.5) bead_2d();

module part() difference() {
    union() { shell_out(); skin(); block(); bosses(); boss_fillets(); beads(); if (use_pillars) pillars(); }
    inner_void();
    void_mid();
    window();
    pocket_cut();
    beam_bores();
    keyhole();
    boss_holes();
    notch();
}

if (piece == "skin") skin();
else if (piece == "pillars") pillars();
else if (piece == "skinpil") union() { skin(); pillars(); }
else if (piece == "shellpil") union() { shell_out(); pillars(); }
else if (piece == "shellskin") union() { shell_out(); skin(); }
else if (piece == "outer") union() { shell_out(); skin(); block(); bosses(); beads(); pillars(); }
else part();
