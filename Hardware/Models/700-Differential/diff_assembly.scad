// 700-Differential assembly — placement model (DC-2).
// Places the nine printed parts and their bought hardware in their assembled
// positions, so the stack can be reviewed by looking at it and so the
// kinematic quantities below can be computed from the built geometry rather
// than asserted about it.
//
// FRAME. Diff Body A at the origin, its End Arm Hub mating face on z = 0 and
// the J4 pivot axis along +Z. Everything else is placed against that, and
// everything but Body A pivots with J4_ANG.
//
// WHAT PLACES WHAT. Every position below is solved from a feature one of the
// parts already carries; none is a free offset chosen to make the picture look
// right. There are three independent chains and they close on each other,
// which is the check that the frame is correct:
//
//   1. The shaft in Body A. Diff Body A's three seats over-determine where the
//      Diff Gear Shaft sits and agree exactly. The shaft's rear 6703 face
//      (shaft z 44.040) lands on the Ø20 waist shoulder at A z 5.000; its
//      Ø27 collar (shaft 28.040) lands 4 mm above the Ø26 step, at A z 21.000,
//      so the 6705 is trapped between two measured shoulders; and its pulley
//      band falls on A z 7.000..15.000, centred on z = 11, which is the belt
//      slot's own centre. All three want SHAFT_Z0 = 49.040 and nothing else.
//
//   2. The gears. All three bevels are one crown (diff_bevel.scad) and each
//      part states where that crown's apex sits on its own axis. A bevel set
//      meshes when, and only when, the apexes coincide, so C is the shaft's
//      apex carried into this frame, and the Split Gear and the Diff Gear
//      Axle are placed by putting their apexes on the same point. Nothing
//      about the gears is positioned by a diameter or a face.
//
//   3. Body B on the shaft. Diff Body B's two 6703s sit 22.4 mm apart between
//      their shoulders and the shaft's front Ø17 journal is 22.5 mm long, so
//      the tunnel's position on the shaft is pinned to a tenth. Placing Body B
//      by its own axis crossing instead — which is what this file does, since
//      that crossing IS the differential centre — puts the two within 0.22 mm
//      of each other. Body B's mating rim then stands 0.53 mm off Diff Body A's
//      Ø60 plate, which is the running clearance between a rotating encoder rim
//      and the static end-stop track it turns over.
//
// The Split Gear's two halves take NO relative transform. 710-001 and 710-002
// are one gear sawn on a 45-degree cone and both are authored in the assembled
// frame: they state the same apex, their crowns meet on the parting cone at
// z 18.500, 710-002's Ø27 wall runs inside 710-001's Ø28 cavity, and 710-002's
// bottom face lands on 710-001's Ø23 seat floor at z 4.000. They are placed by
// the same transform, called twice. A previous revision of this file flipped
// one of them, which cannot be right: mirrored about the shared apex the two
// crowns do not overlap at all.
//
// Measured rather than argued: intersected as they sit here the two halves
// return open shells enclosing exactly 0.000 mm3 apiece (scadmesh segment),
// bounded by that seating face and by BEVEL_SPLIT_ROOT at (14.903, 21.903) —
// both construction points, not accidents. They touch on their shared faces and
// interfere nowhere. The one thing that did NOT line up between them is the
// brad holes 008.6 steps 7-9 drive to lock the halves: 710-001's ran
// z 11.534..12.943 and 710-002's z 12.089..13.456, a 0.5 mm disagreement in
// two references that the faces above leave no freedom to absorb. Since the
// parts are right and only the hole is wrong, the hole is what moves: the
// revised config drills both halves on 710-002's axis, and the previous config
// keeps each reference's own value so the DC-2 comparison still measures the
// reference. Which axis, and why that one, is set out at BRAD_Z in
// diff_params.scad.
//
// CLOCKING. diff_bevel.scad centres a tooth on its own +x, so the three gears
// would arrive with their teeth in phase and their tips buried in each other.
// A 1:1 bevel pair meshes tooth-in-slot, so the Split Gear keeps a tooth on
// each mesh ray and both side bevels are turned half a pitch off it. The two
// rays are 180 degrees apart on the Split Gear, which is ten of its twenty
// pitches, so one clocking serves both. Only the shaft needs a measurement
// here: its crown was exported at a phase of its own, which 720-001 records
// and diff_bevel.scad states.
//
// WHAT IS NOT MODELLED, AND WHY NOT. The belts. They leave through Body A's
// arm slot and their path is set by the upper arm, which is outside this model
// set; the slot is geometry and is in 730-001. Everything else in 007.6 now
// has a placement. The two that were open under DC-11 were both open because
// this file went looking for a BORE:
//   - The needle thrust stack is Ø19 over the Ø8 tube, and no bore in the
//     Split Gear takes it -- but a needle thrust bearing is not radially
//     located. It is a washer stack between two FACES, and the faces are
//     710-001's base annulus and the keeper, on the 10.423 mm of Ø8 tube that
//     stands proud of that base. What hid it was this file butting the keeper
//     straight onto the base, which left the 4.000 mm it occupies reading as
//     no gap at all.
//   - The MR85 has no Ø5 feature to ride on because its Ø5 is the race that
//     leaves this model set. Its OD 8 is what seats, in the top 1.5 mm of
//     720-002's Ø8 rod bore, and placing it is what fixed ROD_TOP.
// The #680-001 brads ARE drawn, but only where a straight one fits: under the
// revised config, where both halves drill to one axis. Under the previous
// config the two holes are 0.5 mm apart, no position for a brad is supported by
// both parts, and drawing one at a position neither part states would hide the
// finding, so nothing is drawn there.
//
// FOUR STACK-UPS THE PLACEMENT EXPOSES. "previous" states each one rather than
// absorbing it, because those parts are measured recreations and moving one to
// hide a gap would put it somewhere no measurement supports. "revised" designs
// all four out:
//
//   - In "previous", the Diff Gear Axle's Ø9 boss reaches 1.34 mm into the
//     shaft's front MR128 seat, where the bearing already is. Something is
//     1.3 mm out between the gear mesh and that seat, and the gear mesh is the
//     datum that cannot move. "revised" designs it out: the boss is the
//     spacer that stops the axle on that MR128's inner race, so the shaft's
//     front journal and Body B's front seat come in by 720-001's front_drop()
//     until the bearing's face is the boss's tip, asserted below.
//   - Diff Body B overlaps the toes of all three bevel crowns that turn
//     against it: its -X end flank with the axle's, its +X end wall with the
//     shaft's, and its chimney cone with the Split Gear Bottom's. None of the
//     three can be removed by moving Body B, since C must lie on both of its
//     axes. "revised" reshapes Body B instead, keeping the RUN clearance off
//     each crown's swept teeth. 730-002's TOE CLEARANCE owns the figures and
//     the construction, and render-all.rs requires each pair to render empty.
//
// Kinematic conformance (specs/003 § Link lengths, 004). In a bevel
// differential the J4 and J5 axes *intersect* — at the differential centre C —
// which is why the measured DH set carries a ~ 0 on both wrist rows. The wrist
// has no axis-to-axis distance, so L4 is the along-arm separation of the J4 and
// J5 stations in the CAD kinematic chain: 39.50 mm, specified in specs/003,
// which closed DC-6 on 2026-09-13. Nothing here is driven to it.
//
// Two readings taken here are withdrawn and are not to be revived as L4. Diff
// Body A's arm centreline at ITS z = 11.000, whose distance below C this file
// once called L4 (2026-09-05): that arm is the L3 spigot — the far end of the
// forearm tube, which ../robot_assembly.scad places it as — so C_OVER_ARM is
// the offset ACROSS the arm from that tube's axis to the wrist centre, while L4
// is a separation ALONG the arm. The two are perpendicular and no edit turns one
// into the other. And HDI-007010's measured DH J4 row d = 39.30 mm,
// which stood as independent corroboration until 2026-09-13: J2, J3 and J4 are
// parallel pitch axes, so d on the rows that follow them is a fit parameter
// rather than a measured offset, and its closeness to 39.50 mm is coincidence.
// C_OVER_ARM below still measures a real and stable relation inside Body A and
// is kept as a tripwire on C's height, but it is NOT L4 and must not be echoed
// or asserted as one.
//
// Everything else about the arm still holds as a measurement of Body A: the
// 20 x 20 R4 section spans z 1..21, the 6 x 6 belt slot z 8..14, and the shell
// is mirror-symmetric about that plane over z in [2,20].
//
// This file previously split L4 as a differential contribution plus an End Arm
// Hub standoff, measured from Body A's z = 0 as a mating face. That was wrong,
// and the correction is worth recording because the arithmetic looked sound.
// The End Arm Hub (400-EndArm/420-001_EndArmHub.stl, CAD HDI-500-001) is at
// the ELBOW, not the wrist: its glue rigs put it a whole L3 away from the
// differential (950-Tooling/GlueRig_EndArmHubToDiff_A+B holds that span in x,
// GlueRig_ArmBodyToEndArmHub_A+B holds L2's in y), and 004's own End Arm Hub
// paragraph says the same in words. There is no face where the two parts meet,
// so there was never a split to make there. The 29.000 mm the hub does carry
// on its own axis — tube socket axis at z = -25.000 up to its top face at
// z = +4.000 — is what the superseded table credited to it as "28.5 mm", and
// that is an L3-end number, not an L4 one.
//
// COST OF A LOOK, and why it is not the obvious answer. Rebuilding all nine
// parts from source costs about 36 s per compile, most of it the two housings
// and the four bevel crowns, so `geometry` can import meshes instead. Which
// meshes matters more than whether:
//
//   from source                              36 s, 1204 tree elements
//   importing out/, as render-all.rs writes  84 s,  111 tree elements
//   importing out/asm/, the same as binary    2 s,  111 tree elements
//
// The middle row is the trap, and it is the format rather than the meshes:
// render-all.rs writes ASCII STL and OpenSCAD's ASCII parser costs 21.4 s on
// 730-002's 8.3 MB alone, against 0.4 s for the same 43374 facets as a 2.2 MB
// binary. Importing is what makes the model cheap to ORBIT — the tree falls by
// a factor of eleven either way — and binary is what makes it cheap to OPEN.
//
// So this file reads out/asm/, which render-meshes.rs writes as binary and
// which is nobody's measurement; render-all.rs's own out/ is left exactly as
// it is, because those meshes are the DC-2 gate. Both are build output and
// neither is tracked (see .gitignore). If the view comes up empty, run
//   ./render-meshes.rs            # or: ./render-meshes.rs previous
// Set geometry = "scad" to build from source instead, which is what the .scad
// files being the record means, and what a `-D config=` switch needs: an
// imported mesh was fixed at whatever configuration rendered it, so a cache
// built as "previous" keeps showing "previous" parts however this file's own
// config reads. That is why the cache takes the configuration as an argument.

