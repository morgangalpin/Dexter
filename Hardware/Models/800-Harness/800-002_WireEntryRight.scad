// #800-002 Wire Entry (Right) — parametric source.
// The other half of the wire entry of #800-001: its mirror image in the split
// plane x = 0. The geometry, constants and fits are documented in
// 800-001_WireEntryLeft.scad, which this file `include`s and whose `SIDE` it
// overrides so that only this half is drawn.

include <800-001_WireEntryLeft.scad>

SIDE = "right";
