// The Belt Director: a shouldered sleeve, shared by the two lengths of it, and the cap that presses in
// behind it.
//
//     210-004_SmallBeltDirector.scad   S1 17.000 long, revised 16.700
//     210-005_LargeBeltDirector.scad   S1 27.000 long, revised 26.000
//     210-001_BeltDirectorCap.scad     the cap, for either
//
// Two MR128s press onto S1, whose Ø8.000 is their bore, so their Ø12 outer races carry the belt; the
// directors push through the Arm Body's lug columns front to back and a cap presses in behind
// (specs/008.5 step 7). Measured from both references with scadmesh profile/slice/radial; they agree
// to 0.002, and their only difference is S1's length. The feature IDs are those of each part's
// .view.json:
//
//     ID  feature   value                       z span
//     H1  head      Ø11.000, solid              -0.500 .. 0
//     S1  shank     Ø8.000                      0 .. length
//     B1  core      Ø4.700, blind to H1         0 .. length
//
// The z rows a histogram reports along S1 (5.667, 11.333 on the Small; 5.4, 6.75, ... on the Large)
// are tessellation rows, not faces. FRAME: the axis on +Z through the origin, H1's top at z = 0.
//
// THE DISCS. The head bears on the bearing at the front and the cap's disc on the one at the back, and a
// disc that reaches the outer race brakes the bearing it locates, since the outer race is the one that
// turns with the belt. `revised` therefore draws both discs at DISC_D, one diameter, between S1's Ø8 and
// the Ø10 halfway line across the MR128's section (700-Differential/diff_params.scad, shoulder_bore), so
// each touches the inner race alone and clears the outer race, DISC_T thick for strength, with the outer
// face's edge rounded DISC_FILLET to be comfortable to handle. The bearing-side edge stays sharp: a round
// there would take the flat the inner race bears on. `previous` keeps the reference head's Ø11 x 0.5.
//
// THE CAP. A solid plug of the core's bore at the press clearance (print_fit.scad), CAP_PLUG long, under a
// disc of the head's size. FRAME: the disc's underside at z = 0, the plug below it. The cap's disc sits on
// the inner race of the bearing behind the shank: `revised` S1 is the span between a column's outer bearings
// (the Arm Body draws B and C 16.7 apart, A 26.0), so it ends flush with the bearing behind it and the disc bears
// on the race and the shank both. S1's `previous` length is the reference's.
//
// FITS (print_fit.scad), revised only: S1 on the MR128's Ø8 bore at the press clearance, and the cap's plug
// in B1 at the press clearance too: both are printed, which is the slip class, but the plug is a press fit by
// design, and a slip gap would let it fall out. S1 in the Arm Body's Ø9 holes is settled there.
//
// Used, not included: each part file calls belt_director(length) or belt_director_cap().

include <../print_fit.scad>

BELT_DIRECTOR_HEAD  = [5.500, 0.500];   // previous: radius, thickness
BELT_DIRECTOR_SHANK = 4.000;            // radius
BELT_DIRECTOR_CORE  = 2.350;            // radius
DISC_D              = 9.500;            // revised: both discs
DISC_T              = 2.000;            // revised: both discs' thickness
DISC_FILLET         = 1.000;            // revised: the round on each disc's outer edge
CAP_PLUG            = 5.000;            // the plug's length: past the bearing's 3.5

// The quarter circle of radius r about c, from angle a0 to a1.
function quarter(c, r, a0, a1, n = 12) = [for (i = [0 : n]) c + r * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]];

module belt_director(length, cfg = "previous")
    let(t = cfg == "previous" ? BELT_DIRECTOR_HEAD[1] : DISC_T,
        r = cfg == "previous" ? BELT_DIRECTOR_HEAD[0] : DISC_D / 2,
        s = cfg == "previous" ? BELT_DIRECTOR_SHANK : fit_pin(2 * BELT_DIRECTOR_SHANK, fit_clearances(cfg)[1]) / 2,
        f = cfg == "previous" ? 0 : DISC_FILLET)
    rotate_extrude() polygon(concat(
        [[0, -t]],
        f > 0 ? quarter([r - f, -t + f], f, -90, 0) : [[r, -t]],
        [[r, 0], [s, 0], [s, length], [BELT_DIRECTOR_CORE, length], [BELT_DIRECTOR_CORE, 0], [0, 0]]));

module belt_director_cap(cfg = "revised")
    let(p = fit_pin(2 * BELT_DIRECTOR_CORE, fit_clearances(cfg)[1]) / 2, r = DISC_D / 2, f = DISC_FILLET)
    rotate_extrude() polygon(concat(
        [[0, -CAP_PLUG], [p, -CAP_PLUG], [p, 0], [r, 0]],
        quarter([r - f, DISC_T - f], f, 0, 90),
        [[0, DISC_T]]));
