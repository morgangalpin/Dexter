// C-102 Dynamixel XL-320 servo: a placement model only, shared by the assemblies that place one, and the
// one home of the servo's dimensions, which the revised parts that mate it read. It draws the case by
// the features that locate it (the plates' holes, the side pads' rivet holes, the front face) and the
// output in one of two states: with its horn (c102_horn), as the roll servo is built, or bare
// (c102_spline), as the span servo is once its horn is taken off (specs/008.11 step 24). It is not a
// replica: the case is solid between its plates, and the gear train, the connectors and the horn's
// centre screw are not drawn.
//
// FRAME. The output axis on +Z through the origin, the case's front face (the output's side) at z = 0
// and the case behind it; the case's near end toward +Y and its tab end toward -Y; its width across X.
// The output stands on z >= 0, turned `turn` deg about +Z: at 0 a spline tooth and the key point along
// +X, and the horn's four holes lie on the axes.
//
// SOURCES. The envelope is the ROBOTIS e-Manual's (https://emanual.robotis.com/docs/en/dxl/x/xl320/):
// 24 x 36 x 27 (W x H x D). The e-Manual gives no other dimension, so the features are the CAD model's
// XL-320, the glTF body `TI1-000-001_DynamixelXL-320-3 v1` of dde/HDIMeterModel.gltf (exported with
// `scadmesh gltf --node 112 --frame 112 --scale 1000`; its origin is the case's mid-depth), which fills
// the envelope exactly: 21 + two 1.5 pads wide, 36 high, a 24 case and a 3 horn deep. The glTF draws no
// spline, so the spline is the Span Driver's reference bore, its only mate. No dimension has been
// measured on a servo: DIMENSIONS below are where a measurement goes, each with its source, and the
// revised parts that mate the servo follow them.
//
// The span servo's spline is pressed into the Span Driver's B1, which `config="revised"` sizes from
// c102_spline() grown by FIT_PRESS per flank (#912-002's FITS), so the press is drawn as that clearance,
// as every press in these assemblies is. Any overlap of the two in an assembly is a placement
// disagreement, not the press.

// --- DIMENSIONS -------------------------------------------------------------------------------------
// The case: half-width (x), near end (y), tab end (y), depth (z). glTF; the e-Manual's 24 x 36 x 27.
function c102_case_dims() = [10.500, 9.000, -27.000, 24.000];
// Each end's corners: R corners' centre x, their radius, and where the chamfer from the side starts,
// short of the end. glTF; #900-001's S1 pocket floor and #911-001's F1 rim follow the outline.
function c102_corners() = [6.914, 2.000, 3.850];
// A plate: thickness, its holes' counterbore diameter and depth. glTF.
function c102_plate() = [3.000, 5.000, 0.800];
// The plates' holes, the side pads' rivet holes and the horn's holes. glTF.
function c102_hole_d() = 4.000;
// The tab holes in (x, y), through both plates. glTF; #912-001's H2 and #911-001's H1.
function c102_tab_holes() = [[0, -24], [-6, -24], [6, -24]];
// The back plate's own holes in (x, y). glTF.
function c102_back_holes() = [[0, 0], [-6, 0], [6, 0]];
// The side pads: how far proud of the case's sides; their spans along y with each one's rivet hole's y;
// their spans along z with each one's rivet hole's z. glTF; #912-001's N1 and #920-001's S3.
function c102_pads() = [1.500, [[-3, 3.5, 0], [-21.5, -15, -18]], [[-9, -3, -6], [-21, -15, -18]]];
// A rivet hole's depth from its pad's face. glTF; deeper than #912-001's reference N1 (3) by 0.8.
function c102_rivet_depth() = 2.200;
// The horn: diameter, height above the front face, its holes' radius. glTF; the e-Manual's 27 less
// the 24 case; #911-002's N1 (Ø3.8 at r 6 on the axes).
function c102_horn() = [17.800, 3.000, 6.000];
// The spline: teeth, tips' radius, roots' radius, length from the front face. #912-002's reference B1;
// its length is in no source and is assumed to be the horn's height.
function c102_spline() = [20, 2.683, 2.356, 3.000];
// The key on the spline's end: width, from r, its R end's centre r, height. #912-002's K2; its height
// is in no source and is assumed.
function c102_key() = [1.000, 1.300, 2.000, 1.000];

// The servo's outline in (x, y), plates and body, without the pads; `grow` offsets it, as a part
// that takes the case at a fit cuts it.
module c102_outline_2d(grow = 0) let(c = c102_case_dims(), k = c102_corners())
  offset(delta = grow) hull() {
    for (s = [-1, 1], y = [c[1] - k[1], c[2] + k[1]]) translate([s * k[0], y]) circle(r = k[1]);
    translate([-c[0], c[2] + k[2]]) square([2 * c[0], c[1] - c[2] - 2 * k[2]]);
  }

