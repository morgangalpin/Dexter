// #210-003 Idler Plug — parametric source.
// The plug the Belt Director Pulley's bearing turns on. It passes through both plates of the Arm Body's D
// column and the pulley's MR85 between them, its head on the upper plate, and an M2 x 20 bolt through its
// bore carries the nut at the lower plate's face (specs/008.5 steps 8-10). The Belt Director Caps
// (#210-001) are a separate part, belt_director.scad's.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/200-ArmBody/210-001_IdlerPlug.stl), in that mesh's frame.
//   config = "revised"  — the plug the D column's through hole takes (200-001_ArmBody.scad): a tube of the
//                         column's whole depth, bored for the bolt.
//
// FRAME. The reference's own: the axis on +Z through the origin, the shank's end at z = 0.
//
// Measured from the reference with scadmesh profile/radial/planes. The feature IDs are those of
// 210-003_IdlerPlug.view.json:
//
//     ID  feature   value     z span
//     S1  shank     Ø6.000    0 .. 5, solid
//     H1  head      Ø11.000   5 .. 6
//
// REVISED. The reference's Ø6 shank is neither the MR85's Ø5 bore nor the upper plate's Ø5 hole, and its
// 5 mm stops short of the upper plate. `revised` is the part that fits both:
//
//     ID  feature   value                                  z span
//     S1  tube      Ø4.900, the MR85's Ø5 bore at the      0 .. TUBE
//                   press clearance
//     H1  head      Ø11.000, outer edge R1                 TUBE .. TUBE + 2
//     B1  bolt bore Ø2.300, the M2 at the slip clearance   through
//
// TUBE is the D column's depth, z 55.650 .. 70.250, so the tube's end is flush with the lower plate's
// face when the head is on the upper plate's. The tube is Ø4.9 in the Arm Body's Ø5.2 holes
// (200-001_ArmBody.scad, plug_hole_r), the slip clearance to it. The head is as thick as the Belt Director discs, with its outer edge rounded.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 144;

SHANK = [3.000, 5.000];    // radius, top
HEAD  = [5.500, 6.000];    // radius, top

MR85_BORE = 5.000;
BOLT_D    = 2.000;         // M2
TUBE      = 14.600;        // revised: z 55.650 .. 70.250 of the Arm Body
HEAD_T    = 2.000;         // revised: as the Belt Director discs
HEAD_R    = 1.000;         // revised: the round on the head's outer edge

module idler_plug_previous()
    rotate_extrude() polygon([[0, 0], [SHANK[0], 0], [SHANK[0], SHANK[1]],
                              [HEAD[0], SHANK[1]], [HEAD[0], HEAD[1]], [0, HEAD[1]]]);

module idler_plug_revised()
    let(c = fit_clearances("revised"), r = fit_pin(MR85_BORE, c[1]) / 2, bore = fit_bore(BOLT_D, c[0]) / 2)
    rotate_extrude() polygon(concat(
        [[bore, 0], [r, 0], [r, TUBE], [HEAD[0], TUBE]],
        [for (i = [0 : 12]) let(a = 90 * i / 12) [HEAD[0] - HEAD_R + HEAD_R * cos(a), TUBE + HEAD_T - HEAD_R + HEAD_R * sin(a)]],
        [[bore, TUBE + HEAD_T]]));

module idler_plug(cfg = config)
    if (cfg == "previous") idler_plug_previous(); else idler_plug_revised();

idler_plug();
