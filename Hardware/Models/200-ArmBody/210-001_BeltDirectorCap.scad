// #210-001 Belt Director Cap — parametric source.
// The cap pressed into the back of a Large or Small Belt Director behind its outer bearing
// (specs/008.5 step 7c). belt_director.scad owns the dimensions and why the disc is the size it is, so the
// cap's disc and the directors' heads agree.
//
//   config = "revised"  — the only configuration: no reference mesh exists for this part (PART-INDEX).
//
// FRAME. The disc's underside at z = 0, the plug below it, the axis on +Z through the origin.

use <belt_director.scad>

/* [Hidden] */
$fn = 144;

belt_director_cap("revised");
