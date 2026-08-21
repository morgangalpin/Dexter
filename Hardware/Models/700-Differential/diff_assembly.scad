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
// set; the slot is geometry and is in 730-001. The needle thrust stack, whose
// seat cannot be located: it is Ø19 over the Ø8 tube, and the only bore in the
// Split Gear wide enough to take it is 710-001's Ø23 pocket, which 710-002's
// Ø17 stub already fills. The MR85, listed as "Diff Gear Axle back", which has
// no Ø5 feature anywhere to ride on. Those two are open under DC-11. The
// #680-001 brads ARE drawn, but only where a straight one fits: under the
// revised config, where both halves drill to one axis. Under the previous
// config the two holes are 0.5 mm apart, no position for a brad is supported by
// both parts, and drawing one at a position neither part states would hide the
// finding, so nothing is drawn there.
//
// THREE STACK-UPS THE PLACEMENT EXPOSES. Each is stated rather than absorbed,
// because the parts are measured recreations and moving one to hide a gap
// would put it somewhere no measurement supports:
//
//   - The Diff Gear Axle's Ø9 boss reaches 1.34 mm into the shaft's front
//     MR128 seat, where the bearing already is. Something is 1.3 mm out
//     between the gear mesh and that seat, and the gear mesh is the datum
//     that cannot move.
//   - Diff Body B's -X end flank and the axle bevel's toe cone are the same
//     45-degree surface: r = x + 5.500 against r = x + 5.224, so the flank
//     stands 0.276 mm inside the cone it is the relief for. The end lip
//     itself clears, at r 13.086 against the cone's 13.224.
//   - Body B's chimney cone, rho = 47.520 - z, against the Split Gear's toe
//     cone at rho = 47.224 - z: 0.296 mm the same way, over the 0.79 mm band
//     below the z = 34 clip where the chimney's corners still show.
//
// The two 0.28 mm figures are the same number on perpendicular axes and no
// single shift removes both, since C must lie on both of Body B's axes. They
// are the size of the residuals these parts already carry — 730-002's own gate
// is 0.414 mm — so they are recorded, not designed out.
//
// Kinematic conformance (DC-6, 004). In a bevel differential the J4 and J5
// axes *intersect* — at the differential centre C — which is why the measured
// DH set carries a ~ 0 on both wrist rows and puts the wrist geometry in the d
// offsets instead. The link length L4 is therefore an offset ALONG the J4
// axis: from the point where L3 lands on that axis, up to C.
//
// So L4 needs one datum this model can supply and one it cannot. The upper end
// is C, which is derived here. The lower end is where the L3 span meets the J4
// axis, and everything about Diff Body A's arm is centred on ITS z = 11.000 —
// the 20 x 20 R4 section spans z 1..21, the 6 x 6 belt slot z 8..14, and the
// shell is mirror-symmetric about that plane over z in [2,20]. Taking that
// centreline as the L3 axis is what L4_BUILT below assumes, and it is the one
// assumption in this file that no measurement here settles: nothing in the
// 700 set shows the tube landing on it. It is the thing to check first.
//
// This file previously split L4 as a differential contribution plus an End Arm
// Hub standoff, measured from Body A's z = 0 as a mating face. That was wrong,
// and the correction is worth recording because the arithmetic looked sound.
// The End Arm Hub (400-EndArm/420-001_EndArmHub.stl, CAD HDI-500-001) is at
// the ELBOW, not the wrist: its glue rigs put it a whole L3 away from the
// differential (950-Tooling/GlueRig_EndArmHubToDiff_A+B span 362 mm in x,
// GlueRig_ArmBodyToEndArmHub_A+B span 405 mm in y), and 004's own End Arm Hub
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
//   ./render-meshes.rs            # or: ./render-meshes.rs revised
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
SEAT_B_FRONT =  9.800;   // 730-002 Ø23 seat, against its step at x 13.8
SEAT_B_REAR  = 28.200;   // 730-002 Ø23 seat, against its step at x 28.2
SEAT_B_COL   = 36.000;   // 730-002 Ø17 column journal, off the R2 at z 36
SEAT_SHAFT_F = 57.000;   // 720-001 front Ø12 seat floor, 3.0 deep from Z0
SEAT_SHAFT_R = -1.400;   // 720-001 rear Ø12 seat, 2.7 deep from Z1
SEAT_SG_TOP  = -0.500;   // 710-001 Ø12 MR128 seat, against its step at z 3
SEAT_SG_BOT  = 13.500;   // 710-002 Ø12 MR128 seat, z 13.5..17.0 — a 3.5 fit
SEAT_SG_6703 =  4.000;   // 710-001 Ø23 pocket, floored where 710-002 bottoms

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
// This is the one placement in the file with no measured feature behind it:
// the axle fixes the rod's upper end and the cut length fixes the lower, but
// nothing found so far says where along the rod the axle sits, so the two are
// taken flush. The End Pulley then lands below Body A's mating face, clear of
// the arm's belt slot, which is a result to check against 008.6 rather than
// one to trust.
ROD_TOP = C.z + BEVEL_APEX_AXLE;
ROD_BOT = ROD_TOP - CF_ROD_LEN;

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
// Two meshes are not in their module's frame. render-all.rs exports each
// file's own top-level call and two of those carry a placement: 720-001 is
// exported in the reference's Y-up orientation and 720-003 in the reference's
// z, PULLEY_REF_Z0 above its module's base. Undoing both here is what lets
// every placement above be written once and mean the same thing either way.
// ---------------------------------------------------------------------------
module part(id) {
    if (geometry == "stl") {
        if (id == "720-001")
            xrot(90) import("out/asm/720-001.stl", convexity = 10);
        else if (id == "720-003")
            down(PULLEY_REF_Z0) import("out/asm/720-003.stl", convexity = 10);
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

// Static: the wrist frame the whole differential hangs on.
color(BODY_C) part("730-001");

j4() {
    // The pivoting carrier, and the J4 encoder rim it turns over Body A's
    // end-stop track.
    color(BODY_C) in_body_b() part("730-002");

    // Input B: the hollow shaft, its integrated 40T pulley and its bevel.
    color(GEAR_C) in_shaft() part("720-001");

    // Input A: the CF rod, its bevel at the top and its pulley at the bottom.
    color(GEAR_C) in_axle() part("720-002");
    color(GEAR_C) up(ROD_BOT + PULLEY_FROM_TIP) part("720-003");

    // Output: the split bevel on the column, both halves on one transform.
    color(GEAR_C) in_split() {
        part("710-001");
        part("710-002");
    }

    // J5 encoder disk, over the Split Gear body and against its stop collar.
    color(ENC_C) in_split() up(CODE_DISK_Z) part("710-004");

    // The keeper, epoxied on the Ø8 tube against the Split Gear's base.
    color(BODY_C) in_split() up(SPLIT_BASE_Z) xrot(180) part("710-003");

    if (show_hardware) {
        color(CARBON_C) up(ROD_BOT) cf_rod();
        color(STEEL_C) {
            // J4 pivot, in Body A.
            up(SEAT_A_6703) bearing(BRG_6703);
            up(SEAT_A_6705) bearing(BRG_6705);
            // J4 pivot, in Body B's tunnel: the pair that spans the shaft's
            // 22.5 mm front journal.
            in_body_b() {
                translate([SEAT_B_FRONT, BODY_B_J4_YZ[0], BODY_B_J4_YZ[1]])
                    yrot(90) bearing(BRG_6703);
                translate([SEAT_B_REAR, BODY_B_J4_YZ[0], BODY_B_J4_YZ[1]])
                    yrot(90) bearing(BRG_6703);
                // J5: the column journal, in 710-002's Ø23 crown bore.
                translate([BODY_B_COL_XY[0], BODY_B_COL_XY[1], SEAT_B_COL])
                    bearing(BRG_6703);
            }
            // The rod's two bearings, in the shaft's own end seats.
            up(SEAT_SHAFT_F) bearing(BRG_MR128);
            up(SEAT_SHAFT_R) bearing(BRG_MR128);
            // The Split Gear on Body B's Ø8 thrust tube, and the fifth 6703 —
            // the pocket between 710-001's Ø23 bore and 710-002's Ø17 stub is
            // exactly a 6703 section, and it is the only seat left once the
            // other four are placed. Both its races turn together, which is
            // not what a bearing is for; recorded under DC-11 rather than
            // explained away.
            in_split() {
                up(SEAT_SG_TOP)  bearing(BRG_MR128);
                up(SEAT_SG_BOT)  bearing(BRG_MR128);
                up(SEAT_SG_6703) bearing(BRG_6703);
            }
            // The four brads that lock the Split Gear's halves together. They
            // are drawn only when both halves drill to one line, which is a
            // config choice — see BRAD_Z in diff_params.scad. Under the
            // reference heights there is no straight brad either part would
            // support, and drawing one anyway would hide that.
            if (BRAD_Z_TOP == BRAD_Z)
                in_split() up(BRAD_Z)
                    for (a = [0 : 90 : 270])
                        zrot(a) right(BRAD_TIP_R)
                            brad(BRAD_HEAD_R - BRAD_TIP_R);
        }
    }
}

// ---------------------------------------------------------------------------
// What the placement computes.
// ---------------------------------------------------------------------------

// L4 as this design builds it (see header): C's height above the plane where
// L3 lands on the J4 axis, which is Diff Body A's arm centreline.
L3_AXIS_Z = 11.000;
L4_BUILT  = C.z - L3_AXIS_Z;

echo(str("L4 along the J4 axis: built=", L4_BUILT, " mm (C at ", C.z,
         " over Body A's arm centreline at ", L3_AXIS_Z,
         ") vs firmware target ", L4_TARGET, " mm, short by ",
         L4_TARGET - L4_BUILT, " mm — DC-6"));
echo(str("  the two kinematic figures agree with the build, not the target: ",
         "GLTF frame separation ", L4_GLTF, " mm, measured DH J4 d=", L4_DH_D,
         " mm"));
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

// A tripwire on the J4-axis stack, not an arbitration of DC-6. The three
// geometric sources for L4 — this build, the GLTF frames, the measured DH set
// — span 2.0 mm; the firmware's figure is 22 mm away from all of them. A 3 mm
// window therefore passes the geometry as it stands and fires if a frame edit
// moves C toward the value the firmware wants, which is the mistake worth
// catching: L4 is not a number to reach by adjusting the model until it fits.
assert(abs(L4_BUILT - L4_GLTF) < 3.0,
       "the J4-axis stack has moved away from the measured wrist geometry");
// The axes must intersect: C lies on the J4 axis (x = y = 0) by construction,
// and the Split Gear is placed on the J5 axis through the same point.
assert(C.x == 0 && C.y == 0, "J4 and J5 axes must intersect at C");
// A bevel set meshes only if every apex is the same point. Each part is placed
// by its own apex, so this holds by construction — assert it anyway, because
// the placement is what would silently stop being true if a frame were edited.
assert(BEVEL_APEX_SPLIT > -BEVEL_INNER_TIP.y,
       "the Split Gear's apex is inside its own teeth - check its frame");
// Revised config must fit the HDI-940 cover envelope across the arm.
if (config == "revised")
    assert(BODY_A_LEN <= COVER_ENVELOPE.x,
           "Diff Body A exceeds the cover envelope");
