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
// tool arm. Which way J4 runs is the open question below, and this file does
// not presuppose it.
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
// THE J4 AXIS IS NOT SETTLED, SO EVERY READING IS DRAWN. Two records in the
// spec set imply perpendicular answers, and the shape of the missing part
// depends on which holds. Drawing one of them would adopt it silently, so the
// arm is drawn once per live reading, side by side along x. The `wrist`
// parameter selects one, or all of them.
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
// WHAT THE TWO READINGS SHARE, which is why they can be drawn as one variable.
// Both hold that the J4 and J5 axes intersect, because a bevel differential
// has no other option, and 700-Differential/diff_assembly.scad asserts it of
// its own frame. So both place that assembly by its diff_centre() -- the one
// point both its axes pass through -- and both put that point where the J5
// axis is: along x through the J5 station's (y, z), at x = 0 by the arm's
// symmetry. Both also send the differential frame's -x out to this frame's +x,
// because Diff Body A's arm runs out along that -x and the tool is on +x.
// What is left is one quarter turn about the J5 axis, and that turn IS the
// question: it carries the J4 axis onto z or onto y and nothing else changes.
//
// WHY THREE ARMS AND NOT TWO. The quarter turn has four landings, not two:
// the J4 axis can go onto +z, -z, +y or -y. Three of them are worth drawing.
//
//   j4_plus_z is specs/003's reading in J3's own sense, since 003 says the two
//   axes are parallel and J3 is drawn along +z here. j4_minus_z is the same
//   reading mirrored and tests the same thing, so it is echoed, not drawn.
//
//   j4_plus_y and j4_minus_y are both specs/004's reading, and 004's argument
//   does not choose between them. Its radius bounds the Ø60 plate's x and z,
//   and the plate lands at x +/-30.000 and z -32.000..28.000 about
//   (x = 0, z = -2.000) in BOTH -- identically, because the two differ only
//   along y, which a radius in the x-z plane says nothing about.
//
// WHAT THE DRAWING SETTLES. z against y, and by the argument specs/004 makes
// rather than by a preference: a disc of one radius can bound this frame's x
// and z together only if its normal is y. Under either z landing the same disc
// bounds x and y instead, and the echoes show what follows -- Diff Body A ends
// up 30 to 46 mm clear of every cover across the arm, where under either y
// landing it lands in the covers' own x and z to a quarter of a millimetre.
//
// WHAT IT DOES NOT SETTLE, and what the third arm is for. Which way along y.
// The two y landings put Body A 75.067 mm apart along the arm and each has a
// record behind it:
//
//   j4_minus_y puts Body A at y 943.828..965.828, inside ENV_GRIPPER on every
//   face with 0.25 mm to spare on three of them. specs/004 says Body A is
//   enclosed by the HDI-950 gripper covers, and this is the landing that
//   satisfies it.
//
//   j4_plus_y puts Body A at y 868.761..890.761, whose near face stands
//   26.967 mm past the L3 tube's. That is the span DC-11(h)'s missing part has
//   to close, and it is the size of a part. Under j4_minus_y the same span is
//   102.034 mm with Diff Body B standing in it, and Body B pivots with J4, so
//   nothing static can cross it. The Diff End Pulley divides the same way:
//   j4_plus_y lands it at y 886.261..896.511, facing the forearm a belt would
//   come down, and j4_minus_y at y 938.078..948.328, facing the tool, which
//   asks the belts to pass the differential before they reach it.
//
// Neither landing is adopted. Adopting one is a spec edit, not a model edit;
// this file draws all three and reports what each measures.
//
// THE L3 GAP. The forearm's far end is open. The End Arm Hub's tube spigot and
// the 243 mm C-505 tube put the tube's far face 36.000 mm short of the J4
// station, and no part in the model set closes that span: specs/009 DC-11(h).
// This file draws the gap as a marked void, sized and positioned from those
// same two measurements, so the missing part's envelope can be seen instead of
// inferred. It is the one thing here drawn because it is absent.

include <BOSL2/std.scad>

