// #511-001 Ex Gear Motor End Cap — parametric source.
// Caps the rear of J3's motor inside the External Gear group. Its top face
// stands on the Ex Gear Mount's four floor bosses, bolted through the NEMA 17
// pattern; eight lugs grip the motor body; the motor's rear face bears on the
// seat. The Ø50 land is the journal the External Gear's lower 6810 inner race
// rides in, and the ring below the land is that race's axial stop.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/500-ExternalGear/).
//   config = "revised"  — the seat raised by seat_raise, pocketing the motor
//                         square that much deeper, and every feature measured
//                         from the seat raised with it. What sets seat_raise
//                         is recorded in exgear_assembly.scad.
//
// FRAME. The reference's own: the axis on +Z, the seat at z = -2.200 (the face
// the motor's rear bears on), the land from z = 0 to the top face at 7.000,
// which stands on the bosses. The lugs hang below the seat to z = -7.200.
//
// Measured from the reference (scadmesh slice/arcs/profile/solid, meridians
// by transform --rz). Every feature is fourfold about the axis and mirror-
// symmetric about the axes and diagonals, except the wire channel and slot,
// which are at +x only:
//
//     feature                      value                  z span
//     land                         R25.000; top edge 0.225 x 45 deg    0 .. 7
//     notches, 4 at 0/90/180/270   13.0 wide, floor r 20.996; R0.51
//                                  mouth rounds tangent to the sides,
//                                  centred on r 24.605; top edges
//                                  0.4 x 45 deg, on round
//                                  the mouths too         -2.2 .. 7
//     ring below the land          R25.750, top outer edge R0.5 to a 0.25
//                                  step at z 0; R0.765 corners at the
//                                  notches, tangent to R25.75   -2.2 .. 0
//     lugs, 8                      inside faces on the 42.292 motor square,
//                                  from the notch side to a full R0.5 end
//                                  centred 13.0 along the face; outside on
//                                  R25.75; R0.5 corner at the notch side;
//                                  R0.5 bottom edges      -7.2 .. -2.2
//     their root fillets           R0.5, round the end and the corner
//     centre bore                  Ø22.5, R1 round into the seat   through
//     wire channel, +x             11.96 wide at mid-height, ceiling at
//                                  z -0.2 with R1 fillets, R1 rounds into
//                                  the seat, from the bore to the notch;
//                                  the bore round follows the fillets
//                                  at a constant 1.0 setback
//     wire slot, +x notch          3.0 wide, floor r 18.146   -0.2 .. 7
//     motor holes, 31.0 square     Ø3.2                   0.8 .. 6
//     their nut traps              hex 5.5 AF, flats facing the axis
//                                                         -2.2 .. 0.8
//     their lead-ins               flat at z 6, then Ø6 to Ø8 at the top
//
// The mouth, lug and ring corner rounds are each tangent to one side only:
// the lug and ring corners were rounded on a notch 0.15 narrower, the land's
// mouths on a disc 0.115 larger.

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// Revised only: how far the seat rises into the cap, mm
seat_raise = 1.000;

/* [Hidden] */
$fn = 144;
epsilon = 0.01;

SEAT          = -2.200;    // the face the motor's rear bears on
TOP           = 7.000;     // the face on the Mount's bosses
LAND_R        = 25.000;
LAND_CHAMFER  = 0.225;     // land's top outer edge
NOTCH         = [6.500, 20.996];   // half-width, floor radius
NOTCH_CHAMFER = 0.400;     // notch and slot top edges
NARROWER      = 0.150;     // the notch the corner rounds were cut on is this much narrower
MOUTH         = [0.510, 0.115];    // land mouth round: radius, disc it was cut on beyond R25
RING_R        = 25.750;
RING_ROUND    = 0.500;     // ring's top outer edge
RING_CORNER   = 0.765;     // ring and lug corner at the notch, outer side
LUG_FLAT      = 21.146;    // lug inner faces: the motor's half-width
LUG_END       = 13.000;    // centre of the lug's end round, along its face
LUG_Z         = -7.200;
LUG_EDGE      = 0.500;     // lug corner, end and bottom-edge rounds, root fillet
BORE_R        = 11.250;
BORE_ROUND    = 1.000;
CHANNEL       = [5.980, 2.000, 1.000];   // half-width at mid-height, height above the seat, round radius
SLOT          = [1.500, 18.146];   // wire slot half-width, floor radius
MOTOR_PITCH   = 31.000;
MOTOR_HOLE_D  = 3.200;
NUT           = [5.500, 3.000];    // across flats, depth above the seat
LEAD_IN       = [6.000, 8.000, 6.000];   // Ø at its floor, Ø at the top, floor z