// --- the model --------------------------------------------------------------------------------------
C102_LAP = 0.005;   // regions overlap so Manifold joins them (no shared faces)
BODY_Y   = -22.500; // the body's tab end between the plates
NUT_R    = 2.540;   // the scallops round the outer tab holes (their nuts)
SHOULDER = -21.500; // the body's tab end outside the scallops

module c102_body_2d() difference() {
  intersection() { c102_outline_2d(); translate([-20, BODY_Y]) square(40); }
  for (s = [-1, 1]) {
    translate([s * 6, -24]) circle(r = NUT_R);
    translate([s > 0 ? 6 : -20, -30]) square([14, SHOULDER + 30]);
  }
}

// A hole through a plate from z0 to z0 + its thickness, counterbored on both faces.
module c102_plate_hole(z0) let(p = c102_plate()) {
  translate([0, 0, z0 - 1]) cylinder(d = c102_hole_d(), h = p[0] + 2);
  translate([0, 0, z0 - 1]) cylinder(d = p[1], h = 1 + p[2]);
  translate([0, 0, z0 + p[0] - p[2]]) cylinder(d = p[1], h = 1 + p[2]);
}

module c102_plate_at(z0, holes) difference() {
  translate([0, 0, z0]) linear_extrude(c102_plate()[0]) c102_outline_2d();
  for (h = holes) translate(h) c102_plate_hole(z0);
}

// One side's four pads (s = ±1).
module c102_pads(s) let(w = c102_case_dims()[0], p = c102_pads()) for (py = p[1], pz = p[2])
  translate([s > 0 ? w - C102_LAP : -w - p[0], py[0], pz[0]]) cube([p[0] + C102_LAP, py[1] - py[0], pz[1] - pz[0]]);

// One side's four rivet holes (s = ±1), through the pad into the body.
module c102_rivet_holes(s) let(p = c102_pads(), x = c102_case_dims()[0] + p[0]) for (py = p[1], pz = p[2])
  translate([s * x, py[2], pz[2]]) rotate([0, s * -90, 0]) {
    translate([0, 0, -1]) cylinder(d = c102_hole_d(), h = 1 + c102_rivet_depth());
    translate([0, 0, -1]) cylinder(d = c102_plate()[1], h = 1 + c102_plate()[2]);
  }

module c102_case() let(t = c102_plate()[0], d = c102_case_dims()[3]) difference() {
  union() {
    c102_plate_at(-t, c102_tab_holes());
    c102_plate_at(-d, concat(c102_tab_holes(), c102_back_holes()));
    translate([0, 0, t - d - C102_LAP]) linear_extrude(d - 2 * t + 2 * C102_LAP) c102_body_2d();
    for (s = [-1, 1]) c102_pads(s);
  }
  for (s = [-1, 1]) c102_rivet_holes(s);
}

// The horn on the output, its top face at the horn's height.
module c102_horn(turn = 0) let(h = c102_horn()) rotate(turn) difference() {
  union() {
    cylinder(d = h[0], h = h[1] - 0.2 + C102_LAP);
    translate([0, 0, h[1] - 0.2]) cylinder(d1 = h[0], d2 = h[0] - 0.4, h = 0.2);
  }
  for (a = [0 : 90 : 270]) rotate(a) translate([h[2], 0, 0]) {
    translate([0, 0, -1]) cylinder(d = c102_hole_d(), h = h[1] + 2);
    translate([0, 0, h[1] - c102_plate()[2]]) cylinder(d = c102_plate()[1], h = 1);
  }
  for (a = [45 : 90 : 315]) rotate(a) translate([h[2], 0, -1]) cylinder(d = 1.6, h = h[1] + 2);
  translate([0, 0, h[1] - 0.5]) cylinder(d = 5.6, h = 1);
}

// The spline's star in (x, y), a tip on +X.
function c102_star() = let(s = c102_spline(), n = 2 * s[0])
  [for (i = [0 : n - 1]) (i % 2 == 0 ? s[1] : s[2]) * [cos(360 / n * i), sin(360 / n * i)]];

// The bare output: the spline from the front face, and the key standing on its end.
module c102_spline(turn = 0) let(s = c102_spline(), k = c102_key()) rotate(turn) {
  linear_extrude(s[3]) polygon(c102_star());
  translate([0, 0, s[3] - C102_LAP]) linear_extrude(k[3] + C102_LAP)
    hull() { translate([k[1], -k[0] / 2]) square([k[2] - k[1], k[0]]); translate([k[2], 0]) circle(d = k[0]); }
}
