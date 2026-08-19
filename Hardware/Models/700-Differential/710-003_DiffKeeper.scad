// #710-003 Diff Keeper — parametric source (DC-2).
// Retaining ring epoxied over the Diff Body B shaft against the 6703 bearing
// (008.6 steps 23-24); a second one joins the Front Panel (008.7).
//
// The bore profile is stepped and filleted: a sliding Ø8.0 seat, an R0.7
// concave fillet out to a short Ø8.5 relief, then an R0.7 quarter round
// flaring to Ø9.9 at the top face — the "chamfered edge" that carries the
// epoxy without wicking it into the bore.
//
// Every dimension below is read from the ring vertices of the reference mesh
// (Reference/meshes/700-Differential/710-003_DiffKeeper.stl). Each ring there
// is a circle of constant radius to within 1e-6 mm, so these are exact
// readings rather than fits:
//
//     z          r        feature
//     0.00000    4.0000   bore mouth; the bottom face is a flat annulus
//     2.46381    4.0000   seat top, where the lower fillet leaves the Ø8 wall
//     3.00000    4.2500   lower fillet meets the relief wall
//     3.30000    4.2500   relief top, where the upper fillet leaves that wall
//     4.00000    4.9500   top face, which the upper fillet meets tangentially
//
// Both fillets carry R = 0.700. Every intermediate ring vertex lies on that
// radius to within 5e-6 mm about centres (4.70, 2.46381) and (4.95, 3.30), so
// 0.7 is the design radius and not a fitted value. Three of the numbers above
// therefore follow from the others and are computed here rather than typed in:
// the upper fillet is a quarter round tangent to both the relief wall and the
// top face, so its radius is (FLARE_TOP_D - RELIEF_D)/2 = 0.7 and the overall
// height is RELIEF_TOP + 0.7 = 4.000; the seat top is where the lower fillet,
// centred at r = 4.70, reaches r = 4.25, which is
// 3.0 - sqrt(0.7^2 - 0.45^2) = 2.4638097, which is what the mesh reads to
// seven decimal places.
//
// A previous revision of this file carried H = 3.964, a 0.708 lower fillet and
// RELIEF_TOP = 3.343, fitted from single cross-sections rather than from ring
// vertices. Those values put the top face 0.036 mm low and the whole flare out
// of place; the ring-vertex reading above replaces them.
//
// The reference divides the lower arc into five equal steps of 9.999° and the
// upper into eight of 11.25°, giving six and nine ring vertices. The segment
// counts below place every one of those rings within 1.7e-5 mm of the
// reference's, in both r and z — four orders below the 0.0034 mm the reference
// mesh's own faceting carries — so no plane check depends on the choice.
//
// Residual against the reference: 0.029 mm, carried by the ring of the upper
// fillet nearest Ø8.58. None of it is geometry, and it divides in two.
//
// The larger part, 0.026 mm, is not reachable from this file at all. `compare`
// bins the reference's vertex radii, merges adjacent bins into runs, and then
// looks for the candidate ring nearest each run's weighted mean; where a run
// spans several rings its mean lies between them, and no candidate can sit on
// it. The reference compared against itself under the same checks reports
// 0.026 mm on this same ring, which is the floor for this part.
//
// The remaining 0.003 mm is the rotational tessellation. The reference's Ø15
// wall is a 105-gon whose vertices all sit at r = 7.500000 but which has no
// vertex at 180°; the nearest is 1.714286° away, so the reference's own
// bounding box reads 7.5 * (1 + cos 1.714286°) = 14.99664 across that axis
// while this model's $fn = 128 circle, having vertices on both axes, reads a
// full 15.0. The gap is 7.5 * (1 - cos 1.714286°) = 0.003357 mm, which is the
// measured bounding-box delta to six decimal places. The same lopsidedness
// displaces the centre `compare` measures radii about by half of it: passed as
// its own candidate, the reference reads its Ø8.084 ring at 8.081, though a
// direct radius histogram of that mesh puts every vertex of the ring at 8.0844.
// Rendering this file at $fn = 105 reproduces the reference's own 0.026 mm
// exactly, which is what establishes that the 0.003 mm is faceting. $fn stays
// at the value diff_params.scad sets for every part, because 105 facets is the
// reference mesh's export setting and not this ring's geometry. The harness
// carries a 0.03 mm tolerance for this part instead.
//
// Two-sided surface distance against the reference is 0.0034 mm, and that
// figure, not the 0.029 mm above, is the measure of how closely the surfaces
// agree. It is the reference's own export chord height. Every circle in that
// mesh is drawn with its facets the same depth below the true circle — the Ø8
// bore as a 76-gon at 4.0 * (1 - cos(180/76)) = 0.003417 mm, the Ø15 wall as a
// 105-gon at 7.5 * (1 - cos(180/105)) = 0.003357 mm — so 0.0034 mm is the
// closest any smooth-walled model can come to it, and this one is there. The
// committed profile it replaces read 0.0406 mm, which was geometry.
//
// Shared values come from diff_params.scad.

include <diff_params.scad>

/* [Hidden] */
OD           = 15.0;     // ring outside diameter
BORE_D       = 8.0;      // seat bore (slides over the Ø8 shaft / CF rod)
RELIEF_D     = 8.5;      // relief bore diameter
FLARE_TOP_D  = 9.9;      // flare diameter at the top face
RELIEF_BOT   = 3.0;      // relief starts; lower fillet ends here
RELIEF_TOP   = 3.3;      // relief ends; upper fillet starts here
FIL_R        = 0.7;      // both fillet radii (measured; identical)

// Derived, so the profile stays closed and tangent if a diameter is respecified.
H            = RELIEF_TOP + FIL_R;                  // 4.000 overall height
LOWER_FIL_CR = BORE_D/2 + FIL_R;                    // 4.700 lower fillet centre r
LOWER_FIL_A  = acos((RELIEF_D/2 - LOWER_FIL_CR) / FIL_R);   // 130.005° end angle
SEAT_TOP     = RELIEF_BOT - FIL_R * sin(LOWER_FIL_A);       // 2.4638097

// Quarter round tangent to the relief wall and the top face requires the flare
// to open by exactly twice the fillet radius; assert it rather than assume it.
assert(abs((FLARE_TOP_D - RELIEF_D)/2 - FIL_R) < 1e-9,
       "upper fillet is not tangent to both the relief wall and the top face");

module diff_keeper() {
    // Six and nine points reproduce the reference's ring spacing (see header).
    lower_arc = arc(n=6, cp=[LOWER_FIL_CR, SEAT_TOP],
                    r=FIL_R, angle=[180, LOWER_FIL_A]);
    upper_arc = arc(n=9, cp=[FLARE_TOP_D/2, RELIEF_TOP],
                    r=FIL_R, angle=[180, 90]);
    // The straight relief wall is the segment between the two arcs; it carries
    // no intermediate vertex, so nothing here is collinear enough to be dropped.
    bore_profile = concat(
        [[0, -epsilon], [BORE_D/2, -epsilon]],
        lower_arc,
        upper_arc,
        [[FLARE_TOP_D/2, H + epsilon], [0, H + epsilon]]
    );
    difference() {
        cyl(d=OD, h=H, anchor=BOTTOM);
        rotate_extrude() polygon(bore_profile);
    }
}

diff_keeper();
