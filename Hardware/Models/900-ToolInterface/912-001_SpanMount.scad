// #912-001 Span Mount — parametric source.
// The part the roll axis turns: bolted on the Roll Driver's end by four M2 x 20 bolts, it carries the
// span XL-320 on its upright plate (two M2 x 12 bolts, the servo's output through the eye) and the
// 25 mm CF strake bonded in its centre slot, onto which the Static Finger is pushed (specs/008.11 steps
// 1-2, 16-18, 25-26 and 46).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/900-ToolInterface/912-001_SpanMount.stl), in that mesh's
//                         frame.
//   config = "revised"  — the same part with print fits on the strake slot, the bolts' holes and the
//                         servo's nubs.
//
// SOURCE. The STL, which is the glTF's `CenterGripper` body exactly. 912-001_SpanMount.step (Reference/,
// 2020-03-12) is a different revision and is not a source: its underside ring is 1.5 deep where the
// STL's is 2.5, its upright plate's top corner stands 0.235 further in, and it lacks the Ø4 counterbores
// of the two servo bolts. Its other surfaces map onto the STL by (x, y, z)_stl = (-y, -x, -z)_step.
//
// FRAME. The reference's own: the roll axis on +Z through the origin, the base plate's underside at
// z = 0 and the ring's foot at z = -2.5.
//
// A region split (mesh-to-scad rung 8). Measured with scadmesh slice/arcs/planes/solid; the feature IDs
// are those of 912-001_SpanMount.view.json:
//
//     ID  feature              value
//     F1  base plate           z 0 .. 4: a circle R11.5 on the axis joined to a block x -1.634 .. 16.243,
//                              y -12.561 .. 19.2 whose left edge above the axis is x 0; corners R5 at
//                              (3.366, -7.561), (11.243, -7.561), (11.243, 14.2), R2 at (2, 17.2);
//                              concave fillets R2 (top left) and R2.5 (bottom left) onto the circle
//     R1  underside ring       z -2.5 .. 0, r 4 .. 10.5 + z (a 45 deg cone), open by G1
//     G1  wire groove          y ±1.25 from the axis to the +X edge, and the Ø8 recess inside R1,
//                              both from the ring's foot up to z 0.5
//     V1  upright plate        x 3.743 .. 7.243, z 4 .. 26.2; outline in (y, z) below; 1 x 45 deg foot
//                              fillets on both faces
//     E1  eye                  Ø12 along X at (y 14.139, z 16), in V1's R9 lobe
//     H2  servo bolt holes ×2  Ø2 along X at (y -9.861, z 10) and (y -9.861, z 22), each with a Ø4
//                              counterbore 1.75 deep from V1's -X face (previous only)
//     C1  strake column        a square turned 45 deg, |x| + |y| <= 5.833, corners R1, z 4 .. 22.7,
//                              on V1's -X side
//     C2  column foot          the same square growing by √2 per mm down to z 4 (|x| + |y| <= 10.783),
//                              from z 7.5, corners R0.65
//     W1  column web           C1 widened where it meets V1: faces y = ±(x + 0.47) from C1's faces to
//                              V1's -X face, filleted R0.5 onto C1
//     S1  strake slot          2.4 (x) x 5.5 (y), through C1 to its top; a 45 deg lead-in from 3.9 x
//                              7.0 at z 0.5 to the slot at z 1.25
//     H1  roll bolt holes ×4   Ø2 at r 6 on 45/135/225/315 deg, through
//     K1  washer pockets ×4    Ø5 on H1 from z 2: on -X a dome R2.5 centred at z 7.9; on +X flat at
//                              z 10 and open through V1 as an arch 5 wide, top z 10 with R2 corners
//     N1  drive nubs ×2        Ø4, z 4 .. 7, at (13.243, -3.861) and (13.243, 14.139)
//
//     V1's outline in (y, z): the left edge y -12.561 up to a corner R1.703 at (-10.857, 22.912), a
//     33.2 deg chamfer up to (-8.923, 26.2), the top z 26.2, a notch from ±6.015 at z 22.7 to ±6.633 at
//     z 26.2, the top to a corner R3 at (16.445, 23.202), a concave R3.33 onto the lobe R9 about E1, a
//     concave R3.16 onto the right edge y 19.2 down to the base plate.
//
// FITS (revised). The strake slot S1 on the C-502 strip (.092" x .220", 2.337 x 5.588), which is
// bonded: fit_bore at FIT_PRESS on both sides, 2.437 x 5.688 (the reference's 5.5 is 0.09 narrower
// than the strip). H1 takes the M2 bolts and K1 their washers (Ø5): fit_bore(2, FIT_SLIP) = Ø2.3 and
// fit_bore(5, FIT_SLIP) = Ø5.3. H2 takes the servo's M2 x 12 bolts at slip, Ø2.3, and its counterbores
// are filled: the bolts come in through a gripper's base, which seats their heads (span_socket.scad's
// S4), so that they hold the base to V1 as well. E1 already clears the Span Driver's Ø11 flange by FIT_RUN
// (probed, not redrawn). The span XL-320 is a bought part, and the features that meet it follow
// ../c102_servo.scad: H2 stands under its tab holes, and N1 stands in its rivet holes at FIT_PRESS, on
// the diameter and short of their floors. R1 (a seat on the Roll Driver's end, which the assembly's
// clash check reads as planar) keeps the reference's size.

