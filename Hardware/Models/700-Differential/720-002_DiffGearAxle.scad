// #720-002 Diff Gear Axle — parametric source (DC-2).
// Input-A bevel gear (20T, 1:1 set), epoxied onto the front end of the
// 96 mm CF rod (008.6 step 20). The MR85 bearing presses into the top of
// the Ø8 bore, ~1 mm proud (008.6 step 19) — the bore doubles as rod seat
// (glued, from below) and bearing seat (pressed, from above).
//
// Geometry solved from 720-002_DiffGearAxle.stl (scadmesh slice sweeps):
// a 55-degree conical back face rising from Ø29.79, straight bevel teeth on
// a 45-degree pitch cone with apex at z = APEX_Z (tips reach the Ø44.055
// datum), the root cone carrying through to a face at ~z 12, then a Ø9
// boss with a 0.5 roundover. Tooth flanks are BOSL2 involute bevel teeth —
// verified by tooth count and OD rather than vertex match (see 009 DC-2).

include <diff_params.scad>
include <BOSL2/gears.scad>

/* [Hidden] */
APEX_Z      = 24.12;    // pitch-cone apex height (virtual, above the part)
FACE_W      = 10.6;     // tooth face width along the pitch cone
BACK_D0     = 29.785;   // back cone diameter at z = 0
BACK_SLOPE  = 2.855;    // back cone diameter growth per mm (55 deg)
HUB_TOP     = 2.24;     // solid hub ends where valleys open
// Shoulder and boss lip: a proud cylindrical shoulder emerges from the
// tooth root cone at z ~9.8 and curves into a flat annulus at z 12.02
// (r, z pairs traced from slice sweeps of the reference).
CAP_PROFILE = [[11.89, 9.70], [11.75, 10.20], [11.54, 10.60], [11.24, 11.00],
               [10.80, 11.40], [10.08, 11.80], [9.873, 11.85], [9.63, 11.93],
               [9.184, 11.99], [9.0, 12.0], [8.463, 12.02]];
CAP_TOP_Z   = 12.02;
BOSS_D      = 9.0;      // top boss diameter
BOSS_TOP    = 14.0;     // overall height
BOSS_ROUND  = 0.5;      // boss top roundover
// One bore serves both duties: the CF rod is glued in from below and the
// MR85 presses in from above, and both are Ø8.
BORE_D      = CF_ROD_D;
assert(BORE_D == BRG_MR85[1], "rod bore and MR85 outside diameter must agree");

module axle_gear_body() {
    intersection() {
        union() {
            cyl(d=46, h=HUB_TOP, anchor=BOTTOM);
            up(APEX_Z)
                bevel_gear(mod=BEVEL_MOD, teeth=BEVEL_TEETH,
                           mate_teeth=BEVEL_TEETH, face_width=FACE_W,
                           spiral=0, cutter_radius=0, slices=24,
                           anchor="apex");
        }
        cyl(d1=BACK_D0, d2=BACK_D0 + BACK_SLOPE * BOSS_TOP, h=BOSS_TOP,
            anchor=BOTTOM);
    }
}

module diff_gear_axle() {
    difference() {
        union() {
            axle_gear_body();
            rotate_extrude()
                polygon(concat([[0, CAP_PROFILE[0][1]]], CAP_PROFILE,
                               [[0, CAP_TOP_Z]]));
            up(CAP_TOP_Z - epsilon)
                cyl(d=BOSS_D, h=BOSS_TOP - CAP_TOP_Z + epsilon,
                    rounding2=BOSS_ROUND, anchor=BOTTOM);
        }
        down(epsilon) cyl(d=BORE_D, h=BOSS_TOP + 2*epsilon, anchor=BOTTOM);
    }
}

diff_gear_axle();
