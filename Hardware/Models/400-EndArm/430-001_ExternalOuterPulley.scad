// #430-001 External Outer Pulley — parametric source.
// The outer channel's stage-1 driven pulley at the elbow: 90T in "previous",
// 108T in "revised" (DC-12). It is locked on the stainless tube by three M3 set
// screws, each running in an M3 nut epoxied into a slot (008.7 steps 17, 18,
// 23). The shared definition, and what each configuration builds, is in
// external_pulley.scad.
//
// FRAME. The axis is +Z through the origin, the rim's lower edge at z 22.5 and
// the top face at z 32.0, the frame the End Arm group's J3-axis parts share.
// The windows and the slots are on 60, 180 and 300 deg. The reference mesh is
// already in this frame.
//
// CONSTRUCTION. The body is turned, so it is one revolved profile (the
// mesh-to-scad ladder's rung 3): bore, web, rim, flanges and the band's core,
// with external_pulley.scad's 90T band (rung 7). The windows are one 2D outline
// each (rung 1): the annulus between the hub and the rim, less the spokes,
// its inner corners rounded R3 and its outer R4 by two openings (rung 5), cut
// through the web, with its top edge's 45 deg chamfer as that outline summed
// with a cone. The nut slots and the set-screw holes are primitive cutters
// (rung 2), patterned; each hole runs from the bore out through the rim, which
// is how a key reaches the set screw.
//
// "revised" keeps everything inside R_CUT, which is the whole web and the
// inner 2 mm of the rim, and adds the 108T rim; the holes are drilled through
// the new rim at their fit.
//
// Measured from the reference with scadmesh planes/slice/arcs/profile/teeth.
// The feature IDs are those of 430-001_ExternalOuterPulley.view.json, which
// labels each one on the mesh:
//
//     ID  feature                     value
//     B1  bore                        Ø8.000 (on the stainless tube), through the web
//     W1  web                         z 23.5 .. 32.0, bore to rim
//     R1  rim                         inner R24.0 above the web; below it R24.987
//                                     at z 22.5, chamfered to R24.0 at z 23.5
//     F1  flanges                     R29.487 z 22.5 .. 23.0, chamfered to R28.487
//                                     at z 24.0; R28.5 at z 30.5, chamfered to
//                                     R29.5 at z 31.5, R29.5 to z 32.0
//     T1  90T GT2 band                z 24.0 .. 30.5, tip R28.397, the rounded-tip
//                                     form
//     O1  windows, 3 on 60 deg        the annulus r 14.0 .. 24.0 between spokes
//         + 120 deg k                 4.0 wide on 0 deg + 120 deg k; inner
//                                     corners R3.0, outer R4.0; top edge chamfered
//                                     1.0 x 45 deg
//     N1  nut slots, 3 on the         2.5 radial (r 5.15 .. 7.65) x 5.5, open at
//         windows' angles             the web's underside; a flat roof at z 29.5,
//                                     its corners chamfered 1.5 x 45 deg
//     T1  (phase)                     a tooth on 0 deg
//     S1  set-screw holes             Ø3.000 at z 26.5 on each slot's radius,
//                                     from the bore out through the rim
//
// FITS (../print_fit.scad), revised only:
//
//     B1, on the Ø8 stainless tube                       press
//     N1, on the M3 nut (5.5 across flats, 2.4 thick)    slip; the reference's
//                                                        slot is line to line
//     S1, on the M3 set screw                            slip

include <external_pulley.scad>

/* [Hidden] */
R_CUT      = 26.0;
RIM_LOWER  = [[1.090, 22.5], [1.090, 23.0], [0.090, 24.0]];
RIM_UPPER  = [[0.103, 30.5], [1.103, 31.5], [1.103, 32.0]];

BORE_D     = 8.000;                    // B1
TUBE_D     = 8.000;
WEB        = [23.500, 32.000];         // W1: z span
RIM        = [24.000, 24.987, 22.500]; // R1: inner r, r at the lower edge, lower edge z
FLANGES    = [29.487, 23.000, 28.487, 24.000, 28.500, 30.500, 29.500, 31.500];
                                       // F1: [r, z] pairs, bottom up
