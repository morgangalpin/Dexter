// #630-005 Flex Spline Attach — parametric source.
// Joins the strain-wave drive's flex spline to the motor face, one per drive
// (J1, J2, J3). The part stands on the motor face, grips the motor body with
// eight lugs, and carries the flex spline hub on its top face. The four
// corner arcs of its Ø50 outline are the journal a 6810 inner race rides in
// all three joints (008.4, 008.5, 008.8).
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/600-StrainWave/).
//   config = "revised"  — the flare below the land removed, so the land runs
//                         to the motor face; the hub interface cut for
//                         C-201's flexspline; and the hub face lowered by
//                         hub_drop. What sets hub_drop, and why the flare
//                         goes, is recorded in
//                         ../500-ExternalGear/exgear_assembly.scad.
//
// FRAME. The reference's own: the axis on +Z, the motor face at z = -1.000
// (the underside the motor bears on), the hub face at z = 9.000. The lugs hang
// below the motor face to z = -6.000.
//
// Measured from the reference (scadmesh slice/arcs/profile/solid). Every
// feature is fourfold about the axis, and mirror-symmetric about the axes and
// the diagonals:
//
//     feature                      value                  z span
//     land (corner arcs)           R25.000                0 .. 9
//     notches, 4 at 0/90/180/270   13.0 wide, floor r 21.0, R0.65 floor
//                                  fillets; R0.8 mouth rounds centred
//                                  0.65 off the sides     -6 .. 9
//     flare below the land         R0.72 quarter round at (25.0, -0.72),
//                                  then straight down; at the mouths its
//                                  side rounds off R0.3 from z -0.4   -1 .. 0
//     lugs, 8                      outside the 42.292 motor square, inside
//                                  R26.5, between the notches; the flare's
//                                  45 deg chamfer runs on over them to
//                                  r 26.5 at z -1.5; R0.5 notch-side and
//                                  bottom-inner edges; tips R0.2..0.3
//                                  above z -2, sharp below    -6 .. -0.72
//     their root fillets           R0.5, round the notch-side corner,
//                                  ending at r 25.62      -1.5 .. -1
//     pilot recess                 Ø23.0                  -1 .. 2
//     centre bore                  Ø5.5, with a Ø5.0 ridge z 4.0 .. 4.5
//                                  and 45 deg leads       2 .. 6.5
//     hub screw holes, 6 on Ø12    Ø2.0, from 0 deg       3.75 .. 9
//     their head pockets           Ø4.0                   2 .. 3.75
//     hub recess                   Ø19.0, 2.5 deep        6.5 .. 9
//     nubs in it, one per hole     Ø3.3 OD                6.5 .. 9
//     motor holes, 31.0 square     Ø3.5                   -1 .. 7
//     their counterbores           Ø10.3, floor at 7.0    7 .. 9
//
// The reference's hub interface (the Ø19 recess and its Ø3.3 nubs on Ø12) is
// not C-201's. The revised hub interface is cut for the flexspline hub of
// c201_spline_seat.scad, which stands on a flat hub face:
//
//     spigot, into the Ø11H7 bore  Ø11, 0.3 lead          top .. top + 2.2
//     nubs, one per Ø4.5 hole      Ø4.5, on Ø17           top .. top + 2.2
//     hub screw holes, in the nubs Ø2.0 (M2), from 0 deg  3.75 .. top + 2.2
//     their head pockets           Ø3.8 (the M2 head)     2 .. 3.75
//
// The spigot centres the hub, and the nubs carry the drive's torque in
// shear. Both stop 0.2 short of the hub's inner face, where the Flex Spline
// Cap bears.
//
// FITS (../print_fit.scad), revised only. The sizes above are the mates'
// nominals; each fit draws its class clearance per side:
//
//     land, in the 6810's Ø50 bore         press
//     lugs, on the motor's 42.3 body       press: they centre the motor,
//                                          and with it the wave generator,
//                                          on the flexspline's axis
//     spigot and nubs, in the hub          press
//     hub screw holes and head pockets     slip
//
// The motor holes (Ø3.5 for M3), their Ø10.3 counterbores and the Ø23 pilot
// over the motor's Ø22 boss already clear by more and keep their size.
//
// The six M2 screws of 008.3 enter from below through the head pockets,
// pass the hub and end in nuts in the Flex Spline Cap, so they are driven
// before the Attach goes on the motor. hub_drop shortens their path through
// this part by the same amount; the Cap's file asserts the screw's reach at
// the longest path, a drop of zero.
//
// The counterbore floors stay at z = 7.000 in both configs: in J1 and J2 the
// #6 washers under the motor screws sit there and overhang the land onto the
// far 6810's inner race.

