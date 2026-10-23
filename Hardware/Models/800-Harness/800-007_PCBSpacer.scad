// #800-007 PCB Spacer — parametric source.
// A plain tube that holds the FPGA board off the Motor Control Board, between
// the two boards (008.10 step 4). An M3x20 bolt passes through its bore.
//
//   config = "previous" — a faithful recreation of the reference mesh
//                         (../Reference/meshes/800-Harness/).
//   config = "revised"  — identical to "previous"; see FITS.
//
// FRAME. The axis is on +Z through the origin, the part from z = 0 to 8.2.
// The reference mesh is already in this frame.
//
// Measured from the reference (scadmesh), feature IDs as in
// 800-007_PCBSpacer.view.json:
//
//     ID  feature   value
//     S1  body      Ø7.000, z 0 .. 8.2
//     B1  bore      Ø3.500, through
//
// CONSTRUCTION. One tube: a cylinder less its bore, the bore overrunning both
// ends so the faces stay clean.
//
// FITS (../print_fit.scad):
//
//     B1, on the M3x20 bolt (Ø3.0)    slip, which asks for Ø3.3
//
// The reference's Ø3.5 is already wider than the slip fit, so "revised" keeps
// it; probes-800-007-wide in render.json pins it.

include <../print_fit.scad>

/* [Configuration] */
// Parameter set: previous (reference) or revised
config = "previous"; // [previous, revised]

/* [Hidden] */
$fn = 96;
OUTER_D = 7.000;   // S1
BORE_D  = 3.500;   // B1
HEIGHT  = 8.200;

module pcb_spacer() difference() {
    cylinder(d = OUTER_D, h = HEIGHT);
    translate([0, 0, -1]) cylinder(d = BORE_D, h = HEIGHT + 2);
}

pcb_spacer();
