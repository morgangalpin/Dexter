// #821 Photointerrupter Shroud (Base): what its body (A) and plate (B) share.
// No part and no top-level geometry. Both parts take their x span and the
// nail row that pins them together from here; each part's header owns the
// rest. Frame: the reference's, the code disk's axis parallel to y through
// (x 0, z -32.5).

SHROUD_X  = [-11.462, 20.533];     // both parts' x span
NAIL_Y    = -3.500;                // N1, the #19 nails through both parts
NAILS     = [12.012, 3.107, -4.941];
NAIL_D    = 1.500;
