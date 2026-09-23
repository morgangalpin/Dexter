// robot_assembly.scad — whole-robot composition.
//
// Places the printed parts, the structural stock and the cover envelopes in
// their assembled positions, so the build can be reviewed by looking at it and
// so a part that is missing shows up as a hole rather than as an absence
// nobody notices. It is the counterpart of 700-Differential/diff_assembly.scad
// one level up: that file composes one subassembly, this one composes the arm.
//
// FRAME. The CAD model frame: +y runs along the arm from the base mount, +z
// across the arm, +x out to the tool. This is the frame specs/003 § Link
// lengths states the joint stations in and the frame specs/004 § Differential
// interface measures Diff Body A in, so it is the frame the spec set already
// speaks. It is not specs/003 § Coordinate frame's operator frame, which is
// Z-up; relating the two is a question about the pose this model is drawn in,
// and nothing here depends on the answer.
//
// J2 and J3 run along z. J1 runs along y. J5 runs along x, out through the
// tool. J4 runs along z, which the wrist section below reads off two mating
// features rather than assuming.
//
// WHAT PLACES WHAT. Every placement below is solved from a feature the part
// itself carries, matched against the CAD assembly in dde/HDIMeterModel.gltf —
// the same file specs/003 and specs/004 read the joint stations from. The
// derivation is written at each call site and names the feature, because a
// placement that cannot be traced to a feature is a guess that renders.
//
// Two rules keep that honest:
//
//   1. A mating feature outranks a bounding box. Where a printed part and its
//      CAD body disagree in size — and two of them do — the part is placed by
//      the face that locates it in the build, and the disagreement is recorded
//      at the call site rather than split between the two ends.
//
//   2. A part whose placement is not determined by anything in the model set
//      is NOT drawn at a plausible position. It goes in UNPLACED below. The
//      value of this file is that the holes in it are real.
//
// THE WRIST LANDING, AND THE TWO FEATURES THAT FIX IT. The differential
// arrives on one transform. Both halves of it are read off a mating feature,
// and neither is chosen:
//
//   Along the arm. Diff Body A's -x end is a 20 x 20 R4 spigot, 386.245 mm2 in
//   section over a 12.700 x 15.304 bore of 131.7156 mm2, and the End Arm Hub's
//   L3 plug is the same spigot -- 386.068 mm2 over the same bore, 131.7158 mm2,
//   the two bores agreeing to two parts in a million. They are the two ends of
//   the one C-505 tube, so Body A's spigot points back down the forearm and the
//   differential frame's -x runs onto this frame's -y.
//
//   Across the arm. The Diff End Pulley hangs off the CF rod below the
//   differential centre, at that assembly's own z -18.838..-8.588, and the belt
//   that drives it comes from the elbow, whose four pulleys stand at
//   z 78.500..96.500 here. The pulley faces the side they are on, so the
//   differential frame's -z runs onto this frame's +z and the J4 axis onto -z.
//
// Those two fix the third: the remaining row is their cross product, which is
// what makes WRIST_BASIS below a proper rotation and the whole of the
// transform. Both features also put the J4 and J5 axes through one point, as a
// bevel differential requires and as 700-Differential/diff_assembly.scad
// asserts of its own frame, so the assembly is placed by its diff_centre().
//
// WHAT THE LANDING THEN MEASURES, none of it fitted. Body A's spigot axis lands
// on (x = 0, z = 35.5335) along y, against the C-505 tube's own
// (x = 0, z = 36.000): coaxial to 0.4665 mm, which is the size of the residuals
// these measured parts already carry. Its 6 x 6 belt slot runs down the spigot
// on x +/-3, z 32.5335..38.5335 -- inside the tube's 20.07 mm bore -- and opens
// at the tip, facing the elbow the belts come from. The spigot is 21.000 mm
// long, against the 16.0 mm of it C-505 laps at the hub.
//
// FOUR READINGS ARE WITHDRAWN, and all four were one mistake. This file drew
// the differential four ways, on the grounds that specs/003 § DH model reads
// the J4 axis parallel to J3 while specs/004 § Differential interface fits Body
// A to the gripper covers by a radius bounding two perpendicular directions at
// once. All four sent the differential frame's -x onto this frame's +x, on the
// reading that Body A's arm is the tool mount. It is not: it is the L3 spigot,
// and the section above is what says so. 003's reading survives -- J4 does run
// along z -- but neither record addressed the quarter turn about that axis, and
// that turn is what the spigot settles. 004's argument is withdrawn with the
// readings it produced: ENV_GRIPPER's +/-30.250 in x and z about z = -2.000 is
// the gripper cover's own section about the tool axis, which begins at the J5
// station and runs out to the tool, and it bounds no plate of Body A's.
//
// WHERE THAT LEAVES THE COVERS. Body A lands inside no measured cover box. The
// forearm skin holds it across the arm with 6.5335 mm to spare and stops
// 30.500 mm short of its far end; the two wrist boxes stop 17.891 mm and
// 18.284 mm below its top. Rule 1 above decides which of the two to place it
// by. What the covers then measure is either a revision the printed
// differential does not match -- as the Main Pivot's and the Arm Body's already
// are -- or a cover the measured set is missing, and the echoes report it
// rather than absorbing it.
//
// THE L3 GAP, WHICH THE LANDING RESHAPES. The forearm's far end is open. The
// End Arm Hub's tube spigot and the 243 mm C-505 tube put the tube's far face
// 36.000 mm short of the J4 station, and no part in the model set closes that
// span: specs/009 DC-11(h). Of those 36.000 mm, Body A's spigot now occupies
// the last 11.500 and 24.500 mm are open air. What closes them carries no
// step across the arm -- the 18.000 mm of step the span was drawn with belonged
// to a withdrawn reading -- and both its ends are female over male, since the
// tube's 20.07 mm bore is what laps the hub's plug and Body A's is that same
// plug. Lapping this end by the 16.0 mm C-505 laps the other asks for 283.5 mm
// of tube against the 243.0 mm specified, so whether the span wants a part or a
// longer cut is DC-11(h)'s to settle and not this file's. The open 24.500 mm is
// drawn as a marked void on the tube's own section, and it is the one thing
// here drawn because it is absent.
//
// RENDERING IT. A preview needs nothing but this file. A full render asks CGAL
// for a closed solid of everything drawn, the nine meshes 700-Differential/
// imports included, so it needs the cache 700-Differential/render-meshes.rs
// writes, which makes each mesh renderable as it goes: that script's header
// says why a mesh that previews correctly can still stop a render, and running
// it is the one step this file cannot take for itself. Expect minutes rather
// than seconds either way, since a render converts every imported mesh.

