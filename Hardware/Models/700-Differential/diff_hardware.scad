// 700-Differential bought-part stand-ins — the bearings and the rod, drawn
// only so the assembly reads as a machine (DC-2).
//
// NOTHING HERE IS A PART MODEL. None of it is printed, none of it is gated
// against a reference, and no dimension below is a measurement. Each module
// draws the ENVELOPE a catalogue part occupies, with just enough shape to be
// recognisable in a render: a bearing shows two races and a sunk shield, the
// rod shows its bore. What they are for is negative space. The seven printed
// parts are dimensioned around these, so a seat that reads as an empty gap in
// the assembly is a placement mistake, and a seat that reads as full is one
// that was checked. Drawing them is the only way to tell those two apart by
// looking.
//
// NO SIZE IS TYPED HERE. Every module takes one of diff_params.scad's
// catalogue triples, [ID, OD, width], so re-specifying a bearing there moves
// both the seat that holds it and the stand-in that fills it. The one number
// this file does choose is how coarsely to draw them: these are illustrations,
// so they are drawn at HW_FN rather than at the $fn the measured parts need.

include <diff_params.scad>

/* [Hidden] */
HW_FN     = 48;     // stand-ins are drawn, not measured
HW_SHIELD = 0.35;   // how deep a shield sits below the race faces

// A deep-groove ball bearing: an outer race, an inner race, and a shield sunk
// between them on both faces. Anchored on its own bottom face, so that placing
// one is a single z — the seat's own floor — and never an arithmetic.
module bearing(spec) {
    id = spec[0];  od = spec[1];  w = spec[2];
    race   = max(0.6, (od - id) / 5);
    shield = min(HW_SHIELD, w / 6);
    difference() {
        tube(id = id, od = od, h = w, anchor = BOTTOM, $fn = HW_FN);
        down(epsilon)
            tube(id = id + race, od = od - race, h = shield + epsilon,
                 anchor = BOTTOM, $fn = HW_FN);
        up(w - shield)
            tube(id = id + race, od = od - race, h = shield + epsilon,
                 anchor = BOTTOM, $fn = HW_FN);
    }
}

// A needle roller thrust bearing between its two washer races (#710-006 is the
// AXK cage; the two AS races are listed with it). Drawn as three stacked rings
// because the stack's height is what the seat has to clear, and that is the
// sum of all three rather than the cage alone.
module thrust_stack(spec = THRUST_AXK0819, race_w = 1.0) {
    id = spec[0];  od = spec[1];  w = spec[2];
    tube(id = id, od = od, h = race_w, anchor = BOTTOM, $fn = HW_FN);
    up(race_w)
        tube(id = id + 0.5, od = od - 0.5, h = w, anchor = BOTTOM, $fn = HW_FN);
    up(race_w + w)
        tube(id = id, od = od, h = race_w, anchor = BOTTOM, $fn = HW_FN);
}

function thrust_stack_h(spec = THRUST_AXK0819, race_w = 1.0) =
    spec[2] + 2 * race_w;

// The #720-006 carbon fibre rod, drawn as the tube it is: its bore is the tool
// conductors' path, so a solid cylinder would misrepresent what the assembly
// has room for. Anchored on its own bottom face, like the bearings.
module cf_rod(len = CF_ROD_LEN) {
    tube(id = CF_ROD_ID, od = CF_ROD_D, h = len, anchor = BOTTOM, $fn = HW_FN);
}

// A #680-001 wire brad: the pin that locks the Split Gear's two halves to each
// other (008.6 steps 7-9), driven radially and trimmed flush. Drawn lying on
// +X from the origin, like the bearings are drawn from their bottom face, so
// placing one is a rotation and a radius and never an arithmetic.
//
// It is drawn at BRAD_D, which is LARGER than the Ø1.5 holes it sits in, and
// that overlap is the point: the fit is an interference, the brad cutting its
// own seat as it goes. Drawing it at the hole's diameter would show a clearance
// the part does not have.
module brad(len) {
    yrot(90) cyl(d = BRAD_D, h = len, anchor = BOTTOM, $fn = HW_FN);
}

// A GT2 belt run between two pulleys is not modelled: the belts leave the
// differential through Diff Body A's arm slot and their path is set by the
// upper arm, which is outside this model set. The slot itself is geometry and
// is in 730-001.
