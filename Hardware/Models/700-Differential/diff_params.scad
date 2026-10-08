// 700-Differential shared parameters — the single source of truth for the
// parametric differential model set (DC-2, specs/009-Design-Completion.md).
//
// Every part file includes this file. Two parameter sets are selectable:
//   config = "revised"  — the DC-2 authored configuration meeting the
//                         interface in specs/004 § Differential interface: it
//                         fits the HDI-940 cover envelope and drills the Split
//                         Gear's brad holes on one axis.
//   config = "previous" — faithful recreation of the previous version's
//                         differential; renders match the reference STLs.
// No configuration here reaches the firmware file's L4 = 59.50 mm, and none is
// meant to: L4 is specified at 39.50 mm in specs/003 § Link lengths, and no
// part here is driven to either figure.
//
// "revised" is the default, and is the setting to keep: it is the model set
// that is worked on and printed (specs/004 § Wrist and differential), so a
// file opened or rendered without a -D sees the new models. "previous" is
// selected with -D config="previous" when the reference meshes are wanted;
// render.rs --verify names the configuration on every render, so its gates do not
// depend on this default.
//
// Dimensions are stated once here; part files and specs reference them.

include <BOSL2/std.scad>
include <../gt2_pulley.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: revised (004 interface, the default) or previous (matches reference STLs)
config = "revised"; // [revised, previous]

/* [Hidden] */
$fn = 128;
epsilon = 0.01;

// The gap drawn between two surfaces that are designed to meet exactly, in mm.
//
// Where a part touches another over a whole surface — a bearing in a seat bored
// to its own diameter, two halves bolted face to face — drawing both at nominal
// makes those surfaces coincident: the solids touch everywhere and
// interpenetrate nowhere. CGAL cannot union a tangency. What it returns is a
// solid that is not a 2-manifold, and such a solid still exports, so the
// failure need not be immediate or loud: a composition holding one either warns
// that the object may not be a valid 2-manifold, or stops outright at "CGAL
// ERROR: assertion violation!" in applyUnion3D, which names no file. Drawing
// one of the two surfaces this far clear of the other leaves the solids
// separate and the union simple.
//
// This is a drawing allowance, not a design clearance. It says nothing about
// how the parts fit, and no seat, bore or part dimension derives from it. The
// size is chosen from both ends: it is a thousand times OpenSCAD's own 1e-6 mm
// vertex grid, so an importer cannot merge the two surfaces back together, and
// it is two orders below the 0.15 mm the parts are measured to, so nothing the
// harness gates on can see it.
DRAW_JOINT = 0.001;

// The print-fit clearances every part draws, per side (../print_fit.scad):
// zero in "previous", which is the reference meshes, and the classes'
// values in "revised". PRESS is for a bought mate (bearings, the CF rod,
// tube and strakes), SLIP for a printed mate and fastener clearances, and
// RUN for a gap between parts that turn past each other without touching.
// Each part's header says which of its features take which.
SLIP  = fit_clearances(config)[0];
PRESS = fit_clearances(config)[1];
RUN   = fit_clearances(config)[2];

// ---------------------------------------------------------------------------
// Off-the-shelf interfaces (007.1 parts catalog: [ID, OD, width] in mm).
// Parts reference these rather than restating a diameter, so re-specifying a
// bearing propagates to every seat that takes it. A few entries are recorded
// for reference and consumed by no geometry; each says so.
// ---------------------------------------------------------------------------
BRG_6705  = [25, 32, 4];    // #620-004, Diff Body A
BRG_6703  = [17, 23, 4];    // #620-003, 5 seats in the differential's own parts
                            //   and a 6th that 008.6 step 2 puts in #420-001
BRG_MR128 = [8, 12, 3.5];   // #620-002, 4 seats: shaft ends, and one per Split
                            //   Gear half. Both counts corrected under DC-11(e)
BRG_MR85  = [5, 8, 2.5];    // #620-001, into the Diff Gear Axle's back bore
THRUST_AXK0819 = [8, 19, 2];   // #710-006 needle thrust; 2x AS0819 races 8x19x1

// The bore of a shoulder that bears on a bearing's OUTER race: halfway across
// the bearing's section. A shoulder bored any smaller also bears on the inner
// race and brakes the bearing it locates. In "revised" every such shoulder is
// bored to this; "previous" keeps the reference's own bores. Body A's Ø20
// waist under its 6703 was already bored to it.
function shoulder_bore(spec) = (spec[0] + spec[1]) / 2;

L3_TUBE_ID  = 20.07;        // C-505 L3 tube's inside dimension, over Body A's
                            //   20 x 20 arm spigot
CF_ROD_D    = 8;            // #720-006 CF rod OD
CF_ROD_ID   = 6;            // #720-006 CF rod bore; the tool conductors' path
CF_ROD_LEN  = 96;           // reference: cut length, set by 008.6 not by geometry
STRAKE_25   = [25, 5.6, 2.5];   // #710-005, 3x. The slots are in the Split
                                //   Gear TOP, and are drawn 5.600 x 2.500 for
                                //   a 5.588 x 2.337 strip -- 0.012 mm across
                                //   the width, the robot's tightest bond fit
                                //   (007.1 C-502). 008.6 step 11 named the
                                //   Bottom, which carries no slot - DC-11(e)
// #720-005 (5x 60 x 4.4 x 1.5) was listed in 007.6. No assembly step places
// it, no part here carries a slot that would take it, and the build record
// does not call for it, so the row is withdrawn - DC-11(e). The constant is
// gone with it; nothing in this model set referred to it.
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
// All three bevels are 20T and mesh 1:1:1 at 90 deg. The GT2 inputs are 40T
// in "previous" and 80T in "revised" (DC-12).
// ---------------------------------------------------------------------------
BEVEL_TEETH   = 20;
BEVEL_OD      = 44.055;     // outside diameter of the side bevels (the
                            // DC-11(f) check datum on Split Gear Top)
