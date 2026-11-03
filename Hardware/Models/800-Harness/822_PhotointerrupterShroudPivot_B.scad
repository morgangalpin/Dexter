// #822 Photointerrupter Shroud (Pivot), cap (B) — parametric source.
// The upper half of the shroud that straddles the edge of J2's code disk
// (#300-002, 300-Pivot/300-002_PivotCodeDisk.scad). It sits on the tongue of
// #822 A (822_PhotointerrupterShroudPivot_A.scad), pinned to it by #19 nails,
// and holds the detector side of J2's two T-1 beam bores; the slits that
// narrow each beam to the disk's tracks are in this part.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — the T-1 package's bore and flange seat opened by the
//                         press clearance; see FITS.
//
// FRAME. The reference's own, which is #822 A's: the code disk's axis is z,
// through the origin; the part is an annular sector between the radial edges
// at 190 and 230 deg, z 2.5 .. 8.5, its underside facing the disk's slot.
// r is the radius about the axis.
//
// Measured from the reference (scadmesh planes/slice/arcs/solid); feature IDs
// as in 822_PhotointerrupterShroudPivot_B.view.json:
//
//     ID  feature              value                                      z span
//     P1  body                 r 41.0 .. 53.5, 190 .. 230 deg             2.5 .. 8.5
//     K1  corner cut           R4 about (-37.544, -5.026), where the 190 deg
//                              edge meets the inner wall (the edge reaches
//                              r 41.53)                                   2.5 .. 8.5
//     B1  beam bore, channel A on r 45 at 208.0 deg: (-39.731, -21.125)
//     B2  beam bore, channel B on r 45 at 216.5 deg: (-36.168, -26.763)
//         each, along z:       slit 0.8 wide, radial, cut from a Ø3.0
//                              circle (the aperture across the disk)      2.5 .. 3.4
//                              lead-in: a revolved R0.524 fillet from
//                              Ø2.33 (z 2.911) out to the Ø3.0 bore (z 3.4),
//                              the slit still open through it             2.911 .. 3.4
//                              Ø3.0 bore                                  3.4 .. 7.5
//                              Ø4.0 counterbore (the flange seat)         7.5 .. 8.5
//     N1  nail holes, Ø1.0, on r 51 at (-48.362, -16.190) and
//         (-37.534, -34.529)                                             through
//
// The planes scadmesh reports at z 2.911, 2.968, 3.046, 3.116, 3.150, 3.204 and
// 3.274 are the facets of the lead-in's curve (probed across the bore at
// z 2.92 .. 3.42: half width 1.17, 1.30, 1.40, 1.45, 1.50); 3.4 is where it meets
// the bore. 4.5 and 6.5 are tessellation rings of the bore, which measures
// Ø2.996 .. 3.000 at every station from z 3.45 to 7.4 and is a pure circle
// (fit rms 0.001). The slit's edges are parallel lines 0.8 apart, centred on
// the bore and lying along its radius, so each bore's slit turns with its angle.
//
// CONSTRUCTION. Profile per layer along z, the disk's axis: P1 with the K1
// corner cut is the one layer, extruded over its z span. The beam bores are
// cut once through it (../photo_shroud.scad, beam_bore: the slit, round and
// counterbore runs), with beam_flare, local to this part, for the lead-in
// (photo_shroud.scad has no curved flare, and its "cone" is straight); N1 is
// cut along z. The sector, K1, the beam axes and N1 are shroud_pivot.scad's,
// which #822 A shares.
//
// FITS (../print_fit.scad): the T-1 package's body (../photo_shroud.scad,
// T1_BODY_D) is drawn line to line in the reference, tighter than the press
// class, so "revised" opens the bore by the press clearance: Ø3.1; the slit
// circle and the lead-in follow the bore. The Ø4.0 counterbore is clearance
// round the flange (photo_shroud.scad) and keeps its size.
// The slit's width is the aperture, not a fit. The #19 nails (Ø1.07) drive
// into N1's Ø1.0: that interference is the reference's intent, a nail pressed
// into printed plastic, so N1 keeps its size in both configs.

