// #100-002 Base Code Disc — parametric source.
// J1's encoder wheel. It snaps onto the strakes protruding from the Base Long (008.4 step 9b), around
// the Base Stator Holder, and the base photointerrupter reads its slits.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/100-Base/), in that mesh's frame.
//   config = "revised"  — the same part with its print fit on the bore.
//
// FRAME. The axis is on +Z through the origin, with the bottom face at z = 0. The first strake slot
// and the first code slit are on +X. The reference mesh is already in this frame.
//
// CONSTRUCTION. The disc is two constant sections, each drawn whole in 2D and extruded once:
//
//     lower layer   z 0 .. 0.2     disc - bore - strake slots - underside groove
//     upper layer   z 0.2 .. 1.6   disc - bore - strake slots - code slits
//
// The slits therefore stay closed across the bottom 0.2, except where the groove opens their middle.
// `layer = "lower"` or `"upper"` draws that profile in 2D, for verification against the mesh's
// section (scadmesh outline; render-all.rs does this).
//
// Measured from the reference with scadmesh planes/radial/slice/arcs/pattern/solid. The feature IDs
// are those of 100-002_BaseCodeDisc.view.json, which labels each one on the mesh:
//
//     ID  feature                     value
//     D1  outer edge                  Ø94.300
//     F1  top face, F2 bottom face    z 1.6, z 0
//     B1  bore                        Ø65.000
//     N1  notches, 6 from 30 deg      R5.200 about r 35.540, blended into B1 with R1.000
//     S1  strake slots, 6 from 0 deg  12.700 tangential x 3.300 radial, about r 35.650
//     C1  code slits, 200 from 0 deg  4.000 radial x 0.800, about r 44.475; upper layer only
//     G1  underside groove            Ø85.900 .. Ø92.000, lower layer only
//
// The slits are centred on the groove's mid-radius. The onshape-v1 STEP (KP0007-01) is an older
// revision: it is 1.0 thick, with 100 slits and R0.8 blends. It confirms D1, G1 and N1 but is not
// the source.
//
// FITS (../print_fit.scad), revised only:
//
//     B1, on the Base Stator Holder's Ø65 body    slip
//
// S1 keeps its size, because it already clears the 12.6 x 3.2 strake by 0.05 per side, which is
// the press clearance. N1 clears the all-thread and its nut by about 2 mm, and is not a fit.

include <BOSL2/std.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D profile
layer = "part"; // [part, lower, upper]

/* [Hidden] */
$fn = 180;  // the mesh's own facets set the residual (0.021 mm either way); 360 doubles the render time

DISC_D   = 94.300;                     // D1
HEIGHT   = 1.600;                      // F1
LOWER_H  = 0.200;                      // the lower layer's top
BORE_D   = 65.000;                     // B1
NOTCH    = [35.540, 5.200, 1.000];     // N1: centre radius, radius, blend radius
SLOT     = [35.650, 12.700, 3.300];    // S1: centre radius, tangential length, radial width
SLIT     = [44.475, 4.000, 0.800];     // C1: centre radius, radial length, width
GROOVE_D = [85.900, 92.000];           // G1: inner and outer diameter

// [count, angle of the first] for each repeated feature.
NOTCHES = [6, 30];
SLOTS   = [6, 0];
SLITS   = [200, 0];

SLIP = fit_clearances(config)[0];

// Children placed at `n` equal angles from `start`, each on its own +X.
module ring_of(pattern) {
    for (k = [0 : pattern[0] - 1])
        rotate(pattern[1] + 360 * k / pattern[0]) children();
}

// B1 and N1: the bore with its notches, the joints blended by a closing.
module bore_2d() {
    offset(r = -NOTCH[2]) offset(r = NOTCH[2]) union() {
        circle(d = fit_bore(BORE_D, SLIP));
        ring_of(NOTCHES) right(NOTCH[0]) circle(r = NOTCH[1]);
    }
}

module slots_2d() {
    ring_of(SLOTS) right(SLOT[0]) square([SLOT[2], SLOT[1]], center = true);
}

module slits_2d() {
    ring_of(SLITS) right(SLIT[0]) square([SLIT[1], SLIT[2]], center = true);
}

module groove_2d() {
    difference() {
        circle(d = GROOVE_D[1]);
        circle(d = GROOVE_D[0]);
    }
}

module lower_2d() {
    difference() {
        circle(d = DISC_D);
        bore_2d();
        slots_2d();
        groove_2d();
    }
}

module upper_2d() {
    difference() {
        circle(d = DISC_D);
        bore_2d();
        slots_2d();
        slits_2d();
    }
}

module base_code_disc() {
    linear_extrude(LOWER_H) lower_2d();
    up(LOWER_H) linear_extrude(HEIGHT - LOWER_H) upper_2d();
}

if (layer == "lower") lower_2d();
else if (layer == "upper") upper_2d();
else base_code_disc();
