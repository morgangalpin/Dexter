// #630-004 Wave Gen Coupler — parametric source.
// Couples the motor shaft to the strain-wave drive's wave generator, one per
// drive (J1, J2, J3), and one design for all three.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/600-StrainWave/): a hex body
//                         reamed onto the shaft and held by two M3 x 8 hex
//                         bolts in M3 nuts, under a keyed Ø10 stub.
//   config = "revised"  — one round piece for C-201 (see REVISED), with the
//                         print fits below. Decision: DC-600-2 in
//                         specs/009-Design-Completion.md.
//
// FRAME. The axis on +Z and the bottom face at z = 0 in both configurations.
// Previous: the reference's own, with the hex body's top face (the stub's
// shoulder) at z = 10.000, the stub's end at z = 23.000 and the set-screw axis
// along X at z = 3.500. Revised: the bottom face stands wgc_above_motor()
// above the motor's mounting face, where the 008.3 step 10 tool sets it, and
// the grub screw's axis lies along +Y at z = 7.900.
//
// Measured from the reference (scadmesh slice/arcs/profile/solid):
//
//     feature                       value                      z span
//     X1 hex body                   16.0 across flats,
//                                   corners on ±Y              0 .. 10
//     S1 stub                       Ø10.0                      10 .. 23
//     K1 key on the stub            3.0 wide, on +Y, its flat
//                                   top 6.0 from the axis      10 .. 23
//     B1 shaft bore                 Ø5.0, through              0 .. 23
//     H1 set-screw hole             Ø3.2 along X, through
//                                   both flats, axis z 3.5     1.9 .. 5.1
//     N1 nut pockets, 2             x ±(2.5 .. 5.0); 5.6 wide
//                                   in Y up to z 5.6, then a
//                                   30 deg gable to its apex   0 .. 7.217
//     W1 openings, 2                each pocket opens into B1
//                                   across |y| < 1.0, the
//                                   wall's tip a full R0.1     0 .. 7.217
//     T1 corner notches, 6          Ø4.0 along each corner's
//                                   radial, axis at z 10.0,
//                                   from a flat end at r 7.0   8 .. 10
//
// The previous render's volume, 2531.88 mm3, closes on the mesh's 2531.88.
//
// CONSTRUCTION (previous). Two layers along Z, each one extruded 2D outline:
// X1, and S1 with K1. B1 is cut through both. N1 is one YZ section extruded
// along X and mirrored, and W1 is that section's strip |y| < 0.95 carried in
// to the axis: its flat end stands at the mean of the R0.1 tip round, 0.05
// off the round at most. H1 and T1 are cylinders. `layer = "hex"` or
// `"stub"` exports a layer's outline with B1, for the outline gates.
//
// REVISED. The keyed stub takes a Cone Drive wave generator's input; C-201's
// takes a Ø6H7 bore through its 15 mm hub, held by two M3 set screws 2.5 in
// from its outer face (007.1 C-201). The motor's Ø5 x 24 shaft, with its
// 15 mm flat, stays as bought. The drive stands 5.0 further from the motor
// than the reference set it, so that the coupler's body runs from over the
// motor's boss, through the Flex Spline Attach, the flexspline's hub and the
// Flex Spline Cap, to just under the wave generator, and its Ø6 stub runs up
// the wave generator's bore past the set screws. Heights above the motor face
// are this frame's z plus 2.5:
//
//     feature                       value                      z span
//     R1 foot                       Ø12.2: 0.5 inside the Attach's M2
//                                   screw heads, which stand at
//                                   r 6.6 up to 5.75 above the
//                                   motor face                 0 .. 3.75
//     R2 grip                       Ø13.0: it passes those heads
//                                   as the Attach goes on over
//                                   it                         3.75 .. 11.3
//     R3 body                       Ø10.0: the running clearance
//                                   in the hub's Ø11 bore      11.3 .. 23.5
//     R4 stub                       Ø6.0, into the wave
//                                   generator's bore, past its
//                                   set screws in J1, J2 and J3  23.5 .. 40
//     B2 shaft bore                 Ø5.0, blind, 1.0 past the
//                                   shaft's tip; 1.0 floor     0 .. 22.5
//     N2 nut pocket, 1              the M3 nut, its axis along
//                                   +Y and its flats facing ±X:
//                                   y 2.5 .. 5.0, x ±2.75; open
//                                   below, a 30 deg gable over
//                                   the nut's upper corner     0 .. 11.075
//     H2 grub-screw hole            Ø3.0 along +Y, axis z 7.9,
//                                   from N2 out through R2     6.4 .. 9.4
//
// The screw is an M3 x 4 grub screw, driven through N2's nut onto the shaft's
// flat, which starts 9.0 above the motor face: its cup point (Ø1.4) lands
// 0.7 past that. It is a grub screw because a bolt's head on R2 would sweep r 6.5 to
// 9.5 as the shaft turns, through the M2 screws' shanks at r 7.5 to 9.5. It is
// driven through the Attach's access hole, and the screw goes in the same
// way. R2 stands 0.5 under the hub's face in J3, whose hub face is the lowest
// (DC-600-2). R2 is wider than the hub's bore, so the coupler goes on the shaft
// before the Attach goes on the motor (008.3).
//
// FITS (../print_fit.scad). Each draws its class clearance per side over its
// mate's nominal:
//
//     previous:  none; the reference's sizes.
//     revised:   B2 on the motor's Ø5 shaft           press
//                R4 in the wave generator's Ø6H7      press
//                H2 on the M3 grub screw              slip
//                N2 on the M3 nut (5.5 AF, 2.4        slip, across its flats
//                  thick)                             and its thickness; it
//                                                     grows inward from its
//                                                     outer face at y 5.0
//
// The running clearances to the parts that stand still about R1, R2 and R3 are
// drawn by those parts and asserted by the Flex Spline Attach.
//
// ASSEMBLY. Placement reads wgc_above_motor(), wgc_top(cfg), wgc_body(cfg),
// wgc_grip(cfg), wgc_foot(cfg), wgc_stub(cfg), wgc_screw_z(cfg),
// wgc_bore_d(cfg) and wgc_bore_top(cfg); this file draws no BOSL2, so an
// assembly can `use` it.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D outline for its outline gate
layer = "part"; // [part, hex, stub]

