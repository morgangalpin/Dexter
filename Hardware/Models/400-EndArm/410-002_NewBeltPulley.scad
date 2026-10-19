// #410-002 New Belt Pulley — parametric source.
// The inner channel's stage-1 driven pulley at the elbow: twin 100T GT2 bands
// on a hub that turns in the two Axis Intersection Halves' 6807s (008.7 steps
// 1-5). Three 6703s in its bore carry the Internal Inner Pulley's tube (step
// 7), and its four pegs locate the End Arm Hub's four back holes (step 8).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/400-EndArm/), in that mesh's
//                         frame.
//   config = "revised"  — the same part with its print fits drawn (FITS).
//
// FRAME. The axis is +Z through the origin, the lower journal's end at z -9
// and the pegged face at z 38. The rod holes are on the axes and the windows
// and pegs on the diagonals. The reference mesh is already in this frame.
//
// CONSTRUCTION. A region split (the mesh-to-scad ladder's rung 8) into two
// turned bodies that meet on the shoulders' cylinder, r 19.5:
//   1. the hub, a revolved profile (rung 3) inside r 19.5: the two 6807
//      journals and shoulders, the bore with its 6703 pockets and their R1
//      edges, less the four rod holes (rung 2, patterned);
//   2. the web, a revolved profile outside r 19.5 (lapped into the hub): the
//      three flanges and the bands' core, with two 100T tooth rings of
//      ../gt2_pulley.scad (rung 7), less the four windows, each one 2D outline
//      extruded through it (rung 1). Cut from the web alone, a window's inner
//      wall is the hub's own cylinder;
//   3. the four pegs, cylinders on the top face.
//
// A window is the annular band between the shoulder and W1's outer circle.
// Each end is three arcs, all convex: a flank circle touching the inner
// circle, one touching the outer, and a smaller tip circle lying inside both
// and touching each, whose centre follows from those two touches. The window
// is drawn as one outline of those arcs. An opening of the flanks' lens by the
// tip radius was tried first: at so shallow a corner it rounded far past the
// tip and left 0.144. Three ends stop 0.11 deg short of the others (END_TRIM),
// so the four windows are not copies; a turn of those ends fits them to 0.112,
// and the rest of that is on their inner flanks. `layer = "web"`
// draws the section through the middle flange in 2D, for verification against
// the mesh's section (scadmesh outline; render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/radial/slice/arcs/profile
// and teeth. The feature IDs are those of 410-002_NewBeltPulley.view.json,
// which labels each one on the mesh:
//
//     ID  feature                     value
//     J1  6807 journals               Ø35.000, z -9 .. -2 and 28 .. 38
//     J2  shoulders                   Ø39.000, z -2 .. 0.5 and 25.5 .. 28
//     F1  flanges, 3                  Ø64.000, z 0.5 .. 2.0, 11.5 .. 14.5 and
//                                     24.0 .. 25.5; each 0.4 x 45 deg chamfered
//                                     on the face toward a band
//     T1  100T GT2 bands, 2           z 2.0 .. 11.5 and 14.5 .. 24.0; tip
//                                     Ø63.144, root Ø61.571, a groove on 0 deg;
//                                     gt2_pulley.scad's rounded-tip form, as the
//                                     Internal pulleys' (the plain form: p95 0.116)
//     B1  bore                        Ø21.000
//     B2  6703 pockets                Ø23.000, z -9 .. -3.5 and 29.5 .. 38; the
//                                     bore's edge into each floor R1
//     H1  rod holes, 4 on the axes    Ø3.000 at r 15.250, through
//     W1  windows, 4 on the diagonals r 19.5 .. 28.28, through the web; each
//                                     end's inner flank R5.0 and outer R4.91,
//                                     their centres 28.4 and 28.0 deg off the
//                                     window's middle; tip R4.05; the ends either
//                                     side of +Y, and the 45 deg window's end by
//                                     +X, 0.11 deg shorter
//     P1  pegs, 4 on the diagonals    Ø5.000 at r 14.500, z 38 .. 41.75
//
// FITS (../print_fit.scad), revised only:
//
//     J1, in the 6807's 35 mm bore              press
//     B2, on the 6703's Ø23 OD                  press
//     H1, on the M3 all-thread                  slip
//     P1, in the End Arm Hub's back holes       slip (two printed parts)

include <../gt2_pulley.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or the section through the middle flange in 2D
layer = "part"; // [part, web]