function end_cap_top() = TOP;
function end_cap_seat(cfg = config, raise = seat_raise) = cfg == "previous" ? SEAT : SEAT + raise;

// --- 2D outlines -----------------------------------------------------------
module convex_round(r) offset(r = r) offset(delta = -r) children();

module notch_cutters(half = NOTCH[0], reach = 40)
    for (a = [0 : 90 : 270]) rotate(a)
        translate([NOTCH[1], -half]) square([reach, 2 * half]);

// The land: R25 less the notches, the mouths rounded tangent to the sides.
module land_2d()
    intersection() {
        circle(r = LAND_R);
        convex_round(MOUTH[0]) difference() { circle(r = LAND_R + MOUTH[1]); notch_cutters(); }
    }

// One quarter of the ring, between the notches at 0 and 90 deg, with corner
// rounds of radius `corner` about fixed centres; the outer radius follows.
module ring_quarter_2d(corner) {
    inset = NOTCH[0] - NARROWER + RING_CORNER;
    intersection() {
        offset(r = corner) intersection() {
            circle(r = RING_R - RING_CORNER);
            translate([inset, inset]) square(RING_R);
        }
        translate([NOTCH[0], NOTCH[0]]) square(RING_R);
    }
}

// One lug in its own frame: inner face on y = LUG_FLAT, from the notch side at
// x = NOTCH[0] to the end round. It is convex: the hull of its corner rounds
// and its outer arc.
function lug_corner_outer() =
    let (y = NOTCH[0] - NARROWER + RING_CORNER) [y, sqrt(pow(RING_R - RING_CORNER, 2) - y * y)];

module lug_2d() {
    c_notch = [NOTCH[0] - NARROWER + LUG_EDGE, LUG_FLAT + LUG_EDGE];
    c_end   = [LUG_END, LUG_FLAT + LUG_EDGE];
    c_outer = lug_corner_outer();
    a1 = atan2(c_end[1], c_end[0]);
    a2 = atan2(c_outer[1], c_outer[0]);
    intersection() {
        translate([NOTCH[0], 0]) square(RING_R);
        hull() {
            translate(c_notch) circle(r = LUG_EDGE);
            translate(c_end) circle(r = LUG_EDGE);
            translate(c_outer) circle(r = RING_CORNER);
            intersection() {
                circle(r = RING_R);
                polygon([[0, 0], 2 * RING_R * [cos(a1), sin(a1)], 2 * RING_R * [cos(a2), sin(a2)]]);
                translate([0, c_end[1]]) square(RING_R);
            }
        }
    }
}

// --- Solids ----------------------------------------------------------------
// Each quarter of the ring is convex: the hull of its outline at the heights
// of its top round.
module ring()
    for (a = [0 : 90 : 270]) rotate(a) hull() {
        translate([0, 0, SEAT]) linear_extrude(epsilon) ring_quarter_2d(RING_CORNER);
        for (t = [0 : 15 : 90])
            translate([0, 0, -RING_ROUND * (1 - sin(t)) - (t == 90 ? epsilon : 0)])
                linear_extrude(epsilon) ring_quarter_2d(RING_CORNER - RING_ROUND * (1 - cos(t)));
    }

// A lug with its bottom edges rounded: the hull of its outline shrunk along
// the round.
module one_lug()
    hull() {
        for (t = [0 : 15 : 90])
            translate([0, 0, LUG_Z + LUG_EDGE * (1 - cos(t))]) linear_extrude(epsilon)
                offset(r = -LUG_EDGE * (1 - sin(t)) - (t == 90 ? 0 : 0.001)) lug_2d();
        translate([0, 0, SEAT - epsilon]) linear_extrude(2 * epsilon) lug_2d();
    }

module each_lug() for (a = [0 : 90 : 270], m = [0, 1]) rotate(a) mirror([m, 0, 0]) children();

// The root fillet's section: u away from the lug's face, v up to the seat.
module root_fillet_section()
    difference() {
        translate([-LUG_EDGE, -LUG_EDGE]) square(LUG_EDGE + epsilon);
        translate([-LUG_EDGE, -LUG_EDGE]) circle(r = LUG_EDGE, $fn = 32);
    }

module fillet_ring(centre, z)
    translate([centre[0], centre[1], z]) rotate_extrude($fn = 48)
        translate([LUG_EDGE, 0]) mirror([1, 0]) root_fillet_section();