/* [Hidden] */
$fn = 144;
epsilon = 0.01;
SEAM_LAP = 0.005;    // the stub runs this far into the hex, so the two join

// Previous.
HEX_AF      = 16.000;
HEX_TOP     = 10.000;
STUB_D      = 10.000;
STUB_TOP    = 23.000;
KEY         = [3.000, 6.000];    // width, flat top's distance from the axis
BORE_D      = 5.000;
SCREW_Z     = 3.500;
SCREW_HOLE  = 3.200;
POCKET      = [5.600, 2.500];    // width across the nut's flats, thickness along X
POCKET_OUT  = 5.000;             // outer face, x
POCKET_FLAT = 5.600;             // top of the straight sides
OPENING     = 0.950;             // W1's half-width
NOTCH       = [4.000, 7.000];    // Ø, the flat end's distance from the axis
// Revised.
ABOVE_MOTOR = 2.500;             // bottom face over the motor face: the boss's 2.0 and the running clearance
FOOT        = [12.200, 3.750];   // R1: Ø, top
GRIP        = [13.000, 11.300];  // R2: Ø, top
BODY        = [10.000, 23.500];  // R3: Ø, top
STUB_END    = 40.000;            // R4's end
BORE_PAST   = 1.000;             // B2's end beyond the shaft's tip
BORE_FLOOR  = 1.000;             // R3 left over B2's end
GRUB_Z      = 7.900;
NUT_OUT     = 5.000;             // N2's outer face, y
// The mates' nominals.
SHAFT       = [5.000, 24.000];   // C-101's shaft: Ø, length beyond the motor face
WG_BORE_D   = 6.000;             // C-201's wave-generator input bore
M3          = 3.000;
NUT         = [5.500, 2.400];    // M3 hex: across flats, thickness

function slip(cfg) = fit_clearances(cfg)[0];
function press(cfg) = fit_clearances(cfg)[1];
function bore_d(cfg) = cfg == "previous" ? BORE_D : fit_bore(SHAFT[0], press(cfg));
function bore_top(cfg) = cfg == "previous" ? STUB_TOP : SHAFT[1] + BORE_PAST - ABOVE_MOTOR;
function stub_d(cfg) = cfg == "previous" ? STUB_D : fit_pin(WG_BORE_D, press(cfg));
function stub_top(cfg) = cfg == "previous" ? STUB_TOP : STUB_END;
function body_top(cfg) = cfg == "previous" ? HEX_TOP : BODY[1];
function screw_hole_d(cfg) = cfg == "previous" ? SCREW_HOLE : fit_bore(M3, slip(cfg));
function pocket(cfg) = cfg == "previous" ? POCKET : [fit_bore(NUT[0], slip(cfg)), fit_bore(NUT[1], slip(cfg))];

// The revised coupler's place and sizes; previous returns its own where it
// has the feature, and undef where it does not.
function wgc_above_motor() = ABOVE_MOTOR;
function wgc_top(cfg = config) = stub_top(cfg);
function wgc_body(cfg = config) = cfg == "previous" ? undef : [BODY[0], body_top(cfg)];
function wgc_grip(cfg = config) = cfg == "previous" ? undef : GRIP;
function wgc_foot(cfg = config) = cfg == "previous" ? undef : FOOT;
function wgc_stub(cfg = config) = [stub_d(cfg), stub_top(cfg) - body_top(cfg)];
function wgc_screw_z(cfg = config) = cfg == "previous" ? SCREW_Z : GRUB_Z;
function wgc_bore_d(cfg = config) = bore_d(cfg);
function wgc_bore_top(cfg = config) = bore_top(cfg);

module bore_2d(cfg) circle(d = bore_d(cfg));

// --- Previous ----------------------------------------------------------------
module hex_outline() rotate(30) circle(d = HEX_AF / cos(30), $fn = 6);
module stub_outline() {
    circle(d = STUB_D);
    translate([-KEY[0] / 2, 0]) square([KEY[0], KEY[1]]);
}

