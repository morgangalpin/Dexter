# 006 — Firmware and Calibration (Dexter HDI Rev A)

This document specifies the firmware configuration and the calibration model of Dexter HDI: the
`Defaults.make_ins` parameters that describe the physical robot to the firmware, the drive constants, and
the factory calibration and bring-up procedure. It is a **derived artifact** — its values follow from the
kinematics ([003](003-Kinematics.md)) and electronics/control ([005](005-Electronics-and-Control.md)) design
and must be regenerated when those change. Values here are `[Specified]` (traceable to the firmware file and
the factory calibration documentation) unless noted.

## Firmware defaults: `Defaults.make_ins`

`Defaults.make_ins` describes the physical robot to the DexRun firmware and sets default operational values;
it is the firmware configuration of record. The HDI configuration:

```
; AxisCal is the gear ratio times the steps per revolution times the microstepping mode
; e.g. for a 52:1 drive with a 400 step motor in 16x microstepping: 52*400*16 = 332800
S, AxisCal, -332800, -332800, -332800, -86400, -86400 ; Dexter HDI

; Interpolation factor for each joint
S, Interpolation, 1, 1, 1, 1, 1 ; Dexter HDI

; Length of each link, in microns. L5 is first, L1 last.
S, LinkLengths, 82440, 59500, 307500, 339092, 235200;

; Joint motion limits, in arcseconds from center
S, J1BoundryHigh, 684010;   S, J1BoundryLow, -684010;
S, J2BoundryHigh, 350010;   S, J2BoundryLow, -350010;
S, J3BoundryHigh, 570010;   S, J3BoundryLow, -570010;
S, J4BoundryHigh, 390010;   S, J4BoundryLow, -390010;
S, J5BoundryHigh, 684010;   S, J5BoundryLow, -684010;

; Maximum torque for tool servos (roll, span)
S, ServoSet2X, 1, 35, 1020; Roll goal torque
S, ServoSet2X, 3, 35, 1020; Span goal torque
```

