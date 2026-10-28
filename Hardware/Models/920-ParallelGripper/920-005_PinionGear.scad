// #920-005 Pinion Gear — parametric source.
// The parallel gripper's pinion: a 12-tooth spur gear on a boss, turned by the Span Driver's flat-sided
// head (#912-002) and meshing with the rack on the Dynamic Finger. It turns in the Static Finger's hub
// slot, holds an M3 nut, and carries the Pinion Bearing EXT (#920-006) on an M3 x 16 bolt
// (specs/008.11 steps 38-45).
//
//   config = "previous" — a faithful recreation of 920-005_PinionGear.step, gated against
//                         ../Reference/meshes/920-ParallelGripper/920-005_PinionGear.stl, in that frame.
//   config = "revised"  — the same part with print fits on the drive slot, the nut trap, the bolt hole
//                         and the EXT's key recess, without the collar R1, and with the top chamfer C2.
//
// SOURCE. 920-005_PinionGear.step (Reference/, `PinionGear`, 2020-03-12); the dimensions below are its
// surfaces' (scadmesh surfaces). Its flanks are B-spline faces, which that command does not report; they
// are the involutes of the planes and cylinders it does report: a standard module 1.75, 20 deg gear,
// whose straight flank below the base circle (Ø19.734) starts at the involute's foot. The reference
// mesh is the STEP tessellated by scadmesh tessellate. The STEP draws neither the two satin-pin holes
// atop the gear that step 38 reams, nor the short hash mark that step 43 aligns the EXT with; this
// recreation does not either.
//
// FRAME. The STEP's own: the axis on +Z through the origin, the boss's end at z -5.5, the gear's
// underside at z 0, the teeth's tops at z 6 and the collar's top at z 6.5. A tooth stands on +X; the
// drive slot opens toward +Y and the key recess points toward -Y.
//
// A stack of constant sections (mesh-to-scad rung 1, profile per layer), less two cutters that are not
// constant along z: the teeth's 45 deg chamfer, revolved (rung 4), and N1's entry flare, a tapered hex.
// `layer = "L1"` .. `"L6"` draws one layer's 2D section for the outline gates. The feature IDs are those
// of 920-005_PinionGear.view.json:
//
//     ID  feature        value                                                 z span
//     G1  teeth          12, module 1.75, 20 deg: tips Ø24.500, root Ø16.698,   0 .. 6.0
//                        R1 root fillets
//     C1  chamfer        45 deg, from r 10.25 at z 0 to the tips at z 2         0 .. 2.0
//     C2  top chamfer    45 deg, from the tips at z 5.5 to r 11.75 at z 6.0     5.5 .. 6.0
//                        (revised only)
//     H1  boss           Ø12.000                                               -5.5 .. 0
//     D1  drive slot     between flats at x ±3.5, open through H1 toward +Y,   -5.5 .. -2.0
//                        a floor at y -4.6 and 45 deg chamfers from
//                        (±3.5, -2.6) to (±1.5, -4.6)
//     N1  nut trap       hex 5.500 across flats, its corners on ±Y, a 45 deg    -2.0 .. 1.3
//                        flare 0.5 out from z -1.5 down to D1
//     B1  bolt hole      Ø3.000                                                1.3 .. 4.5
//     K1  key recess     Ø8 arc between flats at x ±3, closed toward -Y by       4.5 .. 6.5
//                        two chords from (±3, -2.646) to a point at (0, -4)
//     R1  collar         Ø8.800                                                6.0 .. 6.5
//
//     layer  z span        section
//     L1     -5.5 .. -2.0  H1 less D1
//     L2     -2.0 .. 0     H1 less N1
//     L3     0 .. 1.3      G1 less N1
//     L4     1.3 .. 4.5    G1 less B1
//     L5     4.5 .. 6.0    G1 less K1
//     L6     6.0 .. 6.5    R1 less K1 (previous only)
//
// L3 lies wholly within C1, so its section is gated through L2 (N1) and L4 (G1) and by the dist gate.
//
// FITS (revised). D1 takes the Span Driver's head, a printed part: its flats, drawn line to line with
// the head's, open by FIT_SLIP each side (the whole slot grown by 0.15). N1 takes an M3 nut (5.5 across
// flats) and B1 the M3 x 16 bolt: fit_bore(5.5, FIT_SLIP) = 5.800 across flats, its flare kept at 45 deg,
// and fit_bore(3, FIT_SLIP) = Ø3.300. K1 takes the EXT's keyed nose, a printed part drawn line to line
// with it: grown by FIT_SLIP. G1 meshes with the rack and H1 turns in the Static Finger's hub slot; both
// keep the reference's sizes.
//
// COLLAR (revised). R1 is dropped: the gear's top is flat at z 6.0 and K1 is 1.5 deep. R1 stood only 0.40
// outside K1's Ø8 arc, and K1 at slip left 0.25 there, under the 1 mm minimum for a printed wall. The
// 0.5 spacer moves onto the Pinion Bearing EXT (#920-006) as a solid Ø8.8 collar at its nose's root, so
// the pair's envelope is unchanged. The wall outside K1 is now G1's body, over 4 thick.
//
// TOP CHAMFER (revised). The Static Finger's hub slot has an edge 0.25 past the gear's top face and 0.25
// outside its tips (at y 9.757, r 12.5 in the finger's frame), which left 0.354 between it and the tips'
// top corner; the gear turns against the finger, so 0.5 is needed (FIT_RUN). C2 cuts that corner 0.5
// at 45 deg, which leaves 0.71. It takes only addendum, wholly outside the pitch circle (r 10.5).

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D section
layer = "part"; // [part, L1, L2, L3, L4, L5, L6]

