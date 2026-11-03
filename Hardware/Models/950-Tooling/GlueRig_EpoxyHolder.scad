// GlueRig_EpoxyHolder — the glue rigs' epoxy cartridge holder — parametric source.
// A bench that stands the epoxy cartridge while the glue rigs are filled; with the Epoxy Plunger it
// serves all three spans (specs/007.2 § Tooling — glue rigs).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/950-Tooling/), in that mesh's frame.
//   config = "revised"  — the same part; see FITS.
//
// FRAME. The reference's own: the top face on z = 0, the part from y 0 to 30.5, symmetric about x = 0.
//
// CONSTRUCTION. A section in (x, z), extruded along +Y, in three layers: the outer section over
// y 0 .. 10.125 and 20.375 .. 30.5, and the middle section, whose legs' inner faces stand further out,
// over y 10.125 .. 20.375. Each section is a polygon whose corners are rounded in 2D (BOSL2
// round_corners, convex and concave alike). `layer = "outer"` or `"middle"` draws that section in 2D,
// for verification against the mesh's section across y (render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/slice/arcs (sections across y and z):
//
//     ID  feature        value
//     T1  top slab       |x| <= 43.875, z -9.5 .. 0; its outer bottom corners R2
//     C1  centre         |x| <= 21.361 down to z -14.5
//     L1  legs           |x| 21.361 .. 30.375, z -44.5 .. -9.5; outer bottom corners R2, R2 fillets
//                        under T1
//     N1  leg notches    the legs' inner faces at |x| 23.5 over y 10.125 .. 20.375
//
// The faces at y 6.1, 12.2, 18.3 and 24.4 in scadmesh planes are tessellation bands; sections either
// side of them are identical.
//
// FITS: none drawn. The holder meets only the bought epoxy cartridge, whose dimensions the design
// record does not hold, so `revised` is `previous`.

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// What to draw: the part, or one section in 2D
layer = "part"; // [part, outer, middle]

/* [Hidden] */
$fn = 96;
SEAM_LAP = 0.005;   // each layer runs this far into the next, so no two faces coincide

SLAB    = [43.875, 9.500];      // T1: half-width, thickness
CENTRE  = [21.361, 14.500];     // C1: half-width, depth
LEG     = [30.375, 44.500];     // L1: outer half-width, depth
NOTCH_X = 23.500;               // N1: the legs' inner faces over the notch
ROUND   = 2.000;                // T1's and L1's corners, and the fillets under T1
LENGTH  = 30.500;
MIDDLE  = [10.125, 20.375];     // N1's y span

// One section in (x, z), the legs' inner faces at |x| = inner.
module section_2d(inner) {
    half = [[SLAB[0], 0], [SLAB[0], -SLAB[1]], [LEG[0], -SLAB[1]], [LEG[0], -LEG[1]],
            [inner, -LEG[1]], [inner, -CENTRE[1]]];
    r = [0, ROUND, ROUND, ROUND, 0, 0];
    path = concat(half, [for (i = [len(half) - 1 : -1 : 0]) [-half[i].x, half[i].y]]);
    polygon(round_corners(path, method = "circle", radius = concat(r, [for (i = [len(r) - 1 : -1 : 0]) r[i]])));
}

// A section laid in the XZ plane and extruded along +Y from y0 to y1.
module run(y0, y1) translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children();

module epoxy_holder() {
    run(0, MIDDLE[0] + SEAM_LAP) section_2d(CENTRE[0]);
    run(MIDDLE[0], MIDDLE[1]) section_2d(NOTCH_X);
    run(MIDDLE[1] - SEAM_LAP, LENGTH) section_2d(CENTRE[0]);
}

if (layer == "outer") section_2d(CENTRE[0]);
else if (layer == "middle") section_2d(NOTCH_X);
else epoxy_holder();
