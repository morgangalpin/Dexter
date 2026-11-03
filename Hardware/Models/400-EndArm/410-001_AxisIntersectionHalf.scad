// #410-001 Axis Intersection Half — parametric source.
// One of the two mirrored halves that make the elbow's axis intersection: each
// holds a 6807 the New Belt Pulley turns in (008.7 steps 1-2), and the two,
// bonded face to face at z 24 over four 48 mm C-502 strakes (steps 3-5), close
// a 29 x 29 channel round the L2 tube's end (C-504; 007.1 § C-504). Two are
// printed.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/400-EndArm/), in that mesh's
//                         frame.
//   config = "revised"  — the same part with its print fits drawn (FITS).
//
// FRAME. The J3 axis is +Z through the origin; z 0 is the outer face and z 24
// the face the other half bonds to. The L2 channel runs out along -Y, its
// blind end 37.5 from the axis. The reference mesh is already in this frame.
//
// CONSTRUCTION. Everything is a plan section extruded along Z (the
// mesh-to-scad ladder's rung 1), but for two 45 deg faces cut by primitive
// half-spaces (rung 2) and one chamfered section extruded along Y. The plan's
// envelope is H: the ring's circle and its two tangents running down to the
// channel's end (a hull of the circle and two far points on the tangents).
//
//     ring         z 0 .. 9      the circle, with the two posts
//     teardrop     z 0 .. 3      H within R1 about the axis, then a 45 deg cone
//                                out to R1 + 1 at the block's underside, z 4
//     block        z 4 .. 24     H, its underside cut by a 45 deg plane at the
//                                channel's end; above the ring (z 9) H less the
//                                circle, its cusp where each tangent leaves the
//                                circle rounded R0.5 by an opening (rung 5)
//     channel end  z 4 .. 24     the section [|x| <= 20, z 4 .. 24] with its two
//                                bottom edges chamfered 45 deg, along Y from the
//                                end to past where the tangents reach x +-20
//     posts        z 0 .. 24     on the +Y diagonals; above the ring, less the
//                                circle
//
// The bearing's bore and lip, the L2 half-channel and the four strake slots
// are cut through everything afterwards.
//
// Measured from the reference with scadmesh planes/slice/arcs/solid along each
// axis. The feature IDs are those of 410-001_AxisIntersectionHalf.view.json,
// which labels each one on the mesh:
//
//     ID  feature                     value
//     R1  ring                        R32.500 about the axis, z 0 .. 9
//     R2  6807 pocket                 Ø47.000, z 2 .. 9; open above
//     R3  lip                         Ø42.000, z 0 .. 2
//     E1  tangents (H)                tangent to R1 at 16.89 deg below +-X, down
//                                     to the channel's end, y -57.5
//     E2  teardrop                    H within R39.0, z 0 .. 3; a 45 deg cone to
//                                     R40.0 at z 4
//     E3  block's underside           z 4; under H, cut by the 45 deg plane
//                                     y + z = -42
//     E4  fins                        the cusp of H less R1 above z 9, R0.5
//     C1  L2 half-channel             29.0 wide (|x| <= 14.5), floor z 9.5, open
//                                     at z 24 and at the end y -57.5; blind end
//                                     at y -37.5
//     C2  channel end                 |x| <= 20.0 from y -57.5; its bottom edges
//                                     chamfered 45 deg from (16, 4) to (20, 8)
//     P1  posts, 2 on 54 and 126 deg  +-5.794 either side of the diagonal, out
//                                     to r 37.47, outer corners R3.0
//     S1  strake slots, 4 on +-54     5.637 tangential x 2.580 radial, centred
//         and +-126 deg               at r 34.016, through
//
// FITS (../print_fit.scad), revised only:
//
//     R2, on the 6807's Ø47 OD                      press; its floor at z 2 is
//                                                   the bearing's seat
//     S1, on the C-502 strake (2.337 x 5.588)       press. Radially the slot
//                                                   already stands 0.12 a side
//                                                   off the strip and keeps its
//                                                   size; tangentially it stands
//                                                   0.025 a side and opens
//     C1, round the C-504 tube (1.032" ID, .050"   the channel keeps the
//         wall: 28.75 outside)                      reference's 29.0; it already
//                                                   stands 0.125 off the tube
//
// The faces are bonded to the other half and to the strakes' ends: face
// contacts, which take no clearance.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or the plan section at a layer's middle
layer = "part"; // [part, ring, teardrop, block]

/* [Hidden] */
$fn = 240;
epsilon = 0.01;

RING      = [32.500, 9.000];          // R1: radius, top z
POCKET    = [47.000, 2.000];          // R2: Ø, floor z
LIP_D     = 42.000;                   // R3
TANGENT_A = 16.890;                   // E1: the tangent point's angle below +-X
END_Y     = -57.500;                  // E1, C1, C2
TEAR      = [39.000, 3.000, 4.000];   // E2: radius, top z, the cone's top z
UNDER     = [4.000, -42.000];         // E3: underside z; the 45 deg plane y + z = this
FIN_R     = 0.500;                    // E4
TOP       = 24.000;                   // the bonded face
CHANNEL   = [29.000, 9.500, -37.500]; // C1: width, floor z, blind end y
END       = [20.000, 4.000, -40.000]; // C2: half-width, chamfer, the section's reach in y
POST      = [54.000, 5.794, 37.470, 3.000];   // P1: angle, half-width, outer r, corner R
SLOT      = [34.016, 5.637, 2.580];   // S1: centre r, tangential, radial
SLOT_A    = [54, 126, -54, -126];     // S1
STRAKE    = [2.337, 5.588];           // C-502
BEARING_OD = 47.000;                  // 6807
LAP       = 0.005;