include <diff_bevel.scad>
include <diff_hardware.scad>

// The parts are pulled in with `use`, so only their modules are imported and
// their own top-level render calls do not fire. An OpenSCAD `-D config=...`
// override still reaches those modules' scopes, so selecting a configuration
// on the command line switches the parts here too, not just this file.
use <710-001_SplitGearTop.scad>
use <710-002_SplitGearBottom.scad>
use <710-003_DiffKeeper.scad>
use <710-004_RotateCodeDisk.scad>
use <720-001_DiffGearShaft.scad>
use <720-002_DiffGearAxle.scad>
use <720-003_DiffEndPulley.scad>
use <720-004_DiffShaftPulley.scad>
use <730-001_DiffBodyA.scad>
use <730-002_DiffBodyB.scad>

/* [Assembly] */
// Where the printed parts' geometry comes from — see COST OF A LOOK above.
geometry = "stl";   // [stl, scad]
// J4 pivot: turns Diff Body B and everything it carries about the J4 axis.
// The side bevels turn with it, so the teeth stay meshed at any angle.
J4_ANG = 0;         // [-90:1:90]
// Draw the bearings and the CF rod.
show_hardware = true;
// Draw only where two parts overlap as they sit, e.g. ["730-001", "720-004"].
// Any two ids from PARTS. render-all.rs sets it and requires an empty result;
// [] draws the assembly.
interference = [];
// "all", or one id from PARTS: that part alone, in its assembled place. The
// section viewer exports the assembly one id at a time through it.
part = "all";

