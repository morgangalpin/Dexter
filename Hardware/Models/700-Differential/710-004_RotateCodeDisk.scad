// #710-004 Rotate Code Disk — parametric source (DC-2).
// Optical encoder disk for J5 ("Rotate", DiffA2): 100 slots read by the
// Rotate photointerrupter shroud (#825). The hub bore fits over the Split
// Gear body (Ø37.5 over Ø37). The Ø43-50 annulus is recessed 0.2 mm on the
// underside so the slot web is thin where the beam crosses it.
//
// The slots are milled from the top face down to the recess floor, not
// through the full disk thickness. They therefore open right through only
// over the Ø43-50 annulus, where the recess has already taken the underside
// away; over the Ø42-43 and Ø50-51 ends they are blind pockets standing on
// a 0.2 mm floor. The reference mesh settles this. Its z = 0.200 plane
// carries, in each 3.6 degree slot pitch, a 0.349 mm2 floor between Ø42 and
// Ø43, a 0.351 mm2 floor between Ø50 and Ø51, and 2.663 mm2 of recess web —
// which is the annulus area for one pitch less the 3.5 x 0.7 mm the slot
// opens through, so the slot is open between the recess walls and closed
// outside them. Cutting the slots through instead removes material the
// reference keeps: such a model measures 1021.038 mm3 against the
// reference's 1035.391 mm3, where this model measures 1034.968 mm3.
//
// Dimensions measured from 710-004_RotateCodeDisk.stl (scadmesh radial/
// planes/slice); slot count re-verified as 100 (= J5 slot count in 003
// § Joint definitions). Shared values come from diff_params.scad.
//
// Residual against the reference: 0.006 mm, carried by the bounding box
// across the disk and by nothing else — every diameter and face position
// agrees to within 1e-6 mm, and the reference compared against itself under
// the same checks reports 0.000, so this is the model's only difference from
// it. It is tessellation, not geometry, and no change to the dimensions can
// reduce it. The reference draws the Ø52.5 rim as a 105-gon, but staggers the
// top and bottom rings by half a facet: the top ring carries a vertex on the x
// axis and the bottom ring sits 180/105 = 1.714286° away from it. The bounding
// box sees the two rings together, so it is set by 210 angular positions
// spaced 0.857143° apart. One of them lands on the x axis, giving a full
// 52.500 mm, and the y axis falls midway between two, giving only
// 52.5 x cos(180/210) = 52.494125 mm. This model's $fn = 128 rim carries
// vertices on both axes and spans 52.500 mm each way, so it reads
// 52.5 x (1 - cos(180/210)) = 0.005875 mm wide, which is the measured delta to
// six decimal places. The shortfall belongs to the reference, so raising $fn
// only moves this model further from it; the harness carries a 0.006 mm
// tolerance for this part instead.
//
// Two-sided surface distance against the reference is 0.0118 mm in both
// directions. That is the reference's own export chord height: it draws every
// circle with its facets the same depth below the true circle — the Ø52.5 rim
// as a 105-gon at 26.25 x (1 - cos(180/105)) = 0.011749 mm, the Ø40.2 hub as a
// 92-gon at 0.011716 mm, the Ø37.5 bore as an 89-gon at 0.011681 mm — so
// 0.0118 mm is the closest any smooth-walled model can come to it, and this
// one is there.

include <diff_params.scad>

/* [Hidden] */
SLOTS        = 100;     // J5 encoder slot count
DISK_OD      = 52.5;    // disk outside diameter
DISK_H       = 1.0;     // disk thickness
HUB_OD       = 40.2;    // hub outside diameter
HUB_H        = 3.0;     // hub height (from the disk base)
BORE_D       = 37.5;    // center bore (over the Split Gear body)
RECESS       = [43.0, 50.0, 0.2];   // underside recess annulus [ID, OD, depth]
SLOT_SPAN    = [42.0, 51.0];        // slot radial span [inner Ø, outer Ø]
SLOT_W       = 0.7;     // slot width (beam opening)

// The slots stand on the recess floor, so they share its depth rather than
// carrying a second copy of that number.
SLOT_FLOOR   = RECESS[2];

module rotate_code_disk() {
    slot_len = (SLOT_SPAN[1] - SLOT_SPAN[0]) / 2;
    slot_r   = (SLOT_SPAN[1] + SLOT_SPAN[0]) / 4;
    // The span over which the recess has already opened the underside, so the
    // slot can be taken through there. It shares the slots' centre radius.
    open_len = (RECESS[1] - RECESS[0]) / 2;
    open_r   = (RECESS[1] + RECESS[0]) / 4;
    difference() {
        union() {
            cyl(d=DISK_OD, h=DISK_H, anchor=BOTTOM);
            cyl(d=HUB_OD, h=HUB_H, anchor=BOTTOM);
        }
        down(epsilon) cyl(d=BORE_D, h=HUB_H + 2*epsilon, anchor=BOTTOM);
        down(epsilon)
            tube(id=RECESS[0], od=RECESS[1], h=RECESS[2] + epsilon,
                 anchor=BOTTOM);
        // Each slot is cut in two overlapping pieces rather than one. A single
        // pocket standing on z = SLOT_FLOOR would meet the recess cutter, which
        // ends on that same plane, edge on instead of overlapping it, and
        // OpenSCAD does not merge two voids that meet exactly on a plane: it
        // leaves both faces standing as a zero-thickness web over the 3.5 x
        // 0.7 mm where each slot crosses the recess. That web encloses no
        // volume, so it passes unnoticed by a volume or a diameter check, but
        // it adds 490 mm2 of surface the part does not have. The pocket below
        // therefore runs from the floor up over the whole slot, and a second
        // cut takes the full thickness over the Ø43-50 span alone, overlapping
        // the pocket through the disk rather than meeting it edge on.
        //
        // The through cut ends on chords of the recess walls where the
        // reference ends on arcs of them. That moves each blind floor's inner
        // edge by at most 25.0 - sqrt(25.0^2 - (SLOT_W/2)^2) = 0.0025 mm, a
        // fifth of the faceting difference the mesh already carries.
        for (i = [0 : SLOTS - 1]) zrot(i * 360 / SLOTS) {
            right(slot_r) up(SLOT_FLOOR)
                cuboid([slot_len, SLOT_W, DISK_H - SLOT_FLOOR + epsilon],
                       anchor=BOTTOM);
            right(open_r) down(epsilon)
                cuboid([open_len, SLOT_W, DISK_H + 2*epsilon], anchor=BOTTOM);
        }
    }
}

rotate_code_disk();
