// C-201 interface: the circular spline seat shared by the three Stator
// Holders (#110-002 Base, J1; #200-002 Pivot, J2; #511-002 Ex Gear, J3), and
// the flexspline hub the Flex Spline Attach (#630-005) and Cap (#630-006)
// clamp.
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
//     hub          Ø22.5, 2.4 thick, standing proud of the cup's bottom on
//                  its outer face; the bottom is flat inside
//     hub bore     Ø11H7
//     hub holes    6 x Ø4.5 on Ø17, through the hub
//
// The hub's holes have no phase to keep: nothing else on the flexspline is
// indexed to them, so the parts that clamp it start them at 0 deg.
//
// What this file adds is the seat every holder cuts for it: the flange's
// inner face bears on the recess floor, the step drops into a Ø38 pilot
// deep enough that it never lands, and six M3 x 12 socket-head screws pass
// down through the flange into M3 nuts held in hex pockets opened from the
// holder's back face. The nut stands clear of the pilot's floor, so the web
// between them is SEAT_WEB: beside the pocket's flats the pilot's wall is
// all but gone.
//
// FITS (print_fit.scad), per side:
//
//     recess       Ø50 on the flange's Ø50h6   press   seat_recess_d(); it
//                                                      centres the spline
//     pilot        Ø38 on the step's Ø38h7     press   coaxial with the
//                                                      recess on one part
//     nut pockets  5.5 AF on the M3 nut        slip
//
// The Ø3.4 screw holes already clear an M3 by 0.2 and keep it.
//
// FRAME. The seat's own: the axis on +Z, the floor at z = 0, the recess
// above it. A holder whose recess faces -Z mirrors the seat onto its floor.

include <../print_fit.scad>

/* [Hidden] */
epsilon = 0.01;

CS_FLANGE     = [50.000, 6.000];    // Ø, thickness
CS_STEP       = [38.000, 2.000];    // Ø, length below the flange
CS_HOLES      = [3.500, 44.000];    // Ø, circle Ø
CS_HOLE_ANGLE = 30;                 // first hole; six on 60 deg
CS_HOLE_COUNT = 6;
DRIVE_SPAN    = 23.500;             // circular spline outer face to flexspline hub face
FS_HUB        = [22.500, 2.400];    // Ø, thickness
FS_BORE_D     = 11.000;             // H7
FS_HOLES      = [4.500, 17.000];    // Ø, circle Ø
FS_HOLE_COUNT = 6;
// The flexspline's cup, measured (Ø as [major, minor] where it is oval) but
// for the three estimates.
FS_CUP_CLOSED    = 32.600;             // Ø at the closed end, round
FS_CUP_OPEN      = [32.950, 32.070];   // Ø just above the teeth band
FS_CUP_TEETH     = [34.290, 33.030];   // Ø over the teeth band
FS_CUP_MOUTH     = [32.840, 31.340];   // bore Ø in the teeth band
FS_CUP_TEETH_LEN = 6.000;              // estimate
FS_CUP_WALL      = 0.250;              // estimate, at the closed end
FS_CUP_BOTTOM    = 0.600;              // estimate
// The wave generator's hub: Ø, length, how far it stands beyond the circular
// spline's outer face; its Ø6H7 bore runs through it, and its two M3 set
// screws stand WG_SCREW_IN in from its outer face.
WG_HUB        = [14.000, 15.000, 5.000];
WG_BORE_D     = 6.000;
WG_SCREW_IN   = 2.500;

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
function seat_recess_d(c) = fit_bore(CS_FLANGE[0], c);
function fs_hub() = FS_HUB;
function fs_bore_d() = FS_BORE_D;
function fs_holes() = FS_HOLES;
// The wave generator's hub, along the drive from the circular spline's outer
// face toward the flexspline's hub: its outer face (negative: beyond the
// spline's face), its set screws' axis, and its inner end.
function wg_hub_outer() = -WG_HUB[2];
function wg_set_screws() = WG_SCREW_IN - WG_HUB[2];
function wg_hub_inner() = WG_HUB[1] - WG_HUB[2];
// Nut top and bottom, below the floor; the screw's tip, below the floor.
function seat_nut_top() = PILOT_DEPTH + SEAT_WEB;
function seat_nut_bottom() = seat_nut_top() + NUT[1];
function seat_screw_tip() = SCREW_LEN - CS_FLANGE[1];

assert(seat_screw_tip() >= seat_nut_bottom(), "the screw does not pass through its nut");

module seat_holes() for (a = spline_hole_angles()) rotate(a) translate([spline_hole_r(), 0]) children();
module fs_hub_holes() for (i = [0 : FS_HOLE_COUNT - 1]) rotate(360 / FS_HOLE_COUNT * i) translate([FS_HOLES[1] / 2, 0]) children();