// The differential subassembly, for place_differential(). `use` imports its
// modules and diff_centre() without firing its own top-level call, echoes or
// asserts, and leaves its mesh paths resolving against its own directory.
use <700-Differential/diff_assembly.scad>

/* [Wrist] */
// Which way the J4 axis is taken to run — see THE J4 AXIS IS NOT SETTLED.
// "all" draws one arm per live landing, ARM_PITCH apart along x, in the order
// WRIST_DRAWN lists them. "neither" leaves the differential out.
wrist = "all";      // [all, j4_plus_z, j4_minus_z, j4_plus_y, j4_minus_y, neither]
// Separation between arms when more than one is drawn. Clears the widest
// cover, ENV_J3_COVER at x +/-45.346, with room to see between them.
ARM_PITCH = 200;
// Name each arm under its base, so a view of both says which is which.
show_labels = true;

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
// The wrist frame, every way it can land — see THE J4 AXIS IS NOT SETTLED.
//
// WRIST_C is where the J4 and J5 axes cross. The J5 station lies on the J5
// axis, which runs along x, so the crossing shares that station's y and z; the
// arm is symmetric about x = 0 and the J4 axis is on that plane, which gives
// the third coordinate. No new number: it is the J5 station.
//
// basis_for says where the differential frame's own x, y and z go in this one,
// and it is the whole of the difference between the landings. All four rows
// send that frame's x onto -x, which is the half turn Body A's arm fixes; they
// differ only in where its z — the J4 axis — goes. All four are proper
// rotations, each row being the cross product of the two beside it.
// ---------------------------------------------------------------------------
WRIST_C = J5_STN;

WRIST_DIRS = ["j4_plus_z", "j4_minus_z", "j4_plus_y", "j4_minus_y"];

// The landings worth looking at, left to right. j4_minus_z is left out
// because it tests exactly what j4_plus_z tests; it is still echoed.
WRIST_DRAWN = ["j4_plus_z", "j4_plus_y", "j4_minus_y"];

function basis_for(dir) =
    dir == "j4_minus_y" ? [[-1, 0, 0], [0,  0, -1], [0, -1,  0]] :
    dir == "j4_plus_y"  ? [[-1, 0, 0], [0,  0,  1], [0,  1,  0]] :
    dir == "j4_minus_z" ? [[-1, 0, 0], [0,  1,  0], [0,  0, -1]] :
                          [[-1, 0, 0], [0, -1,  0], [0,  0,  1]];

// A differential-frame vector, and a differential-frame point, in this frame.
function wrist_vec(dir, v) = let (b = basis_for(dir))
    v.x * b[0] + v.y * b[1] + v.z * b[2];
function wrist_pt(dir, p) = WRIST_C + wrist_vec(dir, p - diff_centre());

// The same rotation as a matrix, so the geometry and the echoes below are
// placed by one definition rather than by two that have to agree.
function wrist_matrix(dir) = let (b = basis_for(dir)) [
    [b[0].x, b[1].x, b[2].x, 0],
    [b[0].y, b[1].y, b[2].y, 0],
    [b[0].z, b[1].z, b[2].z, 0],
    [      0,      0,      0, 1]];

// Two parts' extents in the frame 700-Differential/diff_assembly.scad places
// them in, from their meshes. These are the only measurements this file takes
// from inside that assembly and they position nothing: they are here so the
// echoes can carry them into this frame and say where each landing puts them.
//
// Diff Body A is the part that does not pivot with J4, so it is the part the
// forearm has to reach and the part specs/004 places inside a cover. The Diff
// End Pulley is where a belt from the elbow lands, so which way it faces says
// which way the belts would have to run.
BODY_A_D = [[-51.000, -30.000,  0.000], [30.000, 30.000, 22.000]];
PULLEY_D = [[-13.000, -13.000, 17.500], [13.000, 13.000, 27.750]];

// A box's extents in this frame, from its eight corners.
function wrist_box(dir, b) =
    let (c = [for (x = [b[0].x, b[1].x], y = [b[0].y, b[1].y],
                   z = [b[0].z, b[1].z]) wrist_pt(dir, [x, y, z])])
    [[min([for (p = c) p.x]), min([for (p = c) p.y]), min([for (p = c) p.z])],
     [max([for (p = c) p.x]), max([for (p = c) p.y]), max([for (p = c) p.z])]];

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

