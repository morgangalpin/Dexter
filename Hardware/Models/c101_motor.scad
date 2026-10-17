// C-101 NEMA 17 stepper: an envelope for assembly placement only, shared by
// the assemblies that place a motor. Its sizes are 007.1 C-101's: the 42.3
// square body with its corners turned to Ø50.8, the Ø22 pilot boss and the
// Ø5 × 24 shaft. The body length is the caller's, because each joint sets it
// to its own motor's measured length; c101_len() is the one they start from.
//
// FRAME. The axis on +Z, the rear face at z = 0, the mounting face at
// z = len, the boss and shaft beyond it.

// The body length every assembly draws, until the measured one replaces it.
function c101_len() = 48.000;

module c101_motor_envelope(len) {
  intersection() {
    translate([-21.15, -21.15, 0]) cube([42.3, 42.3, len]);
    cylinder(d = 50.8, h = len);
  }
  translate([0, 0, len]) cylinder(d = 22, h = 2);
  translate([0, 0, len]) cylinder(d = 5, h = 24);
}