include <../print_fit.scad>
use <../c102_servo.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or the base plate's or upright plate's 2D outline
layer = "part"; // [part, F1, V1]

/* [Hidden] */
$fn = 144;
LAP = 0.005;               // regions overlap so Manifold joins them (no shared faces)
BIG = 40;

PLATE_T   = 4.000;         // F1, z 0 .. 4
PLATE_R   = 11.500;        // F1's circle
BLOCK     = [16.243, -12.561, 19.200];          // F1's block: +X edge, -Y edge, +Y edge
CORNERS5  = [[3.366, -7.561], [11.243, -7.561], [11.243, 14.200]];   // F1's R5 corners
CORNER2   = [2.000, 17.200];                    // F1's R2 corner, its left edge x 0
FILLET_TOP = 2.000;        // F1's concave fillet onto the circle, top left
FILLET_BOT = 2.500;        //   and bottom left

RING      = [4.000, 10.500, 2.500];   // R1: inner r, outer r at z 0, depth
GROOVE    = [1.250, 0.500];           // G1: half-width, top z

V1_X      = [3.743, 7.243];           // V1's faces
V1_TOP    = 26.200;
V1_LEFT   = -12.561;
V1_RIGHT  = 19.200;
V1_FOOT   = 1.000;                    // V1's 45 deg foot fillet, each face
CHAMFER   = [-8.923, 33.2];           // V1's top-left chamfer: where it leaves the top, angle down
CORNER_TL = [[-10.857, 22.912], 1.703];
NOTCH     = [6.015, 22.700, 6.633];   // half-width at its floor, floor z, half-width at the top
CORNER_TR = [[16.445, 23.202], 3.000];
LOBE      = [[14.139, 16.000], 9.000];
LOBE_FILL = [3.330, 3.160];           // concave fillets onto the lobe, above and below it

EYE_D     = 12.000;                   // E1
SERVO_HOLES = [[-9.861, 10.000], [-9.861, 22.000]];   // H2 in (y, z)
SERVO_BOLT  = 2.000;
SERVO_CBORE = [4.000, 1.750];         // H2's counterbore, previous only: diameter, depth from V1's -X face

COLUMN    = [5.833, 1.000, 22.700];   // C1: |x| + |y| bound, corner radius, top
FOOT      = [10.783, 0.650, 7.500];   // C2: bound at z 4, corner radius, top
WEB       = 0.470;                    // W1: its faces are y = ±(x + WEB)
WEB_FILLET = 0.500;                   // W1's concave fillet onto C1's faces

STRAKE_SLOT = [2.400, 5.500];         // S1 (x, y), the reference's
STRAKE      = [2.337, 5.588];         // C-502, .092" x .220"
LEAD_IN     = [0.500, 1.250];         // S1's lead-in, from z to z (45 deg)

