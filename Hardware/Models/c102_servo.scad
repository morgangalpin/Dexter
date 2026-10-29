// C-102 Dynamixel XL-320 servo: a placement model only, shared by the assemblies that place one. It
// draws the case by the features that locate it (the plates' holes, the side pads' rivet holes, the
// front face) and the output in one of two states: with its horn (c102_horn), as the roll servo is
// built, or bare (c102_spline), as the span servo is once its horn is taken off (specs/008.11 step 24).
// It is not a replica: the case is solid between its plates, and the gear train, the connectors and the
// horn's centre screw are not drawn.
//
// FRAME. The output axis on +Z through the origin, the case's front face (the output's side) at z = 0
// and the case behind it to z = -24; the case's near end, 9 from the axis, toward +Y and its tab end
// toward -Y; its width across X. The output stands on z >= 0, turned `turn` deg about +Z: at 0 a spline
// tooth and the key point along +X, and the horn's four Ø4 holes lie on the axes.
//
// SOURCES. The envelope is the ROBOTIS e-Manual's (https://emanual.robotis.com/docs/en/dxl/x/xl320/):
// 24 x 36 x 27 (W x H x D). The e-Manual gives no other dimension, so the features are the CAD model's
// XL-320, the glTF body `TI1-000-001_DynamixelXL-320-3 v1` of dde/HDIMeterModel.gltf (exported with
// `scadmesh gltf --node 112 --frame 112 --scale 1000`; its origin is the case's mid-depth, z -12
// here), which fills the envelope exactly: 21 + two 1.5 pads wide, 36 high, a 24 case and a 3 horn
// deep. Each row names what its value was checked against. The glTF draws no spline, so the spline is
// the Span Driver's bore, its only mate:
//
//     what              value                                            source, cross-check
//     plates ×2         the outline below, 3 thick: z -3 .. 0 (front)    glTF; #900-001's S1 pocket, whose
//                       and -24 .. -21 (back)                            floor is the near end's outline
//     outline           x ±10.5, y -27 .. 9; each end a chamfer from     glTF; #911-001's F1 rim, whose
//                       x ±10.5 3.85 short of the end to R2 corners      inner outline is the tab end's
//                       tangent to it at x ±6.914
//     body              the outline from y -22.5 up, between the         glTF; its sides are drawn flat at
//                       plates; R2.54 scallops round the outer tab       x ±10.5, where the glTF's curve in
//                       holes (their nuts) and y -21.5 outside them      to x ±9.7 between the pads
//     tab holes ×3      Ø4 at (0, -24) and (±6, -24), through both       glTF; #912-001's H2 (24 from E1's
//                       plates, Ø5 x 0.8 counterbored on every face      axis, ±6) and #911-001's H1
//     back holes ×3     the same at (0, 0) and (±6, 0), back plate only  glTF
//     side pads ×8      1.5 proud of the body (x ±10.5 .. ±12), at y     glTF; #912-001's N1 (Ø4, on E1's
//                       -3 .. 3.5 and -21.5 .. -15, z -9 .. -3 and       line and 18 along it, 6 behind
//                       -21 .. -15; each a rivet hole Ø4 at (y 0 or      V1), which stand 3 tall and so
//                       -18, z -6 or -18), Ø5 x 0.8 counterbored from    reach 0.8 past the holes' floor
//                       the pad's face, 2.2 deep (to x ±9.8)
//     horn              Ø17.8 x 3 on the front face, its top edge        glTF; the e-Manual's 27 less the
//                       chamfered 0.2; four Ø4 holes at r 6 on the       24 case; #911-002's N1 (Ø3.8 at
//                       axes, Ø5 x 0.8 counterbored from its top; four   r 6 on the axes)
//                       Ø1.6 at r 6 on the diagonals; a Ø5.6 x 0.5
//                       recess for the centre screw's head
//     spline            20 teeth, tips r 2.683, roots r 2.356, from      #912-002's B1 at its nominal size;
//                       the front face to z 3                            its length, in no source, is
//                                                                        assumed to be the horn's
//     key               1.0 wide, from r 1.3 to an R0.5 end centred      #912-002's K2; its height is in
//                       2.0 out, standing 1.0 proud of the spline        no source and is assumed
//
// The span servo's spline is pressed into the Span Driver's B1. The spline is drawn at B1's nominal star,
// and `config="revised"` grows B1 by FIT_PRESS per flank (#912-002's FITS), so the press is drawn as that
// clearance, as every press in these assemblies is: line to line against the reference B1, and no
// overlap against the revised one. Any overlap of the two in an assembly is a placement disagreement,
// not the press.