/* [Hidden] */
$fn = 240;
epsilon = 0.01;

TEETH      = 100;                          // T1
TIP_D      = 63.144;                       // T1, measured
BANDS      = [[2.000, 11.500], [14.500, 24.000]];   // T1: z spans
ROOT_CLEAR = 0.1;                          // the web's core stops this far inside the grooves
FLANGE     = [32.000, 0.400];              // F1: radius, chamfer
FLANGES    = [[0.500, 2.000], [11.500, 14.500], [24.000, 25.500]];   // F1: z spans
JOURNAL    = [35.000, -9.000, -2.000, 28.000, 38.000];   // J1: Ø, lower span, upper span
SHOULDER   = [39.000, 0.500, 25.500];      // J2: Ø; the web spans z 0.5 .. 25.5 between them
BORE       = [21.000, 23.000, -3.500, 29.500, 1.000];
                                           // B1, B2: bore Ø, pocket Ø, lower floor z,
                                           //         upper floor z, edge round
HOLE       = [15.250, 3.000];              // H1: centre radius, diameter
WINDOW     = [28.280, 5.000, 28.400, 4.910, 28.000, 4.050];
                                           // W1: outer r; inner flank R, its angle off
                                           //     the middle; outer flank R, its angle;
                                           //     tip R
END_TRIM   = [[0.11, 0.11], [0.11, 0], [0, 0], [0, 0]];
                                           // W1: each window's [lower, upper] end turned
                                           //     in, in deg, from 45 deg + 90 deg k
PEG        = [14.500, 5.000, 41.750];      // P1: centre radius, diameter, top z
LAP        = 0.005;                        // the web's lap into the hub
BEARING    = [35.000, 23.000];             // 6807 ID, 6703 OD
M3_D       = 3.000;
PEG_HOLE_D = 5.000;                        // the End Arm Hub's back holes, as drawn

FITS = fit_clearances(config);
function journal_d() = min(JOURNAL[0], fit_pin(BEARING[0], FITS[1]));
function pocket_d()  = max(BORE[1], fit_bore(BEARING[1], FITS[1]));
function hole_d()    = max(HOLE[1], fit_bore(M3_D, FITS[0]));
function peg_d()     = min(PEG[1], fit_pin(PEG_HOLE_D, FITS[0]));

function arc(c, r, a0, a1, n = 8) = [for (i = [0 : n]) c + r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];

// The hub's outline [r, z]: the bore with its pockets and R1 edges, and the
// journals and shoulders.
function hub_profile() =
    let (rb = BORE[0] / 2, rp = pocket_d() / 2, rj = journal_d() / 2, rs = SHOULDER[0] / 2, e = BORE[4])
    concat([[rp, JOURNAL[1]], [rj, JOURNAL[1]], [rj, JOURNAL[2]], [rs, JOURNAL[2]],
            [rs, JOURNAL[3]], [rj, JOURNAL[3]], [rj, JOURNAL[4]], [rp, JOURNAL[4]],
            [rp, BORE[3]]],
           arc([rb + e, BORE[3] - e], e, 90, 180),
           arc([rb + e, BORE[2] + e], e, 180, 270),
           [[rp, BORE[2]]]);

// The web's outline [r, z]: three chamfered flanges and the bands' core.
function web_profile() =
    let (ri = SHOULDER[0] / 2 - LAP, rf = FLANGE[0], c = FLANGE[1],
         rc = gt2_root_d(TIP_D) / 2 - ROOT_CLEAR,
         f = FLANGES, b = BANDS)
    [[ri, f[0][0]], [rf, f[0][0]], [rf, f[0][1] - c], [rf - c, f[0][1]], [rc, b[0][0]],
     [rc, b[0][1]], [rf - c, f[1][0]], [rf, f[1][0] + c], [rf, f[1][1] - c], [rf - c, f[1][1]],
     [rc, b[1][0]], [rc, b[1][1]], [rf - c, f[2][0]], [rf, f[2][0] + c], [rf, f[2][1]],
     [ri, f[2][1]]];

module tooth_rings() {
    for (b = BANDS) translate([0, 0, b[0] - epsilon]) linear_extrude(b[1] - b[0] + 2 * epsilon)
        difference() {
            gt2_teeth_rounded_2d(TEETH, TIP_D);
            circle(r = gt2_root_d(TIP_D) / 2 - 3 * ROOT_CLEAR);
        }
}

