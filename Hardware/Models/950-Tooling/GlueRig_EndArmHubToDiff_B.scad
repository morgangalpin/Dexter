// -----------------------------------------------------------------------------
// GlueRig_EndArmHubToDiff_B — the L3 glue rig's hub half, shortened to the
// specified link length.
//
// WHAT THIS PART IS. The L3 rig bonds the End Arm Hub to the differential over
// the C-505 tube (specs/007.2 § Tooling). It is two printed halves that lap:
// the A half carries the differential register and a shoulder at x = 128.287,
// and this half butts that shoulder with its own end face and carries the hub
// register — a Ø22.971 boss with four Ø1.994 pins on r = 14.500, entering the
// End Arm Hub's Ø22.990 J3 bore and its four Ø4.995 holes.
//
// WHY IT IS EDITED. Both registers are precision fits, so the assembled rig
// states J3 to J4 directly. As exported it stated 309.500 mm, against the
// 307.500 mm specs/003 § Link lengths and Firmware/Defaults.make_ins both
// carry. The firmware and the arm are the design of record, so the jig is what
// moves: specs/009 DC-11(h).
//
// HOW. The 2.000 mm comes out of a prismatic stretch of the bar, not out of
// either register. This half's section is constant over x 160..250 — two rails
// on z 19..23 — so the part is cut at x = 200 and the outboard piece telescoped
// 2.000 mm inboard. Nothing but bar length changes: the end face stays on
// x = 128.287 where the A half's shoulder meets it, so the A half is untouched
// and the lap is unaltered, and the hub register lands on x = 290.635, which is
// 307.500 mm from the A half's differential register at x = -16.865.
//
// The pre-correction mesh is kept at
// ../Reference/superseded/GlueRig_EndArmHubToDiff_B_span309500.stl and is what
// this file cuts; the corrected mesh is rendered over
// GlueRig_EndArmHubToDiff_B.stl. Rendering it needs CGAL:
//   openscad -o 950-Tooling/GlueRig_EndArmHubToDiff_B.stl \
//            950-Tooling/GlueRig_EndArmHubToDiff_B.scad
// -----------------------------------------------------------------------------

SRC   = "../Reference/superseded/GlueRig_EndArmHubToDiff_B_span309500.stl";

CUT   = 200.000;   // inside the constant-section run, clear of every feature
SHORT =   2.000;   // 309.500 as exported, less the specified 307.500

// A box big enough to halve the part at any plane it is cut on.
BIG = 500;
module half(lo, hi) {
    intersection() {
        import(SRC, convexity = 10);
        translate([lo, -BIG, -BIG]) cube([hi - lo, 2 * BIG, 2 * BIG]);
    }
}

// The two pieces overlap by SHORT after the move, so the union has volume to
// work on rather than two faces meeting at zero thickness.
union() {
    half(CUT - BIG, CUT);
    translate([-SHORT, 0, 0]) half(CUT, CUT + BIG);
}