/* [Hidden] */

// ---------------------------------------------------------------------------
// The frame. Two numbers, and everything else is read from a part.
// ---------------------------------------------------------------------------

// A-frame z of the Diff Gear Shaft's own z = 0, solved from Diff Body A's
// three seats — see WHAT PLACES WHAT (1) in the header.
SHAFT_Z0 = 49.040;

// The differential centre: the shaft's bevel apex, carried into this frame.
// The J5 axis crosses the J4 axis here and all three crowns share it.
C = [0, 0, SHAFT_Z0 - BEVEL_APEX_SHAFT];

// C, for a parent composition. `use` imports modules and functions but not
// variables, and C is the only point of this frame a parent needs: it is the
// one point both wrist axes pass through, so placing it places the assembly.
function diff_centre() = C;

// Diff Body B's axis crossing, in Body B's own frame. This point goes on C.
BODY_B_C = [BODY_B_COL_XY[0], BODY_B_J4_YZ[0], BODY_B_J4_YZ[1]];

// Tooth-in-slot clocking — see CLOCKING in the header. The Split Gear needs
// none: diff_bevel centres a tooth on its own +x and yrot(-90) sends that onto
// the mesh ray, so the half pitch is turned into the two side bevels instead.
SHAFT_CLOCK = BEVEL_PHASE_SHAFT - BEVEL_PITCH_ANG / 2;
AXLE_CLOCK  = BEVEL_PITCH_ANG / 2;

