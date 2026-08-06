// #710-003 Diff Keeper — parametric source (DC-2).
// Retaining ring epoxied over the Diff Body B shaft against the 6703 bearing
// (008.6 steps 23-24); a second one joins the Front Panel (008.7).
//
// The bore profile is stepped and filleted: a sliding Ø8.0 seat, a concave
// fillet out to a short Ø8.5 relief, then a second concave fillet flaring to
// Ø9.9 at the top face — the "chamfered edge" that carries the epoxy without
// wicking it into the bore. Fillet radii were solved from cross-section
// measurements of the reference STL (scadmesh slice at z = 1.0/2.6/3.0/3.8).
//
// Shared values come from diff_params.scad.

include <diff_params.scad>

/* [Hidden] */
OD           = 15.0;     // ring outside diameter
H            = 3.964;    // overall height
BORE_D       = 8.0;      // seat bore (slides over the Ø8 shaft / CF rod)
RELIEF_D     = 8.5;      // relief bore diameter
FLARE_TOP_D  = 9.9;      // flare diameter at the top face
SEAT_TOP     = 2.46;     // seat ends / lower fillet tangent point
LOWER_FIL_R  = 0.708;    // lower fillet radius (seat -> relief)
LOWER_FIL_A  = 130.3;    // lower fillet end angle (meets relief wall)
RELIEF_TOP   = 3.343;    // relief ends / upper fillet tangent point
UPPER_FIL_R  = 0.62;     // upper fillet radius (relief -> top flare)
UPPER_FIL_A  = 83.5;     // upper fillet end angle (reaches the top face)

module diff_keeper() {
    lower_arc = arc(n=7, cp=[BORE_D/2 + LOWER_FIL_R, SEAT_TOP],
                    r=LOWER_FIL_R, angle=[180, LOWER_FIL_A]);
    upper_arc = arc(n=9, cp=[RELIEF_D/2 + 0.005 + UPPER_FIL_R, RELIEF_TOP],
                    r=UPPER_FIL_R, angle=[180, UPPER_FIL_A]);
    bore_profile = concat(
        [[0, -epsilon], [BORE_D/2, -epsilon]],
        lower_arc,
        [[RELIEF_D/2 + 0.005, RELIEF_TOP]],
        upper_arc,
        [[FLARE_TOP_D/2, H + epsilon], [0, H + epsilon]]
    );
    difference() {
        cyl(d=OD, h=H, anchor=BOTTOM);
        rotate_extrude() polygon(bore_profile);
    }
}

diff_keeper();
