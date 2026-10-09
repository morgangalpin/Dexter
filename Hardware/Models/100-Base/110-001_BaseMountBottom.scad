// #110-001 Base Mount Bottom — parametric source.
// The base of the robot. Its flange bolts to the Base Mounting Plate, and its tower carries J1: the
// strakes stand in its slots, and the Base Clamp grips its spigot.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/100-Base/), in that mesh's frame.
//   config = "revised"  — the same part with print fits on its mounting holes, and R1's twelve
//                         plateaus trimmed to the floor around them.
//
// FRAME. J1's axis is +Z through the origin, and z = 0 is the mounting face the plate bolts to. The
// arms are on ±X and ±Y. The windows, the strake slots and the hub holes sit at 30° + 60°k, between
// the tower's six columns. The reference mesh is already in this frame.
//
// CONSTRUCTION. A region split:
//
//     tower    T1, S1, B1    one revolved profile, an annulus from z 0 to the spigot's top
//     rounds   W1            each window's R5 rounds, lofted rolling-ball cutters on the tower's
//                            outer face and on the bore's face (window_round.scad), cut from the
//                            tower alone
//     flange   F1            the arms' plan outline swept up with its R5 top edge (offset_sweep)
//     gussets  G1            the side profile on each side's own convex plan, both shrunk by R2 and
//                            grown back by a ball (minkowski), the three sides intersected: every
//                            top edge is a rolling-ball R2, and the corners in plan stay sharp
//     floor    R1            a measured surface: heights on a polar grid over half a sector,
//                            mirrored twelve times (110-001_BaseMountBottom_floor.scad)
//     cutters  W1, K1, B2,   the window prisms, the slots and their chamfers, the bores and holes,
//              H1, H2, M1    and the marking
//
// The floor is added after the window rounds, so where a window's edge dips under the floor the floor
// fills the round, as on the reference. The window prisms are cut after it, and cut the floor too.
//
// `layer = "base"` or `"spigot"` draws the section at z 5 or z 90 in 2D, for verification against
// the mesh's section (scadmesh outline; render-all.rs does this). Between them the tower is a plain
// annulus less the slots, and its section would measure only the reference's facets.
//
// Measured from the reference with scadmesh planes/slice/arcs/solid/transform and section and
// ray-cast probes. The feature IDs are those of 110-001_BaseMountBottom.view.json, which labels each
// one on the mesh:
//
//     ID  feature                       value
//     F1  flange                        two arms 50 wide crossing, ends at ±75 with R12.5 corners;
//                                       z 0 .. 16, top edge R5
//     T1  tower                         Ø85.000, z 0 .. 82 (the shoulder)
//     S1  spigot                        Ø74.604, z 82 .. 98
//     B1  bore                          Ø54.000, from the floor to z 98
//     G1  gussets                       on ±X, 17 wide on the arm's centre; on ±Y, two each, x ±15 .. ±25,
//                                       flush with the arm's sides and trimmed by its end corners.
//                                       One side profile: a top line falling 30.73° outward, tangent
//                                       to the arm end's R5 round (it meets the tower at z 33.167),
//                                       then that round; top edges R2.000
//     W1  windows ×6                    ellipse 19.22 across × 41.00 tall, centre z 41, on radial
//                                       axes; R5 rolling-ball rounds on the tower's face and on the
//                                       bore's face (the floor fills the latter where it is higher)
//     K1  strake slots ×6               3.602 radial × 13.000, centred on r 35.651, from z 4 up;
//                                       1.0 × 45° chamfers round the opening at z 98, down each side
//                                       of its mouth through S1, along the outer edge at the shoulder,
//                                       and along the inner wall's edge on each window's floor
//     B2  hub bore                      Ø20.000, through
//     H2  hub holes ×6                  Ø8.000 on r 22.062, through; counterbore Ø14.000 from z 15,
//                                       open up into the window above it
//     H1  mounting holes ×8             Ø6.000 through, counterbore Ø10.000 from z 10, at
//                                       (±12.5, ±62.5) and (±62.5, ±12.5) as specs/004 places them
//     R1  floor                         the tower's floor, z 14.5 .. 33: a hub ring round B2, six
//                                       ribs out to the columns, saddles between. Not an analytic
//                                       surface; on each rib's centre it is R6.6 off B2, a concave
//                                       R19.84, then R4 onto a flat at z 33
//     M1  marking                       an arrow pointing -Y and an "X", engraved 0.75 on the -Y arm
//
// R1 is sampled from the reference on 0.25 mm × 0.5° steps over θ 0 .. 30° and mirrored: the floor
// repeats every 60° and is mirror-symmetric about each rib and each window. Where the reference shows
// no floor (B2, H2's counterbores, inside the windows and the tower's wall) the table holds a fill that
// the cutters remove; nodes in a hole take the floor's height on its rim. The reference has twelve
// plateaus at exactly z 24.000 on R1 (r 15.0 .. 15.5, 7.5° .. 9° either side of each rib), up to
// 0.35 proud of the surface around them, and the table samples them (FLOOR_PLATEAU lists its nodes).
// Previous draws them. Revised trims each node to a straight line in angle between the floor's
// nodes either side of the plateau on its ring.
//
// The reference mesh is coarse: T1 has a vertex every 11° at the shoulder, so its facets lie up to
// 0.226 inside the circle, S1's up to 0.12 and B1's up to 0.14. This file draws the circles, so
// render-all.rs gates it at ±0.25 rather than ±0.15. Off T1's face the worst miss is 0.18, on W1's
// rounds on the bore's face, where the reference's round is a little tighter at the window's sides
// than a rolling ball.
//
// This is the bolted v9 part from dde/HDIMeterModel.gltf. The onshape KP0001 STEP is an unbolted
// predecessor, with its axis on Y, and is not the source.
//
// FITS (../print_fit.scad), revised only:
//
//     H1, on the M6 cap screw's Ø6 shank            slip
//     H1's counterbore, on its Ø10 head (ISO 4762)  slip
//
// The mesh draws H1 line-to-line on the screw, so it would be drilled out at assembly; revised prints
// it to pass the screw. K1 keeps its size: it
// clears the 12.6 × 3.2 strake by 0.2 per side already. S1 takes no fit: the Base Clamp's
// revised bore clears it, and the clamp grips the strakes (100-001_BaseClamp.scad). What B1, B2 and H2 take is not recorded; they take no clearance
// until virtual assembly shows what mates with them, and then take their fits.

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <../print_fit.scad>
include <110-001_BaseMountBottom_floor.scad>
use <window_round.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one section in 2D
layer = "part"; // [part, base, spigot]