// The tab holes in (x, y), on the front and back plates.
function c102_tab_holes() = [[0, -24], [-6, -24], [6, -24]];
// A plate: thickness, its holes' counterbore diameter and depth.
function c102_plate() = [3.000, 5.000, 0.800];
// The output's height above the front face: the horn's, and the bare spline's without its key.
function c102_output_h() = 3.000;

C102_LAP = 0.005;   // regions overlap so Manifold joins them (no shared faces)

module c102_outline_2d() hull() {
  for (s = [-1, 1], y = [7, -25]) translate([s * 6.914, y]) circle(r = 2);
  polygon([[-10.5, -23.15], [10.5, -23.15], [10.5, 5.15], [-10.5, 5.15]]);
}

module c102_body_2d() difference() {
  intersection() { c102_outline_2d(); translate([-20, -22.5]) square(40); }
  for (s = [-1, 1]) {
    translate([s * 6, -24]) circle(r = 2.54);
    translate([s > 0 ? 6 : -20, -30]) square([14, 8.5]);
  }
}

// A Ø4 hole through a plate from z0 to z0 + 3, counterbored on both faces.
module c102_plate_hole(z0) let(p = c102_plate()) {
  translate([0, 0, z0 - 1]) cylinder(d = 4, h = p[0] + 2);
  translate([0, 0, z0 - 1]) cylinder(d = p[1], h = 1 + p[2]);
  translate([0, 0, z0 + p[0] - p[2]]) cylinder(d = p[1], h = 1 + p[2]);
}

module c102_plate_at(z0, holes) difference() {
  translate([0, 0, z0]) linear_extrude(c102_plate()[0]) c102_outline_2d();
  for (h = holes) translate(h) c102_plate_hole(z0);
}

PAD_Y = [[-3, 3.5, 0], [-21.5, -15, -18]];   // y span, its hole's y
PAD_Z = [[-9, -3, -6], [-21, -15, -18]];     // z span, its hole's z
RIVET_DEPTH = 2.200;                         // a rivet hole's depth from its pad's face

// One side's four pads (s = ±1).
module c102_pads(s) for (py = PAD_Y, pz = PAD_Z)
  translate([s > 0 ? 10.5 - C102_LAP : -12, py[0], pz[0]]) cube([1.5 + C102_LAP, py[1] - py[0], pz[1] - pz[0]]);

// One side's four rivet holes (s = ±1), through the pad into the body.
module c102_rivet_holes(s) for (py = PAD_Y, pz = PAD_Z)
  translate([s * 12, py[2], pz[2]]) rotate([0, s * -90, 0]) {
    translate([0, 0, -1]) cylinder(d = 4, h = 1 + RIVET_DEPTH);
    translate([0, 0, -1]) cylinder(d = c102_plate()[1], h = 1 + c102_plate()[2]);
  }

module c102_case() difference() {
  union() {
    c102_plate_at(-c102_plate()[0], c102_tab_holes());
    c102_plate_at(-24, concat(c102_tab_holes(), [[0, 0], [-6, 0], [6, 0]]));
    translate([0, 0, -21 - C102_LAP]) linear_extrude(18 + 2 * C102_LAP) c102_body_2d();
    for (s = [-1, 1]) c102_pads(s);
  }
  for (s = [-1, 1]) c102_rivet_holes(s);
}

// The horn on the output, its top face at z 3.
module c102_horn(turn = 0) rotate(turn) difference() {
  union() {
    cylinder(d = 17.8, h = 2.8 + C102_LAP);
    translate([0, 0, 2.8]) cylinder(d1 = 17.8, d2 = 17.4, h = 0.2);
  }
  for (a = [0 : 90 : 270]) rotate(a) translate([6, 0, 0]) {
    translate([0, 0, -1]) cylinder(d = 4, h = 5);
    translate([0, 0, 3 - c102_plate()[2]]) cylinder(d = 5, h = 1);
  }
  for (a = [45 : 90 : 315]) rotate(a) translate([6, 0, -1]) cylinder(d = 1.6, h = 5);
  translate([0, 0, 2.5]) cylinder(d = 5.6, h = 1);
}

function c102_star() = [for (i = [0 : 39]) (i % 2 == 0 ? 2.683 : 2.356) * [cos(9 * i), sin(9 * i)]];

// The bare output: the spline from the front face to z 3, and the key standing on its end.
module c102_spline(turn = 0) rotate(turn) {
  linear_extrude(c102_output_h()) polygon(c102_star());
  translate([0, 0, c102_output_h() - C102_LAP]) linear_extrude(1 + C102_LAP)
    hull() { translate([1.3, -0.5]) square([0.7, 1]); translate([2, 0]) circle(d = 1); }
}
