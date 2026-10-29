// #911-002 Roll Driver — parametric source.
// The roll axis's output: a Ø17 shaft carried by the Roll Body's two 6703 bearings, driven by the roll
// XL-320 through four bosses on its underside, and bolted to the Span Mount by four M2 x 20 bolts
// (specs/008.11 steps 5-8 and 17-21).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/900-ToolInterface/911-002_RollDriver.stl), in that mesh's
//                         frame.
//   config = "revised"  — the same part with S1 at the 6703's press fit.
//
// SOURCE. 911-002_RollDriver.step (Reference/, 2020-03-12) and the STL are the same revision: every
// STEP surface (scadmesh surfaces) lands on the STL's sections in the same frame, and the dimensions
// below are the STEP's. The STEP is all planes and cylinders, 30 faces.
//
// FRAME. The reference's (and the STEP's) own: the axis on +Z through the origin, the bosses' feet at
// z = 4.5, the shaft's end at z = 21.
//
// A stack of constant sections (mesh-to-scad rung 1, profile per layer). `layer = "L1"` .. `"L4"`
// draws one layer's 2D profile for the outline gates. The feature IDs are those of
// 911-002_RollDriver.view.json:
//
//     ID  feature                    value                      where
//     N1  drive bosses ×4            Ø3.800                     r 6 on 0/90/180/270 deg, z 4.5 .. 7.3
//     P1  pin holes ×4               Ø1.000                     r 6 on 0/90/180/270 deg, z 4.5 .. 21
//     F1  flange                     Ø18.000                    z 7.3 .. 8.0
//     S1  shaft                      Ø17.000                    z 8.0 .. 21.0
//     W1  wire bore                  Ø5.600                     axis, z 7.3 .. 21
//     C1  bolt counterbores ×4       Ø4.000                     r 6 on 45/135/225/315 deg, z 7.3 .. 9.3
//     B1  bolt holes ×4              Ø2.000                     same places, z 9.3 .. 21
//
//     layer  z span      section
//     L1     4.5 .. 7.3  N1 less P1
//     L2     7.3 .. 8.0  F1 less W1, P1, C1
//     L3     8.0 .. 9.3  S1 less W1, P1, C1
//     L4     9.3 .. 21   S1 less W1, P1, B1
//
// FITS (revised). S1 is pressed into the two 6703s (C-404, 17 x 23 x 4): fit_pin(17, FIT_PRESS)
// = Ø16.900 over the whole shaft, F1 staying Ø18 as the shoulder. C1 takes the M2 x 20 bolts' heads
// (Ø3.8, step 7) at press, not slip: fit_bore(3.8, FIT_PRESS) = Ø3.900, which leaves 0.50 of wall in
// L3 between C1 and the 6703's bore, as the reference does. Slip's Ø4.1 would leave 0.40, narrower than
// one extrusion line. The rest keep the reference's sizes: P1 is reamed for
// satin pins that are glued in (step 5-6), B1 is tapped by the M2 x 20 bolts (step 7), N1 engages the
// servo's horn (unknown mate), and W1 carries wires.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D profile
layer = "part"; // [part, L1, L2, L3, L4]

/* [Hidden] */
$fn = 144;
LAP = 0.005;               // layers overlap so Manifold joins them (no shared faces)

Z = [4.5, 7.3, 8.0, 9.3, 21.0];   // the layers' faces, L1 .. L4

PCD_R     = 6.000;         // N1, P1, C1 and B1 all stand on r 6
BOSS_D    = 3.800;         // N1
PIN_D     = 1.000;         // P1
FLANGE_D  = 18.000;        // F1
SHAFT_D   = 17.000;        // S1, the 6703's bore
WIRE_D    = 5.600;         // W1
CBORE_D   = 4.000;         // C1, the reference's
HEAD_D    = 3.800;         // the M2 x 20 bolt's head, which C1 takes
BOLT_D    = 2.000;         // B1

module at_pcd(start) for (a = [start : 90 : start + 270]) rotate(a) translate([PCD_R, 0]) children();

module pins_2d() at_pcd(0) circle(d = PIN_D, $fn = 48);

module l1_2d() difference() { at_pcd(0) circle(d = BOSS_D, $fn = 72); pins_2d(); }

// One section of the flange or shaft: outline d, less W1, P1 and the 45-degree holes of diameter h.
module disc_2d(d, h) difference() {
    circle(d = d);
    circle(d = WIRE_D, $fn = 96);
    pins_2d();
    at_pcd(45) circle(d = h, $fn = 72);
}

function shaft_d(cfg) = fit_pin(SHAFT_D, fit_clearances(cfg)[1]);
function cbore_d(cfg) = cfg == "revised" ? fit_bore(HEAD_D, fit_clearances(cfg)[1]) : CBORE_D;

module l2_2d(cfg = config) disc_2d(FLANGE_D, cbore_d(cfg));
module l3_2d(cfg = config) disc_2d(shaft_d(cfg), cbore_d(cfg));
module l4_2d(cfg = config) disc_2d(shaft_d(cfg), BOLT_D);

// Layer i's slab, lapped LAP into the layer below.
module slab(i) translate([0, 0, Z[i] - (i > 0 ? LAP : 0)]) linear_extrude(Z[i + 1] - Z[i] + (i > 0 ? LAP : 0)) children();

module roll_driver(cfg = config) {
    slab(0) l1_2d();
    slab(1) l2_2d(cfg);
    slab(2) l3_2d(cfg);
    slab(3) l4_2d(cfg);
}

if (layer == "L1") l1_2d();
else if (layer == "L2") l2_2d();
else if (layer == "L3") l3_2d();
else if (layer == "L4") l4_2d();
else roll_driver();