/* [Hidden] */
$fn = 180;
epsilon = 0.01;

SLIP = fit_clearances(config)[0];

// F1, the flange: [half span, width, end corner radius], height and top round.
ARM        = [75.000, 50.000, 12.500];
FLANGE_H   = 16.000;
FLANGE_R   = 5.000;

// T1, S1, B1: radii and heights.
TOWER_R    = 42.500;
SHOULDER_Z = 82.000;
SPIGOT_R   = 37.302;
TOP_Z      = 98.000;
BORE_R     = 27.000;

// G1, the gussets: the top line's fall from the horizontal, the ±X gusset's half width, the ±Y
// gussets' x span, and the top edges' round.
GUSSET_FALL = 30.730;
GUSSET_HALF = 8.500;
WALL_X      = [15.000, 25.000];
GUSSET_R    = 2.000;

// W1, the windows: semi-axes [across, up], centre height and round. W1 is the window as
// window_round.scad takes it, on a radial axis.
WINDOW     = [9.610, 20.500];
WINDOW_Z   = 41.000;
WINDOW_R   = 5.000;
W1         = [WINDOW.x, WINDOW.y, WINDOW_Z, 0];

// K1, the strake slots: [centre radius, radial width, length], floor, and chamfer.
SLOT       = [35.651, 3.602, 13.000];
SLOT_FLOOR = 4.000;
SLOT_CHAMF = 1.000;

