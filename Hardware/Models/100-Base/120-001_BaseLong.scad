// #120-001 Base Long — parametric source.
// The base's long member, between the Base Mount Bottom and the Main Pivot. It seats on the mount's top
// face, the strakes stand in its slots, the all-thread runs through its holes, and a 6810 bearing sits
// in each end's bore: the lower one on the shoulder 35.0 in, the Base Motor End Cap's flush with the
// top face.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/100-Base/), in that mesh's frame.
//   config = "revised"  — the same part with print fits on its bearing bores.
//
// FRAME. J1's axis is +Z through the origin. The bottom face, which seats on the Base Mount Bottom's
// top face, is at z = -28 and the top face at z = 68. The strake slots and the strake columns sit at
// 0° + 60°k, the all-thread holes and the narrow columns at 30° + 60°k, and the twelve windows between
// them. The reference mesh is already in this frame.
//
// CONSTRUCTION. Six pairs of sides round the axis:
//
//     side    D1, W1      a 30° wedge out to one flat (base_dodecagon.scad), 0° .. 30°, lapping a
//                         little past each corner into what the corner's round removes, and its
//                         window
//     pair    D1, W1      the side and its mirror about the narrow column's plane (30°), the corner
//                         between them rounded by an edge mask. A window's round on B3's face crosses
//                         the 30° plane by about 1.3, so both windows are cut from the pair, not from
//                         the side
//     ring    D1          six pairs at 60°, the corners between them rounded the same way
//     ribs    R1          a loft through measured sections, added to each strake column
//     cutters K1, H1,     the slots and holes, through; the bores
//             B1, B2, B3
//
// Each window is a prism along its flat's normal, set off sideways, and two lofted R5 rolling-ball
// rounds: on the flat and on B3's face (window_round.scad), each on 360 points spaced evenly in the
// normal's angle. The round on B3's face takes window_round's fill, because the face is oblique to the
// offset window and its loft alone leaves a pocket at each end; and it stops on the plane z 15.000,
// below which the reference's bore is whole. The window's other end and the outer rounds run their
// full R5. Beside the narrow column a window's outer round runs 1.43 onto the corner's
// round, which falls 0.10 below the flat there; the round is drawn for the flat throughout.
//
// NOT ON CGAL. CGAL asserts on the windows' cuts in every arrangement tried, and drops cutters when
// it does. Render on Manifold, the default engine; never name "cgal" for this part.
//
// Measured from the reference with scadmesh planes/slice/arcs/pattern/solid/transform. The feature IDs
// are those of 120-001_BaseLong.view.json, which labels each one on the mesh:
//
//     ID  feature                       value
//     D1  body                          the rounded dodecagon (base_dodecagon.scad), z -28 .. 68
//     W1  windows ×12                   ellipse 5.000 across × 38.000 tall at its narrowest (the land,
//                                       r 35 .. 36), centre z 37.000; its axis along its flat's normal
//                                       (15° + 30°k), 1.963 off the flat's centre line toward the narrow
//                                       column; R5 rolling-ball rounds on the flat and on B3's face
//     K1  strake slots ×6               3.602 radial × 13.000, centred on r 35.651, at 0° + 60°k, through
//     H1  all-thread holes ×6           Ø3.500 on r 35.540, at 30° + 60°k, through
//     B1  lower bore                    Ø65.000, z -28 .. 7: the 6810's seat, on the shoulder at z 7
//                                       (35.0 in), and the way in to it
//     B2  upper bore                    Ø65.000, z 61 .. 68: the Base Motor End Cap's 6810
//     B3  centre bore                   Ø60.000, z 7 .. 61
//     R1  ribs ×6                       on the strake columns, |y| ≤ 6.400 about each column's centre
//                                       line: an outer face on r 43.250 below a flat top at z 53.000, and
//                                       an S-shaped underside from the wall (z ≈ 49.1) to the outer face
//                                       (z ≈ 52), a convex round over a concave one. The underside fits no
//                                       revolved or extruded profile: where it meets the outer face its
//                                       height climbs 0.42 from 0° to 8°
//
// R1 is sampled from the reference in the planes y = 0 .. 6.34 (0.5 apart, then 6.2 and 6.34) by
// slicing it (scadmesh slice --axis y --full): each section runs from the outer top corner down the
// underside to the foot, where the section meets the column's wall, and is resampled into 24 points
// evenly spaced along it (120-001_BaseLong_rib.scad). From y 6.0 on, the underside runs on down a
// window's round, which W1's cutter draws, so those sections stop at z 49.000. The table is mirrored
// about each column's centre line, and the 6.34 section is set at the rib's end, 6.400. The reference's
// rib ends are the planes y -6.350 and 6.451, 0.05 off centre.
//
// The reference turns its dodecagon 0.185° off 30°k, and its windows and rib with it, while its slots
// and holes, and its windows' positions at mid-wall, are symmetric about 0° and 30°. This file draws
// everything symmetric about 0° and 30°.
//
// FITS (../print_fit.scad), revised only:
//
//     B1's seat (z 0 .. 7), on the lower 6810's Ø65 outer race         press
//     B1 below it (z -28 .. 0), the way the bearing goes in            slip
//     B2, on the Base Motor End Cap's 6810's Ø65 outer race            press
//
// K1 keeps its size: it clears the 12.6 × 3.2 strake by 0.2 per side already. H1 keeps its size: it
// clears the M3 all-thread by 0.25 per side. B3, W1 and R1 mate with nothing.

