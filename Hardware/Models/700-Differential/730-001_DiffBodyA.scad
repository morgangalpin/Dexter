// #730-001 Diff Body A — parametric source (DC-2), authored functional body.
// The static wrist frame: it carries the J4 pivot bearings — the 6705 in
// the Ø32 top seat and a 6703 in the Ø23 bottom seat (008.6 step 1) — on
// which the Diff Gear Shaft's Ø25 section and Ø17 rear journal turn. The
// GT2 belts pass through the two wing passages from the arm (-X) side;
// the two M3 screws at (-25, +/-8.6) retain the assembly.
//
// This file is an authored redesign (DC-2 is an authoring task): every
// interface below is taken from measurements of 730-001_DiffBodyA.stl
// (seat diameters/depths, screw and pin positions, passage locations,
// envelope), while the sculpted outer shell is replaced by a clean
// parametric outline. The reference part measures 80.984 mm across —
// wider than the HDI-940 cover's 78.0 mm envelope (004 § Differential
// interface); config = "revised" trims the outline to fit (BODY_A_LEN
// in diff_params.scad).

include <diff_params.scad>

/* [Hidden] */
H            = 22.0;    // overall height (J4 axis along Z)
SEAT_6703_H  = 4.0;     // Ø23 seat depth, from the bottom face
WAIST_D      = 20.0;    // clearance bore between the seats
SPACER_Z     = [16.0, 18.0];   // Ø26 spacer shoulder
SEAT_6705_Z  = 18.0;    // Ø32 seat, up to the top face
CHAMBER      = [[11.5, 0], 22, 13, [6.0, 15.5]];  // [center, x, y, z-span]
BELT_PASS    = [[-30.8, 6.9], 24, 13, [6.0, 15.5]]; // mirrored in Y
SCREW_POS    = [[-25.0, 8.58], [-25.0, -8.58]];
SCREW_CLEAR  = [4.6, 18.0];    // Ø, from the bottom
SCREW_THREAD = 3.2;            // M3 thread engagement above
PIN_POS      = [[-32.62, 4.0], [-32.62, -4.0]];
PIN          = [4.0, 2.6];     // Ø, depth from the top
POCKET_R     = 23.04;   // top pocket circle (code-disk end-stop track)
POCKET_ANG   = [30, -30, 90, -90];
POCKET       = [13.0, 2.0];    // Ø, depth from the top

// Outline: a hull of three circles. The +X extent is fixed by the J4
// bearing stack (Ø32 seat plus wall) and does not move; the arm tip is
// derived from BODY_A_LEN, so the body's width *is* that parameter and
// the revised config narrows the part by shortening the arm.
LOBE_MAIN    = [4.0, 52.0];       // [x-center, Ø] over the bearing stack
LOBE_MID     = [-12.0, 60.0];     // widest point, across the wing passages
LOBE_ARM_D   = 30.0;              // arm tip lobe Ø
X_MAX        = LOBE_MAIN[0] + LOBE_MAIN[1] / 2;
ARM_TIP_X    = X_MAX - BODY_A_LEN + LOBE_ARM_D / 2;

echo(str("Diff Body A width=", BODY_A_LEN, " mm  arm tip x=", ARM_TIP_X));
assert(ARM_TIP_X - LOBE_ARM_D / 2 < min(SCREW_POS[0][0], PIN_POS[0][0]),
       "Body A arm is too short to carry its screw and pin features");

module body_a_outline() {
    hull() {
        translate([LOBE_MAIN[0], 0]) circle(d=LOBE_MAIN[1]);
        translate([LOBE_MID[0], 0]) circle(d=LOBE_MID[1]);
        translate([ARM_TIP_X, 0]) circle(d=LOBE_ARM_D);
    }
}

module rounded_slot(center, sx, sy, zspan) {
    translate([center[0], center[1], zspan[0]])
        linear_extrude(zspan[1] - zspan[0])
            rect([sx, sy], rounding=min(sx, sy) / 2.2);
}

module diff_body_a() {
    difference() {
        linear_extrude(H) body_a_outline();
        // J4 bearing ladder, bottom up: 6703, waist, spacer, 6705.
        down(epsilon) cyl(d=BRG_6703[1], h=SEAT_6703_H + epsilon, anchor=BOTTOM);
        up(SEAT_6703_H - epsilon)
            cyl(d=WAIST_D, h=SPACER_Z[0] - SEAT_6703_H + 2*epsilon, anchor=BOTTOM);
        up(SPACER_Z[0]) cyl(d=26.0, h=SPACER_Z[1] - SPACER_Z[0], anchor=BOTTOM);
        up(SEAT_6705_Z) cyl(d=BRG_6705[1], h=H - SEAT_6705_Z + epsilon,
                            anchor=BOTTOM);
        // Clearance chamber toward the differential, belt passages toward
        // the arm.
        rounded_slot(CHAMBER[0], CHAMBER[1], CHAMBER[2], CHAMBER[3]);
        for (s = [1, -1])
            rounded_slot([BELT_PASS[0][0], s * BELT_PASS[0][1]],
                         BELT_PASS[1], BELT_PASS[2], BELT_PASS[3]);
        for (p = SCREW_POS) {
            translate([p[0], p[1], -epsilon])
                cyl(d=SCREW_CLEAR[0], h=SCREW_CLEAR[1] + epsilon, anchor=BOTTOM);
            translate([p[0], p[1], SCREW_CLEAR[1] - epsilon])
                cyl(d=SCREW_THREAD, h=H - SCREW_CLEAR[1] + 2*epsilon,
                    anchor=BOTTOM);
        }
        for (p = PIN_POS)
            translate([p[0], p[1], H - PIN[1]])
                cyl(d=PIN[0], h=PIN[1] + epsilon, anchor=BOTTOM);
        for (a = POCKET_ANG)
            zrot(a) right(POCKET_R) up(H - POCKET[1])
                cyl(d=POCKET[0], h=POCKET[1] + epsilon, anchor=BOTTOM);
    }
}

diff_body_a();
