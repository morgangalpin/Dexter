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
//   F2  the pillars: the concave R5 rolled up the shell's flare (lofted),
//       and F3 the R4 round where the skin's r 40 cuts them;
//   B1  the block: the slab y -15.71 .. 17.03 out to a 10 deg cone from
//       r 40 (z -2.97) to r 44, its sides R2 fillets into the skin and R2
//       rounds at its outer corners (lofted), its top between radial planes
//       at +-27 deg with R3 posts;
//   H1  the bosses on the rim at +-45 deg, R3.75 with Ø2.5 holes
//       countersunk to Ø3.5, and H2 their R2 fillets onto the rim;
//   E1  the beads along the split edges, R1.5, and E2 their R0.8 fillets
//       into the shell (lofted);
// less the voids: the inside (r 32.8, the 45 deg chamfer, the groove with
// its lip, the rim's r 32.5), V1 the front's walls seen from inside (kidney
// recesses, the block's r 32.5, the keyhole's groove), W1 the window under
// the block (R1 all round, R0.5 at the inner wall's noses), P1 the pocket in
// the block (radial walls, 45 deg floor with its R1.515, the beam tubes
// R3.75 left standing), B2 the beams (Ø4.3 / Ø3.2, in the rim Ø3.2 and
// Ø4.3 over a slit aperture), and K1 the keyhole (Ø4.5 at z 11.68, slot
// 3.0, its R2 rounds into the pocket).
//
// Each blend is drawn as the CAD made it and in its order: a ball rolled on
// the surfaces it touches (F2, H2, E2, F3), a round rolled round another
// (the window's noses), or an opening (K1's floor round).
//
// GATE (scadmesh dist, both directions): 0.093 / 0.116 mm, under the 0.15
// tolerance. The reference is the mesh as repaired in place (README § Known
// defects): a skin of the shell left inside the pocket is cut away.
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
function slerp3(a, b, t) = let (w = acos(max(-1, min(1, a * b))))
    w < 0.01 ? a : (sin((1 - t) * w) * a + sin(t * w) * b) / sin(w);
// One station of a rolling-ball fillet: the ball's arc (radius rf about c)
// between its contacts e1 and e2, and a corner beyond them, over deep into
// the material. The fillets F2 and E2 are lofts of these.
function ball_section(c, e1, e2, rf, over) = let (
    a = unit(e1 - c), b = unit(e2 - c), g = acos(max(-1, min(1, a * b))))
    concat([c + unit(a + b) * (rf / cos(g / 2) + over)], [for (i = [0 : 8]) c + rf * slerp3(a, b, i / 8)]);

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
    [[0, 12.0], [32.4, 12.0], [32.4, 12.4], [38.121, 18.121]],
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
// ball's centre stays 10 from the column's axis and on the flare's R20
// offset by 5 (R15 about the flare's centre); each station is the ball's arc
// between its two contacts and the corner beyond them, lofted.
PIL_R = 5;
// The stations' span, as the angle about the flare's centre: from the
// flare's foot (180) on past its end (136.85, where the shell turns to a
// straight line) to the end of the ball's reach (its centre 10 straight out
// from the column's axis). Past the flare's end the ball still rolls on the
// R20 continued, under the shell's line, so the shell's line and bulge
// cover the pillar's top and meet it in a crease. Near the top the fillet
// stands out past the skin's r 40; the CAD cut it there and rounded the
// edge R4 (F3).
PIL_PHI0 = 177.84;
PIL_TOP = 18.5;                         // the cut over it, under the rim's bulge
FLARE_C = [53.519, 3.235];
function pil_end(c1) = acos((norm(c1) + 2 * PIL_R - FLARE_C.x) / 15);
function pil_phis(c1) = let (e = pil_end(c1) + 0.01)
    concat([for (i = [0 : 47]) PIL_PHI0 + (126 - PIL_PHI0) * i / 48], [for (t = [0 : 6]) 126 + (e - 126) * (1 - (1 - t / 6)^2)]);
