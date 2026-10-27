// #822 Photointerrupter Shroud (Pivot), body (A) — parametric source.
// Straddles the edge of J2's code disk (#300-002, 300-Pivot/300-002_PivotCodeDisk.scad)
// and holds J2's emitter and detector facing each other across it. It is the
// lower half of the shroud: its tongue is the slot's outer wall and its twin,
// #822 B (822_PhotointerrupterShroudPivot_B.scad), sits on the tongue, pinned to
// the body by #19 nails.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — the T-1 package's bore and flange seat opened by the
//                         press clearance; see FITS.
//
// FRAME. The reference's own. The code disk's axis is z, through the origin;
// the disk runs in the slot between this part's tongue (z 0 .. 2.5) and #822 B
// (z 2.5 and up), inside r 48.5. The part is an annular sector between the
// radial edges at 190 and 230 deg, outer r 53.5. r is the radius about the axis.
//
// Measured from the reference (scadmesh planes/slice/arcs/solid); feature IDs
// as in 822_PhotointerrupterShroudPivot_A.view.json:
//
//     ID  feature              value                                      z span
//     P1  body                 r 36.5 .. 53.5, 190 .. 230 deg             -6 .. 0
//     K1  corner cut           R4 about (-37.544, -5.026), where the 190 deg
//                              edge meets the inner wall (the edge reaches
//                              r 41.53)                                   -6 .. 0
//     K2  corner round         R4 about (-38.364, -12.993), convex, tangent
//                              to K1's arc and to the inner wall          -6 .. 0
//     T1  tongue               r 48.5 .. 53.5, 190 .. 230 deg             0 .. 2.5
//     B1  beam bore, channel A on r 45 at 208.0 deg: (-39.731, -21.125)
//     B2  beam bore, channel B on r 45 at 216.5 deg: (-36.168, -26.763)
//         each, along z:       Ø3.0, open into the slot                   -5 .. 0
//                              Ø4.0 counterbore (the flange seat)         -6 .. -5
//     N1  nail holes, Ø1.0, on r 51 at (-48.362, -16.190) and
//         (-37.534, -34.529)                                             through
//
// The planes scadmesh reports at z -3.583, -1.167 and 1.25 are tessellation
// rings of the bores and nail holes, not steps: each bore measures Ø2.997 .. 3.000
// at every station from z -4.95 to -0.02, and a pure circle (fit rms 0.000).
// No slit, flat or key crosses the bores in this part; the slits are in #822 B.
//
// CONSTRUCTION. Profile per layer along z, the disk's axis: the body (P1 with
// the K1 and K2 corner) and the tongue T1, each extruded over its z span. The
// beam bores are cut once through every layer (../photo_shroud.scad,
// beam_bore); N1 is cut along z. K2's centre is derived from K1 (tangent to the
// K1 circle and to the inner wall) and checked against the measured centre.
// The sector, K1, the beam axes and N1 are shroud_pivot.scad's, which #822 B
// shares.
//
// FITS (../print_fit.scad): the T-1 package's body (../photo_shroud.scad,
// T1_BODY_D) is drawn line to line in the reference, tighter than the press
// class, so "revised" opens B1 and B2 by the press clearance: Ø3.1. The Ø4.0
// counterbore is clearance round the flange (photo_shroud.scad) and keeps its
// size. The #19 nails (Ø1.07) drive into N1's Ø1.0: that
// interference is the reference's intent, a nail pressed into printed
// plastic, so N1 keeps its size in both configs. The disk (#300-002) runs in
// the slot clear of this part.

include <../print_fit.scad>
include <photo_shroud.scad>
include <shroud_pivot.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// 2D layer to draw alone, for outline checks; "part" draws the part
layer = "part"; // [part, body, tongue]

/* [Hidden] */
$fn = 144;
LAP     = 0.005;
R_BODY  = 36.5;                          // P1's inner wall
R_TONGUE = 48.5;                         // T1's inner wall
BODY_Z  = [-6.0, 0.0];
TONGUE_Z = [0.0, 2.5];
CBORE_D = 4.0;                           // the counterbore round the T-1 flange

K2_C    = circle_meet(K1_C, R_BODY + K_R, 2 * K_R);   // K2's centre
K_EDGE  = edge_meet(ANG[0], K1_C, K_R);               // where K1 meets the 190 deg edge

// The body's x-y section: the sector less K1, with K2 rounding the inner wall into it.
function body_path() = let(
    a2 = ang(K2_C), t12 = (K1_C + K2_C) / 2)
    concat(
        arc_pts([0, 0], R_OUT, ANG[0], ANG[1], 180),
        arc_pts([0, 0], R_BODY, ANG[1], a2, 120),
        arc_pts(K2_C, K_R, a2 - 180, ang(K1_C - K2_C), 24),
        arc_pts(K1_C, K_R, ang(t12 - K1_C), ang(K_EDGE - K1_C), 36));

// A plain annular sector between the radial edges.
function ring_path(ri) = concat(
    arc_pts([0, 0], R_OUT, ANG[0], ANG[1], 180), arc_pts([0, 0], ri, ANG[1], ANG[0], 180));

// A layer's section (2D x, y).
module layer_2d(kind) polygon(kind == "body" ? body_path() : ring_path(R_TONGUE));

module slab(z, kind) translate([0, 0, z[0] - (kind == "body" ? 0 : LAP)])
    linear_extrude(z[1] - z[0] + LAP) layer_2d(kind);

module layers() { slab(BODY_Z, "body"); slab(TONGUE_Z, "tongue"); }

// B1 and B2: the flange seat, then the body's bore through to the slot.
function bore_segs() = let(c = fit_clearances(config)[1],
    db = fit_bore(T1_BODY_D, c), df = CBORE_D)
    [[-7.0, -5.0, "round", df], [-5.0, 0.0, "round", db]];

module beams() for (a = BEAM_A) translate(pol(BEAM_R, a)) beam_bore(bore_segs(), $fn = 96);

module holes() for (at = NAILS) stepped_hole(at, [[-7.0, 3.5, NAIL_D]], $fn = 48);

module shroud_pivot_a() difference() { layers(); beams(); holes(); }

// A layer's whole section as a plane through it cuts it: its outline less the
// nail holes, and less the bores where they run (the body between the flange
// seat and the slot).
module section_2d(kind) difference() {
    layer_2d(kind);
    for (at = NAILS) translate(at) circle(d = NAIL_D, $fn = 48);
    if (kind == "body") for (a = BEAM_A) translate(pol(BEAM_R, a))
        circle(d = fit_bore(T1_BODY_D, fit_clearances(config)[1]), $fn = 96);
}

if (layer == "body" || layer == "tongue") section_2d(layer);
else shroud_pivot_a();
