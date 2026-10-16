// #311-001 Motor End Cap (Base) — parametric source.
// Caps the rear of J1's motor at the top of the Base Long. Its land is pressed
// into the upper 6810's inner race, and its top face is epoxied to the Main
// Pivot's base; eight lugs grip the motor body, and the motor's rear face
// bears on the seat (008.4 steps 4, 6, 8).
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/300-Pivot/).
//   config = "revised"  — the print fits below drawn on the land, the lugs,
//                         the seat and the screw holes.
//
// FRAME. The reference's own: the axis on +Z, the seat at z = -1.700 (the face
// the motor's rear bears on), the land from z = 3.500 to the top face at
// 10.500. The lugs hang below the seat to z = -6.700.
//
// Measured from the reference (scadmesh planes/slice/arcs/solid). Every
// feature is fourfold about the axis and mirror-symmetric about the axes and
// diagonals, except the wire channel, which is at +x only:
//
//     feature                      value                  z span
//     outline                      R26.750 less 4 notches at 0/90/180/270,
//                                  13.0 wide, floor r 20.996, R1.15 floor
//                                  fillets, sharp mouths  -6.7 .. 10.5
//     centre bore                  Ø22.5, R1 round into the seat    through
//     motor holes, 31.0 square     Ø3.2                   through
//     land, the 6810's journal     R25.000; top edges, the notches' too,
//                                  0.4 x 45 deg           3.5 .. 10.5
//     ring below the land          the outline, the 6810's stop    -1.7 .. 3.5
//     lugs, 8                      the outline less the 42.292 motor
//                                  square; R0.5 at the notch-side corner;
//                                  bottom edges R0.5 on the inner face,
//                                  R0.3 round the rest but the outside
//                                                         -6.7 .. -1.7
//     their root fillets           R0.5, along the inner face and round
//                                  the corner, under the seat
//     seat edges at the notches    R0.5, but at +x, where the channel
//                                  opens; the notch cuts them  -1.7 .. -1.557
//     wire channel, +x             ../end_cap_channel.scad, 11.96 wide at
//                                  mid-height, 2.0 high, R1 fillets and
//                                  rounds, from the bore until it meets a
//                                  lug or opens into the notch; the lugs'
//                                  root fillets run up onto its seat rounds
//
// The lugs' corner rounds and the seat's edge rounds were rounded on a notch
// 0.15 narrower, and the notch cuts them: the corners are tangent to the inner
// face only, and the seat's round meets the notch's floor 0.143 above the seat.
//
// CONSTRUCTION. The outline, with the bore and the motor holes, extruded the
// full height; a cylinder cut above the land's foot leaves the land; the
// motor's pocket (../end_cap_channel.scad) cut up to the seat leaves the lugs;
// the edges; the channel, kept to the pocket and the notches; and last the
// root fillets, which fill the corners the channel leaves at the lugs.
//
// FITS (../print_fit.scad), revised only, per side:
//
//     land, in the 6810's Ø50 bore         press
//     lugs, on the motor's 42.3 body       press: they centre the motor
//     seat, on the motor's rear face       press
//     motor holes, on M3                   slip, over Ø3.0
//
// The revised seat is trimmed back up into the cap, and the features drawn
// from the seat (the lugs' roots, the root fillets, the bore's round, the
// channel) move with it. The motor's rear stays at z -1.700 (cap_seat()), so
// the stack the assembly closes is unchanged.
//
// The revised channel's sides are rounded into the bore, as its ceiling is,
// from the ceiling down to the seat (end_cap_channel.scad, round_sides). The
// reference meets them sharp.
//
// The revised root fillets are trimmed to the motor's square, grown by the
// press clearance, as the Flex Spline Attach's are: the motor's rear edge is
// square, and they would stand on it. None is left along the faces; round
// the corners what is left stands off the motor. The Ø22.5 bore over the
// motor's Ø22 boss already clears by more and keeps its size.

include <../print_fit.scad>
use <../end_cap_channel.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 144;
epsilon = 0.01;