/* [Hidden] */
$fn = 144;
LAP = 0.005;               // layers overlap so Manifold joins them (no shared faces)
BIG = 10;

Z = [-5.5, -2.0, 0.0, 1.3, 4.5, 6.0, 6.5];   // the layers' faces, L1 .. L6

TEETH     = 12;            // G1
MODULE    = 1.750;
PRESSURE  = 20;
TIP_R     = 12.250;
ROOT_R    = 8.3492;
FILLET_R  = 1.000;
FLANK_DIR = 8.300;         // G1's straight flank below the base circle, its direction (deg) from the foot
CHAMFER_R = 10.250;        // C1: r at z 0, rising 45 deg
TOP_CHAMFER = 0.500;       // C2 (revised only): 45 deg leg at the tips' top corner
BOSS_D    = 12.000;        // H1
SLOT      = [3.500, 4.600, 2.000];   // D1: flat half-width, floor's depth toward -Y, chamfer leg
NUT_AF    = 5.500;         // N1, the M3 nut's across-flats
FLARE     = 0.500;         // N1's 45 deg flare, per side and in height
BOLT_D    = 3.000;         // B1, the M3 bolt's
KEY       = [4.000, 3.000];          // K1: arc radius, flat half-width
COLLAR_D  = 8.800;         // R1

// --- G1 teeth -----------------------------------------------------------------------------------

PITCH_R = MODULE * TEETH / 2;
BASE_R  = PITCH_R * cos(PRESSURE);
BASE_A  = 90 / TEETH + (tan(PRESSURE) - PRESSURE * PI / 180) * 180 / PI;   // the foot's half-angle
T_TIP   = sqrt((TIP_R / BASE_R) ^ 2 - 1);

function polar(r, a) = r * [cos(a), sin(a)];

// The +Y flank's involute, from its foot on the base circle out to the tip.
function involute(n = 24) = [for (i = [0 : n]) let(t = T_TIP * i / n)
    polar(BASE_R * sqrt(1 + t * t), BASE_A - (t * 180 / PI - atan(t)))];

// One tooth on +X: the straight flanks run in from the feet past the root, the involutes out to the
// tip's arc.
module tooth_2d() let(
    inv = involute(), tip_a = BASE_A - (T_TIP * 180 / PI - atan(T_TIP)),
    foot_in = polar(BASE_R, BASE_A) - 2.5 * polar(1, FLANK_DIR),
    half = concat([foot_in], inv, [for (i = [1 : 8]) polar(TIP_R, tip_a * (1 - i / 8))]))
    polygon(concat(half, [for (i = [len(half) - 2 : -1 : 0]) [half[i].x, -half[i].y]]));

// The root circle and the teeth, the R1 fillets filled in by a closing.
module gear_2d() offset(r = -FILLET_R) offset(r = FILLET_R) union() {
    circle(r = ROOT_R, $fn = 288);
    for (k = [0 : TEETH - 1]) rotate(k * 360 / TEETH) tooth_2d();
}

// --- holes --------------------------------------------------------------------------------------

