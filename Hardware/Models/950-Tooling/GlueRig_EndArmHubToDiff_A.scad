// GlueRig_EndArmHubToDiff_A — the L3 glue rig's differential half — parametric source.
// The L3 rig holds the End Arm Hub (#420-001) and the differential (#730-001 Diff Body A) at their
// finished spacing while the #420-003 tube's epoxy cures (specs/007.2 § Tooling — glue rigs). This
// half carries the differential register: a Ø17 boss that takes a 6703 whose outer race seats in Diff
// Body A, and the head round it. Its plate runs out to the joint, where its tab enters B's notch.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/950-Tooling/), in that mesh's frame.
//   config = "revised"  — the same part with its print fits drawn on the boss and the tab's sides.
//
// FRAME. The rig's common frame, the reference's own: the J4 register's axis on +Z through
// D = (-16.865, 0), the plate on z 18 .. 23 running out along +X to the joint at x 128.287.
//
// CONSTRUCTION. Three layers on the bore, each drawn whole in 2D and extruded once, each lapping
// SEAM_LAP into the one above:
//
//     boss    z -3 .. 0     O1 + R1 - B1
//     head    z 0 .. 18     H1 - B1 - S1
//     plate   z 18 .. 23    H1 + P1 + the tab (l3_rig_joint.scad) - B1 - S1 - W1
//
// `layer = "boss"`, `"head"` or `"plate"` draws that profile in 2D, for verification against the
// mesh's section (render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/radial/slice/arcs/solid:
//
//     ID  feature        value
//     B1  bore           Ø8.000 about D, through
//     O1  register boss  Ø17.000 about D, z -3 .. 0 (the 6703's bore is 17)
//     R1  rim            R20 .. R24 about D, the -X side of x = -5.536; past ±60.24 deg its inner
//                        edge runs straight to the flat at |y| = 17.075; z -3 .. 0
//     H1  head           R24 about D, cut flat on x = -5.536; z 0 .. 23
//     S1  arc slots      2 x r 13 .. 17 about D, each from a radial end on ±60.24 deg round the -X
//                        side to the line |y| = 2.363; z 0 .. 23
//     P1  bar            x -5.536 .. the joint, |y| <= 20.706
//     W1  window         x 13.397 .. 120.897, |y| <= 12.5
//
// The faces at z 10 and at x -36.827 and the like in scadmesh planes are tessellation; sections either
// side of them are identical.
//
// FITS (../print_fit.scad), revised only:
//
//     O1, in the 6703's 17 mm bore        press
//     the tab's sides, in B's notch       slip
//
// O1 is drawn as the Internal Inner Pulley's journal is in the same bearing (#421-002's J1), on the
// register's axis, so the span is unchanged.

include <../print_fit.scad>
include <l3_rig_joint.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D profile
layer = "part"; // [part, boss, head, plate]

/* [Hidden] */
$fn = 180;
SEAM_LAP = 0.005;   // each layer runs this far into the next, so no two faces coincide

D        = [L3_A_AXIS, 0];             // the register's axis
BORE_D   = 8.000;                      // B1
BOSS     = [17.000, -3.000, 0.000];    // O1: diameter, z bottom, z top
RIM_R    = [20.000, 24.000];           // R1
RIM_END_Y = 17.075;                    // R1's inner edge where it meets the flat
HEAD_R   = 24.000;                     // H1
FLAT_X   = -5.536;                     // H1's flat, R1's end
HEAD_Z   = [0.000, 18.000];
PLATE_Z  = [18.000, 23.000];
SLOT     = [13.000, 17.000, 60.240, 2.363];   // S1: inner and outer radius, end angle, half-gap
BAR_W    = 20.706;                     // P1's half-width
WINDOW   = [[13.397, -12.500], [120.897, 12.500]];   // W1: corners

BEARING_ID = 17.000;                   // 6703

FITS = fit_clearances(config);
SLIP = FITS[0];

function boss_d() = config == "previous" ? BOSS[0] : fit_pin(BEARING_ID, FITS[1]);

module bore_2d() translate(D) circle(d = BORE_D);

// The -X side of the flat, as a half-plane.
module flat_side_2d() translate([FLAT_X - 100, -100]) square(100 * [1, 2]);

module head_disc_2d() intersection() { translate(D) circle(r = HEAD_R); flat_side_2d(); }

// The two arc slots, about D: each the annulus between its radial end and the gap on -X.
module slots_2d()
    translate(D) for (s = [-1, 1]) scale([1, s])
        intersection() {
            difference() { circle(r = SLOT[1]); circle(r = SLOT[0]); }
            let(a = -SLOT[2], x0 = SLOT[3] / tan(SLOT[2]))
                polygon([[-30, -SLOT[3]], [x0, -SLOT[3]], [x0, -SLOT[3]] + 40 * [cos(a), sin(a)], [-30, -40]]);
        }

module boss_2d()
    difference() {
        union() {
            translate(D) circle(d = boss_d());
            intersection() {
                translate(D) difference() {
                    circle(r = RIM_R[1]);
                    circle(r = RIM_R[0]);
                    let(e = RIM_R[0] * [cos(SLOT[2]), sin(SLOT[2])], f = [FLAT_X - D.x, RIM_END_Y])
                        polygon([[0, 0], e, f, [f.x, -f.y], [e.x, -e.y]]);
                }
                flat_side_2d();
            }
        }
        bore_2d();
    }

module head_2d() difference() { head_disc_2d(); bore_2d(); slots_2d(); }

module plate_2d()
    difference() {
        union() {
            head_disc_2d();
            translate([FLAT_X, -BAR_W]) square([L3_JOINT_X - FLAT_X, 2 * BAR_W]);
            l3_tab_2d(-SLIP);
        }
        bore_2d();
        slots_2d();
        translate(WINDOW[0]) square(WINDOW[1] - WINDOW[0]);
    }

module slab(z0, z1) translate([0, 0, z0]) linear_extrude(z1 - z0) children();

module rig_l3_a() {
    slab(BOSS[1], BOSS[2] + SEAM_LAP) boss_2d();
    slab(HEAD_Z[0], HEAD_Z[1] + SEAM_LAP) head_2d();
    slab(PLATE_Z[0], PLATE_Z[1]) plate_2d();
}

if (layer == "boss") boss_2d();
else if (layer == "head") head_2d();
else if (layer == "plate") plate_2d();
else rig_l3_a();
