// 700-Differential shared parameters — the single source of truth for the
// parametric differential model set (DC-2, specs/009-Design-Completion.md).
//
// Every part file includes this file. Two parameter sets are selectable:
//   config = "previous" — faithful recreation of the previous version's
//                         differential; renders match the reference STLs.
//   config = "revised"  — the DC-2 authored configuration meeting the
//                         interface in specs/004 § Differential interface: it
//                         fits the HDI-940 cover envelope and drills the Split
//                         Gear's brad holes on one axis. It does NOT reach the
//                         firmware's L4 = 59.50 mm, and no configuration here
//                         does; that is DC-6's open question, not a parameter.
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

CF_ROD_D    = 8;            // #720-006 CF rod OD
CF_ROD_ID   = 6;            // #720-006 CF rod bore; the tool conductors' path
CF_ROD_LEN  = 96;           // reference: cut length, set by 008.6 not by geometry
STRAKE_25   = [25, 5.6, 2.5];   // #710-005, 3x, Split Gear Bottom
// #720-005 (5x 60 x 4.4 x 1.5) is listed in 007.6 but no assembly step
// places it and no part here carries a matching slot - open under
// DC-11(e). Not modeled until that is adjudicated.
STRAKE_60   = [60, 4.4, 1.5];
BRAD_D      = 1.8;          // #680-001 1" #19 finishing nail (locking dowel)

// Where the Split Gear's brad holes are drilled, on the halves' shared z. The
// two halves are locked to each other by driving brads through four radial
// holes (008.6 steps 7-9), which only works if both are drilled on ONE line —
// so the axis belongs to neither part and is stated here.
//
// The references disagree about that line by 0.500 mm, on a Ø1.5 hole. On
// 710-002 a meridional section cuts the hole at 0 degrees and reads a notch
// spanning z 12.002..13.498, an axis at 12.750; on 710-001 the chords through
// the cage band fit a Ø1.497 hole on an axis at 12.250. Nothing in the
// assembly can absorb it: the halves meet face to face on 710-001's Ø23 seat
// floor and again on the gear's parting cone, so their relative position is
// fixed twice over. As referenced there is no straight line through both.
//
// "revised" drills both at 12.750. "previous" keeps each part's own reference
// value, because the DC-2 comparison measures the reference and would report a
// deliberate move as a miss. 12.750 is the height kept because it is the one
// both parts have material for: it leaves a full millimetre of 710-002's Ø27
// wall below the hole (that wall starts at z 11.000, so 12.250 would leave
// 0.500 mm), while 710-001's cage tube spans z 9.990..16.010 and takes either.
// It is also the blind, glued half — the half whose hole actually holds the
// brad — so it is the half whose position should not be the one that moves.
BRAD_Z      = 12.750;
BRAD_Z_TOP  = config == "previous" ? 12.250 : BRAD_Z;

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
// Diff Body B's two axes, in Body B's own frame. The J4 tunnel runs along X at
// (y, z) = (-21, 21) and the column along Z at (x, y) = (21, -21); they cross
// at the differential centre. 730-002 builds every revolve about them and
// diff_assembly.scad places the part by putting that crossing on the J4/J5
// intersection, so the pair is stated once here rather than in either file --
// `use` imports no variables, so the assembly cannot read them from 730-002.
// ---------------------------------------------------------------------------
BODY_B_J4_YZ  = [-21.0, 21.0];
BODY_B_COL_XY = [ 21.0, -21.0];

// ---------------------------------------------------------------------------
// 004 § Differential interface (revised config targets)
// ---------------------------------------------------------------------------
COVER_ENVELOPE = [78.0, 73.5, 50.5];   // HDI-940-001 cover interior envelope

// L4, the J4 -> J5 offset, has three geometric readings and one firmware
// value, and they do not agree. The three geometric ones do: see DC-6, and
// diff_assembly.scad, which computes what this design actually builds and
// checks it against them. L4_TARGET is recorded as the firmware's number, NOT
// as a dimension anything here is driven to.
L4_TARGET      = 59.50;   // Firmware/Defaults.make_ins
L4_GLTF        = 39.50;   // dde/HDIMeterModel.gltf, J4 -> J5 frame separation
L4_DH_D        = 39.30;   // HDI-007010's measured DH set, J4 row's d term

// ---------------------------------------------------------------------------
// Diff Body A axis length — the parameter chain that carries L4 and the
// envelope. "previous" reproduces the reference part; "revised" trims to fit
// COVER_ENVELOPE. Derived L4 is computed in diff_assembly.scad.
//
// 81.0 is the design dimension: the Ø60 top plate's R30 plus the arm's flat
// tip face at x = -51.000, both measured directly. The reference STL's
// bounding box reads 80.984 because a tessellated circle's extreme vertex
// falls short of its true radius — that 0.016 mm is faceting, not geometry,
// and driving the model from it would place the arm's flat face wrongly.
// ---------------------------------------------------------------------------
BODY_A_LEN = config == "previous" ? 81.0 : 77.8;

// Revised-config conformance is asserted where the assembly computes
// L4 (diff_assembly.scad), not here, so single parts stay renderable.

echo(str("diff_params config=", config, "  bevel module=", BEVEL_MOD));
