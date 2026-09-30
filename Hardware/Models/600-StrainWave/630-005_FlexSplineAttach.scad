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
//                         to the motor face, and the hub interface lowered by
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
// The six M2 screws of 008.3 step 7 enter from below through the head
// pockets, pass the hub and end in the Flex Spline Cap. hub_drop shortens
// their path through this part by the same amount, and 008.3 already sizes
// them by the thread left showing, so no fastener changes.
//
// The counterbore floors stay at z = 7.000 in both configs: in J1 and J2 the
// #6 washers under the motor screws sit there and overhang the land onto the
// far 6810's inner race.

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

function attach_motor_face() = MOTOR_FACE;
function attach_hub_face(cfg = config, drop = hub_drop) = cfg == "previous" ? HUB_FACE : HUB_FACE - drop;

// --- 2D outlines -----------------------------------------------------------
module convex_round(r) offset(r = r) offset(delta = -r) children();
module concave_fillet(r) offset(r = -r) offset(delta = r) children();

module notch_cutters(half = NOTCH[0], reach = 40)
    for (a = [0 : 90 : 270]) rotate(a)
        translate([NOTCH[1], -half]) square([reach, 2 * half]);

// The land's outline: the R25 disc less the four notches. The mouth rounds
// are tangent to R25 but not to the notch sides, which they meet at an angle:
// rounds of a notch narrower by the difference, then the notch cut to width.
module land_2d()
    concave_fillet(NOTCH_FILLET) intersection() {
        convex_round(MOUTH_ROUND[0]) difference() {
            circle(r = LAND_R);
            notch_cutters(NOTCH[0] - (MOUTH_ROUND[0] - MOUTH_ROUND[1]));
        }
        difference() { circle(r = LAND_R + 1); notch_cutters(); }
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

module one_lug_2d(r, tip)
    intersection() {
        convex_round(max(tip, 0.001)) intersection() {
            circle(r = r);
            convex_round(LUG_EDGE) difference() { flare_2d(); square(2 * LUG_FLAT, center = true); }
        }
        translate([0, LUG_FLAT - 1]) square(LUG_R + 1);
    }

module lugs(cfg)
    for (a = [0 : 90 : 270], m = [0, 1]) rotate(a) mirror([m, 0, 0]) hull()
        for (l = lug_layers(cfg)) translate([0, 0, l[0]]) linear_extrude(epsilon) one_lug_2d(l[1], l[2]);

// Round the lugs' bottom inner edge, and fillet their inner face into the
// underside of the body.
module lug_bottom_rounds()
    for (a = [0 : 90 : 270]) rotate(a)
        translate([-LUG_R, LUG_FLAT, LUG_Z]) rotate([90, 0, 90])
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
module one_root_fillet() {
    corner = [NOTCH[0] + LUG_EDGE, LUG_FLAT + LUG_EDGE, MOTOR_FACE];
    intersection() {
        translate([corner[0] - epsilon, LUG_FLAT, MOTOR_FACE]) rotate([90, 0, 90])
            linear_extrude(LUG_R) root_fillet_section();
        cylinder(r = ROOT_FILLET_END, h = 20, center = true);
    }
    intersection() {
        translate(corner) rotate(180) rotate_extrude(angle = 90)
            translate([LUG_EDGE, 0]) mirror([1, 0]) root_fillet_section();
        translate([NOTCH[0], 0, LUG_Z]) cube([LUG_R, LUG_R, -LUG_Z]);
    }
}

module lug_root_fillets()
    for (a = [0 : 90 : 270], m = [0, 1]) rotate(a) mirror([m, 0, 0]) one_root_fillet();

module body(cfg, top) {
    translate([0, 0, MOTOR_FACE]) linear_extrude(top - MOTOR_FACE) land_2d();
    if (cfg == "previous") flare();
    difference() { lugs(cfg); lug_bottom_rounds(); }
    lug_root_fillets();
}

module hub_holes() for (a = [0 : 60 : 300]) rotate(a) translate([HUB_PCD / 2, 0]) children();

// The centre bore with its ridge, as a revolved void.
module centre_bore()
    rotate_extrude() polygon([
        [0, PILOT[1] - epsilon], [BORE_D / 2, PILOT[1] - epsilon],
        [BORE_D / 2, RIDGE[1] - RIDGE[3]], [RIDGE[0] / 2, RIDGE[1]],
        [RIDGE[0] / 2, RIDGE[2]], [BORE_D / 2, RIDGE[2] + RIDGE[3]],
        [BORE_D / 2, BORE_TOP + epsilon], [0, BORE_TOP + epsilon]]);

module cuts(top) {
    translate([0, 0, MOTOR_FACE - epsilon]) cylinder(d = PILOT[0], h = PILOT[1] - MOTOR_FACE + epsilon);
    centre_bore();
    hub_holes() {
        translate([0, 0, PILOT[1] - epsilon]) cylinder(d = HEAD_POCKET[0], h = HEAD_POCKET[1] - PILOT[1] + epsilon, $fn = 48);
        translate([0, 0, HEAD_POCKET[1] - epsilon]) cylinder(d = HUB_HOLE_D, h = top, $fn = 48);
    }
    translate([0, 0, top - RECESS[1]]) linear_extrude(RECESS[1] + 1) difference() {
        circle(d = RECESS[0]);
        hub_holes() circle(d = NUB_D, $fn = 48);
    }
    for (x = [-1, 1], y = [-1, 1]) translate([x, y, 0] * MOTOR_PITCH / 2) {
        translate([0, 0, MOTOR_FACE - 1]) cylinder(d = MOTOR_HOLE_D, h = CBORE[1] - MOTOR_FACE + 1 + epsilon, $fn = 48);
        translate([0, 0, CBORE[1]]) cylinder(d = CBORE[0], h = top, $fn = 96);
    }
}

module flex_spline_attach(cfg = config, drop = hub_drop) {
    top = attach_hub_face(cfg, drop);
    assert(top - RECESS[1] > HEAD_POCKET[1], "hub recess would break into the head pockets");
    assert(top > CBORE[1], "hub face must stay above the counterbore floors");
    difference() { body(cfg, top); cuts(top); }
}

flex_spline_attach();
echo(attach_hub_face = attach_hub_face());
