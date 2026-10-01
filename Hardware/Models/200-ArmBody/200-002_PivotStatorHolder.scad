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
BODY_D        = 65.000;
RECESS_D      = 50.000;
BORE_D        = [38.000, 36.000];  // previous, revised
PEG_CIRCLE_R  = 21.500;
PEG           = [3.500, 2.000];    // OD, bore
SCREW_D       = 3.000;

function pivot_floor() = FLOOR;

// --- 2D outlines -----------------------------------------------------------
module concave_fillet(r) offset(r = -r) offset(delta = r) children();

module flange_2d()
    difference() {
        concave_fillet(EAR[2]) union() {
            circle(r = FLANGE[0]);
            for (a = [0 : 90 : 270]) rotate(a)
                offset(r = EAR[2]) translate([FLANGE[0] - EAR[2] - 1, -EAR[1]])
                    square([EAR[0] - FLANGE[0] + EAR[2] + 1, 2 * EAR[1]]);
        }
        for (a = [0 : 90 : 270]) rotate(a) translate([SLOT[0], -SLOT[2]]) square([SLOT[1] - SLOT[0], 2 * SLOT[2]]);
    }

// --- Part ------------------------------------------------------------------
module body(cfg) {
    linear_extrude(FLANGE[1]) flange_2d();
    cylinder(d = BODY_D, h = BACK);
}

module turned_cuts(cfg) {
    translate([0, 0, -epsilon]) cylinder(d = RECESS_D, h = FLOOR + epsilon);
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
            translate([0, 0, FLOOR]) mirror([0, 0, 1]) spline_seat_cuts(BACK - FLOOR);
        }
}

pivot_stator_holder();
echo(seat_floor = FLOOR);