// The differential, in whichever reading `w` names. The transform is the one
// wrist_matrix states and nothing more: carry the assembly's own diff_centre()
// to the origin, turn it, and set that point down on WRIST_C. Its nine parts,
// their bearings and their clocking are that file's business, not this one's.
module in_diff(dir) {
    translate(WRIST_C) multmatrix(wrist_matrix(dir))
        translate(-diff_centre()) children();
}

module place_differential(dir) { in_diff(dir) diff_assembly(); }

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

// The J4 station's axis comes from the landing rather than from a record,
// because which way it points is the whole question. It is the landing's own
// third basis vector, so the line and the differential cannot disagree.
module place_frame(dir) {
    station(BASE_STN, BACK);
    station(J1_STN, BACK);
    station(J2_STN, UP);
    station(J3_STN, UP);
    station(J4_STN, dir == "neither" ? UP : basis_for(dir)[2]);
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
// One arm, in the reading `w` names. Everything but the differential and the
// J4 station's axis is the same in both, and is drawn from the same numbers.
// ---------------------------------------------------------------------------
module arm(dir) {
    if (show_parts) {
        place_base();
        place_main_pivot();
        place_arm_body();
        place_end_arm();
        if (dir != "neither") place_differential(dir);
    }
    if (show_stock)     place_stock();
    if (show_frame)     place_frame(dir);
    if (show_envelopes) place_envelopes();
    if (show_gap)       place_gap();
    if (show_labels)    label(dir);
}

// The reading's name, under the base and flat in the x-y plane, so a view down
// z reads it. Drawn at the base end because that is the end the two arms have
// in common, and a label at the wrist would sit inside the geometry it names.
module label(dir) {
    color(FRAME_C) translate([0, -70, 0]) linear_extrude(1)
        text(dir, size = 16, halign = "center");
}

// ---------------------------------------------------------------------------
if (wrist == "all")
    for (i = [0 : len(WRIST_DRAWN) - 1])
        right((i - (len(WRIST_DRAWN) - 1) / 2) * ARM_PITCH) arm(WRIST_DRAWN[i]);
else arm(wrist);

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
echo(str("L3 gap: ", L3_GAP, " mm along the arm from the tube's far face to the J4 station, ",
         L3_TUBE_Z - J4_STN.z, " mm down across it. DC-11(h)."));
for (u = UNPLACED) echo(str("UNPLACED: ", u[0], " - ", u[1]));

// Where each landing puts Diff Body A, against the two records that bear on
// it: the cover specs/004 § Differential interface says encloses it, and the
// span from the L3 tube's far face that DC-11(h)'s missing part has to close.
// The transform is wrist_matrix's, so this reports the geometry that is drawn
// rather than a second calculation of it, and it moves if the placement does.
for (dir = WRIST_DIRS)
    let (a = wrist_box(dir, BODY_A_D), p = wrist_box(dir, PULLEY_D))
    echo(str(dir, ": Diff Body A ", a[0], "..", a[1],
             box_inside(a, ENV_GRIPPER)
             ? str(" - inside ENV_GRIPPER by ", box_slack(a, ENV_GRIPPER), " mm")
             : " - NOT inside ENV_GRIPPER",
             "; L3 tube far face to its near y = ", a[0].y - L3_TUBE_Y1,
             "; End Pulley at y ", p[0].y, "..", p[1].y, " mm"));

assert(abs(L3_GAP - 36.000) < 0.001,
       "the L3 gap is C-505's own figure; if it moved, a cut length moved with it");
// WRIST_C must lie on the J5 axis, which is what makes the two readings differ
// by a turn about that axis and nothing else. A frame edit that moved it would
// make the pair of pictures a comparison of two different things.
assert(WRIST_C.y == J5_STN.y && WRIST_C.z == J5_STN.z,
       "the J4/J5 crossing must sit on the J5 axis in both readings");
