// #421-006 Pulley Spacer — parametric source.
// A thin flanged washer on the 113 mm stainless tube (C-507, Ø8). One stands
// between the Internal Inner and Outer Pulleys (008.7 step 10), and a second
// between the External Inner and Outer Pulleys (step 22). Two are printed.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/400-EndArm/), in that mesh's
//                         frame.
//   config = "revised"  — the same part with its hub shortened (FITS, below).
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
//     H1, its height (revised)          0.450 shorter: the first spacer is
//                                       the one free length in the stack
//                                       from the Cap's MR128 to the End Arm
//                                       Hub's 6703, which is that much too
//                                       long with the 6703 on its seat
//                                       (endarm_assembly.scad § STACK
//                                       derives it)
//
// The flange and hub faces bear on the pulleys either side: face contacts,
// which take no clearance. They are thrust faces: each spacer stands between
// two pulleys that turn past each other.

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
STACK_TRIM = 0.450;         // H1, revised: the stack's excess

function hub_top() = HUB[1] - (config == "revised" ? STACK_TRIM : 0);

// The hub's R1 round, from the top face down to the cylinder.
function hub_round() = [for (i = [0 : 8]) let (a = 90 - 90 * i / 8)
    [HUB[0] - HUB_R + HUB_R * cos(a), hub_top() - HUB_R + HUB_R * sin(a)]];

PROFILE = concat([[BORE_D / 2, 0], [BORE_D / 2, hub_top()]],
                 hub_round(),
                 [[HUB[0], FLANGE[1]], [FLANGE[0], FLANGE[1]], [FLANGE[0], 0]]);

module pulley_spacer() rotate_extrude() polygon(PROFILE);

pulley_spacer();
