// #210-005 Large Belt Director — parametric source.
// The Large Belt Director: belt_director.scad's shouldered sleeve, with S1 27.000 long (26.000 in `revised`). That file owns
// the measurements, the feature IDs and the deferred fits.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/200-ArmBody/), in that mesh's frame.
//   config = "revised"  — the same part with its head drawn as belt_director.scad's disc and its shank at the press clearance.

use <belt_director.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 144;

LENGTH         = 27.000;   // S1, previous
REVISED_LENGTH = 26.000;   // S1, revised: the span between the outer bearings at A

belt_director(config == "previous" ? LENGTH : REVISED_LENGTH, config);