// Ball centre and shell contact in [r, z], by the angle phi.
function pil_rz(phi) = [FLARE_C + 15 * [cos(phi), sin(phi)], FLARE_C + 20 * [cos(phi), sin(phi)]];
// The ball's centre, by phi, for the column c1 (sgn: the side it rolls to).
function pil_c(c1, sgn, phi) = let (
    rz = pil_rz(phi), rc = rz[0][0], r1 = norm(c1),
    th = atan2(c1.y, c1.x) + sgn * acos(min(1, (rc * rc + r1 * r1 - 4 * PIL_R * PIL_R) / (2 * rc * r1))))
    [rc * cos(th), rc * sin(th), rz[0][1]];
function pil_section(c1, sgn, phi) = let (c = pil_c(c1, sgn, phi), s = pil_rz(phi)[1], u = unit([c.x, c.y]))
    ball_section(c, concat(c1 + PIL_R * unit([c.x, c.y] - c1), c.z), [s[0] * u.x, s[0] * u.y, s[1]], PIL_R, 1.5);
module pillars() difference() {
    intersection() {
        for (s = [0, 1]) vnf_polyhedron(outward(vnf_vertex_array(
            [for (phi = pil_phis(SKIN_C[s][0])) pil_section(SKIN_C[s][0], s == 0 ? -1 : 1, phi)],
            col_wrap = true, caps = true)));
        cylinder(r = SKIN_R, h = 2 * PIL_TOP, center = true, $fn = 720);
    }
    for (s = [0, 1]) pil_round(SKIN_C[s][0], s == 0 ? -1 : 1);
}

// F3, the R4 round of the edge where the skin's r 40 cuts the pillar: a
// ball inside, 4 from r 40 and 9 from the R5 ball's centres, rolled along
// the edge. At each height z of its centre, its angle from the column comes
// by bisection; the cut is the corner between its contacts and beyond the
// edge, less the ball swept.
PIL_RND = 4;
// [distance, centre] of the nearest R5 ball centre to p.
function pil_near(c1, sgn, p) = let (
    ds = [for (phi = [pil_end(c1) : 0.25 : 178]) let (c = pil_c(c1, sgn, phi)) [norm(p - c), c]])
    ds[min_index([for (d = ds) d[0]])];
function pil_q(c1, sgn, z, t) = let (th = atan2(c1.y, c1.x) + sgn * t)
    concat((SKIN_R - PIL_RND) * [cos(th), sin(th)], z);
function pil_f(c1, sgn, z, t) = pil_near(c1, sgn, pil_q(c1, sgn, z, t))[0] - PIL_R - PIL_RND;
function pil_bisect(c1, sgn, z, lo, hi, n) = n == 0 ? (lo + hi) / 2 : let (m = (lo + hi) / 2)
    pil_f(c1, sgn, z, m) > 0 ? pil_bisect(c1, sgn, z, m, hi, n - 1) : pil_bisect(c1, sgn, z, lo, m, n - 1);
// [ball centre, the corner's points] at height z, or [] where there is no edge.
function pil_rnd_station(c1, sgn, z) =
    pil_f(c1, sgn, z, 0) <= 0 || pil_f(c1, sgn, z, 12) >= 0 ? [] : let (
        q = pil_q(c1, sgn, z, pil_bisect(c1, sgn, z, 0, 12, 18)),
        u1 = concat(unit([q.x, q.y]), 0), w = unit(pil_near(c1, sgn, q)[1] - q),
        t1 = q + PIL_RND * u1, t2 = q + PIL_RND * w, g = acos(u1 * w))
    pil_near(c1, sgn, t1)[0] < PIL_R ? [] : [q, [t1, t2, q + (PIL_RND / cos(g / 2) + 1) * unit(u1 + w)]];
module pil_round(c1, sgn) let (
    st = [for (z = [13 : 0.25 : 21]) let (s = pil_rnd_station(c1, sgn, z)) if (len(s) > 0) s])
    difference() {
        for (i = [0 : len(st) - 2]) let (p = concat(st[i][1], st[i + 1][1])) polyhedron(p, hull(p));
        for (i = [0 : len(st) - 2]) hull() for (j = [i, i + 1]) translate(st[j][0]) sphere(r = PIL_RND, $fn = 64);
    }

