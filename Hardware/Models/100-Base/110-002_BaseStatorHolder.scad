// #110-002 Base Stator Holder — parametric source.
// Carries J1's circular spline on the Base Long. Its Ø65 body slides between
// the six strakes, which pass through the flange's slots; the all-thread runs
// through the flange's holes, whose nuts take up the drive's span.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/100-Base/), in that mesh's
//                         frame (see FRAME).
//   config = "revised"  — seats the C-201 circular spline: the pegs and the
//                         two screw holes, laid out for a different drive,
//                         give way to the shared spline seat
//                         (../600-StrainWave/c201_spline_seat.scad).
//
// FRAME. The axis on +Z through the origin, the back face at z = 0, the recess
// floor at 5.000, the flange's face at 16.000, where the recess opens. The
// reference mesh has its axis at (-3.125, 5.413), 6.25 mm off the origin at
// 120 deg; the previous config is placed there so it can be compared with the
// mesh as it is, and the revised config is not.
//
// Measured from the reference (scadmesh slice/arcs/profile, on a copy moved
// onto the axis by transform --translate). Everything is sixfold about the
// axis except the pegs, which are fourfold, and the screw holes, twofold:
//
//     feature                      value                  z span
//     body                         Ø65.0                  0 .. 12
//     flange                       a dodecagon, corners on 30 deg from
//                                  0 deg less 0.17 deg, rounded R10.075
//                                  about centres 32.06 out     12 .. 16
//     strake slots, 6 on 0 deg     13.0 wide, r 33.85 .. 37.452   12 .. 16
//     all-thread holes, 6 on 30    Ø3.0 on r 35.54        12 .. 16
//     their nut traps              hex 5.5 AF, flats facing the axis
//                                                         13.5 .. 16
//     recess                       Ø50.0                  5 .. 16
//     bore                         Ø35.0                  0 .. 5
//     pegs, 4 on 90 deg, Ø43       Ø3.5, Ø2.0 through     0 .. 14
//     screw holes, 135 / -45 deg,  Ø3.0                   0 .. 5
//       Ø43
//
// The z 4.667 and 9.333 planes a histogram reports are tessellation rows on
// the peg bores, not faces.
//
// In the revised config the M3 x 12 screws of the seat stand
// seat_screw_tip() - FLOOR = 1.0 proud of the back face, inside the Ø50
// circle, where only the drive turns.
//
// FITS (../print_fit.scad), revised only:
//
//     all-thread holes, on the M3 rod      slip
//     their nut traps, on the M3 nut       slip
//     recess, on the spline's flange       press, the seat's pilot press
//                                          and its nut pockets slip:
//                                          c201_spline_seat.scad
//
// The strake slots already clear a 12.6 x 3.2 strake by 0.2 on each face, and
// the Ø65 body stands 1.35 inside the slots' inner faces; both keep their
// size.

include <../print_fit.scad>
use <../600-StrainWave/c201_spline_seat.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 144;
epsilon = 0.01;

REF_AXIS      = [-3.125, 5.413];   // the reference mesh's axis
FLOOR         = 5.000;
FLANGE        = [12.000, 16.000];  // bottom, top
DODECAGON     = [32.060, 10.075, -0.170];  // corner centres' radius, corner radius, turn
BODY_D        = 65.000;
SLOT          = [33.850, 37.452, 6.500];   // inner and outer radius, half-width
THREAD_R      = 35.540;
THREAD_D      = 3.000;
TRAP          = [5.500, 13.500];   // across flats, floor
RECESS_D      = 50.000;
BORE_D        = 35.000;
PEG_CIRCLE_R  = 21.500;
PEG           = [3.500, 2.000, 14.000];    // OD, bore, top
SCREW_D       = 3.000;

// --- 2D outlines -----------------------------------------------------------
module flange_2d()
    difference() {
        rotate(DODECAGON[2]) offset(r = DODECAGON[1]) circle(r = DODECAGON[0], $fn = 12);
        for (a = [0 : 60 : 300]) rotate(a) translate([SLOT[0], -SLOT[2]]) square([SLOT[1] - SLOT[0], 2 * SLOT[2]]);
    }

// --- Part ------------------------------------------------------------------
module body() {
    cylinder(d = BODY_D, h = FLANGE[0] + epsilon);
    translate([0, 0, FLANGE[0]]) linear_extrude(FLANGE[1] - FLANGE[0]) flange_2d();
}

function slip(cfg) = fit_clearances(cfg)[0];
function press(cfg) = fit_clearances(cfg)[1];

module common_cuts(cfg) {
    s = slip(cfg);
    translate([0, 0, -epsilon]) cylinder(d = BORE_D, h = FLOOR + 2 * epsilon);
    translate([0, 0, FLOOR]) cylinder(d = cfg == "previous" ? RECESS_D : seat_recess_d(press(cfg)), h = FLANGE[1] - FLOOR + epsilon);
    for (a = [30 : 60 : 330]) rotate(a) translate([THREAD_R, 0, 0]) {
        translate([0, 0, FLANGE[0] - epsilon]) cylinder(d = fit_bore(THREAD_D, s), h = FLANGE[1] - FLANGE[0] + 2 * epsilon, $fn = 48);
        translate([0, 0, TRAP[1]]) linear_extrude(FLANGE[1] - TRAP[1] + epsilon)
            rotate(30) circle(d = fit_bore(TRAP[0], s) / cos(30), $fn = 6);
    }
}

module pegs() for (a = [0 : 90 : 270]) rotate(a) translate([PEG_CIRCLE_R, 0, FLOOR - epsilon])
    cylinder(d = PEG[0], h = PEG[2] - FLOOR + epsilon, $fn = 48);

module peg_and_screw_cuts() {
    for (a = [0 : 90 : 270]) rotate(a) translate([PEG_CIRCLE_R, 0, -epsilon])
        cylinder(d = PEG[1], h = PEG[2] + 2 * epsilon, $fn = 48);
    for (a = [135, -45]) rotate(a) translate([PEG_CIRCLE_R, 0, -epsilon])
        cylinder(d = SCREW_D, h = FLOOR + 2 * epsilon, $fn = 48);
}

module base_stator_holder(cfg = config) {
    if (cfg == "previous")
        translate(REF_AXIS)
            difference() { union() { difference() { body(); common_cuts(cfg); } pegs(); } peg_and_screw_cuts(); }
    else
        difference() { body(); common_cuts(cfg); translate([0, 0, FLOOR]) spline_seat_cuts(FLOOR, press(cfg), slip(cfg)); }
}

base_stator_holder();
echo(seat_floor = FLOOR);