SEAT          = -1.700;    // the face the motor's rear bears on
FOOT          = 3.500;     // the land's foot, the ring's top face
TOP           = 10.500;    // the face on the Main Pivot
LUG_Z         = -6.700;
OUTLINE_R     = 26.750;
LAND_R        = 25.000;
NOTCH         = [6.500, 20.996];   // half-width, floor radius
NOTCH_FILLET  = 1.150;
TOP_CHAMFER   = 0.400;     // land rim and notch top edges
LUG_FLAT      = 21.146;    // lug inner faces: the motor's half-width
LUG_CORNER    = 0.500;     // lugs' notch-side corners, and bottom inner edges
NARROWER      = 0.150;     // the notch the lugs' corners were rounded on is this much narrower
EDGE_ROUND    = 0.300;     // lugs' other bottom edges
ROOT_FILLET   = 0.500;
SEAT_ROUND    = 0.500;     // the seat's edges at the notches without the channel
BORE_R        = 11.250;
BORE_ROUND    = 1.000;
CHANNEL       = [5.980, 2.000, 1.000];   // half-width at mid-height, height above the seat, round radius
MOTOR_PITCH   = 31.000;
MOTOR_HOLE_D  = 3.200;

M3_D          = 3.000;     // the motor screws' nominal diameter

function cap_seat() = SEAT;   // the motor's rear face, in either configuration
function cap_land() = [FOOT, TOP];

function slip(cfg) = fit_clearances(cfg)[0];
function press(cfg) = fit_clearances(cfg)[1];
function lug_flat(cfg) = LUG_FLAT + press(cfg);
function seat(cfg) = SEAT + press(cfg);

// --- 2D outlines -----------------------------------------------------------
module convex_round(r) offset(r = r) offset(delta = -r) children();

// One notch's void, on +x, its floor corners rounded: the floors' fillets.
module notch_2d()
    convex_round(NOTCH_FILLET) translate([NOTCH[1], -NOTCH[0]]) square([OUTLINE_R, 2 * NOTCH[0]]);

module each_notch() for (a = [0 : 90 : 270]) rotate(a) children();

module motor_holes()
    for (x = [-1, 1], y = [-1, 1]) translate([x, y] * MOTOR_PITCH / 2) children();

// The whole section: the notched outline less the bore and the motor holes.
module section_2d(cfg) {
    hole_d = cfg == "previous" ? MOTOR_HOLE_D : fit_bore(M3_D, slip(cfg));
    difference() {
        circle(r = OUTLINE_R);
        each_notch() notch_2d();
        circle(r = BORE_R);
        motor_holes() circle(d = hole_d, $fn = 48);
    }
}

// What is cut up to the seat: the motor's pocket, its corners rounded on the
// narrower notch, and the notches.
module lug_cut_2d(cfg)
    union() {
        motor_pocket_2d(lug_flat(cfg), NOTCH[0] - NARROWER, LUG_CORNER, OUTLINE_R);
        each_notch() notch_2d();
    }

// --- Solids ----------------------------------------------------------------
// How far along a lug's face its root fillet runs: a little past the outline,
// short of the next face's fillet.
function face_end(cfg) = sqrt(pow(OUTLINE_R, 2) - pow(lug_flat(cfg), 2)) + 0.5;

// The root fillets between the seat and each lug, along its inner face and
// round its notch-side corner; at the +x notch they run up onto the channel's
// seat rounds. None runs into a notch.
// Each is cut to the section on its own: CGAL fails on the lot at once.
module root_fillets(cfg)
    for (a = [0 : 90 : 270], m = [0, 1]) intersection() {
        rotate(a) mirror([0, m, 0])
            root_fillet(seat(cfg), a == 0 ? CHANNEL : undef, lug_flat(cfg),
                        NOTCH[0] - NARROWER + LUG_CORNER, LUG_CORNER, ROOT_FILLET, face_end(cfg),
                        a == 0 ? [NOTCH[0], NOTCH[1], NOTCH_FILLET] : narrow_notch());
        translate([0, 0, seat(cfg) - 1]) linear_extrude(2) section_2d(cfg);
    }

// The revised fillets, less the motor's square grown by the press clearance.
module trimmed_root_fillets(cfg)
    difference() {
        root_fillets(cfg);
        translate([0, 0, seat(cfg) - 1]) linear_extrude(2) square(2 * lug_flat(cfg), center = true);
    }

module body(cfg) translate([0, 0, LUG_Z]) linear_extrude(TOP - LUG_Z) section_2d(cfg);

// --- Cuts ------------------------------------------------------------------
// The lugs' bottom edges on their inner faces, corners and notch sides,
// rounded R0.3: the cut region grown, layer by layer, by the round's setback
// at each height. The outline is not convex there, so no hull holds it.
module lug_edge_rounds(cfg, r = EDGE_ROUND, n = 6)
    for (k = [0 : n - 1])
        let (h = (k + 0.5) * r / n, d = r - sqrt(r * r - pow(r - h, 2)))
        translate([0, 0, k == 0 ? LUG_Z - 1 : LUG_Z + k * r / n])
            linear_extrude((k == 0 ? 1 : 0) + r / n + epsilon) offset(r = d) lug_cut_2d(cfg);