WINDOW     = [14.000, 24.000, 2.000, 3.000, 4.000, 1.000];
                                       // O1: inner r, outer r, spoke half-width,
                                       //     inner and outer corner R, chamfer
WINDOW_AT  = [60, 120];                // O1, N1, S1: first angle, pitch
SLOT       = [6.400, 2.500, 5.500, 29.500, 1.500];
                                       // N1: centre r, radial, tangential, roof z,
                                       //     roof's corner chamfer
SCREW      = [3.000, 26.500];          // S1: Ø, z
NUT        = [5.500, 2.400];           // M3 nut: across flats, thickness
M3_D       = 3.000;

FITS = fit_clearances(config);
function bore_d()  = max(BORE_D, fit_bore(TUBE_D, FITS[1]));
function slot()    = [max(SLOT[1], fit_bore(NUT[1], FITS[0])), max(SLOT[2], fit_bore(NUT[0], FITS[0]))];
function screw_d() = max(SCREW[0], fit_bore(M3_D, FITS[0]));

function body_profile() =
    let (rc = REF_ROOT_R - ROOT_CLEAR, f = FLANGES)
    [[bore_d() / 2, WEB[0]], [RIM[0], WEB[0]], [RIM[1], RIM[2]], [f[0], RIM[2]], [f[0], f[1]],
     [f[2], f[3]], [rc, f[3]], [rc, f[5]], [f[4], f[5]], [f[6], f[7]], [f[6], WEB[1]],
     [bore_d() / 2, WEB[1]]];

module window_round_2d() pulley_window_2d(WINDOW);

module at_windows() for (k = [0 : 2]) rotate(WINDOW_AT[0] + k * WINDOW_AT[1]) children();

// The windows' cutter: the outline through the web, and the top edge's
// chamfer as the outline at the chamfer's foot summed with a 45 deg cone.
module window_cutter() {
    c = WINDOW[5];
    translate([0, 0, WEB[0] - 1]) linear_extrude(WEB[1] - WEB[0] + 2) window_round_2d();
    minkowski() {
        translate([0, 0, WEB[1] - c]) linear_extrude(epsilon) window_round_2d();
        cylinder(r1 = 0, r2 = 2 * c, h = 2 * c, $fn = 48);
    }
}

// One nut slot's outline in its tangential plane [y, z]: straight sides from
// below the web up to the flat roof, its two top corners chamfered 45 deg.
function slot_outline(w) =
    let (c = SLOT[4])
    [[-w / 2, WEB[0] - 1], [w / 2, WEB[0] - 1], [w / 2, SLOT[3] - c], [w / 2 - c, SLOT[3]],
     [-w / 2 + c, SLOT[3]], [-w / 2, SLOT[3] - c]];

// One nut slot and its set-screw hole, on +X; the hole reaches `out`.
module slot_cutter(out) {
    s = slot();
    translate([SLOT[0], 0, 0]) rotate([90, 0, 90]) linear_extrude(s[0], center = true) polygon(slot_outline(s[1]));
    translate([BORE_D / 2 - 1, 0, SCREW[1]]) rotate([0, 90, 0]) cylinder(d = screw_d(), h = out - BORE_D / 2 + 1, $fn = 48);
}

// The 90T pulley, before the slots' holes are run out through the rim.
module body() {
    difference() {
        union() {
            rotate_extrude() polygon(body_profile());
            ref_band(FLANGES[3], FLANGES[5]);
        }
        at_windows() window_cutter();
    }
}

module external_outer_pulley() {
    out = config == "previous" ? FLANGES[6] + 1 : EXT_TIP_R + 2;
    difference() {
        external_pulley(R_CUT, RIM_LOWER, RIM_UPPER) body();
        at_windows() slot_cutter(out);
    }
}

external_outer_pulley();