// ---------------------------------------------------------------------------
// Seats, as the parts state them. These position bought hardware only, so they
// are stated here with the part and the feature named rather than hoisted into
// a shared file: if one ever drifts, a stand-in bearing sits visibly proud of
// its seat, which is a failure that shows up by looking. The kinematic numbers
// — the apexes, the phase, Body B's axes — are the ones that must not drift,
// and those are read from diff_bevel.scad and diff_params.scad above.
// ---------------------------------------------------------------------------
SEAT_A_6703  =  1.000;   // 730-001 Ø23 seat, against the Ø20 waist at z 5
SEAT_A_6705  = 17.000;   // 730-001 Ø32 seat, against the Ø26 shoulder at z 17
SEAT_B_FRONT =  9.800 + front_drop();   // 730-002 Ø23 seat, against its step at x 13.8 + front_drop()
SEAT_B_REAR  = 28.200;   // 730-002 Ø23 seat, against its step at x 28.2
SEAT_B_COL   = 36.000;   // 730-002 Ø17 column journal, off the R2 at z 36
SEAT_SHAFT_F = SHAFT_Z0 - front_seat_floor();   // 720-001 front Ø12 seat floor, 3.0 deep from Z0
SEAT_SHAFT_R = -1.400;   // 720-001 rear Ø12 seat, 2.7 deep from Z1
SEAT_SG_TOP  = -0.500;   // 710-001 Ø12 MR128 seat, against its step at z 3
SEAT_SG_BOT  = 13.500;   // 710-002 Ø12 MR128 seat, z 13.5..17.0 — a 3.5 fit
SEAT_SG_6703 =  4.000;   // 710-001 Ø23 pocket, floored where 710-002 bottoms
MR85_PROUD   =  1.000;   // 720-002's back, "~1 mm proud" -- 008.6 step 19

// The brads' two ends, both radii on the Split Gear's own axis: a brad is
// driven until it bottoms in 710-002's blind hole and trimmed flush with
// 710-001's cage. The 5.500 mm between them is what 008.6 step 9 calls
// "~6 mm deep". Its height is BRAD_Z, which is shared and lives in
// diff_params.scad because both halves have to drill to it.
BRAD_TIP_R   = 12.000;   // 710-002's drilled floor (its BRAD_FLOOR)
BRAD_HEAD_R  = 17.500;   // 710-001's Ø35 cage tube, where the brad is cut off

CODE_DISK_Z  =  4.000;   // 710-004's hub ends on 710-001's Ø37.98 stop collar
SPLIT_BASE_Z = -1.000;   // 710-001's base face; the Diff Keeper butts on it
PULLEY_REF_Z0 = 17.500;  // 720-003's Z0, undone when its mesh is imported
PULLEY_FROM_TIP = 6.000; // 008.6 step 16

// The rod runs from the Diff Gear Axle's outer face down through the shaft.
// Where along the rod the axle sits was open here until the MR85 was placed,
// and the MR85 settles it: 008.6 step 19 presses it into the axle's flat back
// ~1 mm proud, so it occupies the top 1.5 mm of the SAME Ø8 bore the rod runs
// in and the rod cannot reach that face. The rod stops 1.5 mm short of it,
// which leaves 12.5 mm of Ø8 lap for the epoxy joint of step 20. The End
// Pulley then lands below Body A's mating face, clear of the arm's belt slot,
// which is a result to check against 008.6 rather than one to trust.
ROD_TOP = C.z + BEVEL_APEX_AXLE - (BRG_MR85[2] - MR85_PROUD);
ROD_BOT = ROD_TOP - CF_ROD_LEN;

