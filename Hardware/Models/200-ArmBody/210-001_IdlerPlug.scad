// #210-001 / #210-003 Idler Plug — parametric source.
// The plug the Belt Director Pulley's bearing turns on, pushed through the Arm Body's D column and
// held by an M2 x 20 bolt (specs/008.5 steps 8-10). This one file serves both part numbers
// (PART-INDEX § One geometry, two part numbers).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/200-ArmBody/), in that mesh's frame.
//   config = "revised"  — the same part. Its fits wait for the arm body's assembly (below).
//
// FRAME. The reference's own: the axis on +Z through the origin, the shank's end at z = 0.
//
// Measured from the reference with scadmesh profile/radial/planes. The feature IDs are those of
// 210-001_IdlerPlug.view.json:
//
//     ID  feature   value     z span
//     S1  shank     Ø6.000    0 .. 5, solid
//     H1  head      Ø11.000   5 .. 6
//
// FITS, deferred: S1 is Ø6.000, but specs/008.5 puts an MR85 (Ø5 bore) on it, and the D column's
// upper plate has a Ø5 hole. Which of the three is right is settled with the arm body's assembly
// (armbody_assembly), so revised draws no fit yet.

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 144;

SHANK = [3.000, 5.000];    // radius, top
HEAD  = [5.500, 6.000];    // radius, top

module idler_plug(cfg = config)
    rotate_extrude() polygon([[0, 0], [SHANK[0], 0], [SHANK[0], SHANK[1]],
                              [HEAD[0], SHANK[1]], [HEAD[0], HEAD[1]], [0, HEAD[1]]]);

idler_plug();