include <../print_fit.scad>
use <c201_spline_seat.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// Revised only: how far the hub face and recess drop, mm (J3 only; J1/J2 print at 0)
hub_drop = 0.000;

/* [Hidden] */
$fn = 144;
epsilon = 0.01;

MOTOR_FACE    = -1.000;    // underside; the motor bears on it
HUB_FACE      = 9.000;     // previous hub face
LAND_R        = 25.000;
NOTCH         = [6.500, 21.000];   // half-width, floor radius
NOTCH_FILLET  = 0.650;
MOUTH_ROUND   = [0.800, 0.650];   // radius, its centre off the notch side
FLARE_ROUND   = 0.720;     // quarter round under the land, previous only
MOUTH_LIP     = [0.300, -0.400];   // flare side round at the notch mouth: radius, start z
LUG_R         = 26.500;
LUG_Z         = -6.000;
LUG_FLAT      = 21.146;    // lug inner faces: the motor's half-width
LUG_EDGE      = 0.500;     // vertical and bottom-inner edge rounds, root fillet
ROOT_FILLET_END = 25.620;  // radius at which the root fillets stop
PILOT         = [23.000, 2.000];   // diameter, top
BORE_D        = 5.500;
RIDGE         = [5.000, 4.000, 4.500, 0.250];  // Ø, z from, z to, lead
BORE_TOP      = 6.500;
HUB_PCD       = 12.000;
HUB_HOLE_D    = 2.000;
HEAD_POCKET   = [4.000, 3.750];    // diameter, top
RECESS        = [19.000, 2.500];   // diameter, depth below the hub face
NUB_D         = 3.300;
MOTOR_PITCH   = 31.000;
MOTOR_HOLE_D  = 3.500;
CBORE         = [10.300, 7.000];   // diameter, floor
// Revised hub interface, for c201_spline_seat.scad's flexspline hub.
SPIGOT_LEAD   = 0.300;             // the spigot's lead chamfer
HUB_CLEAR     = 0.200;             // spigot and nub tops under the hub's inner face
M2            = [2.000, 3.800];    // screw and head diameters

function attach_motor_face() = MOTOR_FACE;
function attach_hub_face(cfg = config, drop = hub_drop) = cfg == "previous" ? HUB_FACE : HUB_FACE - drop;
function attach_head_seat() = HEAD_POCKET[1];

function slip(cfg) = fit_clearances(cfg)[0];
function press(cfg) = fit_clearances(cfg)[1];
function land_r(cfg) = LAND_R - press(cfg);
function lug_flat(cfg) = LUG_FLAT + press(cfg);

// --- 2D outlines -----------------------------------------------------------
module convex_round(r) offset(r = r) offset(delta = -r) children();
module concave_fillet(r) offset(r = -r) offset(delta = r) children();

module notch_cutters(half = NOTCH[0], reach = 40)
    for (a = [0 : 90 : 270]) rotate(a)
        translate([NOTCH[1], -half]) square([reach, 2 * half]);

// The land's outline: the R25 disc less the four notches. The mouth rounds
// are tangent to R25 but not to the notch sides, which they meet at an angle:
// rounds of a notch narrower by the difference, then the notch cut to width.
module land_2d(cfg)
    concave_fillet(NOTCH_FILLET) intersection() {
        convex_round(MOUTH_ROUND[0]) difference() {
            circle(r = land_r(cfg));
            notch_cutters(NOTCH[0] - (MOUTH_ROUND[0] - MOUTH_ROUND[1]));
        }
        difference() { circle(r = land_r(cfg) + 1); notch_cutters(); }
    }

// The notched outline the lugs are cut from, square-mouthed.
module flare_2d()
    concave_fillet(NOTCH_FILLET) difference() { circle(r = LUG_R + 1); notch_cutters(); }

// --- Solids ----------------------------------------------------------------
// The previous config's flare under the land: a quarter round out to R25.72,
// then straight down to the motor face, less the notches. At each notch's
// mouth the flare's side stays on the notch side up to z -0.4, then rounds
// off, R0.3, clear of the land's mouth round.
module flare_ring()
    rotate_extrude() polygon([
        [NOTCH[1] - 1, MOTOR_FACE], [LAND_R + FLARE_ROUND, MOTOR_FACE],
        for (a = [0 : 10 : 90]) [LAND_R + FLARE_ROUND * cos(a), -FLARE_ROUND + FLARE_ROUND * sin(a)],
        [NOTCH[1] - 1, 0]]);

