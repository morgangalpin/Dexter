// Features shared by #825 A and #825 B, the Rotate photointerrupter shroud's
// two halves. No part and no top-level geometry: it only defines modules and
// constants. The beam bore itself is photo_shroud.scad's.
//
// The shroud straddles J5's code disk (#710-004), which turns about the z axis
// through the origin, in the 2 mm gap between the halves (z -8.5 to -6.5). Each
// half carries one end of both beams: two T-1 packages stand in a half's bores,
// on a radius of 23.25 about the origin, 7.6 and 8.2 degrees to either side of
// -y. #825 B (the emitter side) sits on top of the gap, #825 A's tab below it.
//
// PLAN. B's outline is also the outline of A's tab (z -14.5 to -8.5): a wedge
// 20 deg either side of -y about the origin, cut by the disk-side arc of
// radius 20.5, out to the back face at y -30.191, between x -7.7 and 7.511,
// with 1.5 chamfers on the back corners.

include <photo_shroud.scad>

TAB_X     = [-7.700, 7.511];
BACK_Y    = -30.191;
CORNER    = 1.5;              // chamfer on the back corners
DISK_R    = 20.5;             // the arc facing the disk's axis
WEDGE     = 20;               // deg either side of -y
BEAMS     = [[-3.296, -23.013], [3.059, -23.048]];   // B1, B2
NAILS_XY  = [[-2.095, -28.620], [1.905, -28.620]];   // N1
NAIL_D    = 1.000;            // for a #19 nail (Ø1.07): a drive fit, kept

// The wedge's edge meets the end faces at these y.
function wedge_y(x) = -abs(x) / tan(WEDGE);

// The outline of B and of A's tab (2D x, y).
module tab_plan_2d() {
    a = [for (t = [-WEDGE : 4 : WEDGE])
            DISK_R * [sin(t), -cos(t)]];
    polygon(concat(
        [[TAB_X[1], BACK_Y + CORNER], [TAB_X[1] - CORNER, BACK_Y],
         [TAB_X[0] + CORNER, BACK_Y], [TAB_X[0], BACK_Y + CORNER],
         [TAB_X[0], wedge_y(TAB_X[0])]],
        a,
        [[TAB_X[1], wedge_y(TAB_X[1])]]));
}

// The radial direction at a bore, as the spin that lays a slit along it.
function beam_spin(at) = atan2(-at[0], at[1]);

// Both beam bores, each with the section run `segs` ([z0, z1, kind, a, b]).
module beam_bores(segs) for (at = BEAMS)
    translate([at[0], at[1], 0]) beam_bore(segs, beam_spin(at), $fn = 96);

// The two nail holes, from z0 to z1.
module nail_holes(z0, z1) for (at = NAILS_XY)
    stepped_hole(at, [[z0, z1, NAIL_D]], $fn = 48);