// A hexagon with one pair of flats facing the axis, when placed on +X.
module nut_hex(slip) rotate(30) circle(d = fit_bore(NUT[0], slip) / cos(30), $fn = 6);

// The seat's voids, for a floor at z = 0 whose back face is `back` below it,
// with press clearance per side on the pilot and slip on the nut pockets.
module spline_seat_cuts(back, press, slip) {
    assert(back >= seat_nut_bottom(), "the floor is too thin to hold the nut");
    translate([0, 0, -PILOT_DEPTH]) cylinder(d = fit_bore(CS_STEP[0], press), h = PILOT_DEPTH + epsilon, $fn = 144);
    seat_holes() {
        translate([0, 0, -back - epsilon]) cylinder(d = BOLT_HOLE_D, h = back + 2 * epsilon, $fn = 48);
        translate([0, 0, -back - epsilon]) linear_extrude(back - seat_nut_top() + epsilon) nut_hex(slip);
    }
}

// The flexspline, hub face at z = 0 and the cup above it; for assembly
// placement only. The hub, its bore and its holes are the drawing's. The
// drawing leaves the cup undimensioned, so the FS_CUP_* values are measured
// on the drive with the wave generator in it, which holds the open end oval,
// its major axis on X here. The cup tapers from round at its closed end to
// that oval at the teeth band, inside and out.
module flexspline_envelope() {
    teeth_z = DRIVE_SPAN - FS_CUP_TEETH_LEN;
    closed_bore = FS_CUP_CLOSED - 2 * FS_CUP_WALL;
    difference() {
        union() {
            cylinder(d = FS_HUB[0], h = FS_HUB[1], $fn = 144);
            translate([0, 0, FS_HUB[1] - FS_CUP_BOTTOM])
                oval_taper([FS_CUP_CLOSED, FS_CUP_CLOSED], FS_CUP_OPEN, teeth_z - FS_HUB[1] + FS_CUP_BOTTOM);
            translate([0, 0, teeth_z - epsilon]) linear_extrude(FS_CUP_TEETH_LEN + epsilon) oval(FS_CUP_TEETH);
        }
        translate([0, 0, FS_HUB[1]]) oval_taper([closed_bore, closed_bore], FS_CUP_MOUTH, teeth_z - FS_HUB[1]);
        translate([0, 0, teeth_z - epsilon]) linear_extrude(FS_CUP_TEETH_LEN + 1) oval(FS_CUP_MOUTH);
        translate([0, 0, -1]) cylinder(d = FS_BORE_D, h = FS_HUB[1] + 2, $fn = 144);
        fs_hub_holes() translate([0, 0, -1]) cylinder(d = FS_HOLES[0], h = FS_HUB[1] + 2, $fn = 48);
    }
}

// An ellipse of diameters d = [x, y], and a prism of height h that tapers
// from one to another.
module oval(d) scale(d) circle(d = 1, $fn = 144);
module oval_taper(d0, d1, h) linear_extrude(h, scale = [d1[0] / d0[0], d1[1] / d0[1]]) oval(d0);

// The wave generator, in the circular spline's frame (its outer face at
// z = 0, the drive below); for assembly placement only. An envelope: the
// plug and its bearing fill the flexspline's oval bore in the teeth band,
// at the flexspline's phase, and the hub stands 5.0 beyond the drive face.
module wave_generator_envelope()
    translate([0, 0, -FS_CUP_TEETH_LEN]) {
        difference() {
            linear_extrude(FS_CUP_TEETH_LEN) oval(FS_CUP_MOUTH);
            translate([0, 0, -1]) cylinder(d = 14.000, h = FS_CUP_TEETH_LEN + 2);
        }
        translate([0, 0, FS_CUP_TEETH_LEN - wg_hub_inner()]) wg_tube(WG_HUB[0], WG_BORE_D, WG_HUB[1]);
    }

module wg_tube(od, id, h)
    difference() { cylinder(d = od, h = h); translate([0, 0, -1]) cylinder(d = id, h = h + 2); }

// The circular spline as the drawing gives it, outer face at z = 0 and the
// step below; for assembly placement only. Its bore is the flexspline's
// teeth band across the major axis, where the two mesh.
module circular_spline_envelope()
    difference() {
        union() {
            translate([0, 0, -CS_FLANGE[1]]) cylinder(d = CS_FLANGE[0], h = CS_FLANGE[1], $fn = 144);
            translate([0, 0, -CS_FLANGE[1] - CS_STEP[1]]) cylinder(d = CS_STEP[0], h = CS_STEP[1] + epsilon, $fn = 144);
        }
        translate([0, 0, -20]) cylinder(d = FS_CUP_TEETH[0], h = 30, $fn = 144);
        seat_holes() translate([0, 0, -10]) cylinder(d = CS_HOLES[0], h = 20, $fn = 48);
    }
