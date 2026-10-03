// Print-fit clearances, shared by every printed part's `config="revised"`.
//
// A printed part comes off the machine slightly oversize, so a feature drawn
// line-to-line against what it mates with will not go together. Each mating
// feature is drawn at its mate's nominal size plus or minus one of two
// clearances, per side, chosen by what the mate is:
//
//     FIT_PRESS    a bought part the printed one is seated on, located by
//                  or bonded to: bearings, motors, splines, CF rods, tubes
//                  and strakes
//     FIT_SLIP     another printed part, and every fastener's clearance:
//                  screw holes, nut traps and pockets
//
// A third class is not a fit, because its surfaces never meet:
//
//     FIT_RUN      a gap between two parts that turn past each other and
//                  must never touch, such as a housing and a gear's teeth
//
// The classes, their members and exclusions, and how a machine is qualified
// against these values are owned by specs/007.2 § Print fits; the coupon that
// qualifies them is 950-Tooling/fit_coupon.scad.
//
// Every part `include`s this file, so `-D FIT_SLIP=...` reaches a single
// render, and an edit here retunes every part. `config="previous"` draws at
// zero clearance: it is the reference mesh, and its dist gate measures it.

FIT_SLIP  = 0.15;
FIT_PRESS = 0.05;
FIT_RUN   = 0.50;

// A hole or bore that takes a mate of diameter d, and a pin or shaft that
// goes into one, with clearance c per side.
function fit_bore(d, c) = d + 2 * c;
function fit_pin(d, c) = d - 2 * c;

// The clearances a part draws in configuration cfg: [slip, press, run].
function fit_clearances(cfg) =
    cfg == "previous" ? [0, 0, 0] : [FIT_SLIP, FIT_PRESS, FIT_RUN];