// One window, centred on +X, as one outline: the inner circle, then each end's
// three arcs, the outer circle, and the other end mirrored. Each flank circle
// touches its band circle, and the tip circle lies inside both flank circles,
// touching each; its centre is where those two touches put it.
function dir(a) = [cos(a), sin(a)];
function ang(v) = atan2(v.y, v.x);
function arc_pts(c, r, a0, a1, n) = [for (i = [0 : n]) c + r * dir(a0 + (a1 - a0) * i / n)];

// The point at distances d1 from p1 and d3 from p3, on the side away from the axis.
function meet(p1, d1, p3, d3) =
    let (d = norm(p3 - p1), a = (d1 * d1 - d3 * d3 + d * d) / (2 * d),
         h = sqrt(max(0, d1 * d1 - a * a)), u = (p3 - p1) / d, m = p1 + a * u,
         q1 = m + h * [-u.y, u.x], q2 = m - h * [-u.y, u.x])
    ang(q1) > ang(q2) ? q1 : q2;

// The upper end's outline, from the inner circle to the outer.
function window_end() =
    let (ri = SHOULDER[0] / 2, ro = WINDOW[0], r1 = WINDOW[1], r3 = WINDOW[3], rt = WINDOW[5],
         c1 = (ri + r1) * dir(WINDOW[2]), c3 = (ro - r3) * dir(WINDOW[4]),
         ct = meet(c1, r1 - rt, c3, r3 - rt),
         t1 = ang(ct - c1), t3 = ang(ct - c3))
    concat(arc_pts(c1, r1, WINDOW[2] + 180, t1, 16),
           arc_pts(ct, rt, t1, t3, 16),
           arc_pts(c3, r3, t3, WINDOW[4], 16));

// `inner` is the radius the outline closes along between the ends: the
// shoulder's for the section, or inside it for the cutter, which then never
// bounds on the hub's cylinder.
// `ends` turns the window's [lower, upper] end about the axis, toward the
// window's middle when positive (END_TRIM).
function turn(p, a) = [p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a)];
module window_2d(inner = SHOULDER[0] / 2, ends = [0, 0]) {
    e = [for (p = window_end()) turn(p, -ends[1])];
    m = [for (i = [len(e) - 1 : -1 : 0]) let (p = turn(window_end()[i], -ends[0])) [p.x, -p.y]];
    polygon(concat(e, arc_pts([0, 0], WINDOW[0], WINDOW[4] - ends[1], -WINDOW[4] + ends[0], 120), m,
                   arc_pts([0, 0], inner, -WINDOW[2] + ends[0], WINDOW[2] - ends[1], 120)));
}

module window_places() for (k = [0 : 3]) rotate(45 + 90 * k) children();
module windows_2d(inner = SHOULDER[0] / 2)
    for (k = [0 : 3]) rotate(45 + 90 * k) window_2d(inner, END_TRIM[k]);
module axis_places()   for (k = [0 : 3]) rotate(90 * k) children();

module hub() {
    difference() {
        rotate_extrude() polygon(hub_profile());
        axis_places() translate([HOLE[0], 0, JOURNAL[1] - 1])
            cylinder(d = hole_d(), h = JOURNAL[4] - JOURNAL[1] + 2, $fn = 48);
    }
}

module web() {
    difference() {
        union() {
            rotate_extrude() polygon(web_profile());
            tooth_rings();
        }
        translate([0, 0, FLANGES[0][0] - 1]) linear_extrude(FLANGES[2][1] - FLANGES[0][0] + 2)
            windows_2d(SHOULDER[0] / 2 - 0.5);
    }
}

module pegs() {
    window_places() translate([PEG[0], 0, JOURNAL[4] - epsilon])
        cylinder(d = peg_d(), h = PEG[2] - JOURNAL[4] + epsilon, $fn = 90);
}

module new_belt_pulley() {
    union() {
        hub();
        web();
        pegs();
    }
}

// The section through the middle flange: the flange's disc less the bore,
// the rod holes and the windows.
module web_section_2d() {
    difference() {
        circle(r = FLANGE[0]);
        circle(d = BORE[0]);
        axis_places() translate([HOLE[0], 0]) circle(d = hole_d(), $fn = 48);
        windows_2d();
    }
}

if (layer == "web") web_section_2d();
else new_belt_pulley();
