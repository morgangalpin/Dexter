// #720-003 Diff End Pulley — parametric source (DC-2).
// GT2 40T input pulley epoxied onto the 96 mm CF rod, 6 mm from the tip
// (008.6 step 16). Structure, bottom to top: a rounded-off Ø10 locating boss
// (the "protruding side" that faces the rod's long side), a cone out to the
// Ø26 bottom flange, the 40-groove GT2 tooth section, and the Ø26 top
// flange. Three rounded-end arc slots lighten the web, and three glue
// grooves in the Ø8 bore carry epoxy along the rod.
//
// Dimensions measured from 720-003_DiffEndPulley.stl (scadmesh slice --full
// outline analysis). Shared values come from diff_params.scad.
//
// Approximation: the reference's boss-to-flange underside is a sculpted
// (non-revolved) web; it is modeled here as a straight cone. All functional
// surfaces (bore, glue grooves, boss, flanges, teeth, arc slots) are
// dimension-matched; the render-compare script ignores the web's
// tessellation-ring planes.

include <diff_params.scad>

/* [Hidden] */
BOSS_D      = 10.0;    // locating boss diameter
BOSS_H      = 1.0;     // boss height
BOSS_ROUND  = 0.5;     // boss bottom roundover
CONE_H      = 0.9;     // boss -> flange cone height
FLANGE_D    = 26.0;    // belt flange diameter
FLANGE_B_H  = 0.35;    // bottom flange rim height
TOOTH_H     = 7.5;     // GT2 tooth section height
FLANGE_T_H  = 0.5;     // top flange height
BORE_D      = CF_ROD_D;  // epoxied onto the 96 mm CF rod
GLUE_R      = 0.85;    // glue groove cutter radius
GLUE_C      = 4.15;    // glue groove center radius (reaches r = 5.0)
GLUE_A      = [54, 174, 294];   // glue groove angles
GLUE_Z      = 2.5;     // glue groove floor (from the boss base)
KIDNEY_R    = [6.0, 10.0];      // arc slot radial span
KIDNEY_A    = 29.9;    // arc slot half-angle to the cap centers
KIDNEY_ANG  = [60, 180, 300];   // arc slot center angles
KIDNEY_Z    = 1.5;     // arc slot floor (from the boss base)

H = BOSS_H + CONE_H + FLANGE_B_H + TOOTH_H + FLANGE_T_H;
echo(str("Diff End Pulley overall height: ", H, " mm"));

module kidney2d(ang) {
    r_mid = (KIDNEY_R[0] + KIDNEY_R[1]) / 2;
    cap_d = KIDNEY_R[1] - KIDNEY_R[0];
    zrot(ang) union() {
        polygon(concat(
            arc(n=24, r=KIDNEY_R[1], angle=[-KIDNEY_A, KIDNEY_A]),
            reverse(arc(n=24, r=KIDNEY_R[0], angle=[-KIDNEY_A, KIDNEY_A]))
        ));
        for (s = [-1, 1]) zrot(s * KIDNEY_A) right(r_mid) circle(d=cap_d);
    }
}

module diff_end_pulley() {
    difference() {
        union() {
            cyl(d=BOSS_D, h=BOSS_H, rounding1=BOSS_ROUND, anchor=BOTTOM);
            up(BOSS_H) cyl(d1=BOSS_D, d2=FLANGE_D, h=CONE_H, anchor=BOTTOM);
            up(BOSS_H + CONE_H) cyl(d=FLANGE_D, h=FLANGE_B_H, anchor=BOTTOM);
            up(BOSS_H + CONE_H + FLANGE_B_H)
                linear_extrude(TOOTH_H) gt2_pulley_teeth_2d();
            up(H - FLANGE_T_H) cyl(d=FLANGE_D, h=FLANGE_T_H, anchor=BOTTOM);
        }
        down(epsilon) cyl(d=BORE_D, h=H + 2*epsilon, anchor=BOTTOM);
        for (a = GLUE_A)
            zrot(a) right(GLUE_C) up(GLUE_Z)
                cyl(r=GLUE_R, h=H, anchor=BOTTOM);
        up(KIDNEY_Z) linear_extrude(H - KIDNEY_Z + epsilon)
            for (a = KIDNEY_ANG) kidney2d(a);
    }
}

diff_end_pulley();