FITS = fit_clearances(config);
function pocket_d() = max(POCKET[0], fit_bore(BEARING_OD, FITS[1]));
function slot()     = [max(SLOT[1], fit_bore(STRAKE[1], FITS[1])), max(SLOT[2], fit_bore(STRAKE[0], FITS[1]))];

// E1: the ring's circle and its two tangents down past the channel's end.
module h_2d() {
    t = RING[0] * [cos(TANGENT_A), -sin(TANGENT_A)];
    d = [-sin(TANGENT_A), -cos(TANGENT_A)];
    s = (t.y - END_Y + 10) / -d.y;
    intersection() {
        hull() {
            circle(r = RING[0]);
            for (m = [1, -1]) translate([m * (t.x + s * d.x), t.y + s * d.y]) square(epsilon, center = true);
        }
        translate([-50, END_Y]) square([100, 100]);
    }
}

// P1, on +X before it is turned to its diagonal: from inside the ring out to
// its outer r, its outer corners rounded.
module post_2d() {
    p = POST;
    translate([p[2] - p[3], 0]) hull() for (s = [1, -1]) translate([0, s * (p[1] - p[3])]) circle(r = p[3], $fn = 60);
    translate([RING[0] - 8, -p[1]]) square([p[2] - p[3] - RING[0] + 8, 2 * p[1]]);
}

module posts_2d() for (a = [POST[0], 180 - POST[0]]) rotate(a) post_2d();

module ring_2d() union() { circle(r = RING[0]); posts_2d(); }

module teardrop_2d() intersection() { h_2d(); circle(r = TEAR[0]); }

// The block's plan above the ring: H less the circle, the cusps rounded.
module upper_2d() offset(r = FIN_R) offset(r = -FIN_R) difference() { h_2d(); circle(r = RING[0]); }

// C2's section in XZ, along +Y.
module end_section() {
    e = END;
    polygon([[-e[0] + e[1], e[1]], [e[0] - e[1], e[1]], [e[0], 2 * e[1]], [e[0], TOP],
             [-e[0], TOP], [-e[0], 2 * e[1]]]);
}

// E2's cone, from R1 of the teardrop at its top up to R1 + 1 at the block's underside.
module tear_cone() {
    rotate_extrude() polygon([[0, TEAR[1] - LAP], [TEAR[0], TEAR[1] - LAP], [TEAR[0], TEAR[1]],
                              [TEAR[0] + TEAR[2] - TEAR[1], TEAR[2]],
                              [TEAR[0] + TEAR[2] - TEAR[1], TEAR[2] + LAP], [0, TEAR[2] + LAP]]);
}

// E3's 45 deg plane: everything below y + z = UNDER[1].
module under_cutter() {
    translate([0, UNDER[1], 0]) rotate([-45, 0, 0]) translate([-50, -100, -200]) cube([100, 200, 200]);
}

module bodies() {
    // ring and posts
    linear_extrude(RING[1] + LAP) ring_2d();
    translate([0, 0, RING[1]]) linear_extrude(TOP - RING[1])
        difference() { posts_2d(); circle(r = RING[0]); }
    // teardrop
    linear_extrude(TEAR[1]) teardrop_2d();
    intersection() { tear_cone(); translate([0, 0, -1]) linear_extrude(TOP + 2) h_2d(); }
    // block
    difference() {
        union() {
            translate([0, 0, UNDER[0]]) linear_extrude(RING[1] - UNDER[0] + LAP) h_2d();
            translate([0, 0, RING[1]]) linear_extrude(TOP - RING[1]) upper_2d();
        }
        under_cutter();
    }
    translate([0, END[2], 0]) rotate([90, 0, 0]) linear_extrude(END[2] - END_Y) end_section();
}

module cutters() {
    s = slot();
    translate([0, 0, -1]) cylinder(d = LIP_D, h = POCKET[1] + 1 + LAP);
    translate([0, 0, POCKET[1]]) cylinder(d = pocket_d(), h = TOP);
    translate([-CHANNEL[0] / 2, END_Y - 1, CHANNEL[1]]) cube([CHANNEL[0], CHANNEL[2] - END_Y + 1, TOP]);
    for (a = SLOT_A) rotate(a) translate([SLOT[0], 0, TOP / 2]) cube([s[1], s[0], TOP + 2], center = true);
}

module axis_intersection_half() difference() { bodies(); cutters(); }

// The plan sections the gates compare, each with its bore and slots.
module slots_2d() for (a = SLOT_A) rotate(a) translate([SLOT[0], 0]) square([slot()[1], slot()[0]], center = true);

if (layer == "ring") difference() { union() { ring_2d(); teardrop_2d(); } circle(d = LIP_D); slots_2d(); }
else if (layer == "teardrop") difference() { union() { ring_2d(); teardrop_2d(); } circle(d = pocket_d()); slots_2d(); }
else if (layer == "block") difference() {
    union() { upper_2d(); posts_2d(); translate([-END[0], END_Y]) square([2 * END[0], END[2] - END_Y]); }
    circle(r = RING[0]);
    slots_2d();
    translate([-CHANNEL[0] / 2, END_Y - 1]) square([CHANNEL[0], CHANNEL[2] - END_Y + 1]);
}
else axis_intersection_half();
