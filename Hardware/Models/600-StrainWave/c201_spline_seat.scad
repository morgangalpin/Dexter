// C-201 circular spline seat, shared by the three Stator Holders
// (#110-002 Base, J1; #200-002 Pivot, J2; #511-002 Ex Gear, J3).
//
// The circular spline is C-201's fixed-to-the-holder half. The drive's
// interface values are owned by 007.1 C-201, taken from the manufacturer
// drawing (../../Reference/XB1-AS-C-32.pdf); the constants below are that
// table in code:
//
//     flange       Ø50h6, 6 thick, its outer face the drive's mounting face
//     step         Ø38h7, 2 long, on the flange's inner face (toward the
//                  flexspline hub)
//     holes        6 x Ø3.5 on Ø44, through the flange
//     span         23.5, circular spline outer face to flexspline hub face
//
// What this file adds is the seat every holder cuts for it: the flange's
// inner face bears on the recess floor, the step drops into a Ø38 pilot
// deep enough that it never lands, and six M3 x 12 socket-head screws pass
// down through the flange into M3 nuts held in hex pockets opened from the
// holder's back face. The nut stands clear of the pilot's floor, so the web
// between them is SEAT_WEB rather than the 0.25 mm the pilot's wall leaves
// beside the pocket's flats.
//
// FRAME. The seat's own: the axis on +Z, the floor at z = 0, the recess
// above it. A holder whose recess faces -Z mirrors the seat onto its floor.

/* [Hidden] */
epsilon = 0.01;

CS_FLANGE     = [50.000, 6.000];    // Ø, thickness
CS_STEP       = [38.000, 2.000];    // Ø, length below the flange
CS_HOLES      = [3.500, 44.000];    // Ø, circle Ø
CS_HOLE_ANGLE = 30;                 // first hole; six on 60 deg
CS_HOLE_COUNT = 6;
DRIVE_SPAN    = 23.500;             // circular spline outer face to flexspline hub face

PILOT_DEPTH   = 2.200;              // below the floor; the step is 2.000 long
BOLT_HOLE_D   = 3.400;              // M3 clearance
NUT           = [5.500, 2.400];     // M3 hex: across flats, thickness
SEAT_WEB      = 0.200;              // pilot floor to nut
SCREW_LEN     = 12.000;             // M3 x 12, under the head

function drive_span() = DRIVE_SPAN;
function spline_flange() = CS_FLANGE;
function spline_step() = CS_STEP;
function spline_hole_angles() = [for (i = [0 : CS_HOLE_COUNT - 1]) CS_HOLE_ANGLE + 360 / CS_HOLE_COUNT * i];
function spline_hole_r() = CS_HOLES[1] / 2;
function seat_pilot_depth() = PILOT_DEPTH;
// Nut top and bottom, below the floor; the screw's tip, below the floor.
function seat_nut_top() = PILOT_DEPTH + SEAT_WEB;
function seat_nut_bottom() = seat_nut_top() + NUT[1];
function seat_screw_tip() = SCREW_LEN - CS_FLANGE[1];

assert(seat_screw_tip() >= seat_nut_bottom(), "the screw does not pass through its nut");

module seat_holes() for (a = spline_hole_angles()) rotate(a) translate([spline_hole_r(), 0]) children();

// A hexagon with one pair of flats facing the axis, when placed on +X.
module nut_hex() rotate(30) circle(d = NUT[0] / cos(30), $fn = 6);

// The seat's voids, for a floor at z = 0 whose back face is `back` below it.
module spline_seat_cuts(back) {
    assert(back >= seat_nut_bottom(), "the floor is too thin to hold the nut");
    translate([0, 0, -PILOT_DEPTH]) cylinder(d = CS_STEP[0], h = PILOT_DEPTH + epsilon, $fn = 144);
    seat_holes() {
        translate([0, 0, -back - epsilon]) cylinder(d = BOLT_HOLE_D, h = back + 2 * epsilon, $fn = 48);
        translate([0, 0, -back - epsilon]) linear_extrude(back - seat_nut_top() + epsilon) nut_hex();
    }
}

// The circular spline as the drawing gives it, outer face at z = 0 and the
// step below; for assembly placement only.
module circular_spline_envelope()
    difference() {
        union() {
            translate([0, 0, -CS_FLANGE[1]]) cylinder(d = CS_FLANGE[0], h = CS_FLANGE[1], $fn = 144);
            translate([0, 0, -CS_FLANGE[1] - CS_STEP[1]]) cylinder(d = CS_STEP[0], h = CS_STEP[1] + epsilon, $fn = 144);
        }
        translate([0, 0, -20]) cylinder(d = 35.500, h = 30, $fn = 144);
        seat_holes() translate([0, 0, -10]) cylinder(d = CS_HOLES[0], h = 20, $fn = 48);
    }