include <BOSL2/std.scad>
include <../print_fit.scad>
include <base_dodecagon.scad>
include <120-001_BaseLong_rib.scad>
use <window_round.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 180;
epsilon = 0.01;

SLIP  = fit_clearances(config)[0];
PRESS = fit_clearances(config)[1];

// D1: the end faces, and how far each side's wedge laps past its corners.
Z0  = -28.000;
Z1  = 68.000;
LAP = 0.500;

// W1: the window as window_round.scad takes it (semi-axes, centre height, offset across), its round,
// its points round the ellipse (spaced evenly in the normal's angle), and the height below which its
// round on B3's face is cut away.
W1          = [2.500, 19.000, 37.000, 1.963];
WINDOW_R    = 5.000;
WINDOW_N    = 360;
BORE_ROUND_FLOOR = 15.000;

// K1: [centre radius, radial width, length]. H1: [pitch radius, Ø].
SLOT = [35.651, 3.602, 13.000];
HOLE = [35.540, 3.500];

// B1, B2, B3: the bearings' Ø, B3's Ø, and the shoulders.
BEARING_D  = 65.000;
B3_D       = 60.000;
SHOULDER_Z = [7.000, 61.000];
SEAT_Z     = 0.000;   // B1's seat starts the 6810's width below its shoulder

// R1: its half-width, top, and how far its sections are buried in the wall behind their feet.
RIB_HALF = 6.400;
RIB_TOP  = 53.000;
RIB_BURY = 0.300;

// ---- D1, the sides

// The point on the flat whose normal is at 15°, at polar angle a.
function flat_point(a) = DODECAGON_APOTHEM / cos(a - 15) * [cos(a), sin(a)];

// One side: the wedge from the axis out to its flat, 0° .. 30°, lapped past both corners.
module side() {
    up(Z0) linear_extrude(Z1 - Z0) polygon([[0, 0], flat_point(-LAP), flat_point(30 + LAP)]);
}

// The rounding of the corner at polar angle a: an edge mask on the sharp corner, its 150° of
// material between the two flats.
module corner_round(a) {
    zrot(a) right(dodecagon_corner_r()) zrot(105) down(-Z0 + 1)
        rounding_edge_mask(l = Z1 - Z0 + 2, r = DODECAGON_ROUND, ang = 150, excess = 1, anchor = BOTTOM);
}

// ---- W1, the windows

