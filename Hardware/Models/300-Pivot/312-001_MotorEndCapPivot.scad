// #312-001 Motor End Cap (Pivot) — parametric source.
// Caps the rear of J2's motor at the end of the Main Pivot's J2 drum. Its land
// is pressed into a 6810's inner race, and its top face is epoxied to the
// drum's end face; eight lugs grip the motor body, and the motor's rear face
// bears on the seat (008.4 steps 4, 6, 8).
//
//   config = "previous" — faithful recreation of the reference mesh
//                         (../Reference/meshes/300-Pivot/).
//   config = "revised"  — the print fits of #311-001, drawn the same way.
//
// FRAME. The reference's own, the same as #311-001's: the axis on +Z, the seat
// at z = -1.700, the land from z = 3.500 to the top face at 10.500, the lugs
// hanging below the seat to z = -6.700. The wire channel is at +x.
//
// ONE PART, TWO NUMBERS. The reference meshes of #311-001 and #312-001 agree
// to 0.15 mm but for the two features below, so this file is #311-001's with
// those set: it `include`s it, whose geometry, constants and fits are
// documented there, and whose `PART` it overrides so that only this part is
// drawn. A change to the shared cap belongs in 311-001_MotorEndCapBase.scad.
//
// What the Pivot cap sets, each measured from its reference with scadmesh
// planes/slice/arcs/solid, the IDs those of 312-001_MotorEndCapPivot.view.json:
//
//     ID  feature                       here                       #311-001
//     O1  outline, ring and lugs        R26.500                    R26.750
//     H1  motor holes' counterbores     Ø6.0, from the lugs' foot  none
//                                       up to the floor at z 2.3
//
// The motor holes' Ø3.2 continue above the counterbore's floor. The
// counterbore is already 0.25 per side wider than the M3 screw's Ø5.5 head,
// more than the slip clearance, so `revised` keeps its size. The revised
// seat stands 1.0 higher (#311-001), and the floor rises with it to z 3.3,
// 0.2 under the land's foot (counterbore_floor()): 3.95 over the seat's
// face, as in the reference, so a socket head (3.0) stays 0.95 inside.
//
// Every other feature is #311-001's to the gate's 0.15 mm: the notches, the
// land and its chamfers, the lugs and their rounds, the root fillets, the seat,
// the centre bore and the wire channel.

include <311-001_MotorEndCapBase.scad>

PART          = "pivot";
OUTLINE_R     = 26.500;           // O1
COUNTERBORE   = [6.000, 2.300];   // H1: Ø, z of the floor

motor_end_cap_base();
echo(cap_seat = cap_seat());
