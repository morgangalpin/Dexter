// #510-001 External Gear — parametric source.
// J3's output: a 100-tooth GT2 pulley in two bands either side of a flange,
// carried on two 6810s (008.8 step 5), and turned by the Ex Gear Stator
// Holder, whose eight keys go into the slots in its notched end (step 8). The
// belts on its two bands carry J3's motion up the arm.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/500-ExternalGear/), in that
//                         mesh's frame.
//   config = "revised"  — the same part with its print fits on the two 6810s.
//
// FRAME. The part is drawn about +Z, its notched end up (external_gear()).
// The file's top level turns it into the reference's frame, whose axis is +X:
// mesh (x, y, z) = part (z, x, y). exgear_assembly.scad places the part's
// frame directly, up the drive axis. Angles below are about the axis from the
// part's +X (the mesh's +y): one groove of the teeth, and one key slot, lie on
// 0 deg.
//
// CONSTRUCTION. A region split:
//
//   1. The body is one revolved profile (rung 3): the bore with both 6810
//      seats, the outside with its cones, chamfers and flange, and the two
//      bands drawn at R30.700, inside the teeth's root.
//   2. Each tooth band is the GT2 tooth ring (../gt2_pulley.scad,
//      gt2_teeth_rounded_2d) extruded over the band, lapped BAND_LAP into the
//      flanges either side, where their chamfers cover it.
//   3. G1 is cut as one revolved triangle (a revolved cutter).
//   4. The eight key slots are cut last, each one prism: 4.0 wide, its outer
//      face flat at 34.100 from the axis, its floor a 45 deg ramp up from the
//      bore at z 36.250.
//
// `layer = "band"` or `"socket"` draws the section through a tooth band or
// through the slots in 2D, in the reference's coordinates (mesh y, z), for
// verification against the mesh's section (scadmesh outline; render.rs
// --verify does this).
//
// Measured from the reference with scadmesh planes/profile (swept, so each
// radius is the true one, not a facet's)/slice/arcs/teeth. The feature IDs are
// those of 510-001_ExternalGear.view.json:
//
//     ID  feature                    value (z along the axis, r radius)
//     E1  lower end                  z -32.263; Ø70.527 to z -30.263
//     O1  lower rim                  Ø73.954, z -30.263 .. -23.763
//     O2  cone                       to r 33.723 at z -14.362
//     O3  lower collar               r 33.723 to z -11.050, then 45 deg to
//                                    r 31.723 at z -9.050
//     T1  lower band                 z -9.050 .. 1.700
//     F1  flange                     z 1.700 .. 5.700: r 32.000 at both faces,
//                                    45 deg chamfers to r 33.500 over z 3.2 .. 4.2
//     T2  upper band                 z 5.700 .. 15.250
//     O4  upper collar               r 32.478 to z 17.205, 45 deg to r 33.723
//                                    at z 18.450, flat to z 21.214, then a
//                                    45 deg cone out to O5
//     O5  upper rim                  Ø73.954, z 24.468 .. 44.250
//     E2  notched end                z 44.250
//     TT  teeth                      100, GT2, tip Ø63.144, groove bottom
//                                    Ø61.570 (GT2_TOOTH_H), groove R0.61,
//                                    grooves on 0 deg + 3.6 deg k
//     B1  lower 6810 seat            Ø65.000, z -32.263 .. -24.763
//     B2  lower shoulder             Ø62.000 to z -23.763, then a cone in to
//                                    Ø55.000 at z -13.652
//     B3  bore                       Ø55.000 to z 25.243
//     B4  upper 6810 seat            Ø65.000 from z 25.243 to E2; it is also the
//                                    Stator Holder's socket
//     K1  key slots                  8 on 0 deg + 45 deg k, 4.0 wide, outer face
//                                    at 34.100, floor 45 deg from r 32.500 at
//                                    z 36.250 to r 34.100 at z 37.850
//     G1  crack                      a groove closed at its mouth, between O4's
//                                    flat and its cone: floor r 32.478 over
//                                    z 19.831 .. 19.970, its walls rising to meet
//                                    at r 33.723, z 21.214; the tangency the mesh
//                                    was pinched along (README § Known defects)
//
// Left out: the reference's faces within 0.013 of the upper shoulder (it has
// steps at z 25.237, 25.243 and 25.250, each under 0.022 high).
//
// FITS (../print_fit.scad), revised only:
//
//     B1, on the lower 6810's outer race (Ø65)        press
//     B4, on the upper 6810's outer race (Ø65), over
//         the bearing's 7.0 from the shoulder          press
//     B3, round the upper 6810's inner race (Ø54.5),
//         which stays with the Attach while this turns running
//
// B4 above the bearing is the Stator Holder's socket. That fit is drawn on the
// holder (#511-002), so the socket keeps its size. The teeth carry GT2 belts,
// and the slots the holder's keys, whose fit is also the holder's.

include <../print_fit.scad>
include <../gt2_pulley.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or a section's 2D profile
layer = "part"; // [part, band, socket]

/* [Hidden] */
$fn = 360;
epsilon = 0.01;