include <BOSL2/std.scad>

// The differential subassembly, for place_differential(). `use` imports its
// modules and diff_centre() without firing its own top-level call, echoes or
// asserts, and leaves its mesh paths resolving against its own directory.
use <700-Differential/diff_assembly.scad>

/* [View] */
// The differential subassembly, on the landing WRIST_BASIS states.
show_differential = true;
// Printed parts, from the group directories.
show_parts = true;
// Carbon fibre tube stock, drawn from its catalogued section and cut length.
show_stock = true;
// Joint stations and axes.
show_frame = true;
// Cover envelopes, as boxes from the CAD bodies' measured extents.
show_envelopes = true;
// The span no part closes.
show_gap = true;

/* [Hidden] */
$fn = 64;

// ---------------------------------------------------------------------------
// The joint stations, from specs/003 § Link lengths. Each is the origin of a
// DexterHDI_Link<n>_KinematicAssembly node in dde/HDIMeterModel.gltf, and the
// along-arm differences between them are L1..L5. A station is a frame origin
// on its axis, not the axis itself, and at the wrist it is not even that —
// specs/004 § Differential interface records that the J4 and J5 axes intersect
// while these two stations do not lie on one line. Nothing below is placed by
// a station; they are drawn so that what IS placed can be read against them.
// ---------------------------------------------------------------------------
BASE_STN = [0,        0.0000,   0.000];
J1_STN   = [0,      193.7000,   0.000];   // MainPivot_KinematicAssembly
J2_STN   = [0,      231.2000,  55.000];
J3_STN   = [0,      570.2945,  65.000];
J4_STN   = [0,      877.7945,  18.000];
J5_STN   = [0,      917.2945,  -2.000];
TOOL_STN = [54.815, 939.8440,  -2.000];   // Link6, the tool roll frame

