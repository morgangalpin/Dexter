// #200-002 Pivot Stator Holder — parametric source.
// Carries J2's circular spline in the Arm Body. Its Ø65 body slides into the
// Arm Body; its recess takes the spline; the four slotted ears ride the
// all-thread, whose nuts take up the drive's span.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/200-ArmBody/).
//   config = "revised"  — seats the C-201 circular spline: the pegs and the
//                         two screw holes, laid out for a different drive,
//                         give way to the shared spline seat
//                         (../600-StrainWave/c201_spline_seat.scad), and the
//                         bore behind the seat closes from Ø38 to Ø36 so the
//                         nut pockets keep a wall to it.
//
// FRAME. The reference's own: the axis on +Z, the recess opening at z = 0,
// its floor at z = 11.000, the back face at 16.000.
//
// Measured from the reference (scadmesh slice/arcs/profile). Everything is
// fourfold about the axis except the screw holes, which are twofold:
//
//     feature                      value                  z span
//     flange                       R36.5, four ears on 0/90/180/270
//                                  to 41.547 with R4 corners, R4
//                                  fillets into the R36.5      0 .. 2
//     ear slots                    10.0 x 4.0, r 33.516 .. 37.516   0 .. 2
//     body                         Ø65.0                  2 .. 16
//     recess                       Ø50.0                  0 .. 11
//     bore                         Ø38.0                  11 .. 16
//     pegs, 4 on 90 deg, Ø43       Ø3.5, Ø2.0 through     2 .. 16
//     screw holes, -45 / 135 deg,  Ø3.0                   11 .. 16
//       Ø43
//
// The z 6.667 and 11.333 planes a histogram reports are tessellation rows on
// the peg bores, not faces.
//
// In the revised config the M3 x 12 screws of the seat stand
// seat_screw_tip() - (BACK - FLOOR) = 1.0 proud of the back face, inside the
// Ø50 circle, where only the drive turns.
//
// FITS (../print_fit.scad), revised only:
//
//     body, in the Arm Body's Ø65 bore      slip: both are printed
//     ear slots, on the Stator Balancers'   slip: both are printed
//       3.9 x 9.9 shanks
//     recess, on the spline's flange        press, the seat's pilot press
//                                           and its nut pockets slip:
//                                           c201_spline_seat.scad
//
// The ear slots take the four Stator Balancers (#200-003), whose shanks also
// enter the Arm Body's matching 4.0 x 10.0 slots and hold the stator against
// the drive's torque. Each slot opens about its own centre.

include <../print_fit.scad>
use <../600-StrainWave/c201_spline_seat.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 144;
epsilon = 0.01;

FLOOR         = 11.000;
BACK          = 16.000;
FLANGE        = [36.500, 2.000];   // radius, top
EAR           = [37.547, 5.031, 4.000];   // corner centres' x and ±y, their radius
SLOT          = [33.516, 37.516, 5.000];  // inner and outer radius, half-width
SHANK         = [3.900, 9.900];    // a Stator Balancer's shank: radial, across
BODY_D        = 65.000;
RECESS_D      = 50.000;
BORE_D        = [38.000, 36.000];  // previous, revised
PEG_CIRCLE_R  = 21.500;
PEG           = [3.500, 2.000];    // OD, bore
SCREW_D       = 3.000;

function pivot_floor() = FLOOR;

// --- 2D outlines -----------------------------------------------------------
module concave_fillet(r) offset(r = -r) offset(delta = r) children();

function slip(cfg) = fit_clearances(cfg)[0];
function press(cfg) = fit_clearances(cfg)[1];

// An ear slot's [radial, across] size: the measured slot, or the shank's
// section plus the slip clearance, whichever is larger.
function slot_size(cfg) = [max(SLOT[1] - SLOT[0], fit_bore(SHANK[0], slip(cfg))),
                           max(2 * SLOT[2], fit_bore(SHANK[1], slip(cfg)))];

module flange_2d(cfg)
    difference() {
        concave_fillet(EAR[2]) union() {
            circle(r = FLANGE[0]);
            for (a = [0 : 90 : 270]) rotate(a)
                offset(r = EAR[2]) translate([FLANGE[0] - EAR[2] - 1, -EAR[1]])
                    square([EAR[0] - FLANGE[0] + EAR[2] + 1, 2 * EAR[1]]);
        }
        for (a = [0 : 90 : 270]) rotate(a) translate([(SLOT[0] + SLOT[1]) / 2, 0]) square(slot_size(cfg), center = true);
    }

// --- Part ------------------------------------------------------------------
module body(cfg) {
    linear_extrude(FLANGE[1]) flange_2d(cfg);
    cylinder(d = fit_pin(BODY_D, slip(cfg)), h = BACK);
}

module turned_cuts(cfg) {
    translate([0, 0, -epsilon]) cylinder(d = cfg == "previous" ? RECESS_D : seat_recess_d(press(cfg)), h = FLOOR + epsilon);
    translate([0, 0, FLOOR - epsilon]) cylinder(d = cfg == "previous" ? BORE_D[0] : BORE_D[1], h = BACK - FLOOR + 2 * epsilon);
}

module pegs() for (a = [0 : 90 : 270]) rotate(a) translate([PEG_CIRCLE_R, 0, FLANGE[1]])
    cylinder(d = PEG[0], h = FLOOR - FLANGE[1] + epsilon, $fn = 48);

module peg_and_screw_cuts() {
    for (a = [0 : 90 : 270]) rotate(a) translate([PEG_CIRCLE_R, 0, FLANGE[1] - epsilon])
        cylinder(d = PEG[1], h = BACK - FLANGE[1] + 2 * epsilon, $fn = 48);
    for (a = [-45, 135]) rotate(a) translate([PEG_CIRCLE_R, 0, FLOOR - epsilon])
        cylinder(d = SCREW_D, h = BACK - FLOOR + 2 * epsilon, $fn = 48);
}

module pivot_stator_holder(cfg = config) {
    if (cfg == "previous")
        difference() { union() { difference() { body(cfg); turned_cuts(cfg); } pegs(); } peg_and_screw_cuts(); }
    else
        // The seat's frame has its recess on +Z; this part's opens toward -Z.
        difference() {
            body(cfg);
            turned_cuts(cfg);
            translate([0, 0, FLOOR]) mirror([0, 0, 1]) spline_seat_cuts(BACK - FLOOR, press(cfg), slip(cfg));
        }
}

pivot_stator_holder();
echo(seat_floor = FLOOR);