// The side's window, in its flat's frame (turned 15°): the prism from inside B3 out past the flat,
// its round on the flat, and its round on B3's face, cut away below BORE_ROUND_FLOOR as on the
// reference.
module window_cutter() {
    zrot(15) {
        window_prism(W1, B3_D / 2 - 5, DODECAGON_APOTHEM + 2, WINDOW_N, "normal");
        window_round(W1, ["plane", DODECAGON_APOTHEM, 1], WINDOW_R, WINDOW_N, "normal");
        intersection() {
            window_round(W1, ["cyl", B3_D / 2, -1], WINDOW_R, WINDOW_N, "normal", fill = true);
            up(BORE_ROUND_FLOOR) linear_extrude(Z1) square(2 * DODECAGON_APOTHEM, center = true);
        }
    }
}

module mirror_30() { mirror([-sin(30), cos(30), 0]) children(); }

// A pair of sides about the narrow column at 30°: the side and its mirror, the corner between them
// rounded, and the side's window and its mirror cut. A window's round on B3's face crosses the 30°
// plane by about 1.3, so the windows are cut from the pair, not from the side.
module pair() {
    difference() {
        union() { side(); mirror_30() side(); }
        corner_round(30);
        window_cutter();
        mirror_30() window_cutter();
    }
}

// The six pairs, with the strake columns' corners rounded.
module ring() {
    difference() {
        union() for (k = [0 : 5]) zrot(60 * k) pair();
        for (k = [0 : 5]) corner_round(60 * k);
    }
}

// ---- R1, the ribs

// The wall's x behind a foot, where a section's buried edge stands.
function rib_section(y, s) = let (foot = s[len(s) - 1], xb = foot.x - RIB_BURY)
    concat([for (p = s) [p.x, y, p.y]], [[xb, y, foot.y], [xb, y, RIB_TOP]]);

// The table runs over y ≥ 0; the rib is its mirror on -y and itself on +y, with the last section at
// the rib's end.
function rib_y(i, n) = i == n - 1 ? RIB_HALF : RIB_SECTIONS[i][0];
function rib_sections() = let (n = len(RIB_SECTIONS)) concat(
    [for (i = [n - 1 : -1 : 1]) rib_section(-rib_y(i, n), RIB_SECTIONS[i][1])],
    [for (i = [0 : n - 1]) rib_section(rib_y(i, n), RIB_SECTIONS[i][1])]);

// One rib on the strake column at 0°: the sections lofted with triangles, each end one planar face.
module rib() {
    secs = rib_sections();
    ns = len(secs);
    m = len(secs[0]);
    polyhedron(
        points = [for (s = secs) each s],
        faces = concat(
            [for (i = [0 : ns - 2], j = [0 : m - 1])
                let (a = i * m, b = (i + 1) * m, q = (j + 1) % m)
                each [[a + j, b + j, b + q], [a + j, b + q, a + q]]],
            [[for (j = [0 : m - 1]) j]],
            [[for (j = [m - 1 : -1 : 0]) (ns - 1) * m + j]]),
        convexity = 4);
}

module ribs() { for (k = [0 : 5]) zrot(60 * k) rib(); }

// ---- Cutters

module slots() {
    for (k = [0 : 5]) zrot(60 * k) right(SLOT[0]) down(-Z0 + 1)
        linear_extrude(Z1 - Z0 + 2) square([SLOT[1], SLOT[2]], center = true);
}

// The holes take fewer facets than the bores: the reference's have 48.
module holes($fn = 96) {
    for (k = [0 : 5]) zrot(30 + 60 * k) right(HOLE[0]) down(-Z0 + 1) cylinder(d = HOLE[1], h = Z1 - Z0 + 2);
}

module bores() {
    down(-Z0 + 1) cylinder(d = B3_D, h = Z1 - Z0 + 2);
    down(-Z0 + 1) cylinder(d = fit_bore(BEARING_D, SLIP), h = SEAT_Z - Z0 + 1 + epsilon);
    up(SEAT_Z) cylinder(d = fit_bore(BEARING_D, PRESS), h = SHOULDER_Z[0] - SEAT_Z);
    up(SHOULDER_Z[1]) cylinder(d = fit_bore(BEARING_D, PRESS), h = Z1 - SHOULDER_Z[1] + 1);
}

// ---- The part

module base_long() {
    difference() {
        union() { ring(); ribs(); }
        slots();
        holes();
        bores();
    }
}

base_long();