// ---------------------------------------------------------------------------
// The wrist frame — see THE WRIST LANDING above.
//
// WRIST_C is where the J4 and J5 axes cross. The J5 station lies on the J5
// axis, which runs along x, so the crossing shares that station's y and z; the
// arm is symmetric about x = 0 and the J4 axis is on that plane, which gives
// the third coordinate. No new number: it is the J5 station.
//
// WRIST_BASIS says where the differential frame's own x, y and z go in this
// one. Its first row is the spigot's — that frame's -x runs back down the
// forearm — and its third is the End Pulley's, which sends the J4 axis onto -z.
// The second is the cross product of those two, so the basis is a proper
// rotation and no measured row was fitted to make it one.
// ---------------------------------------------------------------------------
WRIST_C = J5_STN;

WRIST_BASIS = [[0, 1, 0], [1, 0, 0], [0, 0, -1]];

// A differential-frame vector, and a differential-frame point, in this frame.
function wrist_vec(v) = v.x * WRIST_BASIS[0] + v.y * WRIST_BASIS[1] +
                        v.z * WRIST_BASIS[2];
function wrist_pt(p) = WRIST_C + wrist_vec(p - diff_centre());

// The same rotation as a matrix, so the geometry and the echoes below are
// placed by one definition rather than by two that have to agree.
function wrist_matrix() = [
    [WRIST_BASIS[0].x, WRIST_BASIS[1].x, WRIST_BASIS[2].x, 0],
    [WRIST_BASIS[0].y, WRIST_BASIS[1].y, WRIST_BASIS[2].y, 0],
    [WRIST_BASIS[0].z, WRIST_BASIS[1].z, WRIST_BASIS[2].z, 0],
    [               0,                0,                0, 1]];

// A box's extents in this frame, from its eight corners.
function wrist_box(b) =
    let (c = [for (x = [b[0].x, b[1].x], y = [b[0].y, b[1].y],
                   z = [b[0].z, b[1].z]) wrist_pt([x, y, z])])
    [[min([for (p = c) p.x]), min([for (p = c) p.y]), min([for (p = c) p.z])],
     [max([for (p = c) p.x]), max([for (p = c) p.y]), max([for (p = c) p.z])]];

// Two parts of the differential, as it places them, carried into this frame.
// They position nothing — they are what the echoes measure the landing by.
// Diff Body A is the part that does not pivot with J4, so it is the part the
// forearm has to reach; the Diff End Pulley is where a belt from the elbow
// lands, so which way it faces says which side the belts run on. Both boxes
// come from diff_assembly.scad, which owns where in its frame each one sits.
BODY_A_W = wrist_box(diff_body_a_box());
PULLEY_W = wrist_box(diff_end_pulley_box());

// Body A's spigot axis, the feature the landing is fixed by, carried here from
// the point diff_assembly.scad states it on. ARM_TIP_Y is the spigot's tip,
// which is Body A's -x end and so the box's near face along the arm.
ARM_AXIS  = wrist_pt(diff_arm_axis());
ARM_TIP_Y = BODY_A_W[0].y;

// Whether the first box lies inside the second, and by how little.
function box_inside(a, b) =
    a[0].x >= b[0].x && a[0].y >= b[0].y && a[0].z >= b[0].z &&
    a[1].x <= b[1].x && a[1].y <= b[1].y && a[1].z <= b[1].z;
function box_slack(a, b) =
    min([a[0].x - b[0].x, a[0].y - b[0].y, a[0].z - b[0].z,
         b[1].x - a[1].x, b[1].y - a[1].y, b[1].z - a[1].z]);