// ---------------------------------------------------------------------------
// What a parent composition reads out of this frame. `use` imports modules and
// functions but not variables, so anything a parent needs is a function here
// rather than a number it would have to keep in step by hand.
//
// Three features carry the wrist's placement, and ../robot_assembly.scad places
// the whole arm by them. Diff Body A is the part that does NOT pivot with J4,
// so it is the part the forearm reaches; its -x end is the 20 x 20 R4 spigot
// the L3 tube slides over, and its axis is the tube's. The Diff End Pulley is
// where a belt from the elbow lands, so which way it faces says which side the
// belts run on.
//
// Each part states its own extent for the configuration in force. Body A takes
// no transform here, so its extent is its placed one; the End Pulley's is
// stated in its reference frame, PULLEY_REF_Z0 above its module's base, and is
// then placed off the rod's far end, so only this file can say where it ends up.
// ---------------------------------------------------------------------------
function diff_body_a_box() = body_a_box();

function diff_end_pulley_box() =
    let (dz = ROD_BOT + PULLEY_FROM_TIP - PULLEY_REF_Z0,
         b  = end_pulley_box_ref())
    [b[0] + [0, 0, dz], b[1] + [0, 0, dz]];

// The spigot's axis, on Body A's shell symmetry plane at ARM_Z.
function diff_arm_axis() = [0, 0, ARM_Z];

// ---------------------------------------------------------------------------
// Frames. Each turns a part's own coordinates into this one, so every
// placement below reads as the number the part states and nothing else.
// ---------------------------------------------------------------------------

// The carrier: everything that pivots about J4. Body A alone stays put.
module j4() { zrot(J4_ANG) children(); }

// Diff Body B's frame. Its +X — the tunnel, toward the mating rim — runs down
// this frame's -Z, and its column runs out along +X.
module in_body_b() {
    translate(C) yrot(90) translate(-BODY_B_C) children();
}

// The Split Gear's frame: local +z points at C, so the part hangs off the
// column at +X and its apex lands on the differential centre.
module in_split() {
    translate(C) yrot(-90) down(BEVEL_APEX_SPLIT) children();
}

// The Diff Gear Shaft's frame: local +z runs down this frame's -Z, which is
// what puts the rear journal in Body A and the crown up at C.
module in_shaft() {
    zrot(SHAFT_CLOCK) up(SHAFT_Z0) xrot(180) children();
}

// The Diff Gear Axle's frame: the opposite side bevel, apex on the same point.
module in_axle() {
    zrot(AXLE_CLOCK) translate(C) xrot(180) down(BEVEL_APEX_AXLE) children();
}

// ---------------------------------------------------------------------------
// The printed parts, from whichever source `geometry` selects.
//
// Three meshes are not in their module's frame. render-all.rs exports each
// file's own top-level call and three of those carry a placement: 720-001 is
// exported in the reference's Y-up orientation, 720-003 in the reference's
// z, PULLEY_REF_Z0 above its module's base, and 720-004 based at z = 0 for
// printing, BAND_Z[0] below its module's frame. Undoing each here is what lets
// every placement above be written once and mean the same thing either way.
// ---------------------------------------------------------------------------
module part(id) {
    if (geometry == "stl") {
        if (id == "720-001")
            xrot(90) import("out/asm/720-001.stl", convexity = 10);
        else if (id == "720-003")
            down(PULLEY_REF_Z0) import("out/asm/720-003.stl", convexity = 10);
        else if (id == "720-004")
            up(BAND_Z[0]) import("out/asm/720-004.stl", convexity = 10);
        else
            import(str("out/asm/", id, ".stl"), convexity = 10);
    }
    else if (id == "710-001") split_gear_top();
    else if (id == "710-002") split_gear_bottom();
    else if (id == "710-003") diff_keeper();
    else if (id == "710-004") rotate_code_disk();
    else if (id == "720-001") diff_gear_shaft();
    else if (id == "720-002") diff_gear_axle();
    else if (id == "720-003") diff_end_pulley();
    else if (id == "720-004") diff_shaft_pulley();
    else if (id == "730-001") diff_body_a();
    else if (id == "730-002") diff_body_b();
    else assert(false, str("no such part: ", id));
}

// ---------------------------------------------------------------------------
// Placement. Colour is by role — housings, gears, encoder, hardware — so that
// what meshes with what is legible in a preview.
// ---------------------------------------------------------------------------

BODY_C   = [0.72, 0.74, 0.78];
GEAR_C   = [0.83, 0.68, 0.42];
ENC_C    = [0.30, 0.32, 0.36];
STEEL_C  = [0.55, 0.60, 0.66];
CARBON_C = [0.16, 0.16, 0.18];