// Module for straight bevel, 90 deg shafts, 20:20 -> 45 deg pitch cones:
// OD = m * (teeth + 2*cos(45)) => m = OD / 21.414
BEVEL_MOD     = BEVEL_OD / (BEVEL_TEETH + 2*cos(45));
// The tooth form itself is gt2_pulley.scad's, shared with the elbow pulleys.
//
// The Diff Gear Shaft's band is 40T in both configs. In "previous" it is the
// shaft's own pulley; in "revised" it is the spline that drives #720-004, the
// 80T ring epoxied over it, because an 80T ring cannot be turned on the shaft
// itself: the shaft enters Body A through the 6705's Ø25 bore, and the ring
// has to be in the chamber before it does (specs/008 § 008.6).
//
// PULLEY_TEETH is the count the belt meets: 40 in "previous", which is what
// both references measure and what the dist gates in render.rs --verify compare
// against, and 80 in "revised", the 40T -> 80T stage-2 of the 13.5:1 train
// (specs/004 § Wrist and differential). A measured 40T keeps its measured
// tip; any other count takes the GT2 standard's.
BAND_TEETH    = 40;         // Diff Gear Shaft band, both configs
BAND_TIP_D    = 24.97;      // its tooth tip diameter (measured)
BAND_Z        = [34.04, 42.04];   // its span on the shaft, in 720-001's frame;
                                  //   #720-004 is authored on the same span
PULLEY_TEETH  = config == "previous" ? 40 : 80;   // Diff End Pulley, #720-004
PULLEY_TIP_D  = PULLEY_TEETH == BAND_TEETH ? BAND_TIP_D
                                           : gt2_tip_d(PULLEY_TEETH);
PULLEY_ROOT_D = gt2_root_d(PULLEY_TIP_D);

// Cross-check the measured tip diameter against the GT2 standard. Agreement
// is what confirms these are 40T GT2 pulleys rather than some other belt.
assert(abs(BAND_TIP_D - gt2_tip_d(BAND_TEETH)) < 0.05,
       "measured pulley tip diameter disagrees with the 40T GT2 standard");

// The Diff Gear Shaft's band section.
module band_teeth_2d() { gt2_teeth_2d(BAND_TEETH, BAND_TIP_D); }

// The input pulleys' tooth section, 720-003 and 720-004.
module pulley_teeth_2d() { gt2_teeth_2d(PULLEY_TEETH, PULLEY_TIP_D); }

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

// Two of Diff Body B's bearing seats, in Body B's frame, stated here because
// the parts on the other side of each bearing have to reach its far face:
//   BODY_B_REAR_SEAT  the +X tunnel 6703's step, x. Its far face is where
//                     720-001's Ø19 shoulder bears on the inner race.
//   BODY_B_COL_SEAT   the column 6703, from the top of the journal's R2, z. Its
//                     far face is where 710-002's crown-bore shoulder bears on
//                     the outer race.
BODY_B_REAR_SEAT = 28.200;
BODY_B_COL_SEAT  = 36.000;

// ---------------------------------------------------------------------------
// L4, the J4 -> J5 offset (004 § Differential interface, specs/003)
// ---------------------------------------------------------------------------
// L4 is specified at 39.50 mm — the along-arm separation of the J4 and J5
// stations in the CAD kinematic chain — in specs/003 § Link lengths, which
// closed DC-6 on 2026-09-13. It is not a dimension anything here is driven to:
// diff_assembly.scad hangs a tripwire on it and arbitrates nothing.
//
// Two readings once carried here are withdrawn, and neither is to be revived
// as an L4 figure. Diff Body A's arm, on 2026-09-06: that arm is the L3 spigot,
// so its offset from C is across the arm rather than along it.
// HDI-007010's measured DH J4 row d = 39.30 mm, on 2026-09-13: J2, J3 and J4
// are parallel pitch axes, so d on the rows that follow them is a fit
// parameter, and its closeness to 39.50 mm is coincidence (specs/003 § DH
// model). The firmware file's 59.50 mm is that span's along-arm and across-arm
// components added together and is superseded; specs/006 carries the line.
//
// There is no HDI-940 cover envelope here. One was carried as COVER_ENVELOPE
// until 2026-09-06 and bounded nothing this model set builds; the figure
// belongs to 004 § Differential interface, which owns it.
L4             = 39.50;   // specified: specs/003 § Link lengths
L4_SUPERSEDED  = 59.50;   // the field Firmware/Defaults.make_ins still carries

// ---------------------------------------------------------------------------
// Diff Body A axis length. One value for both configs.
//
// 81.0 is the design dimension: the Ø60 top plate's R30 plus the arm's flat
// tip face at x = -51.000, both measured directly. The reference STL's
// bounding box reads 80.984 because a tessellated circle's extreme vertex
// falls short of its true radius — that 0.016 mm is faceting, not geometry,
// and driving the model from it would place the arm's flat face wrongly.
//
// One value for both configs because Body A lies inside the forearm skin and
// no wrist cover bounds its length (004 § Differential interface);
// robot_assembly.scad asserts the skin.
// ---------------------------------------------------------------------------
BODY_A_LEN = 81.0;

// Revised-config conformance is asserted where the assembly computes
// L4 (diff_assembly.scad), not here, so single parts stay renderable.

echo(str("diff_params config=", config, "  bevel module=", BEVEL_MOD));
