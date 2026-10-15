// #210-004 Small Belt Director — parametric source.
// The Small Belt Director: belt_director.scad's shouldered sleeve, with S1 17.000 long. That file owns
// the measurements, the feature IDs and the deferred fits.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/200-ArmBody/), in that mesh's frame.
//   config = "revised"  — the same part. Its fits wait for the arm body's assembly.

use <belt_director.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 144;

LENGTH = 17.000;   // S1

belt_director(LENGTH);