include <../print_fit.scad>
include <photo_shroud.scad>
include <shroud_pivot.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// 2D layer to draw alone, for outline checks; "part" draws the part
layer = "part"; // [part, body, slit]

/* [Hidden] */
$fn = 144;
LAP     = 0.005;
R_IN    = 41.0;                          // P1's inner wall
Z       = [2.5, 8.5];
CBORE_D = 4.0;                           // the counterbore round the T-1 flange
SLIT_W  = 0.8;
SLIT_Z  = [2.4, 3.4];
FLARE_Z = [2.911, 3.4];                  // the lead-in's z span
FLARE_R = 0.524;                         // its fillet radius
BORE_Z  = [3.4, 7.5];

K_IN   = circle_meet(K1_C, R_IN, K_R);        // where K1 meets the inner wall
K_EDGE = edge_meet(ANG[0], K1_C, K_R);        // where K1 meets the 190 deg edge

// The body's x-y section: the sector less K1.
function body_path() = concat(
    arc_pts([0, 0], R_OUT, ANG[0], ANG[1], 180),
    arc_pts([0, 0], R_IN, ANG[1], ang(K_IN), 120),
    arc_pts(K1_C, K_R, ang(K_IN - K1_C), ang(K_EDGE - K1_C), 36));

module body_2d() polygon(body_path());

module body() translate([0, 0, Z[0]]) linear_extrude(Z[1] - Z[0]) body_2d();

// The lead-in: a bore of radius rm at z1 narrowing along a fillet of radius
// fr to the radius it has at z0, revolved about the beam axis.
module beam_flare(z0, z1, rm, fr) {
    r = function(z) rm - (fr - sqrt(fr * fr - (z1 - z) * (z1 - z)));
    zs = [for (i = [0 : 16]) z0 + (z1 - z0) * i / 16];
    rotate_extrude() polygon(concat([[0, z0 - LAP]], [for (z = zs) [r(z), z]],
        [[rm, z1 + LAP], [0, z1 + LAP]]));
}

// B1 and B2: the slit, the Ø3.0 bore and the counterbore, with the lead-in.
function bore_segs(db, df) = [
    [SLIT_Z[0], SLIT_Z[1], "slit", db, SLIT_W],
    [BORE_Z[0], BORE_Z[1], "round", db],
    [BORE_Z[1], Z[1] + 1, "round", df]];

module beam(a) {
    c = fit_clearances(config)[1];
    db = fit_bore(T1_BODY_D, c);
    translate(pol(BEAM_R, a)) {
        beam_bore(bore_segs(db, CBORE_D), a - 90, $fn = 96);
        beam_flare(FLARE_Z[0], FLARE_Z[1], db / 2, FLARE_R, $fn = 96);
    }
}

module holes() for (at = NAILS) stepped_hole(at, [[1.5, 9.5, NAIL_D]], $fn = 48);

module shroud_pivot_b() difference() { body(); for (a = BEAM_A) beam(a); holes(); }

// The section a plane through the part cuts: the outline less the nail holes,
// and less the bores ("body", above the lead-in) or the slits ("slit", below it).
module section_2d(kind) difference() {
    body_2d();
    for (at = NAILS) translate(at) circle(d = NAIL_D, $fn = 48);
    for (a = BEAM_A) translate(pol(BEAM_R, a)) {
        db = fit_bore(T1_BODY_D, fit_clearances(config)[1]);
        if (kind == "body") circle(d = db, $fn = 96);
        else intersection() {
            circle(d = db, $fn = 96);
            rotate(a - 90) square([SLIT_W, 2 * db], center = true);
        }
    }
}

if (layer == "body" || layer == "slit") section_2d(layer);
else shroud_pivot_b();