BOLT_PCD_R = 6.000;                   // H1 / K1 at r 6 on 45 deg + k 90 deg
BOLT_D     = 2.000;                   // H1, M2
WASHER_D   = 5.000;                   // K1
POCKET     = [2.000, 7.900, 10.000];  // K1: floor z, -X dome centre z, +X top z
ARCH_R     = 2.000;                   // K1's arch corners

NUBS   = [[13.243, -3.861], [13.243, 14.139]];
NUB    = [4.000, 7.000];              // N1: diameter, top z

// The span XL-320 stands with its front face on V1's +X face, its axis on E1's and its -X side pads on
// F1, so its servo-frame (x, y, z) is this frame's (z - E1's z, y - E1's y, V1's +X face - x).
// Revised takes the features that meet it from ../c102_servo.scad.
function e1() = LOBE[0];
// N1: in the front pads' rivet holes, at the press fit, short of their floors by it.
function nubs(cfg) = cfg == "revised" ? let(p = c102_pads())
    [for (py = p[1]) [V1_X[1] - p[2][0][2], e1().x + py[2]]] : NUBS;
function nub(cfg) = cfg == "revised" ? let(c = fit_clearances(cfg)[1])
    [fit_pin(c102_hole_d(), c), PLATE_T + c102_rivet_depth() - c] : NUB;
// H2: under the tab's two outer holes, in (y, z).
function servo_holes(cfg) = cfg == "revised" ?
    [for (h = [c102_tab_holes()[1], c102_tab_holes()[2]]) [e1().x + h.y, e1().y + h.x]] : SERVO_HOLES;

// --- 2D helpers --------------------------------------------------------------------------------

module closing(r) offset(r = -r) offset(r = r) children();
module opening(r) offset(r = r) offset(r = -r) children();

// A square turned 45 deg, |x| + |y| <= d, with its corners rounded r.
module diamond(d, r) hull() for (a = [0 : 90 : 270]) rotate(a) translate([d - r * sqrt(2), 0]) circle(r = r, $fn = 48);

// --- F1 base plate -----------------------------------------------------------------------------

module plate_raw_2d() union() {
    circle(r = PLATE_R);
    hull() {   // the block above the axis, its left edge at x 0
        translate(CORNER2) circle(r = CORNER2.x);
        for (c = [CORNERS5[1], CORNERS5[2]]) translate(c) circle(r = 5);
        translate([0, CORNERS5[1].y]) square(0.01);
    }
    hull() {   // the block's lower left lobe
        for (c = [CORNERS5[0], CORNERS5[1]]) translate(c) circle(r = 5);
        translate([CORNERS5[0].x, 0]) square(0.01);
    }
}

module plate_2d() union() {
    intersection() { closing(FILLET_TOP) plate_raw_2d(); translate([-BIG, 0]) square(2 * BIG); }
    intersection() { closing(FILLET_BOT) plate_raw_2d(); translate([-BIG, -2 * BIG]) square(2 * BIG); }
}

// --- V1 upright plate, drawn in (y, z) ------------------------------------------------------------

module v1_raw_2d() {
    chamfer_z = V1_TOP - (CHAMFER.x - V1_LEFT) * tan(CHAMFER.y);   // where the chamfer meets the left edge
    union() {
        polygon([[V1_LEFT, PLATE_T - LAP], [V1_RIGHT, PLATE_T - LAP], [V1_RIGHT, LOBE[0].y],
                 [CORNER_TR[0].x, LOBE[0].y], [CORNER_TR[0].x, V1_TOP], [CHAMFER.x, V1_TOP],
                 [V1_LEFT, chamfer_z]]);
        translate(CORNER_TR[0]) circle(r = CORNER_TR[1]);
        translate([CORNER_TR[0].x - 1, LOBE[0].y]) square([CORNER_TR[1] + 1, CORNER_TR[0].y - LOBE[0].y]);
        translate(LOBE[0]) circle(r = LOBE[1]);
    }
}

