// #710-004 Rotate Code Disk — parametric source (DC-2).
// Optical encoder disk for J5 ("Rotate", DiffA2): 100 through-slots read by
// the Rotate photointerrupter shroud (#825). The hub bore fits over the
// Split Gear body (Ø37.5 over Ø37). The Ø43-50 annulus is recessed 0.2 mm
// on the underside so the slot web is thin where the beam crosses it.
//
// Dimensions measured from 710-004_RotateCodeDisk.stl (scadmesh radial/
// planes/slice); slot count re-verified as 100 (= J5 slot count in 003
// § Joint definitions). Shared values come from diff_params.scad.

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

module rotate_code_disk() {
    slot_len = (SLOT_SPAN[1] - SLOT_SPAN[0]) / 2;
    slot_r   = (SLOT_SPAN[1] + SLOT_SPAN[0]) / 4;
    difference() {
        union() {
            cyl(d=DISK_OD, h=DISK_H, anchor=BOTTOM);
            cyl(d=HUB_OD, h=HUB_H, anchor=BOTTOM);
        }
        down(epsilon) cyl(d=BORE_D, h=HUB_H + 2*epsilon, anchor=BOTTOM);
        down(epsilon)
            tube(id=RECESS[0], od=RECESS[1], h=RECESS[2] + epsilon, anchor=BOTTOM);
        for (i = [0 : SLOTS - 1])
            zrot(i * 360 / SLOTS) right(slot_r) down(epsilon)
                cuboid([slot_len, SLOT_W, DISK_H + 2*epsilon], anchor=BOTTOM);
    }
}

rotate_code_disk();
