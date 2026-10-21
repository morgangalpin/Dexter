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
//                         nut pockets keep a wall to it; and the floor and
//                         the back face stand where J2's drive closes on
//                         them, DRIVE_SHIFT toward the opening (negative:
//                         0.3 deeper). The holder's flange is held on the
//                         Stator Balancers' lips, so the floor must meet the
//                         spline's flange where C-101, the Flex Spline
//                         Attach and C-201 put it, from the Pivot Motor End
//                         Cap in the L1 6810. With C-201 the reference's
//                         floor stood 4.3 short of that; the Wave Gen
//                         Coupler's spacing (DC-600-2 in
//                         specs/009-Design-Completion.md) then moved the
//                         drive 4.0 of it further from the motor, which
//                         leaves 0.3. armbody_assembly.scad asserts the
//                         closure.
//
// FRAME. The reference's own: the axis on +Z, the recess opening at z = 0,
// its floor at z = 11.000 (revised 11.300), the back face at 16.000 (revised
// 16.300).
//
// Measured from the reference (scadmesh slice/arcs/profile). Everything is
// fourfold about the axis except the screw holes, which are twofold:
//
//     feature                      value                  z span
//     flange, with its ear slots   the Arm Body's outline  0 .. 2
//                                  (arm_body_outline.scad)
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
//     body, in the Arm Body's bore, which   slip: both are printed
//       is the upper 6810's press bore
//       (Ø65.1)
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
include <arm_body_outline.scad>
use <../600-StrainWave/c201_spline_seat.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 144;
epsilon = 0.01;

FLOOR         = 11.000;
BACK          = 16.000;
FLANGE_TOP    = 2.000;             // the flange's outline is arm_body_outline.scad's
SHANK        = [3.900, 9.900];    // a Stator Balancer's shank: radial, across
BODY_D        = 65.000;
RECESS_D      = 50.000;
BORE_D        = [38.000, 36.000];  // previous, revised
PEG_CIRCLE_R  = 21.500;
PEG           = [3.500, 2.000];    // OD, bore
SCREW_D       = 3.000;
DRIVE_SHIFT   = -0.300;            // revised: the floor and the back face this far toward the opening (here away from it)

function shift(cfg) = cfg == "previous" ? 0 : DRIVE_SHIFT;
function pivot_floor(cfg = config) = FLOOR - shift(cfg);
function pivot_back(cfg = config) = BACK - shift(cfg);

// --- 2D outlines -----------------------------------------------------------
function slip(cfg) = fit_clearances(cfg)[0];
function press(cfg) = fit_clearances(cfg)[1];

// An ear slot's [radial, across] size: the measured slot, or the shank's
// section plus the slip clearance, whichever is larger.
function slot_size(cfg) = [max(ARM_BODY_SLOT[1] - ARM_BODY_SLOT[0], fit_bore(SHANK[0], slip(cfg))),
                           max(2 * ARM_BODY_SLOT[2], fit_bore(SHANK[1], slip(cfg)))];

module flange_2d(cfg)
    difference() {
        arm_body_outline_2d();
        arm_body_slots_2d(slot_size(cfg));
    }

// --- Part ------------------------------------------------------------------
module body(cfg) {
    linear_extrude(FLANGE_TOP) flange_2d(cfg);
    cylinder(d = fit_pin(fit_bore(BODY_D, press(cfg)), slip(cfg)), h = pivot_back(cfg));
}

module turned_cuts(cfg) {
    f = pivot_floor(cfg);
    translate([0, 0, -epsilon]) cylinder(d = cfg == "previous" ? RECESS_D : seat_recess_d(press(cfg)), h = f + epsilon);
    translate([0, 0, f - epsilon]) cylinder(d = cfg == "previous" ? BORE_D[0] : BORE_D[1], h = pivot_back(cfg) - f + 2 * epsilon);
}

module pegs() for (a = [0 : 90 : 270]) rotate(a) translate([PEG_CIRCLE_R, 0, FLANGE_TOP])
    cylinder(d = PEG[0], h = FLOOR - FLANGE_TOP + epsilon, $fn = 48);

module peg_and_screw_cuts() {
    for (a = [0 : 90 : 270]) rotate(a) translate([PEG_CIRCLE_R, 0, FLANGE_TOP - epsilon])
        cylinder(d = PEG[1], h = BACK - FLANGE_TOP + 2 * epsilon, $fn = 48);
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
            translate([0, 0, pivot_floor(cfg)]) mirror([0, 0, 1])
                spline_seat_cuts(pivot_back(cfg) - pivot_floor(cfg), press(cfg), slip(cfg));
        }
}

pivot_stator_holder();
echo(seat_floor = pivot_floor());
