// 700-Differential shared parameters — the single source of truth for the
// parametric differential model set (DC-2, specs/009-Design-Completion.md).
//
// Every part file includes this file. Two parameter sets are selectable:
//   config = "previous" — faithful recreation of the previous version's
//                         differential; renders match the reference STLs.
//   config = "revised"  — the DC-2 authored configuration meeting the
//                         interface in specs/004 § Differential interface
//                         (fits the HDI-940 cover envelope, L4 = 59.50 mm).
//
// Dimensions are stated once here; part files and specs reference them.

include <BOSL2/std.scad>

/* [Configuration] */
// Parameter set: previous (matches reference STLs) or revised (004 interface)
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 128;
epsilon = 0.01;

// ---------------------------------------------------------------------------
// Off-the-shelf interfaces (007.1 parts catalog: [ID, OD, width] in mm).
// Parts reference these rather than restating a diameter, so re-specifying a
// bearing propagates to every seat that takes it. A few entries are recorded
// for reference and consumed by no geometry; each says so.
// ---------------------------------------------------------------------------
BRG_6705  = [25, 32, 4];    // #620-004, Diff Body A
BRG_6703  = [17, 23, 4];    // #620-003, 5 in the differential
BRG_MR128 = [8, 12, 3.5];   // #620-002, Diff Gear Shaft ends
BRG_MR85  = [5, 8, 2.5];    // #620-001, Diff Gear Axle back
THRUST_AXK0819 = [8, 19, 2];   // #710-006 needle thrust; 2x AS0819 races 8x19x1

CF_ROD_D    = 8;            // #720-006 CF rod OD (8 OD x 6 ID)
CF_ROD_LEN  = 96;           // reference: cut length, set by 008.6 not by geometry
STRAKE_25   = [25, 5.6, 2.5];   // #710-005, 3x, Split Gear Bottom
// #720-005 (5x 60 x 4.4 x 1.5) is listed in 007.6 but no assembly step
// places it and no part here carries a matching slot - open under
// DC-11(e). Not modeled until that is adjudicated.
STRAKE_60   = [60, 4.4, 1.5];
BRAD_D      = 1.8;          // #680-001 1" #19 finishing nail (locking dowel)

// ---------------------------------------------------------------------------
// Gear teeth (measured from the reference STLs — see 004 amendment)
// All three bevels are 20T and mesh 1:1:1 at 90 deg; both GT2 pulleys are 40T.
// ---------------------------------------------------------------------------
BEVEL_TEETH   = 20;
BEVEL_OD      = 44.055;     // outside diameter of the side bevels (the
                            // DC-11(f) check datum on Split Gear Top)
// Module for straight bevel, 90 deg shafts, 20:20 -> 45 deg pitch cones:
// OD = m * (teeth + 2*cos(45)) => m = OD / 21.414
BEVEL_MOD     = BEVEL_OD / (BEVEL_TEETH + 2*cos(45));
PULLEY_TEETH  = 40;         // Diff End Pulley + Diff Gear Shaft section
GT2_PITCH     = 2.0;        // GT2 belt pitch
GT2_PLD       = 0.254;      // GT2 pitch line distance (belt standard)
GT2_TIP_D     = 24.97;      // 40T tooth tip diameter (measured)
GT2_GROOVE_R  = 0.8;        // groove cutter radius (root at Ø23.40)
GT2_GROOVE_C  = 12.5;       // groove cutter center radius

// Cross-check the measured tip diameter against the GT2 standard: for an
// n-tooth pulley, pitch Ø = n*p/PI and tip Ø = pitch Ø - 2*PLD. Agreement
// is what confirms these are 40T GT2 pulleys rather than some other belt.
GT2_STD_TIP_D = PULLEY_TEETH * GT2_PITCH / PI - 2 * GT2_PLD;
assert(abs(GT2_TIP_D - GT2_STD_TIP_D) < 0.05,
       "measured pulley tip diameter disagrees with the 40T GT2 standard");

// 2D cross-section of the 40T GT2 pulley tooth ring, shared by the Diff
// End Pulley and the Diff Gear Shaft's integrated pulley section.
module gt2_pulley_teeth_2d() {
    difference() {
        circle(d=GT2_TIP_D);
        for (i = [0 : PULLEY_TEETH - 1])
            zrot(i * 360 / PULLEY_TEETH)
                right(GT2_GROOVE_C) circle(r=GT2_GROOVE_R);
    }
}

// ---------------------------------------------------------------------------
// 004 § Differential interface (revised config targets)
// ---------------------------------------------------------------------------
COVER_ENVELOPE = [78.0, 73.5, 50.5];   // HDI-940-001 cover interior envelope
L4_TARGET      = 59.50;                // firmware L4, J4 -> J5 axis (DC-6)

// ---------------------------------------------------------------------------
// Diff Body A axis length — the parameter chain that carries L4 and the
// envelope. "previous" matches the reference STL (80.98 mm longest
// dimension, exceeds the cover); "revised" trims to fit COVER_ENVELOPE.
// Derived L4 is computed in diff_assembly.scad from the body geometry.
// ---------------------------------------------------------------------------
BODY_A_LEN = config == "previous" ? 80.984 : 77.8;

// Revised-config conformance is asserted where the assembly computes
// L4 (diff_assembly.scad), not here, so single parts stay renderable.

echo(str("diff_params config=", config, "  bevel module=", BEVEL_MOD));