// ---------------------------------------------------------------------------
// Carbon fibre tube stock (specs/007.1 §5).
//
// C-504, the L2 tube: 1.032 inch inside, .050 inch wall, so 28.75 mm outside.
// Its near face bottoms in the Arm Body's 29.000 x 29.000 socket, whose floor
// stands 37.513 mm from the J2 axis, and it is cut 264.0 mm. That lands its
// far face 0.082 mm short of the Axis Intersection Half's blind channel at
// 37.500 mm from the J3 axis, which is the residue C-504 records.
//
// C-505, the L3 tube: 22.0 mm outside, 20.07 mm inside, cut 243.0 mm. It
// slides OVER the End Arm Hub's 20 x 20 R4 spigot and butts a counterbore
// floor 28.500 mm from the J3 axis.
// ---------------------------------------------------------------------------
L2_TUBE_OD  = 28.75;
L2_TUBE_ID  = 26.21;
L2_TUBE_LEN = 264.0;
L2_TUBE_Y0  = J2_STN.y + 37.513;        // the Arm Body socket floor
L2_TUBE_Z   = 89.750;                   // the socket's own centre, measured

L3_TUBE_OD  = 22.00;
L3_TUBE_ID  = 20.07;
L3_TUBE_LEN = 243.0;
L3_TUBE_Y0  = J3_STN.y + 28.500;        // the End Arm Hub counterbore floor
L3_TUBE_Z   = 36.000;                   // the hub's spigot axis, measured

L3_TUBE_Y1  = L3_TUBE_Y0 + L3_TUBE_LEN; // 841.795
L3_GAP      = J4_STN.y - L3_TUBE_Y1;    // 36.000: C-505's own figure
L3_OPEN     = ARM_TIP_Y - L3_TUBE_Y1;   // 24.4995 of it with nothing in it
L3_LAP      = 16.0;                     // what C-505 laps the hub's plug by

// ---------------------------------------------------------------------------
// Cover envelopes, as world extents measured on the CAD bodies. These are not
// printed parts and no model of them is in this repository; they are drawn as
// boxes because where the covers are is what says where the mechanism they
// enclose has to be. Each entry is [min, max].
// ---------------------------------------------------------------------------
ENV_DIFF_COVER = [[-38.998, 838.795, -32.500], [38.992, 912.295, 18.000]];
ENV_DIFF_CAP   = [[-35.000, 912.295, -32.250], [33.477, 921.795, 28.643]];
ENV_GRIPPER    = [[-30.250, 917.295, -32.250], [54.815, 970.795, 28.250]];
ENV_L3_SKIN    = [[-38.963, 534.795,  18.000], [38.963, 916.795, 65.001]];
ENV_J3_COVER   = [[-45.346, 551.200,  65.996], [45.346, 616.842, 153.000]];

// Colours by role, as in diff_assembly.scad.
PRINT_C  = [0.72, 0.74, 0.78];
CARBON_C = [0.16, 0.16, 0.18];
FRAME_C  = [0.90, 0.75, 0.20];
ENV_C    = [0.45, 0.55, 0.70, 0.22];
GAP_C    = [0.85, 0.25, 0.25, 0.45];

// ---------------------------------------------------------------------------
// The printed parts.
//
// Each module states the transform that carries the model's own frame into
// this one, and the feature that fixes it. A transform derived only from a
// bounding box says so.
// ---------------------------------------------------------------------------

// Base group. All three sit on the J1 axis, which is this frame's y, and each
// model is drawn with that axis on its own z — so one quarter turn about x
// serves all three and only the height along the arm differs. The heights are
// the CAD bodies' own: the base mount's foot on y = 0, the clamp's underside
// on y = 82.000, the long member's on y = 98.000.
module place_base() {
    color(PRINT_C) {
        xrot(-90) import("100-Base/110-001_BaseMountBottom.stl", convexity = 8);
        back( 82) xrot(-90) import("100-Base/100-001_BaseClamp.stl", convexity = 8);
        back(126) xrot(-90) import("100-Base/120-001_BaseLong.stl", convexity = 8);
    }
}