// The lugs' bottom inner edges, rounded R0.5 along each face.
module lug_bottom_rounds(cfg)
    for (a = [0 : 90 : 270]) rotate(a)
        translate([lug_flat(cfg), OUTLINE_R, LUG_Z]) rotate([90, 0, 0])
            linear_extrude(2 * OUTLINE_R) difference() {
                translate([-epsilon, -epsilon]) square(LUG_CORNER + epsilon);
                translate([LUG_CORNER, LUG_CORNER]) circle(r = LUG_CORNER, $fn = 48);
            }

// The notch the lugs' corners were rounded on, in root_fillet's terms, with
// the seat's round on its edge.
function narrow_notch() = [NOTCH[0] - NARROWER, NOTCH[1] + NARROWER, NOTCH_FILLET - NARROWER, SEAT_ROUND];

// The round's section: u in from its axis toward the notch, v up from the seat.
module seat_round_2d(m = 0.1)
    difference() {
        translate([0, -m]) square([SEAT_ROUND + m, SEAT_ROUND + m]);
        translate([0, SEAT_ROUND]) circle(r = SEAT_ROUND, $fn = 72);
    }

// The seat's edges at the +x notch, where the channel does not take them:
// rounded on the narrow notch's floor and floor fillets, about an axis
// SEAT_ROUND back from them. The notch cuts the round, and it stops at the
// lugs.
module seat_round(cfg) {
    n = notch_grown(narrow_notch());   // the round's axis
    q = notch_corner(n);               // the floor fillets' centre, +y
    intersection() {
        translate([0, 0, seat(cfg)]) {
            translate([n[1], q[1], 0]) rotate([90, 0, 0]) linear_extrude(2 * q[1]) seat_round_2d();
            for (m = [0, 1]) mirror([0, m, 0]) translate([q[0], q[1], 0]) rotate(90)
                rotate_extrude(angle = 90) translate([n[2], 0]) mirror([1, 0]) seat_round_2d();
        }
        translate([0, 0, seat(cfg) - 1]) linear_extrude(2) lug_cut_2d(cfg);
    }
}

// A cutter that chamfers the top edges of a convex outline.
module top_chamfer(c) hull() {
    translate([0, 0, TOP - c]) linear_extrude(epsilon) children();
    translate([0, 0, TOP]) linear_extrude(1) offset(r = c) children();
}

// The wire channel, kept to the motor's pocket and the notches: it runs on
// through the notch floor's fillets, and stops where it meets a lug. The
// revised channel's sides are rounded into the bore.
module channel(cfg)
    wire_channel(seat(cfg), [BORE_R, BORE_ROUND], CHANNEL, OUTLINE_R, round_sides = cfg != "previous")
        lug_cut_2d(cfg);

module cuts(cfg) {
    land_r = LAND_R - press(cfg);
    translate([0, 0, FOOT]) difference() {   // the step: everything beyond the land
        cylinder(r = OUTLINE_R + 1, h = TOP - FOOT + 1);
        translate([0, 0, -1]) cylinder(r = land_r, h = TOP - FOOT + 3);
    }
    translate([0, 0, LUG_Z - 1]) linear_extrude(seat(cfg) - LUG_Z + 1) lug_cut_2d(cfg);
    lug_bottom_rounds(cfg);
    lug_edge_rounds(cfg);
    for (a = [90 : 90 : 270]) rotate(a) seat_round(cfg);
    edge_round(BORE_R, seat(cfg), BORE_ROUND);
    rotate_extrude() polygon([[land_r - TOP_CHAMFER - epsilon, TOP + epsilon], [land_r + 1, TOP + epsilon],
                              [land_r + 1, TOP - TOP_CHAMFER - 1 - 2 * epsilon]]);
    each_notch() top_chamfer(TOP_CHAMFER) notch_2d();
}

// The root fillets go on last: the cuts would take them with the motor's
// pocket, and the channel where they run up onto its seat rounds.
module motor_end_cap_base(cfg = config)
    union() {
        difference() { body(cfg); cuts(cfg); channel(cfg); }
        if (cfg == "previous") root_fillets(cfg);
        else trimmed_root_fillets(cfg);
    }

motor_end_cap_base();
echo(cap_seat = cap_seat());