// Every id draw() takes, printed parts first. One id is one export for the
// section viewer (diff_assembly.view.json), so a bought set that goes in as a
// unit — a seat's bearings, the thrust stack, the brads — is one id.
PARTS = ["730-001", "730-002", "720-001", "720-004", "720-002", "720-003",
         "710-001", "710-002", "710-004", "710-003",
         "cf_rod", "mr85", "brg_body_a", "brg_body_b", "brg_shaft", "brg_split",
         "thrust_stack", "brads"];

// The assembly is a module rather than a run of top-level calls so that a
// parent composition can place it: ../robot_assembly.scad reaches it with
// `use` and positions it by diff_centre(). Called at the end of this file, so
// opening this file on its own is unchanged. `part` narrows it to one id.
module diff_assembly() for (p = PARTS) if (part == "all" || part == p) draw(p);

// One id, in its assembled place. Body A alone is static: it is the wrist
// frame the whole differential hangs on. Everything else is the carrier and
// turns with J4.
module draw(p) {
    if (p == "730-001") color(BODY_C) placed(p);
    else j4() {
        carried(p);
        if (show_hardware) { rod_and_stacks(p); bearings(p); }
    }
}

module carried(p) {
    // The pivoting carrier, and the J4 encoder rim it turns over Body A's
    // end-stop track.
    if (p == "730-002") color(BODY_C) in_body_b() part(p);

    // Input B: the hollow shaft, its 40T band and its bevel. In "revised"
    // the band is a spline and the 80T ring over it is the pulley.
    if (p == "720-001") color(GEAR_C) placed(p);
    if (p == "720-004" && config == "revised") color(GEAR_C) placed(p);

    // Input A: the CF rod, its bevel at the top and its pulley at the bottom.
    if (p == "720-002") color(GEAR_C) in_axle() part(p);
    if (p == "720-003") color(GEAR_C) placed(p);

    // Output: the split bevel on the column, both halves in one frame, the
    // Top drawn DRAW_JOINT off the Bottom — see SPLIT JOINT below.
    if (p == "710-001") color(GEAR_C) in_split() down(DRAW_JOINT) part(p);
    if (p == "710-002") color(GEAR_C) in_split() part(p);

    // J5 encoder disk, over the Split Gear body and against its stop collar.
    if (p == "710-004") color(ENC_C) in_split() up(CODE_DISK_Z) part(p);

    // The keeper, epoxied on the Ø8 tube. It does NOT butt the Split Gear's
    // base: the needle thrust stack stands between the two (008.6 step 23),
    // so the keeper's epoxy face sits a stack height below SPLIT_BASE_Z.
    if (p == "710-003") color(BODY_C) in_split()
        up(SPLIT_BASE_Z - thrust_stack_h()) xrot(180) part(p);
}

// SPLIT JOINT. The halves mate, and both meshes honour it: at nominal they
// touch over the whole facing surface and interpenetrate nowhere, which is the
// coincidence DRAW_JOINT exists for — 991 contacts, every one of them in this
// one pair. The joint opens rather than shuts, and the meshes decide that:
// opening it leaves the two halves as separate closed shells, each carrying
// its own mesh's volume to the digit — 13020.518 and 6999.825 mm3, summing to
// what the pair measured before — while closing it by the same amount merges
// them into one shell that is not closed and loses 0.299 mm3 to the overlap.
// Neither part moves either way: they are bolted together, and 008.6 seats
// them face to face.

module rod_and_stacks(p) {
    if (p == "cf_rod") color(CARBON_C) up(ROD_BOT) cf_rod();

    // The MR85, pressed into the flat back of the Diff Gear Axle and standing
    // 1 mm proud of it (008.6 step 19). Its OD is the Ø8 rod bore, so it takes
    // the top 1.5 mm of that bore; what its Ø5 rides on closes the wrist above
    // and is outside this model set, which ends here at the J4 axis. See
    // ROD_TOP: this is what says the rod cannot be flush with that face.
    if (p == "mr85") color(STEEL_C) in_axle() up(-MR85_PROUD) bearing(BRG_MR85);

    // The needle thrust stack, on the 10.423 mm of Ø8 tube that stands proud
    // of the Split Gear's base. It is located by the tube and carried by two
    // FACES — 710-001's base annulus, r 5.994..18.500, against the keeper — so
    // it never wanted a bore. Anchored on its own bottom face like the
    // bearings, and drawn downward from that base.
    if (p == "thrust_stack") color(STEEL_C) in_split()
        up(SPLIT_BASE_Z - thrust_stack_h()) thrust_stack();

