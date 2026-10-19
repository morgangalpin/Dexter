// #421-002 Internal Inner Pulley — parametric source.
// The inner channel's stage-2 driver: a 40T GT2 pulley on a long tube. Three
// C-503 strakes are epoxied into its slots (008.7 step 6) and carry the drive
// across the elbow from the New Belt Pulley; the tube is the inner race seat
// of the 6703 that supports it there (specs/004 § Wrist and differential), and
// the stainless tube of the outer channel runs through its bore.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/400-EndArm/), in that mesh's
//                         frame.
//   config = "revised"  — the same part with its print fits drawn (FITS). The
//                         count stays 40T, which specs/004 holds fixed.
//
// FRAME. The axis is +Z through the origin, the tube's end at z -42.5 and the
// pocketed face at z 30.0, the frame the End Arm group's J3-axis parts share
// (robot_assembly.scad § End Arm group). The first slot is on +Y. The
// reference mesh is already in this frame.
//
// CONSTRUCTION. In the order the reference was made:
//   1. revolve the measured meridional profile (the mesh-to-scad ladder's
//      rung 3): tube, boss, flanges, the band's core, and the bore with its
//      pocket and cone;
//   2. extrude a 40T tooth ring of ../gt2_pulley.scad over the band (rung 7);
//   3. cut the three strake slots through the whole length (rung 2's
//      primitive cutters, patterned).
//
// Measured from the reference with scadmesh planes/radial/slice/arcs/profile
// and teeth. 421-002_InternalInnerPulley.dwg is not a source: its ACIS solid
// (read with the ODA File Converter, Models/README.md § Formats) is another
// revision, with five strake slots, an Ø12.4 pocket and an Ø17.2 journal. Its
// tooth is the same, and is drawn analytically: tip Ø24.968, groove R0.6096,
// tip round R0.2286, which gt2_pulley.scad's rounded form fits as R0.61 and
// R0.20. The feature IDs are those of 421-002_InternalInnerPulley.view.json,
// which labels each one on the mesh:
//
//     ID  feature                     value
//     J1  tube, the 6703's journal    Ø17.000, z -42.5 .. 16.5
//     J2  boss, the 6703's shoulder   Ø17.980, z 16.5 .. 19.0
//     F1  lower flange                Ø25.974, z 19.0 .. 19.5, chamfered to
//                                     Ø25.0 at z 20.0
//     T1  40T GT2 band                z 20.0 .. 29.0; tip Ø24.968, root Ø23.395,
//                                     a groove on 0 deg (the rounded-tip form,
//                                     as #421-001's)
//     F2  upper flange                Ø25.0 at z 29.0, chamfered to Ø26.0 at
//                                     z 29.5, Ø26.0 to the top face at z 30.0
//     B1  bore                        Ø9.000, through
//     B2  MR128 pocket                Ø12.000, z 25.8 .. 30.0, a 45 deg cone down
//                                     to the bore at z 24.3
//     S1  strake slots, 3 on 90 deg   5.000 tangential x 2.000 radial, r 6.091
//         + 120 deg k                 .. 8.091, through
//
// FITS (../print_fit.scad), revised only:
//
//     J1, in the 6703's 17 mm bore            press
//     B2, on the MR128's Ø12 OD               press
//     S1, on the C-503 strake (1.45 x 4.50)   press; the reference's slot
//                                             already stands 0.25 off it a
//                                             side, so it keeps its size
//     B1, round the Ø8 stainless tube         the reference's bore stands 0.5
//                                             off it a side, which is the
//                                             running clearance; it keeps its
//                                             size
//
// J2's face is the 6703's shoulder, a face contact.

include <../gt2_pulley.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 180;
epsilon = 0.01;

TEETH      = 40;                  // T1
TIP_D      = 24.968;              // T1, measured
BAND       = [20.000, 29.000];    // T1: z span
ROOT_CLEAR = 0.1;                 // the revolved core stops this far inside the grooves
BOTTOM     = -42.500;             // J1's end face
JOURNAL    = [17.000, 16.500];    // J1: diameter, top z
BOSS       = [17.980, 19.000];    // J2: diameter, top z
FLANGE_LO  = [25.974, 19.500, 25.000];   // F1: diameter, z where the chamfer starts, Ø at BAND[0]
FLANGE_UP  = [25.000, 26.000, 29.500];   // F2: Ø at BAND[1], Ø above the chamfer, z where it ends
TOP        = 30.000;              // F2's top face
BORE_D     = 9.000;               // B1
POCKET     = [12.000, 25.800, 24.300];   // B2: diameter, floor z, cone's foot z on the bore
SLOT       = [7.091, 5.000, 2.000];      // S1: centre r, tangential width, radial depth
SLOT_AT    = [90, 120];                  // S1: first angle, pitch
BEARING_ID = 17.000;              // 6703
MR128_OD   = 12.000;

FITS = fit_clearances(config);
function journal_d() = min(JOURNAL[0], fit_pin(BEARING_ID, FITS[1]));
function pocket_d()  = max(POCKET[0], fit_bore(MR128_OD, FITS[1]));

// The meridional outline [r, z], bore included; the band at the grooves'
// bottom less ROOT_CLEAR, under the tooth ring.
function body_profile() =
    let (rb = gt2_root_d(TIP_D) / 2 - ROOT_CLEAR,
         rp = pocket_d() / 2,
         rr = BORE_D / 2)
    [[rr, BOTTOM], [journal_d() / 2, BOTTOM], [journal_d() / 2, JOURNAL[1]],
     [BOSS[0] / 2, JOURNAL[1]], [BOSS[0] / 2, BOSS[1]], [FLANGE_LO[0] / 2, BOSS[1]],
     [FLANGE_LO[0] / 2, FLANGE_LO[1]], [FLANGE_LO[2] / 2, BAND[0]], [rb, BAND[0]],
     [rb, BAND[1]], [FLANGE_UP[0] / 2, BAND[1]], [FLANGE_UP[1] / 2, FLANGE_UP[2]],
     [FLANGE_UP[1] / 2, TOP], [rp, TOP], [rp, POCKET[1]],
     [rr, POCKET[1] - (rp - rr)]];

module tooth_ring() {
    translate([0, 0, BAND[0] - epsilon]) linear_extrude(BAND[1] - BAND[0] + 2 * epsilon)
        difference() {
            gt2_teeth_rounded_2d(TEETH, TIP_D);
            circle(r = gt2_root_d(TIP_D) / 2 - 3 * ROOT_CLEAR);
        }
}

// One slot, on +X, run out past both end faces.
module slot_cutter() {
    translate([SLOT[0], 0, (BOTTOM + TOP) / 2])
        cube([SLOT[2], SLOT[1], TOP - BOTTOM + 2], center = true);
}

module internal_inner_pulley() {
    difference() {
        union() {
            rotate_extrude() polygon(body_profile());
            tooth_ring();
        }
        for (k = [0 : 2]) rotate(SLOT_AT[0] + k * SLOT_AT[1]) slot_cutter();
    }
}

internal_inner_pulley();
