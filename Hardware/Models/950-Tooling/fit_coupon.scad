// Print-fit coupon: qualifies a machine against ../print_fit.scad's two
// clearances before any part of the robot is printed (specs/007.2 § Print
// fits, DC-11(d)). It carries the fits the parts draw, each against the mate
// the parts draw it for:
//
//     MR128 seat           Ø12 + 2 x FIT_PRESS, 3.5 deep over a Ø9 push-out
//                          hole: the SEAT_D of
//                          ../700-Differential/720-001_DiffGearShaft.scad
//     C-502 strake slot    5.588 x 2.337 + 2 x FIT_PRESS, through: the fit
//                          #710-001 bonds its #710-005 strakes into
//     rod bore             Ø8 + 2 x FIT_PRESS, through: the bore a C-506 tube
//                          is bonded into
//     slip bore            Ø10 + 2 x FIT_SLIP, through
//     peg                  Ø10 x 10, a second body printed beside the plate,
//                          for the slip bore: printed against printed
//
// The machine passes when the MR128 presses in without a reamer, the strake
// enters the slot and the tube the rod bore by hand without rocking, and the
// peg slides through the slip bore. A fit that fails is corrected by editing
// FIT_SLIP or FIT_PRESS in ../print_fit.scad, which every part reads, and
// printing the coupon again, never by sanding parts.
//
// FRAME. The plate on z = 0, its features along +X; the peg stands beside it
// on +Y.

include <../print_fit.scad>

/* [Hidden] */
$fn = 144;
epsilon = 0.01;

PLATE      = [62.000, 20.000, 5.000];
MR128      = [12.000, 3.500];    // OD, width
PUSH_OUT_D = 9.000;
STRIP      = [5.588, 2.337];     // C-502, the #710-005 strake
ROD_D      = 8.000;              // C-506 tube OD
PEG        = [10.000, 10.000];   // diameter, height
STATIONS   = [8.000, 23.000, 37.000, 52.000];   // seat, slot, rod bore, slip bore

module fit_coupon() {
    difference() {
        cube(PLATE);
        translate([STATIONS[0], PLATE[1] / 2, PLATE[2] - MR128[1]])
            cylinder(d = fit_bore(MR128[0], FIT_PRESS), h = MR128[1] + epsilon);
        translate([STATIONS[0], PLATE[1] / 2, -epsilon])
            cylinder(d = PUSH_OUT_D, h = PLATE[2] + 2 * epsilon);
        translate([STATIONS[1], PLATE[1] / 2, PLATE[2] / 2])
            cube([fit_bore(STRIP[1], FIT_PRESS), fit_bore(STRIP[0], FIT_PRESS), PLATE[2] + 2 * epsilon], center = true);
        translate([STATIONS[2], PLATE[1] / 2, -epsilon])
            cylinder(d = fit_bore(ROD_D, FIT_PRESS), h = PLATE[2] + 2 * epsilon);
        translate([STATIONS[3], PLATE[1] / 2, -epsilon])
            cylinder(d = fit_bore(PEG[0], FIT_SLIP), h = PLATE[2] + 2 * epsilon);
    }
    translate([PLATE[0] / 2, PLATE[1] + PEG[0], 0]) cylinder(d = PEG[0], h = PEG[1]);
}

fit_coupon();
echo(fit_slip = FIT_SLIP, fit_press = FIT_PRESS);