// B2, H2, H1.
HUB_R      = 10.000;
HUB_HOLE   = [22.062, 8.000, 14.000, 15.000];   // pitch radius, Ø, counterbore Ø, counterbore floor
// H1 on the M6 cap screw: its shank and head Ø, and the counterbore floor.
SCREW_D    = 6.000;
HEAD_D     = 10.000;
MOUNT_HOLE = [fit_bore(SCREW_D, SLIP), fit_bore(HEAD_D, SLIP), 10.000];
MOUNT_AT   = [for (k = [0 : 3]) for (s = [-1, 1]) zrot(90 * k, p = [62.500, 12.500 * s])];

// M1, the marking, as the mesh's section shows it.
MARK_DEPTH = 0.750;
MARK_ARROW = [[0.750, -42.493], [0.750, -61.379], [3.182, -58.947], [4.243, -60.007], [0.000, -64.250],
              [-4.243, -60.007], [-3.182, -58.947], [-0.750, -61.379], [-0.750, -42.493]];
MARK_X     = [[2.716, -49.231], [2.716, -50.369], [5.211, -52.166], [5.748, -52.507], [5.270, -52.820],
              [2.716, -54.622], [2.716, -55.793], [6.500, -53.083], [9.874, -55.598], [9.874, -54.568],
              [7.776, -52.978], [7.159, -52.561], [7.868, -52.105], [9.874, -50.686], [9.874, -49.558],
              [6.446, -51.999]];

// Every feature at 30° + 60°k.
BAYS = [30 : 60 : 330];

function arc_points(c, r, a0, a1, n = 24) = [for (i = [0 : n]) c + r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];

// ---- F1, the flange

// The two crossing arms' outline, one path: each arm's two end corners, then the inner corner it
// shares with the next arm (inside the tower).
function cross_path() = [for (k = [0 : 3]) each zrot(90 * k, p = concat(
    arc_points([ARM[0] - ARM[2], -ARM[1] / 2 + ARM[2]], ARM[2], -90, 0),
    arc_points([ARM[0] - ARM[2], ARM[1] / 2 - ARM[2]], ARM[2], 0, 90),
    [[ARM[1] / 2, ARM[1] / 2]]))];

module flange() {
    difference() {
        // Triangulated: the sweep's quads between layers are not quite planar.
        vnf_polyhedron(vnf_triangulate(
            offset_sweep(cross_path(), height = FLANGE_H, top = os_circle(r = FLANGE_R), steps = 24)));
        // The arms stop at the tower's face, on the tower's own facets: the windows' rounds dip
        // below the flange's top there, and inside, the floor stands lower than it.
        down(1) cylinder(r = TOWER_R, h = FLANGE_H + 2);
    }
}

// ---- T1, S1, B1, the tower

module tower() {
    rotate_extrude() polygon([[BORE_R, 0], [TOWER_R, 0], [TOWER_R, SHOULDER_Z], [SPIGOT_R, SHOULDER_Z],
                              [SPIGOT_R, TOP_Z], [BORE_R, TOP_Z]]);
}

// ---- W1, the windows' rounds (window_round.scad), on the tower's face and on the bore's

module window_rounds() {
    for (a = BAYS) zrot(a) {
        window_round(W1, ["cyl", TOWER_R, 1], WINDOW_R);
        window_round(W1, ["cyl", BORE_R, -1], WINDOW_R);
    }
}

// ---- G1, the gussets