TEETH       = 100;          // TT
TIP_D       = 63.144;       // TT
BAND_R      = 30.700;       // the body under the teeth, inside their root
BAND_LAP    = 0.005;        // each band's lap into the flanges either side
BAND_LOWER  = [-9.050, 1.700];   // T1
BAND_UPPER  = [5.700, 15.250];   // T2
SEAT_D      = 65.000;       // B1, B4
BORE_R      = 27.500;       // B3
LOWER_SHLDR = -24.763;      // B1's shoulder
UPPER_SHLDR = 25.243;       // B4's shoulder
KEYED_END   = 44.250;       // E2
BOTTOM      = -32.263;      // E1
BEARING_W   = 7.000;        // the 6810's width
SLOT        = [8, 4.000, 34.100, 36.250];  // K1: count, width, outer face, z where the ramp leaves the bore
CRACK       = [[32.478, 19.831], [32.478, 19.970], [33.723, 21.2145]];  // G1: [r, z] floor ends, mouth
OUTER_D     = 65.000;       // the 6810's outer race
INNER_D     = 54.500;       // the 6810's inner race, its outside

// For the assembly: the shoulders the two 6810s stand on, the notched end, the
// lower end, and the largest radius.
function gear_lower_shoulder() = LOWER_SHLDR;
function gear_upper_shoulder() = UPPER_SHLDR;
function gear_keyed_end() = KEYED_END;
function gear_bottom() = BOTTOM;
function gear_rotor_r() = 73.954 / 2;

function seat_r(cfg) = (cfg == "previous" ? SEAT_D : fit_bore(OUTER_D, fit_clearances(cfg)[1])) / 2;
function bore_r(cfg) = cfg == "previous" ? BORE_R : fit_bore(INNER_D, fit_clearances(cfg)[2]) / 2;

// The body's [r, z] profile, the bore up and the outside down, with the seats
// and the bore in configuration cfg. B4 above the bearing keeps SEAT_D.
function body_profile(cfg) = let (s = seat_r(cfg), u = SEAT_D / 2, b = bore_r(cfg)) [
    [s, BOTTOM], [s, LOWER_SHLDR],                          // B1
    [31.000, LOWER_SHLDR], [31.000, -23.763],               // B2
    [b, -13.652], [b, UPPER_SHLDR],                         // B2's cone, B3
    [s, UPPER_SHLDR], [s, UPPER_SHLDR + BEARING_W],         // B4 under the bearing
    [u, UPPER_SHLDR + BEARING_W], [u, KEYED_END],           // B4 above it
    [36.977, KEYED_END], [36.977, 24.468],                  // O5
    [33.723, 21.214], [33.723, 18.450], [32.478, 17.205],   // O4
    [32.478, BAND_UPPER[1]], [BAND_R, BAND_UPPER[1]],       // T2
    [BAND_R, BAND_UPPER[0]], [32.000, BAND_UPPER[0]],
    [33.500, 4.200], [33.500, 3.200], [32.000, BAND_LOWER[1]],   // F1
    [BAND_R, BAND_LOWER[1]], [BAND_R, BAND_LOWER[0]],       // T1
    [31.723, BAND_LOWER[0]], [33.723, -11.050],             // O3
    [33.723, -14.362], [36.977, -23.763],                   // O2
    [36.977, -30.263], [35.263, -30.263], [35.263, BOTTOM]  // O1, E1
];

// The tooth ring, its arcs faceted by angle and length rather than by $fn: a
// whole-circle count on each groove and tip round would put 360 facets on
// every one of the 200 small arcs per band.
module ring_2d() gt2_teeth_rounded_2d(TEETH, TIP_D, $fn = 0, $fa = 1, $fs = 0.05);

module teeth_2d() difference() { ring_2d(); circle(r = BAND_R - 0.1); }

module band(z) translate([0, 0, z[0] - BAND_LAP]) linear_extrude(z[1] - z[0] + 2 * BAND_LAP) teeth_2d();

// One key slot on +X: its section in [r, z], swept across its width.
module slot() {
    w = SLOT[1];
    rotate([90, 0, 0]) translate([0, 0, -w / 2]) linear_extrude(w)
        polygon([[BORE_R, SLOT[3] - (SEAT_D / 2 - BORE_R)], [SEAT_D / 2, SLOT[3]],
                 [SLOT[2], SLOT[3] + SLOT[2] - SEAT_D / 2], [SLOT[2], KEYED_END + 1],
                 [BORE_R, KEYED_END + 1]]);
}

// G1, revolved: a triangle whose apex is carried 0.05 out past O4's corner
// into the air, so the cut never ends on the surface.
module crack() {
    rotate_extrude() polygon([CRACK[0], CRACK[1], CRACK[2] + [0.05, 0.05]]);
}

module external_gear(cfg = config) {
    difference() {
        union() {
            rotate_extrude() polygon(body_profile(cfg));
            band(BAND_LOWER);
            band(BAND_UPPER);
        }
        crack();
        for (k = [0 : SLOT[0] - 1]) rotate(k * 360 / SLOT[0]) slot();
    }
}

// The sections the outline gates read: through a band, and through the slots.
module band_2d() difference() { ring_2d(); circle(r = BORE_R); }

module socket_2d() difference() {
    circle(d = 73.954);
    circle(d = SEAT_D);
    for (k = [0 : SLOT[0] - 1]) rotate(k * 360 / SLOT[0])
        translate([0, -SLOT[1] / 2]) square([SLOT[2], SLOT[1]]);
}

// The part's frame into the reference's: mesh (x, y, z) = part (z, x, y).
module to_reference() multmatrix([[0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0]]) children();

if (layer == "band") band_2d();
else if (layer == "socket") socket_2d();
else to_reference() external_gear(config);
