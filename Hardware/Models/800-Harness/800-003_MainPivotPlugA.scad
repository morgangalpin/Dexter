// #800-003 Main Pivot Plug (A) — parametric source.
// Half of the turned plug that closes round the J1 cable bundle and pushes
// into the Main Pivot's H1 J1 bore (Ø14.000, 300-001_MainPivot.scad BORE_D).
// The two halves split on the plane y = 0: A is the half y <= 0 and B (#800-004)
// the half y >= 0, with the wire channel.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — the print fit below drawn on the spigot.
//
// FRAME. The reference's own: the axis on +Z through the origin, the flange's
// underside at z = 0, the top face at z = 15, the spigot below.
//
// ONE PART, TWO HALVES. This file owns the geometry of both; #800-004 includes
// it and sets HALF. Measured from the references with scadmesh, the IDs those
// of 800-003_MainPivotPlugA.view.json:
//
//     ID  feature                  value                              z span
//     B1  bundle bore              Ø10.0                              -10 .. 15
//     S1  spigot                   Ø14.0 (the J1 bore)                -10 .. 0
//     F1  flange                   R13.5                                0 .. 7
//     K1  cone                     45 deg, R13.5 at z 7 to R5.5 at 15   7 .. 15
//     T1  top face                 R5.0 .. R5.5                        15
//     P1  pocket, both halves      x < -4 from the bore out; a prism along x,
//                                  flat roof z 4.0 for |y| <= 1.0, 45 deg
//                                  sides to |y| = 5.0 at the underside;
//                                  between the bore and R7 (the spigot's
//                                  radius) only |y| <= 3.0 of it is cut  0 .. 4.0
//     C1  channel, B only          along +y from the bore at x = 0, 4.0 wide,
//                                  straight walls to z 1.0, then an R2.0 round;
//                                  open at the underside, clipped to z >= 0
//                                                                       0 .. 3.0
//
// CONSTRUCTION. One rotate_extrude of the profile, cut to its half-space, less
// the pocket and (B) the channel. Cutters are clipped clear of the spigot.
//
// FITS (../print_fit.scad), revised only, per side:
//
//     spigot, in the printed Ø14 bore     slip: outer Ø14 -> fit_pin(14, slip)

include <BOSL2/std.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
// Which half this file draws; #800-004 includes it and names its own.
HALF = "A";
$fn = 144;
BIG = 40;               // cutter reach past any face
SPIGOT_D = 14.000;      // S1
BORE_R = 5.0;           // B1
FLANGE_R = 13.5;        // F1
TOP_R = 5.5;            // T1
Z_BOT = -10;
Z_FLANGE = 7;
Z_TOP = 15;
POCKET_X = -4;          // P1: x of the bore side
POCKET_ROOF = [1.0, 4.0]; // P1: roof half width y, roof z (sides at 45 deg)
POCKET_NECK = 3.0;      // P1: half width inside the spigot's radius (R7)
CHANNEL_W = 4.0;        // C1
CHANNEL_STRAIGHT = 1.0;

function spigot_r(cfg) = fit_pin(SPIGOT_D, fit_clearances(cfg)[0]) / 2;

module plug_profile(cfg) {
    polygon([
        [BORE_R, Z_BOT], [spigot_r(cfg), Z_BOT], [spigot_r(cfg), 0],
        [FLANGE_R, 0], [FLANGE_R, Z_FLANGE], [TOP_R, Z_TOP], [BORE_R, Z_TOP]]);
}

// The half-space of this half: y <= 0 for A, y >= 0 for B.
module half_space() {
    s = HALF == "A" ? -1 : 1;
    translate([-BIG, s > 0 ? 0 : -BIG, Z_BOT - 1])
        cube([2 * BIG, BIG, Z_TOP - Z_BOT + 2]);
}

// P1's section (y, z) for y >= 0, carried 1 mm below the underside on its 45 deg side.
module pocket_half() {
    w = POCKET_ROOF[0]; h = POCKET_ROOF[1];
    polygon([[0, -1], [w + h + 1, -1], [w, h], [0, h]]);
}

// P1's prism along x, from inside the bore out past the flange.
module pocket_prism() {
    translate([-BIG, 0, 0]) rotate([90, 0, 90])
        linear_extrude(BIG + POCKET_X) mirror_copy([1, 0, 0]) pocket_half();
}

// Where P1 cuts: outside the spigot's radius at full width, and inside it
// only within POCKET_NECK of the split and above the underside, so the spigot
// is never cut.
module pocket_reach() {
    difference() {
        translate([-BIG, -BIG, -2]) cube([2 * BIG, 2 * BIG, BIG]);
        translate([0, 0, -3]) cylinder(r = SPIGOT_D / 2, h = BIG);
    }
    translate([-BIG, -POCKET_NECK, 0]) cube([BIG, 2 * POCKET_NECK, BIG]);
}

module pocket() intersection() { pocket_prism(); pocket_reach(); }

// C1: a stadium-ended slot along +y, clipped to z >= 0.
module channel() {
    r = CHANNEL_W / 2;
    intersection() {
        rotate([-90, 0, 0]) linear_extrude(BIG) union() {
            translate([-r, -CHANNEL_STRAIGHT]) square([CHANNEL_W, CHANNEL_STRAIGHT]);
            translate([0, -CHANNEL_STRAIGHT]) circle(r = r);
        }
        translate([-BIG, -1, 0]) cube([2 * BIG, BIG, BIG]);
    }
}

module main_pivot_plug(cfg) {
    difference() {
        intersection() {
            rotate_extrude() plug_profile(cfg);
            half_space();
        }
        pocket();
        if (HALF == "B") channel();
    }
}

main_pivot_plug(config);
