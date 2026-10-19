// #421-001 Internal Outer Pulley — parametric source.
// The outer channel's stage-2 driver: a 40T GT2 pulley locked on the 113 mm
// stainless tube (C-507, Ø8) by three M3 set screws, each running in an M3 nut
// epoxied into a slot (008.7 steps 9, 16, 17). Its belt runs along L3 to the
// differential's 80T input (specs/004 § Wrist and differential).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/400-EndArm/), in that mesh's
//                         frame.
//   config = "revised"  — the same part with its print fits drawn (FITS). The
//                         count stays 40T, which specs/004 holds fixed.
//
// FRAME. The axis is +Z through the origin, the hub's end at z 17.5 and the
// slotted face at z 33.0, the frame the End Arm group's J3-axis parts share
// (robot_assembly.scad § End Arm group). The first slot is on +Y. The
// reference mesh is already in this frame.
//
// CONSTRUCTION. In the order the reference was made:
//   1. revolve the measured meridional profile (the mesh-to-scad ladder's
//      rung 3): hub, flange, the band's core and the slotted hub, bore included;
//   2. extrude a 40T tooth ring of ../gt2_pulley.scad over the band (rung 7,
//      the ring's grooves being one groove patterned);
//   3. cut the three nut slots and their set-screw holes (rung 2's primitive
//      cutters, patterned). A slot is drawn in the plane square to its radius:
//      5.6 wide, open at the top face, its floor a hex nut's corner pointing
//      down, and its mouth chamfered on all four sides.
//
// Measured from the reference with scadmesh planes/radial/slice/arcs/profile
// and teeth; each slot from sections in its own tangential and radial planes.
// The feature IDs are those of 421-001_InternalOuterPulley.view.json, which
// labels each one on the mesh:
//
//     ID  feature                     value
//     B1  bore                        Ø8.000, through
//     H1  hub                         Ø10.000, z 17.5 .. 18.5, R0.5 at its end
//     H2  hub's shoulder              z 18.5 out to r 9.134, rounding R1 up to
//                                     the flange at r 10.0, z 19.0
//     F1  flange                      Ø26.000, z 19.0 .. 19.75
//     T1  40T GT2 band                z 19.75 .. 27.25; tip Ø24.968, root
//                                     Ø23.395, a groove on 0 deg. The tooth is
//                                     gt2_pulley.scad's rounded-tip form (the
//                                     26T Belt Director's), not the plain form
//                                     of the differential's 40T pulleys: its
//                                     section fits to 0.025 against 0.136
//     U1  slotted hub                 Ø26.000, z 27.25 .. 33.0
//     N1  nut slots, 3 on 90 deg      5.6 tangential x 2.5 radial about r 6.075,
//         + 120 deg k                 from z 33 down to 27.967; floor a hex
//                                     corner down to z 26.350 (across flats 5.6,
//                                     centre z 29.583); mouth chamfer 0.4 x 45 deg
//     S1  set-screw holes             Ø3.1 at z 29.5 on each slot's radius, from
//                                     the bore out through the face
//
// FITS (../print_fit.scad), revised only:
//
//     B1, on the Ø8 stainless tube                       press
//     N1, on the M3 nut (5.5 across flats, 2.4 thick)    slip; the slot's centre
//                                                        and floor stay put
//     S1, on the M3 set screw                            slip
//
// 008.7 step 20 presses an MR128 "into the Internal Outer Pulley end", but no
// face of this mesh is a Ø12 seat; see the End Arm notes' reviewer questions.

include <../gt2_pulley.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 180;
epsilon = 0.01;

TEETH     = 40;          // T1
TIP_D     = 24.968;      // T1, measured
BAND      = [19.750, 27.250];   // T1: z span
ROOT_CLEAR = 0.1;        // the revolved core stops this far inside the grooves
BORE_D    = 8.000;       // B1
TUBE_D    = 8.000;       // C-507
HUB       = [5.000, 18.500, 0.500];    // H1: radius, top z, end round
BOTTOM    = 17.500;      // H1's end face
SHOULDER  = [9.134, 1.000];            // H2: start radius, round radius
FLANGE    = [13.000, 19.000];          // F1: radius, bottom z
TOP       = 33.000;      // U1's top face
SLOT      = [6.075, 5.600, 2.500, 27.967, 29.583, 0.400];
                         // N1: centre r, width, depth (radial), floor's sides' z,
                         //     hex centre z, mouth chamfer
