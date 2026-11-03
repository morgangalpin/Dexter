// Strain-relief comb — shared section for #810-001 and #810-002.
// No part and no top-level geometry: it only defines modules.
//
// The comb grips the C-708 6-pin cable's wires. Its section is drawn in 2D in
// x and "height" (the z of the parts' frame); the including part extrudes it
// along y. Comb thickness along y is COMB_T.
//
// The six grooves sit at x = COMB_CX + (k - 2.5) * COMB_PITCH, k = 0..5. The
// meshes measure the pattern centre at -0.131 (Top) and -0.109 (Bottom); the
// design value -0.120 is the one both parts take.
//
//     groove width        1.000     pitch 2.540
//     groove-end corners  R0.3      where a groove meets its ceiling or floor
//     tooth-tip corners   R0.5      only where a tip meets a groove; the
//                                   comb's outer ends, x = +-8.55, are square
//     comb length         x +-8.55

COMB_T        = 2.000;
COMB_HALF     = 8.550;
COMB_CX       = -0.120;
COMB_PITCH    = 2.540;
COMB_GROOVES  = 6;
COMB_GROOVE_W = 1.000;
COMB_END_R    = 0.300;
COMB_TIP_R    = 0.500;

function comb_xs() =
    [for (k = [0 : COMB_GROOVES - 1]) COMB_CX + (k - (COMB_GROOVES - 1) / 2) * COMB_PITCH];

// The grooves' voids with the tips at u = 0 and the ends at u = depth; they
// overrun the tips so only the end corners are rounded within the material.
module comb_voids(depth)
    offset(r = COMB_END_R) offset(delta = -COMB_END_R)
        for (x = comb_xs())
            translate([x - COMB_GROOVE_W / 2, -1]) square([COMB_GROOVE_W, depth + 1]);

// The band's material, wider than the comb and deeper than its band, so that
// opening it rounds only the tips at the grooves; the caller trims it back to
// the square ends and the band's far edge.
module comb_material(depth)
    offset(r = COMB_TIP_R) offset(delta = -COMB_TIP_R)
        difference() {
            translate([-COMB_HALF - 2, 0]) square([2 * COMB_HALF + 4, depth + 2]);
            comb_voids(depth);
        }

// The comb's 2D section in x and height. `tip` is the teeth tips' height,
// `end` the grooves' ceiling or floor, `far` the far edge of the full-material
// band, which runs from `end` towards `far` (the same side as `end` lies from
// `tip`).
module comb_section_2d(tip, end, far) {
    dir = sign(end - tip);
    translate([0, tip]) scale([1, dir])
        intersection() {
            comb_material(abs(end - tip));
            translate([-COMB_HALF, -1]) square([2 * COMB_HALF, abs(far - tip) + 1]);
        }
}
