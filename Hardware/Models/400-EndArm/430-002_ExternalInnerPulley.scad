// #430-002 External Inner Pulley — driven pulley of the inner channel's stage 1
// at the elbow: 90T in "previous", 108T in "revised" (DC-12). The shared
// definition, and what each configuration builds, is in external_pulley.scad.
//
// The reference (Reference/meshes/400-EndArm/) is a hub r 4.5..10.5 over
// z 19.0..35.5 on a Ø9.2 keyed bore, three spokes, and a rim r 25.072..29.5
// over z 19.0..28.5 carrying the 90T band z 20.5..27.0.
//
// "revised" keeps everything inside R_CUT — the hub, the spokes and the inner
// 1.4 mm of the rim — and adds the 108T rim outside it.

include <external_pulley.scad>

/* [Hidden] */
R_CUT     = 26.5;
RIM_LOWER = [[1.103, 19.0], [1.103, 19.4], [0.000, 20.5]];
RIM_UPPER = [[0.000, 27.0], [1.103, 28.1], [1.103, 28.5]];

module external_inner_pulley() {
    external_pulley("430-002_ExternalInnerPulley.stl", R_CUT, RIM_LOWER, RIM_UPPER);
}

external_inner_pulley();
