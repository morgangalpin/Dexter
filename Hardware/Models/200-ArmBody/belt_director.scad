// The Belt Director: a shouldered sleeve, shared by the two lengths of it.
//
//     210-004_SmallBeltDirector.scad   S1 17.000 long
//     210-005_LargeBeltDirector.scad   S1 27.000 long
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
// FITS, deferred: S1 on the MR128's bore is settled with the arm body's assembly (armbody_assembly).
//
// Used, not included: each part file calls belt_director(length).

BELT_DIRECTOR_HEAD  = [5.500, 0.500];   // radius, thickness
BELT_DIRECTOR_SHANK = 4.000;            // radius
BELT_DIRECTOR_CORE  = 2.350;            // radius

module belt_director(length)
    rotate_extrude() polygon([
        [0, -BELT_DIRECTOR_HEAD[1]], [BELT_DIRECTOR_HEAD[0], -BELT_DIRECTOR_HEAD[1]],
        [BELT_DIRECTOR_HEAD[0], 0], [BELT_DIRECTOR_SHANK, 0], [BELT_DIRECTOR_SHANK, length],
        [BELT_DIRECTOR_CORE, length], [BELT_DIRECTOR_CORE, 0], [0, 0]]);
