// #520-003 Nut Holder A and #520-004 Nut Holder B — parametric source.
// Each holder carries the M3 nut one of the two M3 x 46 all-threads (#520-005)
// screws into. It slides into the Ex Gear Mount with its curved face against
// the Mount's bore, which sets which way round it goes (008.7 step 9), and the
// all-thread ties the Mount Top down through it (step 13).
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/500-ExternalGear/), in that
//                         mesh's frame.
//   config = "revised"  — the same part with its print fits on the nut and
//                         the all-thread.
//
// ONE FILE, TWO PARTS. The two holders are mirror images: the reference holds
// both, side by side, as one HD export. Holder A is the body at y 6 .. 14 of
// that export and Holder B its mirror image about y 20, at y 26 .. 34. The
// names follow the two part numbers' order; nothing in the HD set names them.
// `holder` draws "both", as the reference does (the dist gate measures that,
// and the pair prints on one plate), or "A" or "B" alone in the same place.
//
// FRAME. The reference's: the plate's underside on z = 0, the nut's axis on +Z.
// Each holder is laid out exactly as it stands in the Mount, turned 180 deg
// about z: Mount = rot180(p - BORE_C) + (-0.655, 0), where (-0.655, 0) is the
// Mount bore's centre (520-001). mount_place() applies that.
//
// CONSTRUCTION. Two constant sections, each drawn whole in 2D and extruded
// once (profile per layer):
//
//     plate   z 0 .. 1.2     outline - Ø3 hole
//     trap    z 1.2 .. 3.5   outline - hex nut trap, open on top
//
// The outline is a rectangle whose -x side is the Mount bore's R38 arc, about a
// centre 10 mm off the hole along y, toward the mirror plane. `layer = "plate"`
// or `"trap"` draws that profile in 2D (Holder A, or both), for verification
// against the mesh's section (scadmesh outline; render.rs --verify does this).
//
// Measured from the reference with scadmesh planes/slice/arcs. The feature IDs
// are those of 520-003_ExGearNutHold.view.json:
//
//     ID  feature                     value
//     O1  outline                     x BORE arc .. -2.623, y 6.0 .. 14.0
//     C1  curved face                 R38.000 about (-53.245, 20.000); the
//                                     arc's vertices lie within 0.005 of it
//     T1  thickness                   z 0 .. 3.5
//     H1  all-thread hole             Ø3.000 about (-7.623, 10.000), z 0 .. 1.2
//     N1  nut trap                    hexagon 5.400 across flats, corners on
//                                     +-x, same axis, z 1.2 .. 3.5
//
// The hole's axis lies 5.000 inside the +x face and 4.000 from each side; the
// curved face's centre lies 45.623 along -x from it, as the Mount's all-thread
// holes at (-46.278, +-10) lie from its bore's centre.
//
// FITS (../print_fit.scad), revised only:
//
//     H1, on the M3 all-thread (Ø3.0)                 slip
//     N1, on the M3 nut (DIN 934, 5.5 across flats)   slip
//
// The reference's trap is 5.4 across flats, 0.05 inside the nut per side.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]
// Which holder to draw
holder = "both"; // [both, A, B]
// What to draw: the part, or one layer's 2D profile
layer = "part"; // [part, plate, trap]

/* [Hidden] */
$fn = 360;
epsilon = 0.01;

X_FACE    = -2.623;              // O1, the straight face away from the bore
WIDTH     = 8.000;               // O1, y 6 .. 14 for Holder A
HOLE_C    = [-7.623, 10.000];    // H1 and N1 axis, Holder A
BORE_R    = 38.000;              // C1
BORE_C    = [-53.245, 20.000];   // C1's centre; y 20 is the mirror plane between A and B
PLATE_H   = 1.200;               // H1's layer
HEIGHT    = 3.500;               // T1
HOLE_D    = 3.000;               // H1
TRAP_AF   = 5.400;               // N1, across flats
ROD_D     = 3.000;               // the M3 all-thread H1 takes
NUT_AF    = 5.500;               // the M3 nut N1 takes
MOUNT_C   = [-0.655, 0];         // the Mount bore's centre, in the Mount's frame

SLIP = fit_clearances(config)[0];

function hole_d() = config == "previous" ? HOLE_D : fit_bore(ROD_D, SLIP);
function trap_af() = config == "previous" ? TRAP_AF : fit_bore(NUT_AF, SLIP);

// Holder A's outline: its rectangle less the Mount bore's disc.
module outline_2d() {
    difference() {
        translate([BORE_C.x, HOLE_C.y - WIDTH / 2]) square([X_FACE - BORE_C.x, WIDTH]);
        translate(BORE_C) circle(r = BORE_R);
    }
}

module plate_2d() difference() { outline_2d(); translate(HOLE_C) circle(d = hole_d(), $fn = 96); }

// A hexagon with its corners on +-x.
module trap_2d() difference() { outline_2d(); translate(HOLE_C) circle(d = trap_af() / cos(30), $fn = 6); }

module nut_holder_a() {
    linear_extrude(PLATE_H + epsilon) plate_2d();
    translate([0, 0, PLATE_H]) linear_extrude(HEIGHT - PLATE_H) trap_2d();
}

// Holder B is Holder A's mirror image about the plane between them.
module mirror_b() translate([0, BORE_C.y]) mirror([0, 1, 0]) translate([0, -BORE_C.y]) children();

// One holder, "A" or "B", in the reference's frame.
module nut_holder(which) {
    if (which == "A") nut_holder_a();
    else mirror_b() nut_holder_a();
}

// Children drawn in this file's frame, moved to where they stand in the Mount's
// frame (its bore's centre at MOUNT_C), at the Mount's height z0.
module mount_place(z0) translate([MOUNT_C.x, MOUNT_C.y, z0]) rotate(180) translate(-BORE_C) children();

module drawn(which) {
    for (h = which == "both" ? ["A", "B"] : [which]) nut_holder(h);
}

module drawn_2d(which, l) {
    for (h = which == "both" ? ["A", "B"] : [which])
        if (h == "A") { if (l == "plate") plate_2d(); else trap_2d(); }
        else mirror_b() { if (l == "plate") plate_2d(); else trap_2d(); }
}

if (layer == "part") drawn(holder);
else drawn_2d(holder, layer);