// N1's section in (y, z), open below z = 0: straight sides up to POCKET_FLAT,
// then the 30 deg gable.
module pocket_2d() {
    w = POCKET[0] / 2;
    polygon([[-w, -1], [w, -1], [w, POCKET_FLAT], [0, POCKET_FLAT + w * tan(30)], [-w, POCKET_FLAT]]);
}

module pockets() {
    t = POCKET[1];
    for (m = [0, 1]) mirror([m, 0, 0])
        rotate([90, 0, 90]) {
            translate([0, 0, POCKET_OUT - t]) linear_extrude(t) pocket_2d();
            linear_extrude(POCKET_OUT - t + epsilon) intersection() {
                pocket_2d();
                translate([-OPENING, -2]) square([2 * OPENING, HEX_TOP + 2]);
            }
        }
}

module notches()
    for (k = [0 : 5]) rotate(90 + 60 * k) translate([NOTCH[1], 0, HEX_TOP]) rotate([0, 90, 0])
        cylinder(d = NOTCH[0], h = HEX_AF, $fn = 48);

module previous_coupler()
    difference() {
        union() {
            linear_extrude(HEX_TOP) hex_outline();
            translate([0, 0, HEX_TOP - SEAM_LAP]) linear_extrude(STUB_TOP - HEX_TOP + SEAM_LAP) stub_outline();
        }
        translate([0, 0, -1]) linear_extrude(STUB_TOP + 2) bore_2d("previous");
        pockets();
        translate([0, 0, SCREW_Z]) rotate([0, 90, 0]) cylinder(d = SCREW_HOLE, h = HEX_AF + 2, center = true, $fn = 48);
        notches();
    }

// --- Revised -----------------------------------------------------------------
// R1 to R4 as one revolved profile.
module revised_profile(cfg)
    polygon([[0, 0], [FOOT[0] / 2, 0], [FOOT[0] / 2, FOOT[1]], [GRIP[0] / 2, FOOT[1]],
             [GRIP[0] / 2, GRIP[1]], [BODY[0] / 2, GRIP[1]], [BODY[0] / 2, BODY[1]],
             [stub_d(cfg) / 2, BODY[1]], [stub_d(cfg) / 2, STUB_END], [0, STUB_END]]);

// N2, a prism along Y from its outer face inward to the bore, open below. Its
// flats face ±X, so the nut slides up it, and its roof is the nut's upper
// corner: straight sides to GRUB_Z + w tan 30, then a 30 deg gable to the
// apex at GRUB_Z + w / cos 30, w the half-width.
function nut_pocket_apex(cfg) = GRUB_Z + pocket(cfg)[0] / 2 / cos(30);
function nut_pocket_shoulder(cfg) = GRUB_Z + pocket(cfg)[0] / 2 * tan(30);
module nut_pocket(cfg) {
    p = pocket(cfg);
    w = p[0] / 2;
    translate([0, NUT_OUT, 0]) rotate([90, 0, 0]) linear_extrude(p[1])
        polygon([[-w, -1], [w, -1], [w, nut_pocket_shoulder(cfg)], [0, nut_pocket_apex(cfg)], [-w, nut_pocket_shoulder(cfg)]]);
}

module revised_coupler(cfg)
    difference() {
        rotate_extrude() revised_profile(cfg);
        translate([0, 0, -1]) cylinder(d = bore_d(cfg), h = bore_top(cfg) + 1);
        nut_pocket(cfg);
        translate([0, NUT_OUT - epsilon, GRUB_Z]) rotate([-90, 0, 0]) cylinder(d = screw_hole_d(cfg), h = GRIP[0], $fn = 48);
    }

module wave_gen_coupler(cfg = config)
    if (cfg == "previous") previous_coupler();
    else revised_coupler(cfg);

assert(POCKET_OUT < HEX_AF / 2 - 2, "the bolt's wall outside the nut pocket is too thin");
assert(POCKET_FLAT + POCKET[0] / 2 * tan(30) < HEX_TOP - NOTCH[0] / 2, "the pocket's apex reaches the notches");
assert(bore_top("revised") + BORE_FLOOR <= BODY[1], "the stub stands on the shaft bore's floor");
assert(nut_pocket_apex("revised") < GRIP[1], "the nut pocket's apex reaches past the grip, beside the body");
assert(nut_pocket_shoulder("revised") < GRIP[1] - 0.4, "the nut pocket's roof outside the body is under two layers");
assert(norm([pocket("revised")[0] / 2, NUT_OUT]) < GRIP[0] / 2 - 0.6, "the grip's wall outside the nut pocket's corners is too thin");
assert(GRUB_Z - 0.7 + ABOVE_MOTOR > SHAFT[1] - 15 + 0.5, "the grub screw's cup point is off the shaft's flat");

if (layer == "hex") difference() { hex_outline(); bore_2d(config); }
else if (layer == "stub") difference() { stub_outline(); bore_2d(config); }
else wave_gen_coupler();