// One lug's root fillet, at seat height z: along its face, and round its end
// and its notch-side corner, up to the notch side and the ring's radius.
module one_root_fillet(z) {
    c_notch = [NOTCH[0] - NARROWER + LUG_EDGE, LUG_FLAT + LUG_EDGE];
    c_end   = [LUG_END, LUG_FLAT + LUG_EDGE];
    intersection() {
        union() {
            translate([c_notch[0], LUG_FLAT, z]) rotate([90, 0, 90])
                linear_extrude(c_end[0] - c_notch[0]) root_fillet_section();
            fillet_ring(c_end, z);
            fillet_ring(c_notch, z);
        }
        translate([NOTCH[0], 0, z - 1]) cube([RING_R, RING_R, 2]);
        cylinder(r = RING_R, h = 20, center = true);
    }
}

module body(s) {
    translate([0, 0, SEAT]) linear_extrude(TOP - SEAT) land_2d();
    ring();
    each_lug() one_lug();
    each_lug() one_root_fillet(s);
}

// --- Cuts ------------------------------------------------------------------
// A round on the edge where a vertical wall at radius r0 meets a face at z,
// the material lying beyond r0 and above z; the cutter reaches `under` below z.
module edge_round(r0, z, r, under = epsilon)
    translate([0, 0, z]) rotate_extrude() polygon([
        [r0 - epsilon, -under], [r0 + r, -under],
        for (t = [0 : 10 : 90]) [r0 + r - r * sin(t), r - r * cos(t)],
        [r0 - epsilon, r]]);

// The wire channel's section, y across and z up from the seat.
module channel_2d() {
    w = CHANNEL[0]; h = CHANNEL[1]; r = CHANNEL[2];
    half = [[w + r, -epsilon],
            for (t = [10 : 10 : 80]) [w + r - r * sin(t), r - r * cos(t)],
            [w, r],
            for (t = [10 : 10 : 80]) [w - r + r * cos(t), r + r * sin(t)],
            [w - r, h]];
    polygon(concat([[0, -epsilon]], half, [for (i = [len(half) - 1 : -1 : 0]) [-half[i][0], half[i][1]]]));
}

// The bore's round runs on round the ceiling's side fillets at a constant
// setback of BORE_ROUND on both faces, not at a constant radius: at fillet
// angle t (0 at the wall, 90 at the flat) the ball touches the bore and the
// fillet BORE_ROUND from their seam, so its radius grows from R1 at the flat
// to R1.81 at the wall as the faces open out. It stops at the plane of the
// channel's wall, so toward the wall it narrows onto the bore to the seam, and
// below the fillets the wall meets the bore sharp.
function unit(v) = v / norm(v);
function blend_station(t, s) =   // [seam, nb, nc, ub, uc, ball radius]
    let (y = CHANNEL[0] - CHANNEL[2] + CHANNEL[2] * cos(t),
         seam = [sqrt(BORE_R * BORE_R - y * y), y, s + CHANNEL[2] + CHANNEL[2] * sin(t)],
         nb = -[seam[0], seam[1], 0] / BORE_R,   // face normals, into the void
         nc = -[0, cos(t), sin(t)],
         edge = unit(cross(nb, nc)),
         ub0 = unit(cross(edge, nb)), ub = ub0 * nc > 0 ? -ub0 : ub0,   // along each face,
         uc0 = unit(cross(edge, nc)), uc = uc0 * nb > 0 ? -uc0 : uc0,   // away from the seam
         radius = BORE_ROUND * tan(acos(ub * uc) / 2))
    [seam, nb, nc, ub, uc, radius];

// The cutter's section at fillet angle t, in the plane square to the seam: from
// a point in the void past the seam, out along the bore to the ball, round the
// ball's near side, and back along the fillet. The ends sit 0.1 into the void
// so no cutter face lies on a face the part has.
function blend_section(t, s, arc = 12) =
    let (b = blend_station(t, s), seam = b[0], nb = b[1], nc = b[2], m = 0.1,
         centre = seam + BORE_ROUND * b[3] - b[5] * nb)
    concat([seam + m * (nb + nc), seam + BORE_ROUND * b[3] + m * nb],
           [for (k = [0 : arc]) centre + b[5] * unit((arc - k) * nb + k * nc)],
           [seam + BORE_ROUND * b[4] + m * nc]);

// The sections lofted from the wall (t 0) to the flat (t 90).
module side_blend(s, step = 2.5) {
    stations = [for (t = [0 : step : 90]) blend_section(t, s)];
    n = len(stations[0]);
    last = len(stations) - 1;
    polyhedron(
        points = [for (sec = stations) each sec],
        faces = concat(
            // The caps are fans of triangles: a section is planar only to rounding,
            // and CGAL rejects an n-gon that is not exactly planar.
            [for (k = [1 : n - 2]) [0, k, k + 1]],
            [for (k = [1 : n - 2]) [last * n, last * n + k + 1, last * n + k]],
            [for (i = [0 : last - 1], k = [0 : n - 1]) each [
                [i * n + k, (i + 1) * n + k, (i + 1) * n + (k + 1) % n],
                [i * n + k, (i + 1) * n + (k + 1) % n, i * n + (k + 1) % n]]]));
}