module v1_2d() difference() {
    union() {
        // the top-left corner rounded, the rest as drawn
        difference() { v1_raw_2d(); translate([V1_LEFT - 1, 20]) square([5, 10]); }
        intersection() { opening(CORNER_TL[1]) v1_raw_2d(); translate([V1_LEFT - 1, 20]) square([5, 10]); }
        // the concave fillets onto the lobe
        intersection() { closing(LOBE_FILL[0]) v1_raw_2d(); translate([17, LOBE[0].y]) square([10, 15]); }
        intersection() { closing(LOBE_FILL[1]) v1_raw_2d(); translate([17, 0]) square([10, LOBE[0].y]); }
    }
    let(s = (NOTCH.z - NOTCH.x) / (V1_TOP - NOTCH.y))
        polygon([[-NOTCH.x, NOTCH.y], [NOTCH.x, NOTCH.y], [NOTCH.x + s * (V1_TOP + 1 - NOTCH.y), V1_TOP + 1],
                 [-NOTCH.x - s * (V1_TOP + 1 - NOTCH.y), V1_TOP + 1]]);
}

// (y, z) drawn, extruded along +x: a rotation taking 2D x to y, 2D y to z and extrusion z to x.
YZ_TO_X = [[0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]];

module upright() {
    translate([V1_X[0], 0, 0]) multmatrix(YZ_TO_X) linear_extrude(V1_X[1] - V1_X[0]) v1_2d();
    // the foot fillets, a 45 deg triangle on each face along the plate's length
    translate([0, V1_LEFT, 0]) rotate([-90, 0, 0]) mirror([0, 1, 0]) linear_extrude(V1_RIGHT - V1_LEFT)
        polygon([[V1_X[0] - V1_FOOT, PLATE_T - LAP], [V1_X[1] + V1_FOOT, PLATE_T - LAP],
                 [V1_X[1], PLATE_T + V1_FOOT], [V1_X[0], PLATE_T + V1_FOOT]]);
}

// --- C1/C2 strake column and its foot, on V1's -X side -------------------------------------------

// C1's section: the square, widened where it meets V1 by W1, faces y = ±(x + 0.47) from the square's
// faces out to V1's face, and the concave corner between them filleted R0.5.
module column_raw_2d() union() {
    diamond(COLUMN.x, COLUMN.y);
    let(a = (COLUMN.x - WEB) / 2) polygon([[a, a + WEB], [V1_X[0] + LAP, V1_X[0] + WEB + LAP],
                                           [V1_X[0] + LAP, -V1_X[0] - WEB - LAP], [a, -a - WEB]]);
}

module column_2d() union() {
    column_raw_2d();
    let(a = (COLUMN.x - WEB) / 2)
        intersection() { closing(WEB_FILLET) column_raw_2d(); for (s = [-1, 1]) translate([a - 0.8, s * (a + WEB) - 0.8]) square(1.6); }
}

module column() intersection() {
    union() {
        translate([0, 0, PLATE_T - LAP]) linear_extrude(COLUMN.z - PLATE_T + LAP) column_2d();
        hull() {
            translate([0, 0, PLATE_T - LAP]) linear_extrude(0.01) diamond(FOOT.x, FOOT.y);
            translate([0, 0, FOOT.z]) linear_extrude(0.01) diamond(COLUMN.x, FOOT.y);
        }
    }
    translate([-BIG, -BIG, 0]) cube([BIG + V1_X[0] + LAP, 2 * BIG, BIG]);
}

// --- R1 underside ring -----------------------------------------------------------------------------

module ring() rotate_extrude()
    polygon([[RING.x, -RING.z], [RING.y - RING.z, -RING.z], [RING.y + LAP, LAP], [RING.x, LAP]]);

// --- cutters ---------------------------------------------------------------------------------------

module at_bolts(side) for (a = side > 0 ? [-45, 45] : [135, 225]) rotate(a) translate([BOLT_PCD_R, 0]) children();

module groove() {
    translate([0, 0, -RING.z - 1]) cylinder(r = RING.x, h = RING.z + 1 + GROOVE.y);
    translate([0, -GROOVE.x, -RING.z - 1]) cube([BIG, 2 * GROOVE.x, RING.z + 1 + GROOVE.y]);
}