`[Specified]` — *Source: `Firmware/Defaults.make_ins`.* Link lengths and joint boundaries are specified in
kinematic terms in [003](003-Kinematics.md#link-lengths) and [003](003-Kinematics.md#joint-travel-limits).
The HD values are retained (commented) in the source file for reference; the deltas are the HD→HDI design
changes described in [001](001-Overview.md#5-design-lineage).

## Drive constants (`AxisCal`)

`AxisCal` is the per-joint conversion between motor steps and joint angle:
`AxisCal = gear_ratio × motor_steps_per_rev × microstepping`.

| Joints | Value | Derivation | Net reduction | Meaning |
|---|---|---|---|---|
| J1, J2, J3 | −332800 | 52 × 400 × 16 | **52:1** | 52:1 strain-wave, 0.9°/step (400-step) motor, 16× microstepping. **Identical to HD** — the base-joint reduction is unchanged. |
| J4, J5 | −86400 | 13.5 × 400 × 16 | **13.5:1** | HDI resolves the wrist through a **physical pulley reduction** of 13.5:1 (vs HD's −36000 = 5.625:1 = 90T/16T belt, plus microstep oscillation). |

- **`Interpolation`** = 1 for all joints on HDI. HD used 16 on J4/J5 to sub-divide microsteps for the
  oscillation trick; HDI sets 1 because the belt reduction supplies wrist resolution physically.
- **The net wrist reduction *is* derivable — 13.5:1.** `AxisCal = gear_ratio × 400 × 16`, so
  86400 / 6400 = **13.5:1**. What is *not* pinned by the firmware alone is the *decomposition into tooth
  counts*; that is the design-completion item ([009](009-Design-Completion.md#wrist-reduction-ratio)).
- ⚠️ **The HD 16T→90T pulleys give 5.625:1, not 13.5:1.** Reusing the HD driven pulley set unchanged against
  the HDI `AxisCal` would produce a **2.4× wrist-scale error**. The wrist must net 13.5:1 (revised
  differential and/or re-toothed pulleys), or `AxisCal` must be set to the as-built ratio — see
  [009](009-Design-Completion.md#wrist-reduction-ratio) and
  [004](004-Mechanical-Architecture.md#wrist-and-differential-j4-j5).

`[Specified]` (J1–J3; J4/J5 net ratio 13.5:1), `[Provisional]` (J4/J5 tooth-count realization). *Source:
`Firmware/Defaults.make_ins`, `Firmware/AxisCal.txt`; wiki `Hardware.md`, `Joints.md`, `Firmware.md`,
`set-parameter-oplet.md`.*

> **AxisCal.txt vs Defaults.make_ins — base-joint note.** `AxisCal.txt` is a derived runtime file
> (`−(gear_ratio × microstep × steps) / 1 296 000` per joint, plus a trailing `ANGLE_END_RATIO` term
> `−round(ratio_J4 / ratio_J3 × 2²⁴)`). The copy in this repo encodes **50:1** on J1–J3 (line value
> −0.24691 = 50, and the trailing term −4 529 848 = −round(13.5 / 50 × 2²⁴)), while `Defaults.make_ins`
> and the physical Cone Drive #14 set specify **52:1**. `Defaults.make_ins` (52:1) is authoritative; the
> sampled `AxisCal.txt` appears stale/mis-generated and **must be regenerated to 52:1 on a real build** (a
> 50:1 file would give ≈4 % base-joint scale error). Both files agree J4/J5 = 13.5:1.

## Calibration model

Dexter HDI's precision depends on mapping each joint's raw optical-encoder readings to true joint position.
This mapping — the encoder **eye centers** and **index-pulse mapping** — is established once and **recorded
onto the specific robot** (`AdcCenters.txt`, `HiMem.dta`, `post_cal_info.JSON`). Once recorded, the mapping
removes the effect of imperfect code-disk slots, so the joint always returns to the exact commanded position
(REQ-CTL-6, REQ-PRE-1).

**Policy: an HDI is calibrated at the factory and is not re-calibrated in the field.** Recalibration is
complex, the eye calibration affects the movement calibration, and there is no simple recovery if the
recorded values are overwritten incorrectly. Operationally:

- A **factory-built or already-calibrated unit** keeps its recorded calibration and is **not** recalibrated.
  Do not save calibration on such a unit.
- A **from-scratch build** (new opto boards, new code disks, new drives) has no recorded calibration and
  **must run the full factory procedure once** before first use — this is unavoidable for a new build and is
  the single most consequential bring-up step. The calibration **engine** (`dde/low_level_dexter/`:
  `Calibrate_Encoders_Function.dde`, `calibrate_optical.js`, `calibrate_build_tables.js`, `calibrate_ui.js`,
  `ViewEye*.js`) and `PHUI2RCP.js` (`Firmware/dde_apps/`) are in the public repos; the two HDI job
  wrappers (`Setup_Find_Index_Home_HDI*.dde`, `Find_Index_Pulses_HDI.dde`) are not yet, and reconstructing
  them is a design-completion item ([009](009-Design-Completion.md#from-scratch-calibration-files)).

`[Specified]` — *Source: wiki `Encoder-Calibration.md`, `Dexter-Setup.md`; factory calibration PDFs.*

## Factory calibration procedure

For **from-scratch builds only.** Transcribed from the factory HDI calibration documentation
(`DDE/InitialCalibration/HDI CAL INSTRUCTIONS- STEP {1,2,3}.pdf`). Requires WinSCP/PuTTY (or equivalent
SCP/SSH), DDE, and a grounded anti-static wrist strap whenever handling the FPGA board.

### Step 1 — deploy files and set serial number
1. Copy the factory file bundle onto the robot's SD filesystem via WinSCP (`Host 192.168.1.142`, user
   `root`). Change the default password on any unit exposed to an untrusted network.
   - `dde_apps/*` → `/srv/samba/share/dde_apps/`; `share/*` → `/srv/samba/share/`;
     `www/*` → `/srv/samba/share/www/`; `core/*` → `/root/Documents/dde/core/`
2. Power-cycle. Set the system clock via PuTTY (`date -s "<DDMonYY>"`).
3. Rebuild DexRun: `./pg` from `/srv/samba/share/` (a `gcc` compile of `DexRun.c`; benign
   `-Wstrict-aliasing` warnings are expected).
4. Edit `Defaults.make_ins` to set the six-digit **Dexter serial number** (printed on the Main Pivot) in
   place of the placeholder — this sets the MAC address and avoids LAN collisions between units. Power-cycle.

### Step 2 — per-joint eye calibration
1. Secure the robot with clearance for full rotation on every joint; remove the end effector's front part.
2. Align the "X" on the Base Long with the center of the ExGear Mount Bottom (J3 wire exit); fine-tune by
   aligning the J1 opto block's right edge with the raised notch on the Base Code Disk.
3. Move to the most upright (home) position; power on.
4. In DDE, open the calibration job file (`Setup_Find_Index_Home_HDI*.dde` from the factory bundle;
   [009](009-Design-Completion.md#from-scratch-calibration-files)) → `Jobs → Calibrate Dexter…` → select the
   robot. Wait for the "Initializing…" dialog to clear (DDE has read `AdcCenters.txt`).
5. **Start with J2, not J1** — this order avoids over-rotating J2 into the work surface if J1/J2 wiring is
   swapped.
6. For each joint, adjust the two trim potentiometers until the plotted cycle is a centered,
   counter-clockwise circle (a clockwise cycle means the phototransistors are installed backwards — swap
   them). Center the eye and **Save**. Repeat for all 5 joints.
   - *Troubleshooting:* a cycle leaning to one side → opto block too far, move closer; a flattened/partial
     cycle → shim the opto block (start 0.05", add as needed); a cycle that won't center → phototransistor
     holes undersized, rework/replace the block.

### Step 3 — movement calibration and go-live
1. Confirm the Step 2 base alignment; fresh reboot; open the calibration file.
2. `Undef` → `Clear` → `Eval`.
3. `Check_Eye_Order` — each row should show a clear largest-value pattern; a row breaking the pattern means
   that joint's eye needs revisiting (diode swap, disconnected opto wire, or off-center eye).
4. `Calibrate Optical Encoders` — moves each joint through its full range, recording index-pulse timing.
5. (Optional) verify smooth motion: `Dexter.set_Follow_Me()`, move each joint by hand, then
   `Dexter.set_Keep_Position()` and `OpenLoop`.
6. `Initial_Scan` — per joint, verify index-pulse (green) spike separation increases by 2 on each side of
   the 3 home (black) spikes, with no gaps within usable travel (a gap far from home is tolerable if the
   robot always powers on near home; a gap near home is not). `Save_Scan_Results`.
7. Power off; move to home (J1 at "X", others at visual zero); power on.
8. `Check_Eye_Order` → `Center_Eye` (await `Done`) → `Find_Idx_Eyes_Setup` (records
   `idx_eye_to_cal_offset`, small integers) → `Save_Eye_Offset` → `Find_Idx_Eyes_For_Cal`.
9. `Calibrate Optical Encoders` again → `post_cal_info` (writes `post_cal_info.JSON` — the artifact that
   makes "no recalibration needed" real) → `Check_Eye_Order` → `Find_Idx_Eyes` (confirm correct home
   return).
10. Enable boot jobs: in `/srv/samba/share/RunDexRun`, remove the leading `#` from the home-finding line
    (`Find_Index_Pulses_HDI.dde`) — always enable this — and, for default PhUI startup, the `PHUI2RCP.js`
    line. Power-cycle; boot takes ~3 minutes, after which the end effector "nods" to confirm readiness. To
    redo calibration later, re-comment both lines so PhUI does not start and block DDE access.

`[Specified]` — *Source: `DDE/InitialCalibration/HDI CAL INSTRUCTIONS- STEP {1,2,3}.pdf`.*

## Boot and PhUI

On power-up, Dexter HDI loads Ubuntu 16.04 from microSD, then — unlike Dexter 1/HD — spends a minute or two
**finding its home position via the index eyes**, then (if `RunDexRun` is configured per Step 3.10) enters
**PhUI** and waits for physical commands. **While in any startup mode, including PhUI, the robot does not
respond to DDE or other control software** — only the web interface, SSH, or console work in that window. To
exit PhUI, grip the tool interface and "cog" up (rotate to a detent) without moving sideways until the robot
pushes back and returns home. `[Specified]` — *Source: wiki `Dexter-Setup.md`, `PhysicalUserInterface.md`.*

## Maintenance

Run the robot through several training series and stress-test for ~36 hours after build. Replace the
strain-wave (Cone Drive) lubricant at **100 hours** and again at **2000 hours**. Adjust belts as needed
(REQ-ENV-4). `[Specified]` — *Source: factory calibration documentation (Step 3 maintenance note).*