SLOT_AT   = [90, 120];   // N1: first angle, pitch
SCREW     = [3.100, 29.500];   // S1: diameter, z
NUT       = [5.500, 2.400];    // M3 nut: across flats, thickness
M3_D      = 3.000;

FITS = fit_clearances(config);
function bore_d()  = max(BORE_D, fit_bore(TUBE_D, FITS[1]));
function slot_w()  = max(SLOT[1], fit_bore(NUT[0], FITS[0]));
function slot_t()  = max(SLOT[2], fit_bore(NUT[1], FITS[0]));
function screw_d() = max(SCREW[0], fit_bore(M3_D, FITS[0]));

function arc(c, r, a0, a1, n = 8) = [for (i = [0 : n]) c + r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];

// The meridional outline [r, z], bore included; the band at the grooves'
// bottom less ROOT_CLEAR, under the tooth ring.
function body_profile() =
    let (rb = gt2_root_d(TIP_D) / 2 - ROOT_CLEAR)
    concat([[bore_d() / 2, BOTTOM]],
           arc([HUB[0] - HUB[2], BOTTOM + HUB[2]], HUB[2], -90, 0),
           [[HUB[0], HUB[1]]],
           arc([SHOULDER[0], HUB[1] + SHOULDER[1]], SHOULDER[1], -90, -30),
           [[FLANGE[0], FLANGE[1]], [FLANGE[0], BAND[0]], [rb, BAND[0]], [rb, BAND[1]],
            [FLANGE[0], BAND[1]], [FLANGE[0], TOP], [bore_d() / 2, TOP]]);

module tooth_ring() {
    translate([0, 0, BAND[0] - epsilon]) linear_extrude(BAND[1] - BAND[0] + 2 * epsilon)
        difference() {
            gt2_teeth_rounded_2d(TEETH, TIP_D);
            circle(r = gt2_root_d(TIP_D) / 2 - 3 * ROOT_CLEAR);
        }
}

// One slot's outline in its tangential plane [x, z]: straight sides from
// above the top face down to the floor, whose two faces meet at the hex's
// corner. A wider slot keeps its hex centre, so its floor deepens.
function slot_outline(w) =
    let (rh = w / 2 / cos(30))
    [[-w / 2, TOP + 1], [w / 2, TOP + 1], [w / 2, SLOT[4] - rh / 2], [0, SLOT[4] - rh],
     [-w / 2, SLOT[4] - rh / 2]];

// One slot, on +X: the outline extruded across the slot's depth, and the
// mouth's chamfer as the hull of the slot's section at the chamfer's foot and
// its section grown by twice the chamfer above the top face.
module slot_cutter() {
    w = slot_w();
    t = slot_t();
    c = SLOT[5];
    translate([SLOT[0], 0, 0]) {
        rotate([90, 0, 90]) linear_extrude(t, center = true) polygon(slot_outline(w));
        hull() {
            translate([0, 0, TOP - c]) cube([t, w, epsilon], center = true);
            translate([0, 0, TOP + c]) cube([t + 4 * c, w + 4 * c, epsilon], center = true);
        }
    }
}

// One set-screw hole, on +X, from inside the bore out past the face.
module screw_cutter() {
    translate([0, 0, SCREW[1]]) rotate([0, 90, 0]) cylinder(d = screw_d(), h = FLANGE[0] + 2, $fn = 48);
}

module internal_outer_pulley() {
    difference() {
        union() {
            rotate_extrude() polygon(body_profile());
            tooth_ring();
        }
        for (k = [0 : 2]) rotate(SLOT_AT[0] + k * SLOT_AT[1]) {
            slot_cutter();
            screw_cutter();
        }
    }
}

internal_outer_pulley();
