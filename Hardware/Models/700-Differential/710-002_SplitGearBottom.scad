// #710-002 Split Gear Bottom — parametric source (DC-2).
// The lower half of the split output bevel gear: it presses into the Split
// Gear Top (008.6 step 8) and carries the apex-side half of the 20 bevel
// teeth — a castellated tooth lip whose toes continue as 20 tapering
// prongs. Tooth clocking against the Top half is set during assembly via
// the brad windows (008.6 steps 8-9). Below the gear: a 55-degree back
// cone down to a Ø17 wire-guide stub (funnel bore Ø13 -> Ø8.5), the MR128
// seat, and the Ø18/Ø23 sleeve-and-seat ladder for the 6703, with a
// conical clearance groove between sleeve and outer wall. Three notches in
// the Ø27 wall take the 25 mm CF strakes (step 11).
//
// This source replaces the shipped STL, which was ~1000x oversize
// (DC-11(f)); the corrected reference was verified against the Ø23/Ø12
// bearing seats and the Top's Ø28 press interface. Tooth flanks are BOSL2
// involute bevel teeth — verified by tooth count and OD, not vertex match.

include <diff_params.scad>
include <BOSL2/gears.scad>

/* [Hidden] */
Z0          = 4.0;      // base face (reference coordinates)
Z_TOP       = 27.368;   // prong tip truncation plane
STUB        = [17.0, 8.2];        // [Ø, top] wire-guide stub
FUNNEL      = [[4.5, 13.0], [5.2, 11.1], [6.2, 9.1], [6.5, 8.9], [6.9, 8.5]];
// Stub-to-body trumpet curve, (r, z) sampled from the reference's
// tessellation rings (fillet off the stub, then the flaring back wall).
TRUMPET     = [[8.5, 8.2], [8.674, 8.42], [8.767, 8.55], [8.876, 8.72],
               [9.17, 9.04], [9.79, 9.40], [10.42, 9.62], [11.06, 9.87],
               [11.68, 10.12], [12.31, 10.40], [12.94, 10.69], [13.5, 11.0]];
BODY_D      = 27.0;     // main body diameter
BODY_TOP    = 21.0;     // body ends where the tooth lip flares
SEAT_MR128  = [13.5, 17.0];       // MR128 seat span (Ø12)
SLEEVE_ID   = 18.0;     // sleeve bore above the MR128 seat
SLEEVE_TOP  = 21.7;     // sleeve ends; 6703 seat (Ø23) above
GROOVE_POLY = [[11.5, 18.5], [12.2, 19.2], [13.2, 20.2], [13.5, 21.2],
               [15.3, 22.4], [11.5, 22.4]]; // clearance groove (r, z)
POCKET_D    = 25.5;     // crown pocket freeing the prong ring
POCKET_Z    = 25.4;
SB_APEX     = 39.35;    // bevel pitch-cone apex (virtual, above the part)
SB_FW       = 12.2;     // bevel face width (toes reach the prong tips)
// Tooth envelope: flare off the body, peak, then decline over the prongs.
TIP_TRIM    = [[21.0, 27.05], [23.7, 34.81], [25.4, 30.6], [27.6, 29.5]];
STRAKE_A    = [90, 210, 330];     // strake notch angles
STRAKE_R    = 14.25;    // strake notch center radius
STRAKE_SPAN = [12.03, 13.48];     // strake notch z span
LIP_FLARE   = [[21.0, 27.0], [21.9, 30.4]];  // body -> tooth lip flare

module bottom_gear_teeth() {
    intersection() {
        up(SB_APEX)
            bevel_gear(mod=BEVEL_MOD, teeth=BEVEL_TEETH,
                       mate_teeth=BEVEL_TEETH, face_width=SB_FW,
                       spiral=0, cutter_radius=0, slices=24, anchor="apex");
        union() {
            for (i = [0 : len(TIP_TRIM) - 2])
                up(TIP_TRIM[i][0])
                    cyl(d1=TIP_TRIM[i][1], d2=TIP_TRIM[i+1][1],
                        h=TIP_TRIM[i+1][0] - TIP_TRIM[i][0], anchor=BOTTOM);
        }
    }
}

module split_gear_bottom() {
    difference() {
        union() {
            up(Z0) cyl(d=STUB[0], h=STUB[1] - Z0, anchor=BOTTOM);
            rotate_extrude()
                polygon(concat([[0, TRUMPET[0][1]]], TRUMPET,
                               [[0, TRUMPET[len(TRUMPET)-1][1]]]));
            up(TRUMPET[len(TRUMPET)-1][1] - epsilon)
                cyl(d=BODY_D, h=BODY_TOP - TRUMPET[len(TRUMPET)-1][1] + epsilon,
                    anchor=BOTTOM);
            up(LIP_FLARE[0][0])
                cyl(d1=LIP_FLARE[0][1], d2=LIP_FLARE[1][1],
                    h=LIP_FLARE[1][0] - LIP_FLARE[0][0], anchor=BOTTOM);
            bottom_gear_teeth();
        }
        // Wire funnel and bore ladder, bottom up.
        up(Z0 - epsilon)
            cyl(d=FUNNEL[0][1], h=FUNNEL[0][0] - Z0 + epsilon, anchor=BOTTOM);
        for (i = [0 : len(FUNNEL) - 2])
            up(FUNNEL[i][0] - epsilon)
                cyl(d1=FUNNEL[i][1], d2=FUNNEL[i+1][1],
                    h=FUNNEL[i+1][0] - FUNNEL[i][0] + 2*epsilon, anchor=BOTTOM);
        up(FUNNEL[len(FUNNEL)-1][0] - epsilon)
            cyl(d=FUNNEL[len(FUNNEL)-1][1],
                h=SEAT_MR128[0] - FUNNEL[len(FUNNEL)-1][0] + epsilon,
                anchor=BOTTOM);
        up(SEAT_MR128[0])
            cyl(d=BRG_MR128[1], h=SEAT_MR128[1] - SEAT_MR128[0], anchor=BOTTOM);
        // Seat-top chamfer, then the sleeve bore.
        up(SEAT_MR128[1] - epsilon)
            cyl(d1=BRG_MR128[1], d2=SLEEVE_ID, h=0.25 + epsilon, anchor=BOTTOM);
        up(SEAT_MR128[1] + 0.25 - epsilon)
            cyl(d=SLEEVE_ID, h=SLEEVE_TOP - SEAT_MR128[1] - 0.25 + epsilon,
                anchor=BOTTOM);
        up(SLEEVE_TOP - epsilon)
            cyl(d=BRG_6703[1], h=POCKET_Z - SLEEVE_TOP + 2*epsilon,
                anchor=BOTTOM);
        rotate_extrude() polygon(GROOVE_POLY);
        up(POCKET_Z) cyl(d=POCKET_D, h=Z_TOP - POCKET_Z + 1, anchor=BOTTOM);
        up(Z_TOP) cyl(d=40, h=3, anchor=BOTTOM);
        for (a = STRAKE_A)
            zrot(a) right(STRAKE_R) up(STRAKE_SPAN[0])
                cuboid([STRAKE_25[2], STRAKE_25[1],
                        STRAKE_SPAN[1] - STRAKE_SPAN[0]], anchor=BOTTOM);
    }
}

split_gear_bottom();