    // The four brads that lock the Split Gear's halves together. They are
    // drawn only when both halves drill to one line, which is a config choice
    // — see BRAD_Z in diff_params.scad. Under the reference heights there is
    // no straight brad either part would support, and drawing one anyway
    // would hide that.
    if (p == "brads" && BRAD_Z_TOP == BRAD_Z) color(STEEL_C) in_split() up(BRAD_Z)
        for (a = [0 : 90 : 270])
            zrot(a) right(BRAD_TIP_R) brad(BRAD_HEAD_R - BRAD_TIP_R);
}

module bearings(p) color(STEEL_C) {
    // J4 pivot, in Body A.
    if (p == "brg_body_a") {
        up(SEAT_A_6703) bearing(BRG_6703);
        up(SEAT_A_6705) bearing(BRG_6705);
    }
    // J4 pivot, in Body B's tunnel: the pair that spans the shaft's 22.5 mm
    // front journal. And J5: the column journal, in 710-002's Ø23 crown bore.
    if (p == "brg_body_b") in_body_b() {
        translate([SEAT_B_FRONT, BODY_B_J4_YZ[0], BODY_B_J4_YZ[1]]) yrot(90) bearing(BRG_6703);
        translate([SEAT_B_REAR, BODY_B_J4_YZ[0], BODY_B_J4_YZ[1]]) yrot(90) bearing(BRG_6703);
        translate([BODY_B_COL_XY[0], BODY_B_COL_XY[1], SEAT_B_COL]) bearing(BRG_6703);
    }
    // The rod's two bearings, in the shaft's own end seats.
    if (p == "brg_shaft") {
        up(SEAT_SHAFT_F) bearing(BRG_MR128);
        up(SEAT_SHAFT_R) bearing(BRG_MR128);
    }
    // The Split Gear on Body B's Ø8 thrust tube, and the 6703 between its
    // halves — see SPLIT 6703 below.
    if (p == "brg_split") in_split() {
        up(SEAT_SG_TOP)  bearing(BRG_MR128);
        up(SEAT_SG_BOT)  bearing(BRG_MR128);
        up(SEAT_SG_6703) bearing(BRG_6703);
    }
}

// SPLIT 6703. The 6703 between the Split Gear's halves is an ASSEMBLY bearing,
// not a running one: 710-001's Ø23 bore and 710-002's Ø17 stub are the 6703's
// two race diameters exactly, the void between them is its width plus 0.253,
// and 008.6 installs it into the Top at step 5 — BEFORE step 8 presses the
// halves together and turns one against the other to clock the teeth. It
// carries that rotation, and thereafter stands as a ground Ø17/Ø23
// concentricity bush. Its races turning together once the brads are in is the
// finished state, not a defect.

// Where Body A and the input-pulley parts sit. The carrier's J4 turn is the
// caller's.
module placed(id) {
    if (id == "730-001") part(id);
    else if (id == "720-001" || id == "720-004") in_shaft() part(id);
    else if (id == "720-003") up(ROD_BOT + PULLEY_FROM_TIP) part(id);
    else assert(false, str("placed() does not place ", id));
}

if (len(interference) == 2)
    intersection() { draw(interference[0]); draw(interference[1]); }
else
    diff_assembly();

// ---------------------------------------------------------------------------
// What the placement computes.
// ---------------------------------------------------------------------------

// C's height above Diff Body A's arm centreline (see header). This was read as
// L4 until 2026-09-05; that arm is the L3 spigot, so this is an across-arm
// offset and no L4 reading. ../robot_assembly.scad measures the same span in
// the robot frame, as the L3 tube's axis over Body A's spigot axis, and reports
// the residual. Kept because it is a stable relation to hang a tripwire on.
ARM_Z       = 11.000;
C_OVER_ARM  = C.z - ARM_Z;

echo(str("C over Body A's arm centreline: ", C_OVER_ARM, " mm (C at ", C.z,
         " over ", ARM_Z, "). NOT L4 — that arm is the L3 spigot and this is ",
         "an across-arm offset. See specs/003 § Link lengths"));
echo(str("  L4 is specified at ", L4, " mm and is not read from this file; ",
         "Firmware/Defaults.make_ins still carries ", L4_SUPERSEDED, " mm"));
echo(str("differential centre C=", C, "  geometry=", geometry,
         "  J4=", J4_ANG, " deg"));