module flare_notch_2d() {
    half = [[NOTCH[0], MOTOR_FACE - epsilon], [NOTCH[0], MOUTH_LIP[1]],
            for (a = [10 : 10 : 80]) [NOTCH[0] + MOUTH_LIP[0] * (1 - cos(a)), MOUTH_LIP[1] + MOUTH_LIP[0] * sin(a)],
            [NOTCH[0] + MOUTH_LIP[0], MOUTH_LIP[1] + MOUTH_LIP[0]], [NOTCH[0] + MOUTH_LIP[0], epsilon]];
    polygon(concat(half, [for (i = [len(half) - 1 : -1 : 0]) [-half[i][0], half[i][1]]]));
}

module flare()
    difference() {
        flare_ring();
        for (a = [0 : 90 : 270]) rotate(a) translate([NOTCH[1], 0, 0]) rotate([90, 0, 90])
            linear_extrude(LUG_R) flare_notch_2d();
    }

// Eight lugs: outside the motor square, inside R26.5, between the notches,
// with their corners at the notch rounded. Each is convex, so it is the hull
// of its outline at a few heights: (z, outer radius, tip round). The outer
// radius is R26.5 below z -1.5; above it, in the previous config, the flare's
// 45 deg chamfer carries on up to the quarter round. The tips, where the
// flat meets the outer radius, are sharp below z -2 and round off above.
function lug_layers(cfg) = concat(
    [[LUG_Z, LUG_R, 0], [-2.000, LUG_R, 0], [-1.500, LUG_R, 0.300],
     [MOTOR_FACE, LUG_R - 0.500, 0.200]],
    cfg == "previous" ? [[-FLARE_ROUND - epsilon, LAND_R + FLARE_ROUND, 0.200]] : []);

module one_lug_2d(r, tip, flat)
    intersection() {
        convex_round(max(tip, 0.001)) intersection() {
            circle(r = r);
            convex_round(LUG_EDGE) difference() { flare_2d(); square(2 * flat, center = true); }
        }
        translate([0, flat - 1]) square(LUG_R + 1);
    }

module lugs(cfg)
    for (a = [0 : 90 : 270], m = [0, 1]) rotate(a) mirror([m, 0, 0]) hull()
        for (l = lug_layers(cfg)) translate([0, 0, l[0]]) linear_extrude(epsilon) one_lug_2d(l[1], l[2], lug_flat(cfg));

// Round the lugs' bottom inner edge, and fillet their inner face into the
// underside of the body.
module lug_bottom_rounds(cfg)
    for (a = [0 : 90 : 270]) rotate(a)
        translate([-LUG_R, lug_flat(cfg), LUG_Z]) rotate([90, 0, 90])
            linear_extrude(2 * LUG_R) difference() {
                translate([-epsilon, -epsilon]) square(LUG_EDGE + epsilon);
                translate([LUG_EDGE, LUG_EDGE]) circle(r = LUG_EDGE);
            }

// The fillet's section: u away from the lug's face, v up to the underside.
module root_fillet_section()
    difference() {
        translate([-LUG_EDGE, -LUG_EDGE]) square(LUG_EDGE + epsilon);
        translate([-LUG_EDGE, -LUG_EDGE]) circle(r = LUG_EDGE);
    }

// One lug's root fillet: along its inner face from the notch-side corner
// round to ROOT_FILLET_END, short of the tip,
// and swept round that corner round up to the notch's side.
module one_root_fillet(cfg) {
    corner = [NOTCH[0] + LUG_EDGE, lug_flat(cfg) + LUG_EDGE, MOTOR_FACE];
    intersection() {
        translate([corner[0] - epsilon, lug_flat(cfg), MOTOR_FACE]) rotate([90, 0, 90])
            linear_extrude(LUG_R) root_fillet_section();
        cylinder(r = ROOT_FILLET_END, h = 20, center = true);
    }
    intersection() {
        translate(corner) rotate(180) rotate_extrude(angle = 90)
            translate([LUG_EDGE, 0]) mirror([1, 0]) root_fillet_section();
        translate([NOTCH[0], 0, LUG_Z]) cube([LUG_R, LUG_R, -LUG_Z]);
    }
}

