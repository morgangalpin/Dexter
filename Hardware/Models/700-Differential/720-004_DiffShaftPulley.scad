// #720-004 Diff Shaft Pulley — parametric source (DC-12).
// The 80T GT2 input pulley of the Diff Gear Shaft's channel, in "revised"
// only. In "previous" the shaft's own 40T band is that pulley and this part
// does not exist.
//
// A ring rather than teeth on the shaft, because the shaft enters Diff Body A
// through the 6705's Ø25 bore and an 80T tooth ring cannot follow it. The ring
// is set into Body A's pulley chamber through the +X window first, and the
// shaft is then driven through it (specs/008 § 008.6): its bore is the female
// of the shaft's 40T band, so the band keys it like a spline, and epoxy in the
// bore holds it axially.
//
// Authored in 720-001's frame, on BAND_Z — the span it shares with the band —
// so the assembly places it with the shaft's own transform. The exported mesh
// is based at z = 0 for printing.

include <diff_params.scad>

assert(config == "revised",
       "#720-004 exists only in the revised configuration (DC-12)");

/* [Hidden] */
FLANGE_H    = 0.75;     // each flange; leaves a 6.5 mm belt band
FLANGE_OVER = 0.5;      // flange radius over the tooth tip
SPLINE_GAP  = 0.1;      // radial gap over the band, taken up by the epoxy

RING_H      = BAND_Z[1] - BAND_Z[0];
FLANGE_R    = PULLEY_TIP_D / 2 + FLANGE_OVER;

// The part's extent in 720-001's frame, for the assembly.
function shaft_pulley_box() =
    [[-FLANGE_R, -FLANGE_R, BAND_Z[0]], [FLANGE_R, FLANGE_R, BAND_Z[1]]];

module diff_shaft_pulley() {
    up(BAND_Z[0]) difference() {
        union() {
            cyl(r = FLANGE_R, h = FLANGE_H, anchor = BOTTOM);
            up(FLANGE_H - epsilon)
                linear_extrude(RING_H - 2 * FLANGE_H + 2 * epsilon)
                    pulley_teeth_2d();
            up(RING_H - FLANGE_H) cyl(r = FLANGE_R, h = FLANGE_H, anchor = BOTTOM);
        }
        down(epsilon) linear_extrude(RING_H + 2 * epsilon)
            offset(delta = SPLINE_GAP) band_teeth_2d();
    }
}

down(BAND_Z[0]) diff_shaft_pulley();