// The side profile, in [s, z] with s out along the arm: under the top line to where it touches the
// arm end's round, then round that.
GUSSET_END = [ARM[0] - FLANGE_R, FLANGE_H - FLANGE_R];   // the round's centre
GUSSET_TAN = GUSSET_END + FLANGE_R * [sin(GUSSET_FALL), cos(GUSSET_FALL)];
echo(str("G1 top line meets the tower at z ", GUSSET_TAN.y + tan(GUSSET_FALL) * (GUSSET_TAN.x - TOWER_R)));

function gusset_profile(s0) = concat(
    [[s0, 0], [s0, GUSSET_TAN.y + tan(GUSSET_FALL) * (GUSSET_TAN.x - s0)]],
    arc_points(GUSSET_END, FLANGE_R, 90 - GUSSET_FALL, 0, 16),
    [[ARM[0], 0]]);

GUSSET_S0 = 30;   // where every gusset starts, inside the tower

// The +X arm's own outline, convex: square across, its far corners rounded.
module arm_2d() {
    hull() {
        translate([GUSSET_S0 - 5, -ARM[1] / 2]) square([ARM[0] - ARM[2] - GUSSET_S0 + 5, ARM[1]]);
        for (s = [-1, 1]) translate([ARM[0] - ARM[2], s * (ARM[1] / 2 - ARM[2])]) circle(r = ARM[2]);
    }
}

// The side profile on a convex plan, every top edge rounded by the ball: the profile and the plan
// each shrunk by it, intersected, and grown back by it.
module rounded_on(r = GUSSET_R) {
    minkowski() {
        intersection() {
            down(10) linear_extrude(80) offset(r = -r) children();
            xrot(90) linear_extrude(200, center = true) offset(r = -r) polygon(gusset_profile(GUSSET_S0));
        }
        sphere(r = r, $fn = 48);
    }
}

// The gusset on the +X arm between y0 and y1. Each of its sides is rounded on its own plan (a
// half-plane, or the arm's outline) and the three are intersected, so its top edges are rounded and
// the corner where a side meets the arm's end stays sharp, as on the reference. It runs on into the
// tower's wall, short of the bore's rounds (r < 32.4): it is added after the windows' outer rounds,
// and fills them where it crosses them, as on the reference.
module gusset(y0, y1) {
    span = [ARM[0] + 10 - GUSSET_S0, 60];
    difference() {
        intersection() {
            rounded_on() translate([GUSSET_S0 - 5, y0]) square(span);
            rounded_on() translate([GUSSET_S0 - 5, y1 - span[1]]) square(span);
            rounded_on() arm_2d();
        }
        down(1) cylinder(r = BORE_R + 6, h = 60);
    }
}

module gussets() {
    for (a = [0, 180]) zrot(a) gusset(-GUSSET_HALF, GUSSET_HALF);
    for (a = [90, 270]) zrot(a) yflip_copy() gusset(WALL_X[0], WALL_X[1]);
}

// ---- R1, the floor

// FLOOR_Z[i][j] is the height at radius FLOOR_R[i] and angle FLOOR_T[j] in [0, 30]. The ring of
// angles runs once round, each 30° folded back onto the table.
FLOOR_NT = len(FLOOR_T) - 1;
FLOOR_NA = 12 * FLOOR_NT;
function floor_fold(j) = let (s = floor(j / FLOOR_NT), k = j - s * FLOOR_NT) s % 2 == 0 ? k : FLOOR_NT - k;
function floor_angle(j) = let (s = floor(j / FLOOR_NT), k = j - s * FLOOR_NT)
    s * 30 + (s % 2 == 0 ? FLOOR_T[k] : 30 - FLOOR_T[FLOOR_NT - k]);

// The plateau's nodes in the table, one run per ring: [radius, first angle, last angle].
FLOOR_PLATEAU = [[15.00, 7.5, 9.0], [15.25, 8.0, 9.0], [15.50, 9.0, 9.0]];

function floor_index(v, list) = [for (k = [0 : len(list) - 1]) if (abs(list[k] - v) < 1e-6) k][0];