// Main Pivot. Its own z is the J1 axis and its own x is this frame's z: the
// model spans x -32.500..55.000 and the CAD body spans z -32.500..55.000, the
// same two numbers, which is what identifies the mapping. Placed with its base
// plane on the J1 station.
//
// The model is 6.5 mm taller along the J1 axis than the CAD body (71.500
// against 65.000) and 4.0 mm narrower across the arm (67.965 against 72.000),
// and the CAD body is not symmetric about the arm plane while the model is.
// Two revisions of one part. It is placed on the mating plane — the J1
// station, where it meets the long member — so the difference shows at the far
// end instead of being split between the two ends.
module place_main_pivot() {
    color(PRINT_C) back(J1_STN.y) xrot(-90) zrot(-90)
        import("300-Pivot/300-001_MainPivot.stl", convexity = 8);
}

// Arm Body. Already drawn in a frame parallel to this one: its own z is this
// frame's z and its own y = 0 is the J2 axis. The translation is the J2
// station's y with the CAD body's z = 62.000, and the part confirms it rather
// than being assumed into it — placed so, the model's low y face lands within
// 0.08 mm of the CAD body's, and its 29 x 29 socket lands on the L2 tube.
//
// The CAD body runs 23.4 mm further along the arm than the model. That end is
// the cone-drive boss, which the printed part does not carry.
module place_arm_body() {
    color(PRINT_C) translate([0, J2_STN.y, 62.000])
        import("200-ArmBody/200-001_ArmBody.stl", convexity = 8);
}

// End Arm group. The models in 400-EndArm/ that sit on the J3 axis share one
// frame, which is what lets one transform place them all: each is centred on
// its own (x, y) = (0, 0) to within 0.01 mm, and the hub — which is not,
// because its spigot runs out along the arm — puts that same origin on the J3
// axis.
//
// The transform is fixed by the hub and checked by two of its features. The
// model's x is this frame's y and its z is this frame's z, so the mapping is a
// quarter turn about z; the offsets follow from the CAD body's extents. Placed
// that way the hub's own x = 0 lands on the J3 station and its spigot axis, at
// its own z = -25.000, lands on z = 36.000 — which is where specs/004
// § Differential interface independently puts the L3 tube.
//
// 410-001_AxisIntersectionHalf is NOT in this frame and is not drawn here; see
// UNPLACED.
module in_end_arm() { translate([0, J3_STN.y, 61.000]) zrot(90) children(); }

module place_end_arm() {
    color(PRINT_C) in_end_arm() {
        import("400-EndArm/420-001_EndArmHub.stl", convexity = 8);
        import("400-EndArm/421-001_InternalOuterPulley.stl", convexity = 8);
        import("400-EndArm/421-002_InternalInnerPulley.stl", convexity = 8);
        import("400-EndArm/430-001_ExternalOuterPulley.stl", convexity = 8);
        import("400-EndArm/430-002_ExternalInnerPulley.stl", convexity = 8);
    }
}

// The differential. The transform is the one wrist_matrix states and nothing
// more: carry the assembly's own diff_centre() to the origin, turn it, and set
// that point down on WRIST_C. Its nine parts, their bearings and their clocking
// are that file's business, not this one's.
module in_diff() {
    translate(WRIST_C) multmatrix(wrist_matrix())
        translate(-diff_centre()) children();
}

module place_differential() { in_diff() diff_assembly(); }

// ---------------------------------------------------------------------------
// Structural stock.
// ---------------------------------------------------------------------------
module square_tube(od, id, len) {
    difference() {
        cuboid([od, od, len], anchor = BOTTOM, rounding = 2, edges = "Z");
        cuboid([id, id, len + 2], anchor = BOTTOM);
    }
}

