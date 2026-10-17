// #300-002 Pivot Code Disk — parametric source.
// J2's encoder wheel. It slides onto the Main Pivot's J2 drum, flat side away
// from the body (008.4 step 5), and the J2 photointerrupter reads its slits.
// Six windows lighten it; two pegs stand on its hub side.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/300-Pivot/), in that mesh's
//                         frame.
//   config = "revised"  — the same part with its print fit on the bore.
//
// FRAME. The axis is on +Z through the origin, the flat face at z = 0 and the
// hub rising from the other face. The first code slit and the first window
// are on +X. The reference mesh is already in this frame.
//
// CONSTRUCTION. The disc is two constant sections, each drawn whole in 2D and
// extruded once, as #100-002's is:
//
//     lower layer   z 0 .. 0.2     disc - bore - windows - holes - underside groove
//     upper layer   z 0.2 .. 1.6   disc - bore - windows - holes - code slits
//
// The slits therefore stay closed across the bottom 0.2, except where the
// groove opens their middle. The hub is one revolved profile and each peg
// another; the holes are cut through the lot. `layer = "lower"` or `"upper"`
// draws that profile in 2D, for verification against the mesh's section
// (scadmesh outline; render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/radial/slice/arcs/pattern
// and profile (the pegs' from the mesh turned 30 deg). The feature IDs are
// those of 300-002_PivotCodeDisk.view.json, which labels each one on the mesh:
//
//     ID  feature                     value
//     D1  outer edge                  Ø95.000
//     F1  top face, F2 flat face      z 1.6, z 0
//     B1  bore                        Ø53.200, through
//     W1  windows, 6 from 0 deg       r 31.5 .. 41.5, between spokes 6.0 wide
//                                     on 30 deg + 60 deg k; R4 corners
//     C1  code slits, 180 from 0 deg  3.8 radial x 0.8, about r 45.0; upper layer only
//     G1  underside groove            Ø87.0 .. Ø93.0, lower layer only
//     H1  hub                         Ø59.0 to z 6.2, then a 45 deg cone out
//                                     to Ø63.0 at the top face, z 3.6 .. 1.6
//     P1  pegs, 2 at 30 and 90 deg    Ø6.0 about r 35.822, z 1.6 .. 6.2; a 45 deg
//                                     flare 1.0 wide at the foot
//     P2  peg holes                   Ø1.0, through the disc and the peg
//
// The slits are centred on the groove's mid-radius.
//
// FITS (../print_fit.scad), revised only:
//
//     B1, on the Main Pivot's Ø53 J2 drum     slip
//
// The reference's own bore stands 0.1 off the drum per side.

include <BOSL2/std.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one layer's 2D profile
layer = "part"; // [part, lower, upper]

/* [Hidden] */
$fn = 180;
epsilon = 0.01;

DISC_D    = 95.000;                    // D1
HEIGHT    = 1.600;                     // F1
LOWER_H   = 0.200;                     // the lower layer's top
BORE_D    = 53.200;                    // B1; the drum it slides on is JOURNAL_D
JOURNAL_D = 53.000;
WINDOW    = [31.500, 41.500, 4.000];   // W1: inner radius, outer radius, corner radius
SPOKE_W   = 6.000;                     // between the windows, on 30 deg + 60 deg k
SLIT      = [45.000, 3.800, 0.800];    // C1: centre radius, radial length, width
GROOVE_D  = [87.000, 93.000];          // G1: inner and outer diameter
HUB       = [29.500, 6.200, 3.600];    // H1: outer radius, top z, z of the cone's start
HUB_FOOT  = 31.500;                    // the cone's radius at the top face
PEG       = [35.822, 3.000, 6.200, 1.000, 1.000];   // P1: centre radius, radius, top z, flare, hole Ø

// [count, angle of the first] for each repeated feature.
WINDOWS = [6, 0];
SLITS   = [180, 0];
PEGS    = [2, 30, 60];                 // count, angle of the first, pitch

SLIP = fit_clearances(config)[0];

// Children placed at `n` equal angles from `start`, each on its own +X.
module ring_of(pattern) {
    for (k = [0 : pattern[0] - 1])
        rotate(pattern[1] + 360 * k / pattern[0]) children();
}

// One window, on +X: the annulus between the spokes either side, its corners
// rounded by an opening.
module window_2d() {
    offset(r = WINDOW[2]) offset(delta = -WINDOW[2]) intersection() {
        difference() { circle(r = WINDOW[1]); circle(r = WINDOW[0]); }
        rotate(30)  translate([-100, -100 - SPOKE_W / 2]) square([200, 100]);
        rotate(-30) translate([-100, SPOKE_W / 2]) square([200, 100]);
    }
}

module windows_2d() ring_of(WINDOWS) window_2d();

module slits_2d() {
    ring_of(SLITS) right(SLIT[0]) square([SLIT[1], SLIT[2]], center = true);
}

module groove_2d() {
    difference() {
        circle(d = GROOVE_D[1]);
        circle(d = GROOVE_D[0]);
    }
}

// The bore's radius in this configuration: the reference's, or the drum's plus the slip fit.
function bore_r() = fit_bore(config == "previous" ? BORE_D : JOURNAL_D, SLIP) / 2;

module peg_places() {
    for (k = [0 : PEGS[0] - 1]) rotate(PEGS[1] + PEGS[2] * k) right(PEG[0]) children();
}

module peg_holes_2d() peg_places() circle(d = PEG[4], $fn = 48);

module lower_2d() {
    difference() {
        circle(d = DISC_D);
        circle(r = bore_r());
        windows_2d();
        groove_2d();
        peg_holes_2d();
    }
}

module upper_2d() {
    difference() {
        circle(d = DISC_D);
        circle(r = bore_r());
        windows_2d();
        slits_2d();
        peg_holes_2d();
    }
}

module hub() {
    rotate_extrude() polygon([[bore_r(), HEIGHT - epsilon], [bore_r(), HUB[1]], [HUB[0], HUB[1]],
                              [HUB[0], HUB[2]], [HUB_FOOT, HEIGHT], [HUB_FOOT, HEIGHT - epsilon]]);
}

// A peg's cylinder.
module peg() cylinder(r = PEG[1], h = PEG[2] - HEIGHT + epsilon, $fn = 90);

// A peg's flare: a 45 deg cone from the top face out to PEG[3] past the
// cylinder, which the spoke clips to its own width.
module peg_flare() {
    rotate_extrude() polygon([[0, HEIGHT - epsilon], [PEG[1] + PEG[3], HEIGHT - epsilon],
                              [PEG[1] + PEG[3], HEIGHT], [PEG[1], HEIGHT + PEG[3]], [0, HEIGHT + PEG[3]]]);
}

// The pegs, and their flares kept to the material of the top face.
module pegs() {
    up(HEIGHT - epsilon) peg_places() peg();
    intersection() {
        peg_places() peg_flare();
        translate([0, 0, HEIGHT - 1]) linear_extrude(3) difference() { circle(d = DISC_D); windows_2d(); }
    }
}

module pivot_code_disk() {
    difference() {
        union() {
            linear_extrude(LOWER_H) lower_2d();
            up(LOWER_H - epsilon) linear_extrude(HEIGHT - LOWER_H + epsilon) upper_2d();
            hub();
            pegs();
        }
        peg_places() down(1) cylinder(d = PEG[4], h = PEG[2] + 2, $fn = 48);
    }
}

if (layer == "lower") lower_2d();
else if (layer == "upper") upper_2d();
else pivot_code_disk();