// B1, the block: the slab between its side planes (y -15.71 and 17.03),
// its outside the skin's r 40 turning through a 10 deg cone (from z -2.97)
// up to r 44. Its vertical edges are rounded in the CAD's order: first the
// R2 fillets from each side into the skin's r 40, vertical cylinders on
// fixed axes (on r 42, 2 out from the side plane); then the R2 rounds of
// its outer corners, each resting on the outside (centre on r_out - 2) and
// on that fillet (centre 4 from its axis). The side plane itself is used
// up, so the plan is an S-curve, convex R2 into concave R2, which stands
// out past the side plane as the cone widens. Above the rim radial planes
// at +-27 deg cut it, and R3 posts round the edges where those planes meet
// the fillets.
CONE_T = tan(10);
CONE_Z = [-2.97, -2.97 + 4 / CONE_T];   // the cone, from r 40 to r 44
function r_out(z) = min(44, max(40, 40 + CONE_T * (z - CONE_Z[0])));
BLOCK_A = [[38.090, -17.710], [37.442, 19.024]];  // the fillets' axes, -y and +y
BLOCK_R = 2.0;                                  // the fillets and the corner rounds
BLOCK_WEDGE = 27;
BLOCK_POSTS = [[34.505, -14.208], [35.191, 14.569]];
POST_R = 3.0;
function arc_open(c, p0, p1, n) = let (a = arc_s(c, p0, p1, n)) [for (i = [0 : n - 1]) a[i]];
// The corner round's centre for side s (0: -y, 1: +y) when the outside is r R.
function corner_c(s, R) = let (
    A = BLOCK_A[s], ra = norm(A), rc = R - BLOCK_R,
    d = acos(min(1, (rc * rc + ra * ra - 4 * BLOCK_R * BLOCK_R) / (2 * rc * ra))))
    pol(rc, atan2(A.y, A.x) + (s == 0 ? d : -d));
// Where the corner round meets the fillet.
function block_T(s, R) = (BLOCK_A[s] + corner_c(s, R)) / 2;
// The outside of the plan, from the -y side's T up to the +y side's: the
// corner rounds and the outer arc.
function block_outside(R, n) = let (cm = corner_c(0, R), cp = corner_c(1, R))
    concat(arc_open(cm, block_T(0, R), cm * R / norm(cm), n),
           arc_open(O, cm * R / norm(cm), cp * R / norm(cp), 3 * n),
           arc_open(cp, cp * R / norm(cp), block_T(1, R), n));
// The plan below the rim at z: from the skin up the -y fillet, round the
// outside, down the +y fillet, and closed inside the skin.
function block_plan(z, n = 12) = let (
    R = r_out(z), Sm = BLOCK_A[0] * SKIN_R / norm(BLOCK_A[0]), Sp = BLOCK_A[1] * SKIN_R / norm(BLOCK_A[1]))
    concat(arc_open(BLOCK_A[0], Sm, block_T(0, R), n), block_outside(R, n),
           arc_open(BLOCK_A[1], block_T(1, R), Sp, n), [Sp], arc_s(O, Sp * 0.9, Sm * 0.9, n));
// The loft's stations, closer where the S-curve opens from nothing; below
// the first, the first again shrunk under the skin.
BLOCK_Z = [-2.9, -2.8, -2.6, -2.3, -1.9, -1.4, -0.8, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
           14, 15, 16, 17, 18, 19, CONE_Z[1]];
module block_loft() vnf_polyhedron(outward(vnf_vertex_array(
    concat([[for (p = block_plan(BLOCK_Z[0])) concat(p * 0.999, BLOCK_Z[0] - 0.1)]],
           [for (z = BLOCK_Z) [for (p = block_plan(z)) concat(p, z)]]),
    col_wrap = true, caps = true)));
// The plan above the cone (r 44): each side runs from its radial plane
// round its post (tangent to the plane at W and to the fillet at Q) and
// along the fillet to the corner round.
function post_WQ(s) = let (P = BLOCK_POSTS[s], A = BLOCK_A[s])
    [P + POST_R * [-sin(BLOCK_WEDGE), (s == 0 ? -1 : 1) * cos(BLOCK_WEDGE)], A + BLOCK_R * unit(P - A)];
