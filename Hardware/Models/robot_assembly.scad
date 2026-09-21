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
// The three pitch axes J2, J3 and J4 run along z. J1 runs along y. J5 runs
// along x, out through the tool arm.
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
// THE J4 AXIS IS NOT SETTLED, and the differential is not drawn until it is.
// Two records in the spec set imply perpendicular answers, and the shape of
// the missing part depends on which holds.
//
//   Along z, with J2 and J3. specs/003 § DH model reads the J3 row's
//   alpha = 0.8072 deg off a calibrated unit, which says the J3 and J4 axes
//   are parallel, and states it in words. J3 runs along z: the four End Arm
//   pulleys share one axis on this frame's z, and the hub that carries them
//   puts its L3 spigot perpendicular to it at z = 36.000, where specs/004
//   independently puts the tube.
//
//   Along y, down the forearm. specs/004 § Differential interface fits Diff
//   Body A to the gripper covers by its Ø60 top plate's 29.988 mm tessellated
//   radius, which bounds cover x at -30.250 AND cover z at -32.250/+28.250
//   about z = -2.000. A radius bounds two directions at once only if the plate
//   lies in this frame's x-z plane -- which puts its normal, the J4 axis,
//   along y, through (x = 0, z = -2.000). That is also the J5 station's z, so
//   the two axes would intersect there, as a bevel differential requires.
//
// Neither reading is adopted here. Drawing the differential would pick one
// silently, which is the one thing this file is built not to do.
//
// THE L3 GAP. The forearm's far end is open. The End Arm Hub's tube spigot and
// the 243 mm C-505 tube put the tube's far face 36.000 mm short of the J4
// station, and no part in the model set closes that span: specs/009 DC-11(h).
// This file draws the gap as a marked void, sized and positioned from those
// same two measurements, so the missing part's envelope can be seen instead of
// inferred. It is the one thing here drawn because it is absent.

include <BOSL2/std.scad>

/* [View] */
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
L3_GAP      = J4_STN.y - L3_TUBE_Y1;    // 36.000, and nothing fills it

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

module place_frame() {
    station(BASE_STN, BACK);
    station(J1_STN, BACK);
    station(J2_STN, UP);
    station(J3_STN, UP);
    station(J4_STN, UP);
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

// The span between the L3 tube's far face and the J4 station, drawn on the
// tube's own section because the tube is the one end of it that exists.
//
// What belongs here is bounded on three sides even though no model of it
// exists. It takes the 22.0 mm tube on (x = 0, z = 36.000) from y no further
// than 841.795. It carries 18.000 mm of step across the arm, from that tube
// axis down to the J4 station's z = 18.000. And it is covered: ENV_DIFF_COVER
// is that cover, its top face lands on z = 18.000, and a section taken 1 mm
// under that face centres on the J4 station's y to 0.07 mm. The cover's
// interior is the room the part has.
//
// None of the part is drawn, because none of its geometry is known -- only
// where it has to begin, where it has to end, and what it has to fit inside.
module place_gap() {
    color(GAP_C) translate([0, L3_TUBE_Y1, L3_TUBE_Z]) xrot(-90)
        cuboid([L3_TUBE_OD, L3_TUBE_OD, L3_GAP], anchor = BOTTOM);
}

// ---------------------------------------------------------------------------
if (show_parts) {
    place_base();
    place_main_pivot();
    place_arm_body();
    place_end_arm();
}
if (show_stock)     place_stock();
if (show_frame)     place_frame();
if (show_envelopes) place_envelopes();
if (show_gap)       place_gap();

// ---------------------------------------------------------------------------
// UNPLACED. What the arm needs and this file does not draw, with the reason.
// A part leaves this list when a feature is found that fixes it, not when a
// position is chosen that looks right.
// ---------------------------------------------------------------------------
UNPLACED = [
  ["#410-001 Axis Intersection Half x2",
   "holds the L2 tube's far end 37.500 mm from the J3 axis, but its model is not in the End Arm group's frame and its own channel has not been located"],
  ["700-Differential, 9 parts",
   "has a subassembly model, but nothing fixes where it sits on the arm, and the two records that bear on which way its J4 axis points disagree - see THE J4 AXIS IS NOT SETTLED"],
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
echo(str("L3 gap: ", L3_GAP, " mm along the arm from the tube's far face to the J4 station, ",
         L3_TUBE_Z - J4_STN.z, " mm down across it. DC-11(h)."));
for (u = UNPLACED) echo(str("UNPLACED: ", u[0], " - ", u[1]));

assert(abs(L3_GAP - 36.000) < 0.001,
       "the L3 gap is C-505's own figure; if it moved, a cut length moved with it");
