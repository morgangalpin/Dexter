// The lead groove of the two solder jigs, shared by both.
//
//     830-001_SolderJig6PinHolder.scad   six grooves down from the front block's top, one per pin
//     830-002_SolderJigLEDRig.scad       two per LED, up from the lip's underside, one per lead
//
// A groove is 0.750 wide with a round end, and its mouth's two edges are rounded R0.2. Measured on
// both references (scadmesh arcs across the grooves): the walls 0.750 apart and the mouth rounds
// R0.200 on each; the round end, on a coarse tessellation, reads as one arc of about R0.4 whose ends
// sit on the walls.
//
// Included, not used, so that its constants reach the including file.

LEAD_GROOVE_W = 0.750;   // across the walls
LEAD_GROOVE_R = 0.200;   // the mouth's rounds

// One groove's cutter in 2D, its mouth on y = 0 centred on x = 0, `depth` deep along +y to the end
// of its round. It reaches 1 below the mouth, so it cuts through the face it opens in.
module lead_groove_2d(depth) {
    w = LEAD_GROOVE_W;
    r = LEAD_GROOVE_R;
    translate([-w / 2, -1]) square([w, depth - w / 2 + 1]);
    translate([0, depth - w / 2]) circle(d = w);
    for (s = [-1, 1]) scale([s, 1]) difference() {
        translate([w / 2 - 0.01, -1]) square([r + 0.01, r + 1]);
        translate([w / 2 + r, r]) circle(r = r);
    }
}