function slip(cfg) = fit_clearances(cfg)[0];

// D1, run out past H1 toward +Y.
module slot_2d(cfg) offset(delta = slip(cfg)) polygon([[-SLOT[0], BIG], [-SLOT[0], SLOT[2] - SLOT[1]],
    [SLOT[2] - SLOT[0], -SLOT[1]], [SLOT[0] - SLOT[2], -SLOT[1]], [SLOT[0], SLOT[2] - SLOT[1]], [SLOT[0], BIG]]);

// A hex af across flats, its corners on ±Y.
module hex_2d(af) rotate(90) circle(d = af / cos(30), $fn = 6);

function nut_af(cfg) = fit_bore(NUT_AF, slip(cfg));

// K1: the Ø8 arc between the flats, closed toward -Y by chords from the flats' ends to the arc's point.
module key_2d(cfg) let(k = KEY, y = sqrt(k[0] ^ 2 - k[1] ^ 2)) offset(delta = slip(cfg)) intersection() {
    circle(r = k[0]);
    polygon([[-k[1], -y], [0, -k[0]], [k[1], -y], [k[1], BIG], [-k[1], BIG]]);
}

// --- layers -------------------------------------------------------------------------------------

module l1_2d(cfg = config) difference() { circle(d = BOSS_D); slot_2d(cfg); }
module l2_2d(cfg = config) difference() { circle(d = BOSS_D); hex_2d(nut_af(cfg)); }
module l3_2d(cfg = config) difference() { gear_2d(); hex_2d(nut_af(cfg)); }
module l4_2d(cfg = config) difference() { gear_2d(); circle(d = fit_bore(BOLT_D, slip(cfg))); }
module l5_2d(cfg = config) difference() { gear_2d(); key_2d(cfg); }
module l6_2d(cfg = config) difference() { circle(d = COLLAR_D); key_2d(cfg); }

// Layer i's slab, lapped LAP into its neighbour from the side of the narrower section: L1 .. L3 up (D1
// holds N1, N1 holds B1), L5 and L6 down (K1 holds B1). No slab then stands LAP proud of D1's ceiling
// or N1's, which the Span Driver's head and the M3 nut sit on.
LAP_LO = [0, 0, 0, 0, LAP, LAP];
LAP_HI = [LAP, LAP, LAP, 0, 0, 0];

module slab(i) translate([0, 0, Z[i] - LAP_LO[i]]) linear_extrude(Z[i + 1] - Z[i] + LAP_LO[i] + LAP_HI[i])
    children();

// C1: everything outside the cone r = z + 10.25, from below the underside to above the tips.
module chamfer() rotate_extrude($fn = 288)
    polygon([[CHAMFER_R - 1, -1], [TIP_R + 2, -1], [TIP_R + 2, TIP_R + 2 - CHAMFER_R]]);

// C2: everything outside the cone r = (TIP_R - TOP_CHAMFER) + (Z[5] - z), from below the tips' corner
// to above the top face.
module top_chamfer() rotate_extrude($fn = 288)
    polygon([[TIP_R - TOP_CHAMFER - 1, Z[5] + 1], [TIP_R + 2, Z[5] + 1],
             [TIP_R + 2, Z[5] - TOP_CHAMFER - 2]]);

// N1's flare: from D1's ceiling (and LAP into D1) up to N1 at 45 deg.
module flare(cfg) let(af = nut_af(cfg), h = FLARE + LAP)
    translate([0, 0, Z[1] - LAP]) linear_extrude(h, scale = af / (af + 2 * h)) hex_2d(af + 2 * h);

module pinion_gear(cfg = config) difference() {
    union() {
        slab(0) l1_2d(cfg);
        slab(1) l2_2d(cfg);
        slab(2) l3_2d(cfg);
        slab(3) l4_2d(cfg);
        slab(4) l5_2d(cfg);
        if (cfg != "revised") slab(5) l6_2d(cfg);   // R1: see COLLAR (revised)
    }
    chamfer();
    if (cfg == "revised") top_chamfer();   // C2: see TOP CHAMFER (revised)
    flare(cfg);
}

if (layer == "L1") l1_2d();
else if (layer == "L2") l2_2d();
else if (layer == "L3") l3_2d();
else if (layer == "L4") l4_2d();
else if (layer == "L5") l5_2d();
else if (layer == "L6") l6_2d();
else pinion_gear();