// A node's height with the plateau trimmed: on a run, straight in angle between the nodes either side.
function floor_trimmed(i, j) = let (
    run = [for (p = FLOOR_PLATEAU) if (floor_index(p[0], FLOOR_R) == i && FLOOR_T[j] >= p[1] && FLOOR_T[j] <= p[2]) p]
) len(run) == 0 ? FLOOR_Z[i][j] : let (
    j0 = floor_index(run[0][1], FLOOR_T) - 1,
    j1 = floor_index(run[0][2], FLOOR_T) + 1,
    f  = (FLOOR_T[j] - FLOOR_T[j0]) / (FLOOR_T[j1] - FLOOR_T[j0])
) FLOOR_Z[i][j0] + f * (FLOOR_Z[i][j1] - FLOOR_Z[i][j0]);

FLOOR = config == "revised"
    ? [for (i = [0 : len(FLOOR_R) - 1]) [for (j = [0 : FLOOR_NT]) floor_trimmed(i, j)]]
    : FLOOR_Z;

// The floor as one solid from z 0 to the surface, between the first and last radius.
module floor_body() {
    nr = len(FLOOR_R);
    na = FLOOR_NA;
    top = [for (i = [0 : nr - 1]) for (j = [0 : na - 1])
        [FLOOR_R[i] * cos(floor_angle(j)), FLOOR_R[i] * sin(floor_angle(j)), FLOOR[i][floor_fold(j)]]];
    bottom = [for (i = [0, nr - 1]) for (j = [0 : na - 1])
        [FLOOR_R[i] * cos(floor_angle(j)), FLOOR_R[i] * sin(floor_angle(j)), 0]];
    t = function(i, j) i * na + j % na;
    b = function(o, j) nr * na + o * na + j % na;
    polyhedron(concat(top, bottom), concat(
        [for (i = [0 : nr - 2]) for (j = [0 : na - 1])
            each [[t(i, j), t(i + 1, j), t(i + 1, j + 1)], [t(i, j), t(i + 1, j + 1), t(i, j + 1)]]],
        [for (j = [0 : na - 1]) [b(0, j), b(0, j + 1), b(1, j + 1), b(1, j)]],
        [for (j = [0 : na - 1]) [t(0, j), t(0, j + 1), b(0, j + 1), b(0, j)]],
        [for (j = [0 : na - 1]) [t(nr - 1, j), b(1, j), b(1, j + 1), t(nr - 1, j + 1)]]),
        convexity = 10);
}

// ---- Cutters

// The windows' prisms, from the axis out through the tower.
module windows() {
    for (a = BAYS) zrot(a) window_prism(W1, 0, TOWER_R + 5);
}

module slot_2d() { translate([SLOT[0], 0]) square([SLOT[1], SLOT[2]], center = true); }

// Above the shoulder the slot opens through the spigot's face. The chamfer down each side of that
// mouth, for the +y side: from 1 back along the end wall to 1 round the spigot's face, as a plan
// triangle reaching into the slot and off the face.
function mouth_chamfer() = let (
    y  = SLOT[2] / 2,
    a0 = asin(y / SPIGOT_R),
    p  = [SPIGOT_R * cos(a0) - SLOT_CHAMF, y],
    q  = SPIGOT_R * [cos(a0 + SLOT_CHAMF / SPIGOT_R * 180 / PI), sin(a0 + SLOT_CHAMF / SPIGOT_R * 180 / PI)],
    d  = (q - p) / norm(q - p),
    p1 = p - 0.3 * d,
    p2 = q + 0.5 * d
) [p1, p2, [p2.x + 1, p1.y]];

module mouth_2d() { yflip_copy() polygon(mouth_chamfer()); }