module channel(s) {
    translate([0, 0, s]) rotate([90, 0, 90]) linear_extrude(NOTCH[1] + epsilon) channel_2d();
    intersection() {   // the bore's round into the channel's flat ceiling, out to
                       // the radial plane through the seam's end, where side_blend
                       // takes over
        edge_round(BORE_R, s + CHANNEL[1], BORE_ROUND, under = 0.05);   // past the fillets' chords
        a = asin((CHANNEL[0] - CHANNEL[2]) / BORE_R) + 0.5;   // lapping side_blend
        translate([0, 0, s]) linear_extrude(2 * CHANNEL[1])
            polygon([[0, 0], RING_R * [cos(a), -sin(a)], RING_R * [cos(a), sin(a)]]);
    }
    for (m = [0, 1]) mirror([0, m, 0]) intersection() {   // not onto the bore past the wall
        side_blend(s);
        translate([0, 0, s]) cube([RING_R, CHANNEL[0], 3 * CHANNEL[1]]);
    }
}

// A cutter that chamfers the top edges of a convex notch outline.
module top_chamfer(c) hull() {
    translate([0, 0, TOP - c]) linear_extrude(epsilon) children();
    translate([0, 0, TOP]) linear_extrude(1) offset(r = c) children();
}

// The chamfer run on round a land mouth: a cone about the round's centre, over
// the round's arc from the notch side out to the land's edge.
module mouth_chamfer(c) {
    y = NOTCH[0] + MOUTH[0];
    centre = [sqrt(pow(LAND_R + MOUTH[1] - MOUTH[0], 2) - y * y), y];
    m = 0.1;
    translate(centre) rotate(-90) rotate_extrude(angle = 90 + atan2(centre[1], centre[0]), $fn = 96)
        polygon([[MOUTH[0] - c - m, TOP + m], [MOUTH[0] + m, TOP + m], [MOUTH[0] + m, TOP - c - m]]);
}

module slot_2d()translate([SLOT[1], -SLOT[0]]) square([RING_R, 2 * SLOT[0]]);

module motor_holes()
    for (a = [45 : 90 : 315]) rotate(a) translate([MOTOR_PITCH / sqrt(2), 0]) children();

module cuts(s) {
    translate([0, 0, SEAT - 1]) cylinder(r = BORE_R, h = TOP - SEAT + 2);
    edge_round(BORE_R, s, BORE_ROUND);
    channel(s);
    translate([0, 0, s]) linear_extrude(TOP - s + 1) slot_2d();
    for (a = [0 : 90 : 270]) rotate(a) top_chamfer(NOTCH_CHAMFER) translate([NOTCH[1], -NOTCH[0]]) square([RING_R, 2 * NOTCH[0]]);
    for (a = [0 : 90 : 270], k = [0, 1]) rotate(a) mirror([0, k, 0]) mouth_chamfer(NOTCH_CHAMFER);
    top_chamfer(NOTCH_CHAMFER) slot_2d();
    rotate_extrude() polygon([[LAND_R - LAND_CHAMFER - epsilon, TOP + epsilon], [LAND_R + 1, TOP + epsilon],
                              [LAND_R + 1, TOP - LAND_CHAMFER - 1 - 2 * epsilon]]);
    motor_holes() {
        translate([0, 0, SEAT - 1]) cylinder(d = MOTOR_HOLE_D, h = TOP - SEAT + 2, $fn = 48);
        translate([0, 0, s - epsilon]) rotate(-30) cylinder(r = NUT[0] / sqrt(3), h = NUT[1] + epsilon, $fn = 6);
        translate([0, 0, LEAD_IN[2]]) cylinder(d1 = LEAD_IN[0], d2 = LEAD_IN[1] + 2 * epsilon, h = TOP - LEAD_IN[2] + epsilon, $fn = 96);
    }
    if (s > SEAT)   // the deeper pocket: the motor's square, up to the raised seat
        translate([0, 0, SEAT - epsilon]) linear_extrude(s - SEAT + epsilon) square(2 * LUG_FLAT, center = true);
}

module ex_gear_motor_end_cap(cfg = config, raise = seat_raise) {
    s = end_cap_seat(cfg, raise);
    assert(s + NUT[1] < LEAD_IN[2], "nut traps would reach the lead-ins");
    difference() { body(s); cuts(s); }
}

ex_gear_motor_end_cap();
echo(end_cap_seat = end_cap_seat());
