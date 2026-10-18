// #630-004 Wave Gen Coupler — parametric source.
// Couples the motor shaft to the strain-wave drive's wave generator, one per
// drive (J1, J2, J3). The hex body is reamed onto the motor's Ø5 shaft and
// held by two M3 x 8 hex bolts, each threaded through an M3 nut in its pocket
// (008.3 steps 8 to 11); the stub above it carries the wave generator.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/600-StrainWave/).
//   config = "revised"  — the stub C-201's wave generator takes, with the
//                         shaft bore stopped in the hex (see STUB), and the
//                         print fits below.
//
// FRAME. The reference's own: the axis on +Z, the hex body's bottom face at
// z = 0, its top face (the stub's shoulder) at z = 10.000, and the stub's end
// at z = 23.000 (previous) or 25.000 (revised). The set-screw axis lies along
// X at z = 3.500.
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
// CONSTRUCTION. Two layers along Z, each one extruded 2D outline: X1, and
// S1 with K1 (S2 in revised). B1 is cut once, through both or into X1. N1 is one YZ section extruded
// along X and mirrored, and W1 is that section's strip |y| < 0.95 carried
// in to the axis: its flat end stands at the mean of the R0.1 tip round,
// 0.05 off the round at most. H1 and T1 are cylinders. `layer = "hex"` or
// `"stub"` exports a layer's outline with B1, for the outline gates.
//
// STUB. S1 and K1 take a Cone Drive wave generator's input. C-201's takes a
// Ø6H7 bore with two M3 set screws at 90 deg, 2.5 in from its hub's outer end
// (007.1 C-201). The manufacturer's drawing (../../Reference/XB1-AS-C-32.pdf)
// runs that bore through the hub's full 15 mm. A Ø6 stub has no room for the
// Ø5 shaft through it, so, by the reviewer's decision (DC-600-1), the revised
// stub is solid and the shaft bore stops in the hex:
//
//     S2 stub, into the Ø6H7 bore          Ø6.0, 15.0 long, the bore's depth
//                                          (z 10 .. 25)
//     B1 shaft bore                        blind, ending at z 9.0: a 1.0
//                                          floor under the stub's root,
//                                          which would otherwise stand on
//                                          the bore's rim alone
//
// FITS (../print_fit.scad), revised only. Each draws its class clearance per
// side over its mate's nominal:
//
//     S2 in the wave generator's Ø6H7      press
//     B1 on the motor's Ø5 shaft           press
//     H1 on the M3 x 8 bolt                slip
//     N1 on the M3 nut (5.5 AF, 2.4 thick) slip, across its flats and its
//                                          thickness; the pocket grows
//                                          inward from its outer face at
//                                          x 5.0, so the bolt's wall keeps
//                                          its thickness, and its gable
//                                          rises with its width
//
// ASSEMBLY. Placement reads wgc_shoulder(), wgc_top(cfg), wgc_screw_z(),
// wgc_stub(cfg) and wgc_bore_top(cfg); this file draws no BOSL2, so an
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
BORE_FLOOR  = 1.000;             // revised: hex left under the stub's root
// The mates' nominals, for the revised fits.
SHAFT_D     = 5.000;             // C-101's shaft
WG_BORE     = [6.000, 15.000];   // C-201's wave-generator input bore: Ø, depth
M3          = 3.000;
NUT         = [5.500, 2.400];    // M3 hex: across flats, thickness

function slip(cfg) = fit_clearances(cfg)[0];
function press(cfg) = fit_clearances(cfg)[1];
function bore_d(cfg) = cfg == "previous" ? BORE_D : fit_bore(SHAFT_D, press(cfg));
function bore_top(cfg) = cfg == "previous" ? STUB_TOP : HEX_TOP - BORE_FLOOR;
function stub_d(cfg) = cfg == "previous" ? STUB_D : fit_pin(WG_BORE[0], press(cfg));
function stub_top(cfg) = cfg == "previous" ? STUB_TOP : HEX_TOP + WG_BORE[1];
function screw_hole_d(cfg) = cfg == "previous" ? SCREW_HOLE : fit_bore(M3, slip(cfg));
function pocket(cfg) = cfg == "previous" ? POCKET : [fit_bore(NUT[0], slip(cfg)), fit_bore(NUT[1], slip(cfg))];

function wgc_shoulder() = HEX_TOP;
function wgc_top(cfg = config) = stub_top(cfg);
function wgc_screw_z() = SCREW_Z;
function wgc_hex_af() = HEX_AF;
function wgc_stub(cfg = config) = [stub_d(cfg), stub_top(cfg) - HEX_TOP];
function wgc_bore_d(cfg = config) = bore_d(cfg);
function wgc_bore_top(cfg = config) = bore_top(cfg);

module bore_2d(cfg) circle(d = bore_d(cfg));
module hex_outline() rotate(30) circle(d = HEX_AF / cos(30), $fn = 6);
// S1 with K1 (previous), or S2 (revised).
module stub_outline(cfg) {
    circle(d = stub_d(cfg));
    if (cfg == "previous") translate([-KEY[0] / 2, 0]) square([KEY[0], KEY[1]]);
}

// N1's section in (y, z), open below z = 0: straight sides up to POCKET_FLAT,
// then the 30 deg gable.
module pocket_2d(cfg) {
    w = pocket(cfg)[0] / 2;
    polygon([[-w, -1], [w, -1], [w, POCKET_FLAT], [0, POCKET_FLAT + w * tan(30)], [-w, POCKET_FLAT]]);
}

module pockets(cfg) {
    t = pocket(cfg)[1];
    for (m = [0, 1]) mirror([m, 0, 0])
        rotate([90, 0, 90]) {
            translate([0, 0, POCKET_OUT - t]) linear_extrude(t) pocket_2d(cfg);
            linear_extrude(POCKET_OUT - t + epsilon) intersection() {
                pocket_2d(cfg);
                translate([-OPENING, -2]) square([2 * OPENING, HEX_TOP + 2]);
            }
        }
}

module screw_hole(cfg)
    translate([0, 0, SCREW_Z]) rotate([0, 90, 0]) cylinder(d = screw_hole_d(cfg), h = HEX_AF + 2, center = true, $fn = 48);

module notches()
    for (k = [0 : 5]) rotate(90 + 60 * k) translate([NOTCH[1], 0, HEX_TOP]) rotate([0, 90, 0])
        cylinder(d = NOTCH[0], h = HEX_AF, $fn = 48);

module wave_gen_coupler(cfg = config)
    difference() {
        union() {
            linear_extrude(HEX_TOP) hex_outline();
            translate([0, 0, HEX_TOP - SEAM_LAP]) linear_extrude(stub_top(cfg) - HEX_TOP + SEAM_LAP) stub_outline(cfg);
        }
        // Through the stub's end (previous), or blind (revised).
        translate([0, 0, -1]) linear_extrude(bore_top(cfg) + (cfg == "previous" ? 2 : 1)) bore_2d(cfg);
        pockets(cfg);
        screw_hole(cfg);
        notches();
    }

assert(POCKET_OUT < HEX_AF / 2 - 2, "the bolt's wall outside the nut pocket is too thin");
assert(POCKET_FLAT + pocket("revised")[0] / 2 * tan(30) < HEX_TOP - NOTCH[0] / 2, "the pocket's apex reaches the notches");
assert(bore_top("revised") > POCKET_FLAT + pocket("revised")[0] / 2 * tan(30), "the blind bore ends below the nut pockets");

if (layer == "hex") difference() { hex_outline(); bore_2d(config); }
else if (layer == "stub") difference() { stub_outline(config); bore_2d(config); }
else wave_gen_coupler();