echo(BRAD_Z_TOP == BRAD_Z
     ? str("Split Gear brads: both halves drilled on z=", BRAD_Z,
           ", brad r ", BRAD_TIP_R, "..", BRAD_HEAD_R, " (",
           BRAD_HEAD_R - BRAD_TIP_R, " mm deep, 008.6 step 9 says ~6)")
     : str("Split Gear brads: NOT drawn - 710-001 drills z=", BRAD_Z_TOP,
           " and 710-002 z=", BRAD_Z, ", ", BRAD_Z - BRAD_Z_TOP,
           " mm apart on a ", BRAD_D, " mm brad"));
echo(str("bevel set: apexes on C from shaft ", BEVEL_APEX_SHAFT,
         ", split ", BEVEL_APEX_SPLIT, ", axle ", BEVEL_APEX_AXLE,
         "; teeth ", -BEVEL_INNER_TIP.y, " .. ", -BEVEL_HEEL_ROOT.y,
         " mm out from C"));

// A tripwire on the J4-axis stack, and not a claim that C_OVER_ARM is L4 — it
// is not. It happens to sit 2.0 mm from the specified L4 and 22 mm from the
// superseded firmware figure, so a 3 mm window passes the geometry as it stands
// and fires if a frame edit moves C toward the value the firmware file wants.
// That is the mistake worth catching: nothing here is a number to reach by
// adjusting the model until it fits.
assert(abs(C_OVER_ARM - L4) < 3.0,
       "the J4-axis stack has moved away from the measured wrist geometry");
// The axes must intersect: C lies on the J4 axis (x = y = 0) by construction,
// and the Split Gear is placed on the J5 axis through the same point.
assert(C.x == 0 && C.y == 0, "J4 and J5 axes must intersect at C");
// A bevel set meshes only if every apex is the same point. Each part is placed
// by its own apex, so this holds by construction — assert it anyway, because
// the placement is what would silently stop being true if a frame were edited.
assert(BEVEL_APEX_SPLIT > -BEVEL_INNER_TIP.y,
       "the Split Gear's apex is inside its own teeth - check its frame");
// Body A's envelope is the forearm skin, which is in the robot frame, so
// ../robot_assembly.scad asserts it (004 § Differential interface).
//
// The End Pulley hangs off the rod's far end, below Body A: their extents must
// not overlap along J4, whatever the pulley's size. #720-004 sits inside Body
// A's chamber, which no extent can check; render-all.rs renders that pair's
// overlap instead.
assert(diff_end_pulley_box()[1].z < diff_body_a_box()[0].z,
       "the Diff End Pulley reaches Diff Body A");
echo(str("Diff End Pulley top z=", diff_end_pulley_box()[1].z,
         ", Diff Body A base z=", diff_body_a_box()[0].z));

// In "revised" the axle's boss is the spacer on the front MR128's inner race:
// the bearing's outer face is the boss's tip.
MR128_FRONT_FACE = SEAT_SHAFT_F + BRG_MR128[2];
AXLE_BOSS_TIP = C.z + BEVEL_APEX_AXLE - boss_z()[1];
assert(config == "previous" || abs(MR128_FRONT_FACE - AXLE_BOSS_TIP) < 1e-6,
       "the axle's boss does not land on the front MR128");
echo(str("front MR128 face z=", MR128_FRONT_FACE, ", axle boss tip z=", AXLE_BOSS_TIP));

// Named, so the section viewer (diff_assembly.view.json) reads them; every
// length is mm. The axle's boss is quoted in this frame: in_axle() turns the
// part over, so its local z runs down from C.z + BEVEL_APEX_AXLE.
AXLE_BOSS_Z = [for (z = boss_z()) C.z + BEVEL_APEX_AXLE - z];
echo(config = config);
echo(geometry = geometry);
echo(j4_ang = J4_ANG);
echo(axle_boss_d = boss_d());
echo(axle_boss_wall = boss_wall());                   // the boss's body around the rod bore
echo(axle_boss_face_wall = boss_face_wall());         // its tip face, on the MR128's inner race
echo(axle_boss_wall_measured = boss_wall_measured()); // the Ø9 boss's wall on the reference mesh
echo(axle_rod_bore = rod_bore_d());
echo(axle_boss_z_low = round(min(AXLE_BOSS_Z) * 1000) / 1000);
echo(axle_boss_z_high = round(max(AXLE_BOSS_Z) * 1000) / 1000);
