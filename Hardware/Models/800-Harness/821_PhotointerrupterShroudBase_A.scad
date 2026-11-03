// #821 Photointerrupter Shroud (Base), body (A) — parametric source.
// Straddles the edge of J1's code disk (#100-002) and holds J1's emitter and
// detector facing each other across it; it stands on its plate, #821 B
// (821_PhotointerrupterShroudBase_B.scad), pinned to it by #19 nails, and the
// optical board (C-703) sits against its back face.
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — identical to "previous"; see FITS.
//
// FRAME. The reference's own. The code disk's axis is parallel to y, through
// (x 0, z -32.5); the disk runs in the slot S1, between the outer jaw (y < -14)
// and the body. The body's underside is z = 7, where it stands on #821 B.
//
// Measured from the reference (scadmesh planes/slice/arcs/solid); feature IDs
// as in 821_PhotointerrupterShroudBase_A.view.json. r is the radius about the
// disk's axis.
//
//     ID  feature              value                               y span
//     O1  block                the shared x span, z 7 .. 18        -20 .. 1.75
//     J1  outer jaw underside  r 42.5                              -20 .. -14
//     S1  disk slot            r 48.0 (open below it)              -14 .. -11
//     J2  inner jaw underside  r 41.0                              -11 .. -8
//     B1  beam bore, channel A on r 44 at 0 deg: (0, 11.5)
//     B2  beam bore, channel B on r 44 at 8.777 deg: (6.714, 10.977)
//         each, along y:       Ø4.2 flat at +1.6 in x (counterbore) -20 .. -18
//                              Ø3.2, with a radial slot 1.7 wide out
//                              through J1's underside              -18 .. -14
//                              Ø2.8 cut to a radial slit 0.6 wide  -11 .. -10
//                              Ø3.2                                -10 .. -7
//                              cone Ø3.2 to Ø3.3                   -7 .. -6.8
//                              cone Ø3.3 to Ø3.7                   -6.8 .. -6.603
//                              (both cones flat at +1.6 in x)
//                              Ø4.2 flat at +1.6 in x              -6.603 .. 1.75
//     N1  nail holes through A and B (shroud_base.scad)            z 7 .. 18
//     H1  holes on N1's row, x 17.692 and -8.622: Ø1.0 z 7 .. 9.0, Ø2.5 9.0 .. 18
//
// The x span and N1 are shroud_base.scad's, which #821 B shares.
//
// The flats (the T-1 packages' flange flat) are square to x in both bores,
// though B2's slit leans with its radius. The step from Ø3.2 into the Ø4.2
// bore is a curve in the reference (r 1.625 at y -6.9, 1.65 at -6.8, 1.725 at
// -6.7, 1.83 at -6.6, then a step face at -6.603); the two cones follow it.
//
// CONSTRUCTION. Profile per layer along y, the disk's axis: each of the four
// layers (J1, S1, J2 and the plain block behind) is the block's x-z section
// less its circle about the disk's axis, extruded over its y span. The beam
// bores are cut once through every layer (../photo_shroud.scad, beam_bore),
// as a lug sandwich's hole is; N1 and H1 are cut along z.
//
// FITS (../print_fit.scad): none is drawn. The T-1 packages (Ø3.0 body) sit in
// Ø3.2 and their flanges in Ø4.2, already wider than the press fit; the #19
// nails (Ø1.07) in Ø1.5; and the disk (#100-002, 1.6 thick) runs in a 3.0
// slot. So "revised" draws the reference, and probes-821-a-wide holds the
// beam bores open.

include <../print_fit.scad>
include <photo_shroud.scad>
include <shroud_base.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// 2D layer to draw alone, for outline checks; "part" draws the part
layer = "part"; // [part, j1, s1, j2, back]

/* [Hidden] */
$fn = 144;
LAP     = 0.005;
BOX_Y   = [-20.000, 1.750];
BOX_Z   = [7.000, 18.000];
DISK_Z  = -32.500;                    // the disk's axis, at x 0
// [y0, y1, cut radius] per layer, from -y; 0 is uncut
LAYERS  = [[-20.000, -14.000, 42.500],   // J1
           [-14.000, -11.000, 48.000],   // S1
           [-11.000,  -8.000, 41.000],   // J2
           [ -8.000,   1.750, 0]];       // back
BEAM_R  = 44.000;
BEAM_A  = [0, 8.777];                 // B1, B2: degrees from +z towards +x
BEAM    = [[-21.0, -18.0, "flat", 4.2, 1.6],
           [-18.0, -13.0, "key", 3.2, 1.7],
           [-11.0, -10.0, "slit", 2.8, 0.6],
           [-10.0, -7.0, "round", 3.2],
           [-7.0, -6.8, "cone", 3.2, 3.3, 1.6],
           [-6.8, -6.603, "cone", 3.3, 3.7, 1.6],
           [-6.603, 2.75, "flat", 4.2, 1.6]];
H1_X    = [17.692, -8.622];
H1      = [[6.0, 9.0, 1.0], [9.0, 19.0, 2.5]];

// A layer's x-z section (2D x, z): the block less the disk's clearance circle.
module layer_2d(cut_r) difference() {
    translate([SHROUD_X[0], BOX_Z[0]]) square([SHROUD_X[1] - SHROUD_X[0], BOX_Z[1] - BOX_Z[0]]);
    if (cut_r > 0) translate([0, DISK_Z]) circle(r = cut_r, $fn = 720);
}

// The layers stacked along y, each lapped into the next.
module layers() for (i = [0 : len(LAYERS) - 1]) {
    l = LAYERS[i];
    lo = i == 0 ? 0 : LAP;
    translate([0, l[1] + LAP, 0]) rotate([90, 0, 0])
        linear_extrude(l[1] - l[0] + LAP + lo) layer_2d(l[2]);
}

// B1 and B2, each placed on its radius and spun so its slit lies radial.
module beams() for (a = BEAM_A)
    translate([BEAM_R * sin(a), 0, DISK_Z + BEAM_R * cos(a)]) rotate([-90, 0, 0])
        beam_bore(BEAM, a, $fn = 96);

module holes() {
    for (x = NAILS) stepped_hole([x, NAIL_Y], [[6.0, 19.0, NAIL_D]], $fn = 48);
    for (x = H1_X) stepped_hole([x, NAIL_Y], H1, $fn = 48);
}

module shroud_base_a() difference() { layers(); beams(); holes(); }

if (layer == "j1") layer_2d(LAYERS[0][2]);
else if (layer == "s1") layer_2d(LAYERS[1][2]);
else if (layer == "j2") layer_2d(LAYERS[2][2]);
else if (layer == "back") layer_2d(0);
else shroud_base_a();