module place_stock() {
    color(CARBON_C) {
        // C-504, the L2 span.
        translate([0, L2_TUBE_Y0, L2_TUBE_Z]) xrot(-90)
            square_tube(L2_TUBE_OD, L2_TUBE_ID, L2_TUBE_LEN);
        // C-505, the L3 span.
        translate([0, L3_TUBE_Y0, L3_TUBE_Z]) xrot(-90)
            square_tube(L3_TUBE_OD, L3_TUBE_ID, L3_TUBE_LEN);
    }
}

// ---------------------------------------------------------------------------
// The frame, and the gap.
// ---------------------------------------------------------------------------
module station(p, axis) {
    translate(p) {
        color(FRAME_C) sphere(d = 6);
        color([FRAME_C.x, FRAME_C.y, FRAME_C.z, 0.5])
            rot(from = UP, to = axis) cyl(d = 2, l = 180);
    }
}

// The J4 station's axis is drawn from the landing rather than from a record, so
// that the line and the differential cannot disagree: it is where WRIST_BASIS
// sends the differential frame's own J4 axis.
module place_frame() {
    station(BASE_STN, BACK);
    station(J1_STN, BACK);
    station(J2_STN, UP);
    station(J3_STN, UP);
    station(J4_STN, wrist_vec([0, 0, 1]));
    station(J5_STN, RIGHT);
    station(TOOL_STN, RIGHT);
}

module envelope(e) {
    color(ENV_C) translate(e[0])
        cube([e[1].x - e[0].x, e[1].y - e[0].y, e[1].z - e[0].z]);
}

module place_envelopes() {
    envelope(ENV_DIFF_COVER);
    envelope(ENV_DIFF_CAP);
    envelope(ENV_GRIPPER);
    envelope(ENV_L3_SKIN);
    envelope(ENV_J3_COVER);
}

// The open span between the L3 tube's far face and Body A's spigot tip, drawn
// on the tube's own section because both of its ends now carry that section.
//
// What belongs here is bounded on four sides even though no model of it exists.
// It takes the 22.0 mm tube on (x = 0, z = 36.000) from y no further than
// 841.795, and it presents the spigot 24.500 mm later on (x = 0, z = 35.5335)
// — the two axes 0.4665 mm apart, so the part is a straight coaxial joint and
// carries no step. Both ends it meets are male, and both are the same male:
// C-505's bore is what laps them. And it is covered by ENV_L3_SKIN, which holds
// the span in x and z with room to spare; ENV_DIFF_COVER is not its cover, that
// box stopping at z = 18.000, well below this axis.
//
// None of the part is drawn, because none of its geometry is known — only where
// it has to begin, where it has to end, and what it has to fit inside.
module place_gap() {
    color(GAP_C) translate([0, L3_TUBE_Y1, L3_TUBE_Z]) xrot(-90)
        cuboid([L3_TUBE_OD, L3_TUBE_OD, L3_OPEN], anchor = BOTTOM);
}

// ---------------------------------------------------------------------------
// The arm.
// ---------------------------------------------------------------------------
module arm() {
    if (show_parts) {
        place_base();
        place_main_pivot();
        place_arm_body();
        place_end_arm();
        if (show_differential) place_differential();
    }
    if (show_stock)     place_stock();
    if (show_frame)     place_frame();
    if (show_envelopes) place_envelopes();
    if (show_gap)       place_gap();
}

arm();

// ---------------------------------------------------------------------------
// UNPLACED. What the arm needs and this file does not draw, with the reason.
// A part leaves this list when a feature is found that fixes it, not when a
// position is chosen that looks right.
// ---------------------------------------------------------------------------
UNPLACED = [
  ["#410-001 Axis Intersection Half x2",
   "holds the L2 tube's far end 37.500 mm from the J3 axis, but its model is not in the End Arm group's frame and its own channel has not been located"],
  ["#100-002, #300-002, #410-003 code disks",
   "each on its joint's axis, but the seat that sets its height is unmeasured"],
  ["600-StrainWave, stator holders, motor end caps",
   "the drives at J1, J2 and J3; no mating feature measured yet"],
  ["500-ExternalGear, 6 parts",
   "the CAD body places the mount low on the base, well off the arm axis; the model's frame has not been matched to it"],
  ["800-Harness 18 parts, 900-ToolInterface, 950-Tooling",
   "harness, gripper and build fixtures"],
];

