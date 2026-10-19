// #421-006 Pulley Spacer — parametric source.
// A thin flanged washer on the 113 mm stainless tube (C-507, Ø8). One stands
// between the Internal Inner and Outer Pulleys (008.7 step 10), and a second
// between the External Inner and Outer Pulleys (step 22). Two are printed.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/400-EndArm/), in that mesh's
//                         frame.
//   config = "revised"  — the same part; its one fit already reaches its class
//                         (FITS, below), so nothing changes.
//
// FRAME. The axis is +Z through the origin, the flange's flat face at z = 0
// and the hub rising from its other face. The reference mesh is already in
// this frame.
//
// CONSTRUCTION. The part is turned, so it is one revolved profile (the
// mesh-to-scad ladder's rung 3).
//
// Measured from the reference with scadmesh planes/radial/slice/profile. The
// feature IDs are those of 421-006_PulleySpacer.view.json, which labels each
// one on the mesh:
//
//     ID  feature                     value
//     F1  flange                      Ø26.000, z 0 .. 0.800
//     H1  hub                         Ø11.000, z 0.800 .. 1.800
//     R1  hub's top outer edge        R0.400
//     B1  bore                        Ø8.300, through
//
// The section at mid-flange holds only the flange's circle and the bore, so
// nothing is cut through the flange.
//
// FITS (../print_fit.scad):
//
//     B1, on the Ø8 stainless tube      press; the reference's Ø8.300 already
//                                       stands 0.150 off it per side, so the
//                                       bore keeps its size (007.2 § Print fits)
//
// The flange and hub faces bear on the pulleys either side: face contacts,
// which take no clearance.

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 180;

FLANGE = [13.000, 0.800];   // F1: radius, top z
HUB    = [5.500, 1.800];    // H1: radius, top z
HUB_R  = 0.400;             // R1
BORE_D = 8.300;             // B1
TUBE_D = 8.000;             // the C-507 tube it rides on

// The hub's R1 round, from the top face down to the cylinder.
function hub_round() = [for (i = [0 : 8]) let (a = 90 - 90 * i / 8)
    [HUB[0] - HUB_R + HUB_R * cos(a), HUB[1] - HUB_R + HUB_R * sin(a)]];

PROFILE = concat([[BORE_D / 2, 0], [BORE_D / 2, HUB[1]]],
                 hub_round(),
                 [[HUB[0], FLANGE[1]], [FLANGE[0], FLANGE[1]], [FLANGE[0], 0]]);

module pulley_spacer() rotate_extrude() polygon(PROFILE);

pulley_spacer();
