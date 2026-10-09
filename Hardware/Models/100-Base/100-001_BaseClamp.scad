// #100-001 Base Clamp — parametric source.
// A split ring that seats on the Base Mount Bottom's shoulder and closes the six strakes into the
// spigot's grooves, tightened by one M3 x 20 mm bolt across the split
// (specs/004 § Base mounting plate).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/100-Base/), in that mesh's frame.
//   config = "revised"  — the ring moved RING_RISE outward so its bore clears the strakes and the
//                         spigot (FITS), and print-fit clearances on the bolt's three features.
//
// FRAME. The axis is on +Z through the origin, the bottom face is at z = 0, and the split is on +X.
// The reference mesh is already in this frame.
//
// Measured from the reference with scadmesh radial/slice/arcs/solid. The feature IDs are those of
// 100-001_BaseClamp.view.json, which labels each one on the mesh:
//
//     ID  feature                      value
//     R1  outer wall                   Ø90.000
//     R2  bore                         Ø74.500
//     F1  top face, F2 bottom face     z 15, z 0; no chamfers
//     S1  split slot, on +X            1.000 wide, full height, through the wall
//     B1  bolt hole, across S1         Ø3.000, y -9 .. 7.5
//     B2  nut trap, +Y side            hex 5.5 AF, corners on ±Z, y 7.5 outward
//     B3  head counterbore, -Y side    Ø5.500, y -9 outward
//
// B1–B3 share one axis along Y, at the wall's mid-radius (41.125; the mesh gives 41.122) and
// mid-height. B2 and B3 run out through R1. The derived volume closes on the mesh's 29 325.7 mm³.
//
// FITS (../print_fit.scad), revised only:
//
//     B1, on the M3 bolt             slip
//     B2, on the M3 nut              slip
//     B3, on the M3 bolt's head      slip
//
//     R2, on the six C-501 strakes     press, on their outer corners
//     R2, on the Mount's S1 spigot     slip
//
// R2 is a clamping bore: the bolt closes S1 and the ring flexes onto the strakes. The strakes stand in
// the Mount's K1 slots, 12.700 × 3.175 on r 35.651, so their flat outer faces put their corners at
// r 37.776, outside the Ø74.604 spigot; a bore at the reference's R2 cuts 0.53 into each corner and
// 0.05 into the spigot. Revised moves the whole ring outward by RING_RISE, until R2 clears the corners
// by the press clearance, which clears the spigot by more than slip. The wall, S1 and B1–B3 move with
// it, unchanged. R2 is drawn circumscribing its circle, so no facet comes inside the clearance; closing
// it onto the corners takes about 0.3 of S1's 1.000.

include <BOSL2/std.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 144;
epsilon = 0.01;

RING      = [37.250, 45.000, 15.000];  // R2 radius, R1 radius, height
SPLIT_W   = 1.000;                     // S1
BOLT_D    = 3.000;                     // B1
NUT_AF    = 5.500;                     // B2
HEAD_D    = 5.500;                     // B3
NUT_FROM  = 7.500;                     // y where B2 starts
HEAD_FROM = -9.000;                    // y where B3 starts

// What R2 fits, revised only: the C-501 strake (tangential, radial) on the Mount's K1 centre radius,
// and the Mount's S1 spigot.
STRAKE    = [12.700, 3.175];
STRAKE_R  = 35.651;
SPIGOT_D  = 74.604;

SLIP  = fit_clearances(config)[0];
PRESS = fit_clearances(config)[1];

// The strakes' outer corners, and the ring's outward move that clears them and the spigot.
STRAKE_CORNER_R = norm([STRAKE_R + STRAKE[1] / 2, STRAKE[0] / 2]);
RING_RISE = config == "previous" ? 0
          : max(STRAKE_CORNER_R + PRESS, SPIGOT_D / 2 + SLIP) - RING[0];
BORE_R  = RING[0] + RING_RISE;
OUTER_R = RING[1] + RING_RISE;

// The bolt axis: mid-radius of the wall, mid-height.
BOLT_X = (BORE_R + OUTER_R) / 2;
BOLT_Z = RING[2] / 2;
// Far enough along Y for B2 and B3 to clear R1.
BOLT_REACH = OUTER_R + 1;

echo(bolt_axis_x = BOLT_X);
echo(bolt_axis_z = BOLT_Z);
echo(bore_d = 2 * BORE_R);

// A round cutter on the bolt axis from y0 to y1.
module bolt_cyl(d, y0, y1) {
    translate([BOLT_X, (y0 + y1) / 2, BOLT_Z])
        ycyl(d = d, l = y1 - y0, anchor = CENTER);
}

// B2: a hexagonal prism on the bolt axis from y0 to y1, corners on ±Z.
module nut_prism(af, y0, y1) {
    translate([BOLT_X, y0, BOLT_Z])
        xrot(-90) linear_extrude(y1 - y0) zrot(90) hexagon(id = af);
}

module split_slot() {
    translate([BORE_R - 1, -SPLIT_W / 2, -1])
        cube([OUTER_R - BORE_R + 2, SPLIT_W, RING[2] + 2]);
}

module base_clamp() {
    difference() {
        tube(h = RING[2], or = OUTER_R, ir = BORE_R, circum = config != "previous", realign = false, anchor = BOTTOM);
        split_slot();
        bolt_cyl(fit_bore(BOLT_D, SLIP), -BOLT_REACH, BOLT_REACH);
        nut_prism(fit_bore(NUT_AF, SLIP), NUT_FROM, BOLT_REACH);
        bolt_cyl(fit_bore(HEAD_D, SLIP), -BOLT_REACH, HEAD_FROM);
    }
}

base_clamp();