// K1, with its chamfers: round the opening at the top; down each side of its mouth above the
// shoulder; along the outer edge at the shoulder; and where the inner wall meets the window's floor,
// a 45° run square to that edge, from the wall to the floor, which is the window's ellipse: the
// prism's section grows by 1 as it nears the wall. For a convex section the hull of two of its
// offsets is every offset between, so two thin slices on the 45° line make it.
module slots() {
    inner = SLOT[0] - SLOT[1] / 2;
    outer = SLOT[0] + SLOT[1] / 2;
    for (a = BAYS) zrot(a) {
        up(SHOULDER_Z - epsilon) linear_extrude(TOP_Z - SHOULDER_Z + 1) mouth_2d();
        up(SLOT_FLOOR) linear_extrude(TOP_Z) slot_2d();
        hull() {
            up(TOP_Z - SLOT_CHAMF) linear_extrude(epsilon) slot_2d();
            up(TOP_Z + SLOT_CHAMF) linear_extrude(epsilon) offset(delta = 2 * SLOT_CHAMF) slot_2d();
        }
        xrot(90) linear_extrude(SLOT[2], center = true)
            polygon([[outer - 0.5, SHOULDER_Z - SLOT_CHAMF - 0.5], [outer + 2, SHOULDER_Z + 1],
                     [outer - 0.5, SHOULDER_Z + 1]]);
        intersection() {
            hull() {
                zrot(90) xrot(90) up(inner - SLOT_CHAMF - 0.5) linear_extrude(epsilon)
                    offset(r = -0.5) window_2d(W1);
                zrot(90) xrot(90) up(inner + 0.5 - epsilon) linear_extrude(epsilon)
                    offset(r = SLOT_CHAMF + 0.5) window_2d(W1);
            }
            translate([inner - SLOT_CHAMF - 0.5, -SLOT[2] / 2, 0]) cube([SLOT_CHAMF + 1, SLOT[2], WINDOW_Z]);
        }
    }
}

// The holes take fewer facets than the tower: the reference's have about 65, and 96 leave them
// 0.003 inside their circles.
module holes($fn = 96) {
    down(1) cylinder(r = HUB_R, h = TOP_Z + 2);
    for (a = BAYS) zrot(a) right(HUB_HOLE[0]) {
        down(1) cylinder(d = HUB_HOLE[1], h = HUB_HOLE[3] + 2);
        up(HUB_HOLE[3]) cylinder(d = HUB_HOLE[2], h = WINDOW_Z - HUB_HOLE[3]);
    }
    for (p = MOUNT_AT) translate(p) {
        down(1) cylinder(d = MOUNT_HOLE[0], h = MOUNT_HOLE[2] + 2);
        up(MOUNT_HOLE[2]) cylinder(d = MOUNT_HOLE[1], h = 40);
    }
}

module marking() {
    up(FLANGE_H - MARK_DEPTH) linear_extrude(1) { polygon(MARK_ARROW); polygon(MARK_X); }
}

// ---- The part

module base_mount_bottom() {
    difference() {
        union() {
            difference() { tower(); window_rounds(); }
            flange();
            gussets();
            floor_body();
        }
        windows();
        slots();
        holes();
        marking();
    }
}

// ---- Sections, as the mesh is cut: through every through-hole and slot below the counterbores;
// through the spigot.

module ring_2d(r0, r1) { difference() { circle(r = r1); circle(r = r0); } }
module hole_ring_2d(d) { for (a = BAYS) zrot(a) right(HUB_HOLE[0]) circle(d = d); }

if (layer == "base") difference() {
    union() { polygon(cross_path()); circle(r = TOWER_R); }
    circle(r = HUB_R);
    hole_ring_2d(HUB_HOLE[1]);
    for (p = MOUNT_AT) translate(p) circle(d = MOUNT_HOLE[0]);
    for (a = BAYS) zrot(a) slot_2d();
}
else if (layer == "spigot") difference() {
    ring_2d(BORE_R, SPIGOT_R);
    for (a = BAYS) zrot(a) { slot_2d(); mouth_2d(); }
}
else base_mount_bottom();
