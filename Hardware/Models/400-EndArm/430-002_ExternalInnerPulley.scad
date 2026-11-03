// #430-002 External Inner Pulley — parametric source.
// The inner channel's stage-1 driven pulley at the elbow: 90T in "previous",
// 108T in "revised" (DC-12). It slides onto the stainless tube (008.7 step 21)
// and takes the Internal Inner Pulley's three C-503 strakes in its slots, which
// carry its drive across the elbow. The shared definition, and what each
// configuration builds, is in external_pulley.scad.
//
// FRAME. The axis is +Z through the origin, the rim's lower face at z 19.0 and
// the hub's top at z 35.5, the frame the End Arm group's J3-axis parts share.
// The windows and the slots are on 90, 210 and 330 deg. The reference mesh is
// already in this frame.
//
// CONSTRUCTION. As #430-001's: one revolved profile (the mesh-to-scad
// ladder's rung 3) holding the hub's bore, cone and counterbore, the web, the
// rim and flanges and the band's core, with external_pulley.scad's 90T band
// (rung 7); the windows are external_pulley.scad's window outline (rung 1,
// corners by openings, rung 5) cut through the web; the slots are primitive
// cutters (rung 2), patterned.
//
// "revised" keeps everything inside R_CUT — the hub, the spokes and the inner
// 1.4 mm of the rim — and adds the 108T rim outside it.
//
// Measured from the reference with scadmesh planes/slice/arcs/profile/teeth.
// The feature IDs are those of 430-002_ExternalInnerPulley.view.json, which
// labels each one on the mesh:
//
//     ID  feature                     value
//     H1  hub                         R10.5, z 19.0 .. 35.5
//     B1  bore                        Ø11.974 z 19.0 .. 22.6, a 45 deg cone to
//                                     Ø9.0 at z 24.1, Ø9.0 to z 27.5
//     B2  counterbore                 Ø17.0, z 27.5 .. 35.5
//     W1  web and rim                 z 19.0 .. 28.5; rim inner R25.072
//     F1  flanges                     R29.5 z 19.0 .. 19.4, chamfered to R28.397
//                                     at z 20.5; from R28.397 at z 27.0 chamfered
//                                     to R29.5 at z 28.1, R29.5 to z 28.5
//     T1  90T GT2 band                z 20.5 .. 27.0, as #430-001's
//     O1  windows, 3 on 90 deg        the annulus r 10.5 .. 25.072 between spokes
//         + 120 deg k                 4.0 wide on 30 deg + 120 deg k; every
//                                     corner R4.0; through the web
//     S1  strake slots, 3 on the      5.0 tangential x 2.0 radial about r 7.091,
//         windows' angles             from the lower face up into B2; each mouth
//                                     chamfered 0.25 x 45 deg into B2's floor,
//                                     the chamfer's outer corners clipped at
//                                     r 8.6 (measured; unclipped, they cut 0.29
//                                     into B2's wall); the 210 deg slot's mouth
//                                     is plain on its side toward 300 deg
//
// FITS (../print_fit.scad), revised only:
//
//     B2, on the Internal Inner Pulley's Ø17 journal end      slip (two printed
//                                                             parts; the
//                                                             reference is line
//                                                             to line)
//
// S1 takes the C-503 strakes (1.45 x 4.50) of #421-002 with at least 0.25 a
// side, and B1's Ø9.0 stands 0.5 a side off the Ø8 stainless tube, the running
// clearance; both keep their size.

include <external_pulley.scad>

/* [Hidden] */
R_CUT     = 26.5;
RIM_LOWER = [[1.103, 19.0], [1.103, 19.4], [0.000, 20.5]];
RIM_UPPER = [[0.000, 27.0], [1.103, 28.1], [1.103, 28.5]];

HUB       = [10.500, 19.000, 35.500];          // H1: radius, z span
BORE      = [11.974, 22.600, 9.000, 24.100, 27.500];
                                               // B1: Ø, top of that Ø, Ø below the
                                               //     cone, its z, its top z
COUNTERBORE_D = 17.000;                        // B2
JOURNAL_D = 17.000;                            // #421-002's journal, nominal

function counterbore_d() = max(COUNTERBORE_D, fit_bore(JOURNAL_D, fit_clearances(config)[0]));
WEB_TOP   = 28.500;                            // W1
RIM_IN    = 25.072;                            // W1
FLANGES   = [29.500, 19.400, 20.500, 27.000, 28.100];
                                               // F1: r, the lower chamfer's top z,
                                               //     the band's span, the upper
                                               //     chamfer's top z
WINDOW    = [10.500, 25.072, 2.000, 4.000, 4.000];   // O1, as pulley_window_2d() takes it
WINDOW_AT = [90, 120];                         // O1, S1: first angle, pitch
SLOT      = [7.091, 5.000, 2.000, 0.250, 8.600];
                                               // S1: centre r, tangential, radial,
                                               //     mouth chamfer into B2's floor,
                                               //     the radius that clips its corners
SLOT_PLAIN = [0, -1, 0];                       // S1: each slot's unchamfered side, by k

function body_profile() =
    let (rc = REF_ROOT_R - ROOT_CLEAR, f = FLANGES, b = BORE)
    [[b[0] / 2, HUB[1]], [f[0], HUB[1]], [f[0], f[1]], [REF_TIP_R, f[2]], [rc, f[2]],
     [rc, f[3]], [REF_TIP_R, f[3]], [f[0], f[4]], [f[0], WEB_TOP], [HUB[0], WEB_TOP],
     [HUB[0], HUB[2]], [counterbore_d() / 2, HUB[2]], [counterbore_d() / 2, b[4]],
     [b[2] / 2, b[4]], [b[2] / 2, b[3]], [b[0] / 2, b[1]]];

// The 90T pulley.
module body() {
    difference() {
        union() {
            rotate_extrude() polygon(body_profile());
            ref_band(FLANGES[2], FLANGES[3]);
        }
        for (k = [0 : 2]) rotate(WINDOW_AT[0] + k * WINDOW_AT[1]) {
            translate([0, 0, HUB[1] - 1]) linear_extrude(WEB_TOP - HUB[1] + 2) pulley_window_2d(WINDOW);
            translate([SLOT[0], 0, (HUB[1] - 1 + BORE[4] + 1) / 2])
                cube([SLOT[2], SLOT[1], BORE[4] - HUB[1] + 2], center = true);
            mouth_chamfer(SLOT_PLAIN[k]);
        }
    }
}

// A slot's mouth chamfer into B2's floor, on +X: the hull of the slot's
// section at the chamfer's foot and its section grown by the chamfer at the
// floor, but not on a plain side (-1 for -Y), its outer corners clipped.
module mouth_chamfer(plain) {
    c = SLOT[3] + epsilon;
    y0 = -SLOT[1] / 2 - (plain == -1 ? 0 : c);
    y1 = SLOT[1] / 2 + c;
    intersection() {
        cylinder(r = SLOT[4], h = 2 * BORE[4]);
        translate([SLOT[0], 0, BORE[4]]) hull() {
            translate([0, 0, -SLOT[3]]) cube([SLOT[2], SLOT[1], epsilon], center = true);
            translate([-SLOT[2] / 2 - c, y0, epsilon]) cube([SLOT[2] + 2 * c, y1 - y0, epsilon]);
        }
    }
}

module external_inner_pulley() {
    external_pulley(R_CUT, RIM_LOWER, RIM_UPPER) body();
}

external_inner_pulley();