echo(str("robot_assembly: J2..J3 = ", J3_STN.y - J2_STN.y,
         "  J3..J4 = ", J4_STN.y - J3_STN.y,
         "  J4..J5 = ", J5_STN.y - J4_STN.y, " mm along the arm"));
echo(str("L2 tube ", L2_TUBE_Y0, "..", L2_TUBE_Y0 + L2_TUBE_LEN,
         " on z=", L2_TUBE_Z, ";  L3 tube ", L3_TUBE_Y0, "..", L3_TUBE_Y1,
         " on z=", L3_TUBE_Z));
echo(str("L3 gap: ", L3_GAP, " mm along the arm from the tube's far face to the J4 station; ",
         L3_OPEN, " of it open, the rest Body A's spigot. DC-11(h)."));
for (u = UNPLACED) echo(str("UNPLACED: ", u[0], " - ", u[1]));

// The landing, reported against the features that fix it and the records that
// bear on it. Every figure comes through wrist_box, so this measures the
// geometry that is drawn rather than calculating it a second time, and it moves
// if the placement does.
echo(str("wrist landing: J4 axis along ", wrist_vec([0, 0, 1]), " through ", WRIST_C,
         "; Diff Body A ", BODY_A_W[0], "..", BODY_A_W[1],
         "; End Pulley ", PULLEY_W[0], "..", PULLEY_W[1]));
echo(str("  spigot axis on (x=", ARM_AXIS.x, ", z=", ARM_AXIS.z, ") against the L3 tube's z=",
         L3_TUBE_Z, " — coaxial to ", L3_TUBE_Z - ARM_AXIS.z, " mm"));
echo(str("  spigot tip at y ", ARM_TIP_Y, ", tube far face at ", L3_TUBE_Y1,
         " — ", L3_OPEN, " mm open; a ", L3_LAP, " mm lap here wants ",
         ARM_TIP_Y + L3_LAP - L3_TUBE_Y0, " mm of tube against ", L3_TUBE_LEN));
for (e = [["ENV_DIFF_COVER", ENV_DIFF_COVER], ["ENV_DIFF_CAP", ENV_DIFF_CAP],
          ["ENV_GRIPPER", ENV_GRIPPER], ["ENV_L3_SKIN", ENV_L3_SKIN]])
    echo(str("  Diff Body A vs ", e[0], ": ",
             box_inside(BODY_A_W, e[1])
             ? str("inside by ", box_slack(BODY_A_W, e[1]), " mm")
             : str("NOT inside, worst face ", box_slack(BODY_A_W, e[1]), " mm")));

assert(abs(L3_GAP - 36.000) < 0.001,
       "the L3 gap is C-505's own figure; if it moved, a cut length moved with it");
// WRIST_C must lie on the J5 axis. A frame edit that moved it would turn the
// differential about a line the J5 station is not on.
assert(WRIST_C.y == J5_STN.y && WRIST_C.z == J5_STN.z,
       "the J4/J5 crossing must sit on the J5 axis");
// The landing is fixed by Body A's spigot being the L3 tube's far end, so the
// two have to stay coaxial. They measure 0.4665 mm apart, which is a residual;
// a window ten times that passes it and fires on anything that is not one.
assert(abs(ARM_AXIS.z - L3_TUBE_Z) < 5.0 && abs(ARM_AXIS.x) < 0.001,
       "Body A's spigot has left the L3 tube's axis — WRIST_BASIS is what places it");
// And the spigot must point back down the arm, not out past the wrist: its tip
// is the near face along y, and it has to fall short of the plate it grows from.
assert(ARM_TIP_Y < WRIST_C.y && L3_OPEN > 0,
       "Body A's spigot must face the elbow, with the L3 tube short of its tip");