function block_top_plan(n = 12) = let (m = post_WQ(0), p = post_WQ(1))
    concat([pol(30, -BLOCK_WEDGE)], arc_open(BLOCK_POSTS[0], m[0], m[1], n),
           arc_open(BLOCK_A[0], m[1], block_T(0, 44), n), block_outside(44, n),
           arc_open(BLOCK_A[1], block_T(1, 44), p[1], n), arc_open(BLOCK_POSTS[1], p[1], p[0], n),
           [p[0]], arc_open(O, pol(30, BLOCK_WEDGE), pol(30, -BLOCK_WEDGE), 2 * n));
module block() {
    block_loft();
    translate([0, 0, CONE_Z[1] - 0.01]) linear_extrude(RIM_TOP - CONE_Z[1] + 0.01) polygon(block_top_plan());
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
WIN_A = 23;
module window() minkowski() {
    translate([0, 0, -31]) linear_extrude(27)
        offset(delta = -0.995) polygon(concat([O], arc_pts(O, 38, -WIN_A, WIN_A, 48)));
    sphere(r = 1, $fn = 96);
}
// Where each window side cuts the R1.8 nose of the inner wall (V1, centre
// NOSE_C, on the side's plane to 0.03), the vertical edge is rounded R0.5,
// and the window's R1 ceiling fillet then runs round that round: about the
// round's axis the wall stands out 1.5 - sqrt(1 - (z + 4)^2) at height z.
// Past the nose, where the side's plane is the void's own face, the wall
// has no ceiling fillet, so the cut takes the corner's whole sector, from
// the side round to the nose, less that solid of revolution.
NOSE_C = [31.772, -13.448];
NOSE_R = 1.8;
WIN_RND = 0.5;
WIN_FIL = 1;
// [the round's axis, the sector's outline] for the -y side.
function nose_cut() = let (
    u = [cos(WIN_A), -sin(WIN_A)], m = [sin(WIN_A), cos(WIN_A)],
    qm = -NOSE_C * m - WIN_RND, q = NOSE_C - sqrt((NOSE_R - WIN_RND)^2 - qm^2) * u + qm * m)
    [q, [q, q + 3 * m, q + 3 * unit(m - u), q - 3 * u, q + 3 * unit(q - NOSE_C)]];
// The round and its fillet about the axis, as [radius, z].
NOSE_FIL = concat([[0, -33], [WIN_RND, -33]],
    [for (i = [0 : 16]) let (z = -4 + i / 16) [WIN_RND + WIN_FIL - sqrt(WIN_FIL^2 - (z + 4)^2), z]],
    [[WIN_RND + WIN_FIL, -2], [0, -2]]);
module nose_rounds() for (k = [0, 1]) mirror([0, k, 0]) let (c = nose_cut()) difference() {
    translate([0, 0, -32]) linear_extrude(29) polygon(c[1]);
    translate(c[0]) rotate_extrude($fn = 96) polygon(NOSE_FIL);
}

// P1, the pocket in the block: radial walls at -9.9 and 11.9 deg, its floor
// a 45 deg chamfer from r 32.5 at z 3 out to r 39.5, R1.515 into the wall;
// at z 19 the wall steps in to r 39.0 and runs up into the groove.
POCKET = concat([[30, 3 - 3], [32.5, 3], [39.080, 9.580]],
    arc_to([37.986, 10.628], [39.080, 9.580], [39.500, 10.628], 6, true),
    [[39.500, 19.000], [39.000, 19.000], [39.000, 21.000], [30, 21.000]]);
module pocket() rotate(-9.9) rotate_extrude(angle = 21.8, $fn = 720) polygon(POCKET);

// B2, the beams: on r 35 at 18.06 and -16.05 deg. Each bore is Ø4.3 up to
// z 8, Ø3.2 to the groove; in the rim Ø3.2 from the lip to z 27.5 and Ø4.3
// above. Round each, inside the pocket, a tube R3.75 stands.
BEAM_R = 35.0;
BEAM_A = [18.06, -16.05];
TUBE_R = 3.75;
BEAM_RUN = [[-5, 8, 4.3], [8, 18.5, 3.2]];
// In the rim, from above: Ø3.2 down to its floor at z 23.5, R1 round the
// floor's edge, and Ø4.3 down to z 27.5, R0.5 round its floor's edge; the
// meridional profile [r, z] about the beam's axis.
BEAM_RIM = concat([[0, 23.5], [0.6, 23.5]], arc_to([0.6, 24.5], [0.6, 23.5], [1.6, 24.5], 8, true),
    [[1.6, 27.5], [1.65, 27.5]], arc_to([1.65, 28.0], [1.65, 27.5], [2.15, 28.0], 6, true),
    [[2.15, 31.5], [0, 31.5]]);
// The aperture through that floor, from the groove: a slot 3.108 long
// (radially, centred on r 34.99) and 0.65 wide; over the floor a band 0.85
// wide on the same line clears the floor's R1 across the bore.
BEAM_SLIT = [22.0, 23.5, 34.99, 3.108, 0.65];   // z0, z1, r, length, width
BEAM_BAND = [24.6, 0.85];                       // its top, its width
module beam_bores() for (a = BEAM_A) translate(pol(BEAM_R, a)) {
    for (s = BEAM_RUN) translate([0, 0, s[0] - LAP]) cylinder(d = s[2], h = s[1] - s[0] + 2 * LAP, $fn = 96);
    rotate_extrude($fn = 96) polygon(BEAM_RIM);
    rotate(a) translate([BEAM_SLIT[2] - BEAM_R, 0, BEAM_SLIT[0]])
        linear_extrude(BEAM_SLIT[1] - BEAM_SLIT[0] + LAP) square([BEAM_SLIT[3], BEAM_SLIT[4]], center = true);
    intersection() {
        rotate(a) translate([0, 0, BEAM_SLIT[1] - LAP])
            linear_extrude(BEAM_BAND[0] - BEAM_SLIT[1]) square([4, BEAM_BAND[1]], center = true);
        cylinder(r = 1.6, h = 2 * BEAM_BAND[0], $fn = 96);
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
// (y 0.708, z 11.68), and a slot 3.0 wide from it up through the top. The
// slot's inner end is R1.5 at x 40.495 (on the groove's r 39.0); in the
// block, outside the shell, the slot runs straight in to the pocket, and
// R2 rounds take its sides into the pocket's wall (r 39.5). The rounds run
// down to the pocket's floor, and the floor's R1.515 round then runs along
// the floor's edge with them as with the wall.
KEY = [0.708, 11.680, 4.500, 3.000, 40.495];
KEY_TOP = 19.0;                        // the pocket's top
module keyhole() {
    translate([30, KEY[0], KEY[1]]) rotate([0, 90, 0]) cylinder(d = KEY[2], h = 20, $fn = 64);
    translate([0, KEY[0], KEY[1]]) linear_extrude(RIM_TOP + 1 - KEY[1]) hull() {
        translate([KEY[4], 0]) circle(d = KEY[3], $fn = 48);
        translate([50, -KEY[3] / 2]) square([1, KEY[3]]);
    }
    difference() {
        union() {
            translate([0, KEY[0], KEY[1]]) linear_extrude(KEY_TOP - KEY[1] + LAP)
                translate([38, -KEY[3] / 2]) square([13, KEY[3]]);
            key_floor();
        }
        shell_out();
    }
}
// The R2 rounds' plan; each starts a little inside the slot so that no face
// of it lies on the slot's.
module key_rounds_2d() for (s = [-1, 1]) let (
    ys = KEY[0] + s * KEY[3] / 2, yi = ys - s * 0.05, c = [sqrt(41.5^2 - (ys + s * 2)^2), ys + s * 2],
    p = [sqrt(39.5^2 - ys^2), ys])
    polygon(concat([[p.x - 0.5, yi], [c.x, yi]], arc_s(c, [c.x, ys], c * 39.5 / 41.5, 12), [c * 39.3 / 41.5]));
// The pocket by the keyhole, with the rounds and the slot's start, opened
// by the floor's round: the plan eroded by POCKET_RND, over the floor's
// chamfer (z = r - 29.5) raised by as much, swept by the ball. The slot is
// narrower than the ball, so the opening drops it; the keyhole restores it.
POCKET_RND = 1.515;
module key_floor() intersection() {
    minkowski() {
        intersection() {
            linear_extrude(KEY_TOP + 3) offset(r = -POCKET_RND, $fn = 96) union() {
                intersection() { circle(r = 39.5, $fn = 720); translate([30, -4]) square([10, 9.5]); }
                key_rounds_2d();
                translate([38, KEY[0] - KEY[3] / 2]) square([6, KEY[3]]);
            }
            rotate_extrude($fn = 720) let (z0 = -29.5 + POCKET_RND * sqrt(2))
                polygon([[0, z0], [60, z0 + 60], [0, z0 + 60]]);
        }
        sphere(r = POCKET_RND, $fn = 48);
    }
    cylinder(r = 50, h = KEY_TOP + LAP);
}

// H1, the bosses on the rim at +-45 deg: R3.75 on r 36.25, Ø2.5 holes.
BOSS = [36.250, 3.750, 2.500];
module bosses() for (a = [45, -45]) translate([each pol(BOSS[0], a), 22]) cylinder(r = BOSS[1], h = 8.5, $fn = 96);

// H2, each boss's fillet onto the rim's outside: a ball of radius rf rolled
// round the boss, rf from its side, resting on the rim's profile (the bulge
// R3, the R3 round above it and the 45 deg chamfer, each offset by rf). The
// CAD rolled it before cutting the top: the chamfer's cone runs on above
// z 30.5 and the top cuts the fillet, so on the top face it reads as a
// concave round between the boss and the chamfer's edge.
BOSS_F = 2.0;
RIM_TOP = 30.5;
// The rim profile's offset by rf, piece by piece, each only over its own
// span: [z, outward normal] of the ball's centre over r, from the bulge R3,
// the R2.94 round, the chamfer (continued upward) and its lower end (the
// concave R2 between the bulge and the round is where their offsets cross).
function off_arc(r, c, R, a0, a1) = abs(r - c.x) <= R
    ? let (v = c.y + sqrt(R * R - (r - c.x)^2), a = atan2(v - c.y, r - c.x))
        (a >= a0 && a <= a1 ? [[v, [r - c.x, v - c.y] / R]] : [])
    : [];
function rim_env(r, rf) = let (
    f = r - rf / sqrt(2),
    p = concat(off_arc(r, [38.990, 20.750], 3 + rf, -53, 54.2), off_arc(r, [37.266, 23.320], 2.94 + rf, 16.7, 45),
               f <= 39.336 ? [[64.745 + rf * sqrt(2) - r, [1, 1] / sqrt(2)]] : [],
               off_arc(r, [39.336, 25.411], rf, 40, 50)))
    len(p) == 0 ? [99, [0, 1]] : p[max_index([for (q = p) q[0]])];
// One station, the ball rf out from the boss in the direction psi:
// [that direction, the ball's centre, the rim's normal under it].
function boss_station(axis, rc, rf, psi) = let (
    d = [cos(psi), sin(psi)], pxy = axis + (rc + rf) * d, env = rim_env(norm(pxy), rf))
    [d, [pxy.x, pxy.y, env[0]], env[1]];
// The corner the ball fills at a station: its contacts with the boss and
// the rim, and points under them inside the material (not the ball's
// centre: where the rim falls away past the contact, the triangle to the
// centre would take in air).
function boss_corner(st, rf) = let (
    d = concat(st[0], 0), c = st[1], n = st[2], u = unit([c.x, c.y]),
    nr = [n[0] * u.x, n[0] * u.y, n[1]], eb = c - rf * d, er = c - rf * nr)
    [eb - 0.05 * d, er, er - 0.3 * nr, [eb.x, eb.y, min(er.z, c.z) - rf - 0.5] - 0.05 * d];
// The fillet over the directions psis (degrees, in order) whose corner
// with the cone lies under the top (outside the chamfer's edge, r 34.245,
// and a margin): the corners between stations, less the ball swept along
// its centre's path.
module cyl_fillet(axis, rc, rf, psis) let (
    st = [for (p = psis) let (s = boss_station(axis, rc, rf, p)) if (norm(axis + rc * s[0]) > 34.245 - 0.3) s])
    difference() {
        for (i = [0 : len(st) - 2]) let (p = concat(boss_corner(st[i], rf), boss_corner(st[i + 1], rf)))
            polyhedron(p, hull(p));
        for (i = [0 : len(st) - 2]) hull() for (j = [i, i + 1]) translate(st[j][1]) sphere(r = rf, $fn = 48);
    }
// Cut at the top, a hair under it so that no face lies on the rim's.
module under_top() intersection() {
    children();
    cylinder(r = 50, h = 2 * (RIM_TOP - LAP), center = true);
}
module boss_fillets() under_top()
    for (s = [1, -1]) cyl_fillet(pol(BOSS[0], 45 * s), BOSS[1], BOSS_F, [for (p = [-170 : 0.5 : 170]) 45 * s + p]);
// The holes, Ø2.5 with a 90 deg countersink to Ø3.5 at the top.
BOSS_CSK = 3.5;
module boss_holes() for (a = [45, -45]) translate(pol(BOSS[0], a)) {
    translate([0, 0, 22.5]) cylinder(d = BOSS[2], h = 9, $fn = 48);
    translate([0, 0, RIM_TOP - (BOSS_CSK - BOSS[2]) / 2])
        cylinder(d1 = BOSS[2], d2 = BOSS_CSK + 2 * LAP, h = (BOSS_CSK - BOSS[2]) / 2 + LAP, $fn = 48);
}

// E1, the beads along the split edges: R1.5 on (1.5, +-34.3) and the flange
// x 0 .. 3 back to the shell; z -29 .. 12.5.
BEAD = [1.5, 34.3, 1.5];                // the bead's centre and radius
module bead_2d() for (s = [1, -1]) {
    translate([BEAD[0], s * BEAD[1]]) circle(r = BEAD[2], $fn = 48);
    translate([0, s > 0 ? 32.8 : -34.3]) square([3, 1.5]);
}
// E2, the fillet R0.8 from the flange's face (x 3) into the shell; where
// the shell flares out past the face, from the bead itself. The ball rests
// on the shell's r 33.496 and then on its R20 flare, each offset by 0.8.
BEAD_F = 0.8;
function bead_station(zc) = let (
    rf = BEAD_F, R20 = norm([33.496, 3.244] - FLARE_C),
    rc = zc <= FLARE_C.y ? 33.496 + rf : FLARE_C.x - sqrt((R20 - rf)^2 - (zc - FLARE_C.y)^2),
    yf = sqrt(rc * rc - (3 + rf)^2), B = [BEAD[0], BEAD[1]],
    // on the face, or else on the bead (the circle rc about O meets the
    // bead's circle BEAD[2] + rf on the flange's side)
    cb = let (d = norm(B), a = (rc * rc - (BEAD[2] + rf)^2 + d * d) / (2 * d))
        a * B / d + sqrt(rc * rc - a * a) * [B.y, -B.x] / d,
    cxy = yf <= BEAD[1] ? [3 + rf, yf] : cb,
    e1 = yf <= BEAD[1] ? [3, yf] : B + BEAD[2] * unit(cb - B),
    n = zc <= FLARE_C.y ? [1, 0] : (FLARE_C - [rc, zc]) / (R20 - rf),
    c = concat(cxy, zc))
    ball_section(c, concat(e1, zc), c - rf * concat(n[0] * unit(cxy), n[1]), rf, 0.3);
// Up to z 12.4, where the shell swallows the bead.
BEAD_Z = concat([-29.5], [for (z = [3.2 : 0.4 : 12.4]) z]);
module bead_fillets() intersection() {
    for (s = [1, -1]) mirror([0, s < 0 ? 1 : 0, 0])
        vnf_polyhedron(outward(vnf_vertex_array([for (z = BEAD_Z) bead_station(z)], col_wrap = true, caps = true)));
    translate([0, 0, -29]) cylinder(r = 50, h = 41.5);
}
module beads() translate([0, 0, -29]) linear_extrude(41.5) bead_2d();

module part() difference() {
    union() { shell_out(); skin(); block(); bosses(); boss_fillets(); beads(); bead_fillets(); if (use_pillars) pillars(); }
    inner_void();
    void_mid();
    window();
    nose_rounds();
    pocket_cut();
    beam_bores();
    keyhole();
    boss_holes();
}

if (piece == "skin") skin();
else if (piece == "pillars") pillars();
else if (piece == "skinpil") union() { skin(); pillars(); }
else if (piece == "shellpil") union() { shell_out(); pillars(); }
else if (piece == "shellskin") union() { shell_out(); skin(); }
else if (piece == "outer") union() { shell_out(); skin(); block(); bosses(); beads(); pillars(); }
else part();