module lug_root_fillets(cfg)
    for (a = [0 : 90 : 270], m = [0, 1]) rotate(a) mirror([m, 0, 0]) one_root_fillet(cfg);

// The revised hub seat's height above the hub face: the spigot's and the nubs'.
function seat_rise() = fs_hub()[1] - HUB_CLEAR;

// The revised spigot and nubs, standing on the hub face at z = 0.
module hub_seat(cfg) {
    spigot_r = fit_pin(fs_bore_d(), press(cfg)) / 2;
    rotate_extrude() polygon([
        [0, -epsilon], [spigot_r, -epsilon], [spigot_r, seat_rise() - SPIGOT_LEAD],
        [spigot_r - SPIGOT_LEAD, seat_rise()], [0, seat_rise()]]);
    fs_hub_holes() translate([0, 0, -epsilon])
        cylinder(d = fit_pin(fs_holes()[0], press(cfg)), h = seat_rise() + epsilon, $fn = 48);
}

module body(cfg, top) {
    translate([0, 0, MOTOR_FACE]) linear_extrude(top - MOTOR_FACE) land_2d(cfg);
    if (cfg == "previous") flare();
    else translate([0, 0, top]) hub_seat(cfg);
    difference() { lugs(cfg); lug_bottom_rounds(cfg); }
    lug_root_fillets(cfg);
}

module hub_holes(cfg) {
    if (cfg == "previous") for (a = [0 : 60 : 300]) rotate(a) translate([HUB_PCD / 2, 0]) children();
    else fs_hub_holes() children();
}

// The centre bore with its ridge, as a revolved void, open to `top`.
module centre_bore(top)
    rotate_extrude() polygon([
        [0, PILOT[1] - epsilon], [BORE_D / 2, PILOT[1] - epsilon],
        [BORE_D / 2, RIDGE[1] - RIDGE[3]], [RIDGE[0] / 2, RIDGE[1]],
        [RIDGE[0] / 2, RIDGE[2]], [BORE_D / 2, RIDGE[2] + RIDGE[3]],
        [BORE_D / 2, top + epsilon], [0, top + epsilon]]);

module cuts(cfg, top) {
    seat_top = cfg == "previous" ? top : top + seat_rise();
    translate([0, 0, MOTOR_FACE - epsilon]) cylinder(d = PILOT[0], h = PILOT[1] - MOTOR_FACE + epsilon);
    centre_bore(cfg == "previous" ? BORE_TOP : seat_top);
    head_d = cfg == "previous" ? HEAD_POCKET[0] : fit_bore(M2[1], slip(cfg));
    hole_d = cfg == "previous" ? HUB_HOLE_D : fit_bore(M2[0], slip(cfg));
    hub_holes(cfg) {
        translate([0, 0, PILOT[1] - epsilon]) cylinder(d = head_d, h = HEAD_POCKET[1] - PILOT[1] + epsilon, $fn = 48);
        translate([0, 0, HEAD_POCKET[1] - epsilon]) cylinder(d = hole_d, h = seat_top, $fn = 48);
    }
    if (cfg == "previous") translate([0, 0, top - RECESS[1]]) linear_extrude(RECESS[1] + 1) difference() {
        circle(d = RECESS[0]);
        hub_holes(cfg) circle(d = NUB_D, $fn = 48);
    }
    for (x = [-1, 1], y = [-1, 1]) translate([x, y, 0] * MOTOR_PITCH / 2) {
        translate([0, 0, MOTOR_FACE - 1]) cylinder(d = MOTOR_HOLE_D, h = CBORE[1] - MOTOR_FACE + 1 + epsilon, $fn = 48);
        translate([0, 0, CBORE[1]]) cylinder(d = CBORE[0], h = top, $fn = 96);
    }
}

module flex_spline_attach(cfg = config, drop = hub_drop) {
    top = attach_hub_face(cfg, drop);
    // The reference's recess left 2.5 over the head pockets; the revised
    // seat keeps that much material under its flat hub face.
    assert(top - RECESS[1] > HEAD_POCKET[1], "the hub face comes too near the head pockets");
    assert(top > CBORE[1], "hub face must stay above the counterbore floors");
    difference() { body(cfg, top); cuts(cfg, top); }
}

flex_spline_attach();
echo(attach_hub_face = attach_hub_face());
