// The rounded dodecagon shared by the base's long member and the stator holder that bolts under it.
//
//     120-001_BaseLong.scad          D1, the body's outline, built from its flats and corner rounds
//     110-002_BaseStatorHolder.scad  the flange, which matches the Base Long's outline
//
// Twelve flats DODECAGON_APOTHEM from the axis, with their normals on 15° + 30°k, so the corners sit on
// 30°k. Each corner is rounded R DODECAGON_ROUND. Measured from 120-001's reference: the flats' apothem
// is 41.0494 .. 41.0502 and the corners fit R10.019 .. 10.022 on centres 32.120 .. 32.123 out.
// 110-002's reference measured [32.060, 10.075], the same outline within 0.01. Both references turn the
// outline a little off these angles (+0.185° and -0.17°), but this outline does not: the windows, slots
// and holes are symmetric about 0° and 30°, and leaving the turn out moves no flat by more than 0.02.
//
// Included, not used, so that its constants reach the including file.

DODECAGON_APOTHEM = 41.050;
DODECAGON_ROUND   = 10.020;

// The radius of the corner rounds' centres, and of the sharp dodecagon's corners.
function dodecagon_centre_r() = (DODECAGON_APOTHEM - DODECAGON_ROUND) / cos(15);
function dodecagon_corner_r() = DODECAGON_APOTHEM / cos(15);

module dodecagon_2d() { offset(r = DODECAGON_ROUND) circle(r = dodecagon_centre_r(), $fn = 12); }
