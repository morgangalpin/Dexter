// GlueRig_EndArmHubToDiff_B — the L3 glue rig's hub half — parametric source.
// The L3 rig holds the End Arm Hub (#420-001) and the differential (#730-001 Diff Body A) at their
// finished spacing while the #420-003 tube's epoxy cures (specs/007.2 § Tooling — glue rigs). This
// half carries the hub register: four tubes that enter the hub's four Ø5.000 peg holes round its J3 seat,
// and a rim that hugs the hub's Ø50 body. Its plate's end takes A's tab in a notch.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/950-Tooling/GlueRig_EndArmHubToDiff_B.stl), in that
//                         mesh's frame.
//   config = "revised"  — the same part with the slip fit drawn on the tubes and on the rim round the
//                         hub.
//
// THE SPAN. The rig as first exported held its registers 309.500 apart; L3 is 307.500, and the jig is
// what moved (specs/009 DC-11(h)). The reference mesh is that corrected part: the shipped mesh
// (../Reference/superseded/GlueRig_EndArmHubToDiff_B_span309500.stl) cut at x 200, inside the bar's
// constant section, with its outboard piece moved 2.000 inboard. This file draws it directly: every
// feature past the cut is placed from the hub register E, which stands L3_SPAN from A's register
// (l3_rig_joint.scad), so the span is one constant.
//
// FRAME. The rig's common frame, the reference's own: the plate on z 18 .. 23 from the joint at
// x 128.287 out along +X to the hub register's axis on +Z through E = (290.635, 0).
//
// CONSTRUCTION. Three layers, each drawn whole in 2D and extruded once, each lapping SEAM_LAP into the
// plate:
//
//     rim     z 13 .. 18    R1
//     tubes   z 15 .. 18    T1 - T2
//     plate   z 18 .. 23    P1 + H1 - the notch (l3_rig_joint.scad) - W1 - B1 - T2
//
// `layer = "rim"`, `"tubes"` or `"plate"` draws the section from that layer's height in 2D (`"tubes"`
// draws the rim with them), for verification against the mesh's section (render.rs --verify does
// this).
//
// Measured from the reference with scadmesh planes/radial/slice/arcs/solid:
//
//     ID  feature        value
//     H1  head           R29 about E
//     P1  bar            the joint .. E, |y| <= 20.706
//     W1  window         x 145.897 .. 251.397 (E - 39.238), |y| <= 12.5
//     B1  bore           Ø23.000 about E (scadmesh's circle fit reads 22.971 on its 86-gon); plate only
//     R1  rim            R25 .. R29 about E, round the +X side; it ends where H1 meets P1's edges,
//                        and its inner edge runs from there tangent to R25
//     T1  tubes          4 x Ø5.000 on E ± (10.253, ±10.253) (r 14.5 on 45 deg + 90 deg k)
//     T2  tube bores     4 x Ø2.000, through the tubes and the plate
//
// B1 is a hole: the reference's volume closes only with it open.
//
// FITS (../print_fit.scad), revised only:
//
//     T1, in the End Arm Hub's Ø5.000 peg holes (#420-001's P1)             slip
//     R1's inner face, round the End Arm Hub's Ø50 body (#420-001's O1)    slip
//
// T1 is drawn as the New Belt Pulley's pegs are in the same holes (#410-002's P1), and its centres
// stay where they are, so the span is unchanged. The joint's slip is A's tab's. The End Arm Hub's
// dimensions are those of ../400-EndArm/420-001_EndArmHub.scad (O1, P1).

include <../print_fit.scad>
include <l3_rig_joint.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D profile
layer = "part"; // [part, rim, tubes, plate]

/* [Hidden] */
$fn = 180;
SEAM_LAP = 0.005;   // each layer runs this far into the plate, so no two faces coincide

E        = [L3_A_AXIS + L3_SPAN, 0];   // the hub register's axis
HEAD_R   = 29.000;                     // H1
BAR_W    = 20.706;                     // P1's half-width
WINDOW   = [145.897, E.x - 39.238, 12.500];   // W1: x start, x end, half-width
BORE_D   = 23.000;                     // B1
RIM      = [25.000, 13.000, 18.000];   // R1: inner radius, z bottom, z top
TUBE     = [5.000, 2.000, 14.500, 15.000];   // T1, T2: diameters, radius of the centres, z bottom
PLATE_Z  = [18.000, 23.000];

HUB_R    = 25.000;                     // the End Arm Hub's body
PEG_HOLE_D = 5.000;                    // the End Arm Hub's peg holes

SLIP = fit_clearances(config)[0];

function rim_r()  = config == "previous" ? RIM[0] : HUB_R + SLIP;
function tube_d() = config == "previous" ? TUBE[0] : fit_pin(PEG_HOLE_D, SLIP);

// Where H1 meets P1's edges.
RIM_END_X = E.x - sqrt(HEAD_R * HEAD_R - BAR_W * BAR_W);

module tube_places() for (a = [45 : 90 : 315]) translate(E) rotate(a) right(TUBE[2]) children();

module right(x) translate([x, 0]) children();

module rim_2d()
    difference() {
        intersection() {
            translate(E) circle(r = HEAD_R);
            translate([RIM_END_X, -HEAD_R]) square([2 * HEAD_R, 2 * HEAD_R]);
        }
        hull() {
            translate(E) circle(r = rim_r());
            for (s = [-1, 1]) translate([RIM_END_X, s * BAR_W]) square(0.01, center = true);
        }
    }

module tubes_2d() tube_places() difference() { circle(d = tube_d()); circle(d = TUBE[1]); }

module plate_2d()
    difference() {
        union() {
            translate([L3_JOINT_X, -BAR_W]) square([E.x - L3_JOINT_X, 2 * BAR_W]);
            translate(E) circle(r = HEAD_R);
        }
        l3_tab_2d();
        translate([WINDOW[0], -WINDOW[2]]) square([WINDOW[1] - WINDOW[0], 2 * WINDOW[2]]);
        translate(E) circle(d = BORE_D);
        tube_places() circle(d = TUBE[1]);
    }

module slab(z0, z1) translate([0, 0, z0]) linear_extrude(z1 - z0) children();

module rig_l3_b() {
    slab(RIM[1], RIM[2] + SEAM_LAP) rim_2d();
    slab(TUBE[3], RIM[2] + SEAM_LAP) tubes_2d();
    slab(PLATE_Z[0], PLATE_Z[1]) plate_2d();
}

if (layer == "rim") rim_2d();
else if (layer == "tubes") { rim_2d(); tubes_2d(); }
else if (layer == "plate") plate_2d();
else rig_l3_b();