module strake_slot(cfg) let(c = fit_clearances(cfg), w = cfg == "previous" ? STRAKE_SLOT : [fit_bore(STRAKE.x, c[1]), fit_bore(STRAKE.y, c[1])], g = LEAD_IN[1] - LEAD_IN[0]) {
    translate([-w.x / 2, -w.y / 2, LEAD_IN[0] - 1]) cube([w.x, w.y, BIG]);
    hull() {
        translate([-w.x / 2 - g, -w.y / 2 - g, LEAD_IN[0] - 0.01]) cube([w.x + 2 * g, w.y + 2 * g, 0.01]);
        translate([-w.x / 2, -w.y / 2, LEAD_IN[1]]) cube([w.x, w.y, 0.01]);
    }
}

module bolt_cutters(cfg) let(c = fit_clearances(cfg), b = fit_bore(BOLT_D, c[0]), w = fit_bore(WASHER_D, c[0])) {
    for (s = [-1, 1]) at_bolts(s) translate([0, 0, -RING.z - 1]) cylinder(d = b, h = RING.z + 1 + POCKET.x + 1, $fn = 48);
    // -X pair: the pocket with its dome
    at_bolts(-1) {
        translate([0, 0, POCKET.x]) cylinder(d = w, h = POCKET.y - POCKET.x, $fn = 96);
        translate([0, 0, POCKET.y]) sphere(d = w, $fn = 96);
    }
    // +X pair: the pocket up to z 10 on C1's side of V1's face, and its arch out through V1
    for (y = [-1, 1]) let(c = BOLT_PCD_R / sqrt(2)) translate([c, y * c, 0]) {
        intersection() {
            translate([0, 0, POCKET.x]) cylinder(d = w, h = POCKET.z - POCKET.x, $fn = 96);
            translate([-BIG, -BIG, 0]) cube([BIG + V1_X[0] - c, 2 * BIG, BIG]);
        }
        translate([0, 0, POCKET.x]) cylinder(d = w, h = PLATE_T - POCKET.x, $fn = 96);
        translate([V1_X[0] - c, 0, 0]) multmatrix(YZ_TO_X) linear_extrude(V1_X[1] + V1_FOOT + 1 - V1_X[0]) hull() {
            translate([-w / 2, PLATE_T - LAP]) square([w, 0.01]);
            for (s = [-1, 1]) translate([s * (w / 2 - ARCH_R), POCKET.z - ARCH_R]) circle(r = ARCH_R, $fn = 48);
        }
    }
}

module upright_cutters(cfg) let(c = fit_clearances(cfg)) {
    translate([-1, LOBE[0].x, LOBE[0].y]) rotate([0, 90, 0]) cylinder(d = EYE_D, h = BIG);
    for (p = servo_holes(cfg)) translate([-1, p.x, p.y]) rotate([0, 90, 0]) {
        cylinder(d = fit_bore(SERVO_BOLT, c[0]), h = BIG, $fn = 48);
        if (cfg == "previous") cylinder(d = SERVO_CBORE.x, h = 1 + V1_X[0] + SERVO_CBORE.y, $fn = 72);
    }
}

// --- the part ------------------------------------------------------------------------------------

module span_mount(cfg = config)
    difference() {
        union() {
            linear_extrude(PLATE_T) plate_2d();
            difference() { ring(); translate([0, -GROOVE.x, -RING.z - 1]) cube([BIG, 2 * GROOVE.x, RING.z + 2]); }
            upright();
            column();
            for (p = nubs(cfg)) translate([p.x, p.y, PLATE_T - LAP]) cylinder(d = nub(cfg).x, h = nub(cfg).y - PLATE_T + LAP);
        }
        groove();
        strake_slot(cfg);
        bolt_cutters(cfg);
        upright_cutters(cfg);
    }

// F1's section between the pockets' floor and its top (z 2 .. 4): the outline less S1 and K1.
module plate_section_2d(cfg = config) let(c = fit_clearances(cfg))
    difference() {
        plate_2d();
        projection(cut = true) translate([0, 0, -3]) strake_slot(cfg);
        for (s = [-1, 1]) at_bolts(s) circle(d = fit_bore(WASHER_D, c[0]), $fn = 96);
    }

if (layer == "F1") plate_section_2d();
else if (layer == "V1") v1_2d();
else span_mount();
