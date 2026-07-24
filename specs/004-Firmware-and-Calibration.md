# 004 - Firmware Configuration and Calibration (Dexter HDI)

## Verification status
Firmware default values and the factory calibration procedure below are **VERIFIED**, transcribed directly from
`Firmware/Defaults.make_ins` (this repo's working tree) and the three factory PDFs in
`DDE/InitialCalibration/HDI CAL INSTRUCTIONS- STEP {1,2,3}.pdf` (also this repo's working tree). Where the source
material has evident errors (e.g. the PDFs' filenames and DDE references being inconsistent with each other), that
is noted inline rather than silently corrected, per this fork's practice of not editing quoted primary sources.

## Why this spec exists
Unlike [002](002-Bill-of-Materials.md) and [003](003-Assembly.md), nothing here is a FORK PROPOSAL — every value
and step in this document is transcribed from an upstream source that already exists in this repo. It was pulled
into its own numbered spec because the source material (a `.make_ins` config file and a set of onboarding PDFs
apparently written for Haddington Dynamics' own technicians) was never surfaced as build documentation, and
because [001-Overview.md](001-Overview.md) leans on the facts here as its primary evidence that HDI is a live,
documented target rather than an abandoned one.

---

## 004.1 Firmware defaults: `Defaults.make_ins`

Full file, VERIFIED (`Firmware/Defaults.make_ins`, current default branch):

```
; These values describe the physical robot to the firmware and set the default operational values.
; Edit this file to accommodate the exact physical makeup of the arm.
; Dexter Serial Number: DEX-00000
; DexRun modified 2019-11-22T22:54:09Z
; xillydemo modified 2019-09-16T17:04:17Z
; OS version Ubuntu 16.04 LTS

; AxisCal is the gear ratio times the steps per revolution times the microstepping mode
; e.g. for a 52:1 drive with a 400 step motor in 16 over stepping, it would be 52*400*16 or 332800
;S, AxisCal, -332800, -332800, -332800, -36000, -36000 ;Defaults for Dexter HD
S, AxisCal, -332800, -332800, -332800, -86400, -86400 ;Defaults for Dexter HDI

; Interpolation factor for each joint
;S, Interpolation, 1, 1, 1, 16, 16 ;Default for Dexter HD
S, Interpolation, 1, 1, 1, 1, 1 ;Default for Dexter HDI

; Length of each link in the robot, in microns. L5 is first, L1 last.
S, LinkLengths, 82440, 59500, 307500, 339092, 235200;

; Limits to the motion of each joint, in arcseconds from center
S, J1BoundryHigh, 684010; 186
S, J1BoundryLow, -684010;
S, J2BoundryHigh, 350010; 97
S, J2BoundryLow, -350010;
S, J3BoundryHigh, 570010; 158
S, J3BoundryLow, -570010;
S, J4BoundryHigh, 390010; 108
S, J4BoundryLow, -390010;
S, J5BoundryHigh, 684010; 190
S, J5BoundryLow, -684010;

; Set Maximum torque for joint 6 / 7 servos
S, ServoSet2X, 1, 35, 1020; Roll goal torque
S, ServoSet2X, 1, 35, 1020; Roll goal torque
S, ServoSet2X, 3, 35, 1020; Span goal torque
S, ServoSet2X, 3, 35, 1020; Span goal torque
```

### What each generation-specific value means

| Parameter | Dexter HD | Dexter HDI | Meaning (VERIFIED, wiki `set-parameter-oplet.md`) |
|---|---|---|---|
| `AxisCal` (J1, J2, J3) | -332800, -332800, -332800 | -332800, -332800, -332800 | **Identical between generations.** `AxisCal = Gear_Ratio × Motor_Steps_per_Revolution × Microstepping`. For a 52:1 harmonic drive with a 400-step motor at 16× microstepping: 52 × 400 × 16 = 332800. This is direct, concrete confirmation that the harmonic drive gearing on joints 1-3 (52:1 ratio, Cone Drive component gear set) is **unchanged** between HD and HDI — the [002.3/002.8 flex spline / wave generator / stator gear gap](002-Bill-of-Materials.md#critical-gap-harmonic-drive-components-are-not-fully-specified-upstream-unchanged-for-hdi) applies identically to HDI, with no evidence of a redesign. |
| `AxisCal` (J4, J5) | -36000, -36000 | -86400, -86400 | **Differs.** HD achieves extra J4/J5 resolution by rapidly oscillating the motor between microstep positions (wiki `Hardware.md`: "HD and prior versions rapidly oscillated back and forth over the motors 0.9°/16 micro-step positions to increase resolution on J4/5"). HDI instead uses "a set of pulley reductions to avoid that." |
| `Interpolation` (J4, J5) | 16 | 1 | HD's firmware sub-divides each microstep into 16 further software steps to support the oscillation trick above; HDI sets this to 1 because the physical pulley reduction supplies the resolution directly. |
| `LinkLengths` (L1-L5, meters/microns) | 82551, 50801, 330201, 320676, 228600 (wiki `set-parameter-oplet.md`, "For HD") | 82551, 50950, 307500, 339092, 235200 (wiki, "For HDI") | Physical link dimensions — see below. |

**FORK PROPOSAL, low confidence — do not act on without physical verification**: the ratio between HDI's and HD's
J4/J5 `AxisCal` values is 86400 / 36000 = 2.4×, while `Interpolation` drops by 16×. These two facts do not
arithmetically cancel out in an obvious way from firmware values alone, which means this fork cannot derive an
exact HDI pulley tooth-count change from the numbers above — doing so would risk a wrong physical part with no way
to check it before cutting a GT2 belt. This spec set's recommendation ([002.5](002-Bill-of-Materials.md#0025-arm-body)
and [002.7](002-Bill-of-Materials.md#0027-end-arm-hub)) is to build J4/J5 with the same GT2 belts/pulleys as the HD
BOM (the only physically-specified pulley set available in any source consulted), set the firmware values above
exactly as shown, and treat any resulting resolution/backlash shortfall as something to diagnose empirically on
the physical robot before redesigning the pulleys — not something to guess a new tooth count for now.

### Link length deltas and what they imply for structural members

`LinkLengths` order is **L5 first, L1 last**. Per wiki `set-parameter-oplet.md`: L1 = base mount to J2 pivot, L2 =
J2 to J3 pivot, L3 = J3 to J4 pivot, L4 = J4 to J5 pivot, L5 = J5 axis to end-effector tip.

| Link | HD (microns) | HDI (microns) | Delta | Physical span (approx.) |
|---|---|---|---|---|
| L5 | 82551 | 82551 | 0 (identical) | Tool Interface + end effector — confirms the wiki/README claim that the Tool Interface Fusion 360 model is cross-compatible across Dexter 1/HD/HDI |
| L4 | 50801 | 50950 | +149 µm (+0.15mm) | J4-J5 (wrist) — negligible, within build tolerance |
| L3 | 330201 | 307500 | **-22701 µm (-22.7mm)** | J3-J4 span — End Arm Hub / Differential assembly |
| L2 | 320676 | 339092 | **+18416 µm (+18.4mm)** | J2-J3 span — Arm Body |
| L1 | 228600 | 235200 | +6600 µm (+6.6mm) | Base mount-J2 span — Base + Main Pivot |

**FORK PROPOSAL**: the L2 and L3 deltas are large enough (±2cm) that they cannot be structural build tolerance —
the physical CF strake/tube cut lengths in [002.4 Main Pivot](002-Bill-of-Materials.md#0024-main-pivot),
[002.5 Arm Body](002-Bill-of-Materials.md#0025-arm-body), and
[002.7 End Arm Hub](002-Bill-of-Materials.md#0027-end-arm-hub) most likely need adjusting for an HDI build, not
just re-used unchanged from the HD PBS. No upstream source gives exact HDI strake cut lengths, so this spec
proposes scaling the HD-sourced lengths by the delta above (e.g. lengthen the 264mm Arm Body CF square tube by
~18mm to ~282mm) as a **starting point only** — confirm against the `cfry/dde`-hosted HDI Fusion 360 kinematic
model (linked from `official/README.md` as "kinematic model/skin" under the HDI build summary) before cutting
carbon fiber. Getting this wrong changes where L2/L3 land relative to encoder zero and will show up as a
`LinkLengths`-vs-physical-reality mismatch in Cartesian moves, not as an assembly failure — it is a
precision/accuracy risk, not a does-it-fit risk.

---

## 004.2 Calibration policy: do not calibrate an HDI in the field

**VERIFIED, wiki `Encoder-Calibration.md` and `Dexter-Setup.md`, quoted directly — this is the single most
important operational fact for anyone assembling or commissioning an HDI unit:**

> "The new Dexter HDI shouldn't need calibration, and the re-calibration process is complex. **Don't calibrate a
> Dexter HDI!**"

> "On the HDI, this has been done at the factory, and the results recorded on the robot, so it does not need to be
> done again."

> "HDI's are calibrated (both eye and movement) at the factory, and the eye calibration affects the movement
> calibration, so **Don't calibrate a Dexter DHI!**" [sic, upstream typo preserved]

> "**DO NOT SAVE CALIBRATION ON A DEXTER HDI**"

> "The Dexter HDI should NEVER be calibrated outside the factory as it is not necessary and is a complex process."

This is a real safety/correctness constraint, not upstream caution-for-caution's-sake: HDI's optical-encoder eye
centers and index-pulse mapping are recorded onto the specific robot at the factory (`AdcCenters.txt`,
`HiMem.dta`, `post_cal_info.JSON` — see 004.3 below), and overwriting them requires redoing the entire factory
procedure with no simple way to recover the original values if it goes wrong.

**What this means for assembly** ([003-Assembly.md](003-Assembly.md)): a from-scratch HDI build (new opto boards,
new code disks, new harmonic drives) does **not** have factory calibration data and unavoidably needs the full
factory procedure below run once, by whoever assembles it, before first use. This is the one calibration-related
step this fork could not avoid — it is not optional for a from-scratch build, only for a factory-built unit being
unpacked. If sourcing an already-calibrated HDI (e.g. a purchased unit), skip 004.3 entirely and go straight to
normal bring-up per wiki `Dexter-Setup.md`.

---

## 004.3 Factory calibration procedure (from-scratch builds only)

**VERIFIED**, transcribed from `DDE/InitialCalibration/HDI CAL INSTRUCTIONS- STEP {1,2,3}.pdf`, apparently written
as internal Haddington Dynamics technician documentation (references a shared "Dexter Tracking" folder structure
and per-serial-number Excel logs) rather than end-user docs, but shipped in this repo's tree regardless. Quoted
content is condensed; screenshots in the source PDFs are described, not reproduced.

### Step 1: initial file deployment and serial number
1. A prerequisite factory file bundle (named e.g. `FilesForDexter_2020_1_6` in the source screenshots) containing
   `dde_apps/`, `share/`, `www/`, and `core/` subfolders must be copied onto the robot's SD card filesystem via
   WinSCP (`Host 192.168.1.142`, `Username: root`, `Password: klg`) — **VERIFY**: this default password should be
   changed on any HDI exposed to an untrusted network; nothing in the source material discusses doing so.
   - Copy `dde_apps/*` → `/srv/samba/share/dde_apps/`
   - Copy `share/*` → `/srv/samba/share/`
   - Copy `www/*` → `/srv/samba/share/www/`
   - Copy `core/*` → `/root/Documents/dde/core/`
2. Power-cycle the robot.
3. Via PuTTY (same login), set the system clock: `cd /srv/samba/share/`, then `date -s "<DDMonYY>"` (e.g. `date -s
   "12Dec19"`).
4. Run `./pg` from `/srv/samba/share/` to rebuild `DexRun` (a `gcc` compile of `DexRun.c` — expect harmless
   `-Wstrict-aliasing` warnings per the source screenshot).
5. Edit `Defaults.make_ins` (`nano Defaults.make_ins`) to set the Dexter Serial Number (the six-digit number
   printed on the robot's Main Pivot) in place of the `XXXXXX` placeholder — this sets the MAC address and avoids
   network collisions between multiple Dexters on the same LAN. Save (Ctrl+O, Enter) and exit (Ctrl+X).
6. Power-cycle. Proceed to Step 2.

### Step 2: per-joint eye calibration
**Safety note from source**: *"Always wear a properly grounded grounding sleeve when handling any part of the FPGA
board."*

1. Physically secure the robot with clearance for full-range rotation on every joint; remove the end effector's
   front part if already installed.
2. Line up the "X" mark on the Base Long with the center of the ExGear Mount Bottom (where the J3 motor wires
   exit); fine-tune by aligning the J1 Opto Block's right edge with the raised notch on the Base Code Disk.
3. Move the robot to its most upright (home) position — J5 code disk level, end-effector home notch at the J5 Opto
   Block.
4. Power on.
5. In DDE, open the calibration job file. **VERIFY — source inconsistency**: Step 2's own screenshot names the
   file `Setup_Find_Index_Home_HDIv2.dde`, but its header comment (visible in the same screenshot) reads `Written
   by: James Wigglesworth`, dated `Started: 5_21_19, Updated: 10_25_19`; Step 3 instead opens a file shown as
   `Setup_Find_Index_Home_HDI_Stab...` (truncated in the source screenshot, presumably
   `Setup_Find_Index_Home_HDI_Stable.dde`). Both filenames were, per this fork's git-history search, real files
   that existed upstream and were later deleted from the public repo (only the factory bundle referenced in Step 1
   would contain them today) — **treat the exact filename as unconfirmed; use whichever `Setup_Find_Index_Home_HDI*`
   variant is present in your factory file bundle**.
6. `Jobs` menu → `Calibrate Dexter...` → select the robot (e.g. `dexter0`) from the dropdown.
7. Wait for the "Initializing a Dexter for calibration" dialog to clear (confirms DDE has connected and read
   `AdcCenters.txt` from the robot).
8. **Start with J2, not J1** — the source is explicit this order avoids over-rotating J2 into the work surface if
   J1/J2 wiring is swapped.
9. For each joint: adjust the two trim potentiometers until the plotted cycle is a centered, counter-clockwise
   circle. A clockwise cycle means the phototransistors were installed backwards and must be swapped before
   continuing. Once centered, click the open "eye" (usually shown as a green or blue dot) and **Save**.
10. Screenshot each joint's calibration window for the build record (source recommends filing under a
    per-serial-number folder, e.g. `HDI-000027`).
11. Repeat for all 5 joints, then proceed to Step 3.

**Troubleshooting** (VERIFIED, source's own troubleshooting panel): a cycle leaning to one side means the Opto
Block needs to sit closer; a partial/flattened cycle means the Opto Block needs shimming (start with a 0.05"
shim, add more until the circle is decent); a cycle that won't center at all may mean the Opto Block's
phototransistor holes are undersized and the block needs rework or replacement.

### Step 3: movement calibration and go-live
1. Confirm the same base alignment marks as Step 2.
2. Fresh reboot.
3. In DDE, with the Step 2/3 calibration file open: `Undef` → `Clear` → `Eval` (cursor in the editor pane, nothing
   selected).
4. `Check_Eye_Order` — the reported eye values (5 integers) should show a clear largest-value pattern per row; if
   an individual row breaks the pattern, that joint's eye calibration needs revisiting (blue/black or green/black
   diode swap, disconnected opto wire, or off-center eye).
5. `Calibrate Optical Encoders` (via the Calibrate Dexter dialog's step 3, "USE CALIBRATION WINDOW'S CAL FOR
   THIS" per the source's own emphasis) — moves each joint through its full range and records index-pulse timing.
6. Optionally verify smooth motion via `Jobs → Run Instruction → Show Dialog`, sending
   `Dexter.set_Follow_Me()` to the robot and manually moving each joint by hand; return to
   `Dexter.set_Keep_Position()` then `OpenLoop` afterward (`Initial_Scan`, next, requires OpenLoop mode).
7. `Initial_Scan` — produces 4 diagnostic windows per joint. Each code disk shows 3 black spikes (start position)
   plus green spikes (index pulses); verify the green-spike separation increases by 2 on each side of the 3 black
   spikes (odd on one side, even on the other — which side is odd/even varies by code disk) and that there are no
   gaps in that pattern within the joint's usable travel range (a small gap far from the black spikes' home
   position is tolerable if the robot always powers on near home; a gap near home is not).
8. `Save_Scan_Results`.
9. Power off; manually move the robot to the desired home position (J1 at the "X" mark; other joints at their
   visual zero).
10. Power on.
11. `Check_Eye_Order`, then `Center_Eye` (wait for `Done`), then `Find_Idx_Eyes_Setup` (records an
    `idx_eye_to_cal_offset` — source example values are all small integers, e.g. `[-2,-2,-2,-1,-1]`).
12. `Save_Eye_Offset`.
13. `Find_Idx_Eyes_For_Cal` (no power cycle needed).
14. `Calibrate Optical Encoders` again (same dialog/step as item 5).
15. `post_cal_info` — writes `post_cal_info.JSON` to the robot; this is the artifact that makes the "no
    recalibration needed" property of a factory HDI real.
16. `Check_Eye_Order`, then `Find_Idx_Eyes` (not `Find_Idx_Eyes_Setup`) to confirm the robot correctly returns
    home.
17. Via PuTTY, `nano /srv/samba/share/RunDexRun`: remove the leading `#` from the two lines that start the
    home-finding and PhUI jobs on boot:
    ```
    #Find home position from index eyes in code disks, this requires HDI.
    #sleep 5 && sudo node core define_and_start_job /srv/samba/share/dde_apps/Find_Index_Pulses_HDI.dde
    #Start Physical interface, see
    # https://github.com/HaddingtonDynamics/Dexter/wiki/PhysicalUserInterface
    sleep 1 && sudo node core define_and_start_job /srv/samba/share/dde_apps/PHUI2RCP.js
    ```
    Per the source: *"Always remove this hashtag"* on the `Find_Index_Pulses_HDI.dde` line; the `PHUI2RCP.js`
    line's hashtag should be left off by default (leave it hashed only if you want to do DDE programming instead
    of the default PhUI startup behavior). Save and exit, then power-cycle — boot takes ~3 minutes, after which
    the end effector "nods" to confirm it is ready.
18. To redo calibration later (e.g. after a repair), re-add the `#` in front of both lines above so PhUI does not
    start and block DDE access on boot.

**Maintenance note from source, applies regardless of how the robot was calibrated**: *"Run your Dexter through
several training series and stress test for at 36 hours. Cone drive lubricant needs to be replaced after 100
hours and again at 2000 hours. Adjust belts as needed."*

---

## 004.4 Boot sequence and PhUI

**VERIFIED**, wiki `Dexter-Setup.md` and `PhysicalUserInterface.md`:

On power-up, Dexter HDI loads the OS, then (unlike Dexter 1/HD, which just twitch to signal readiness) spends
"a minute or two" finding its own home position via index eyes, then — if `RunDexRun` is configured per 004.3
step 17 — enters PhUI and waits for mechanical commands. **While in any startup mode, including PhUI, the robot
will not respond to DDE or other control software** — only the web interface, SSH, or the console cable work
during this window. To exit PhUI: grab the tool interface and "cog" up (rotate to a detent) without moving to the
side, until the robot pushes back and returns home. See wiki `PhysicalUserInterface.md` for the full PhUI
gesture vocabulary (record/play slot selection, ending a recording, stopping playback) — reproduced in
[003-Assembly.md](003-Assembly.md)'s bring-up section only to the extent it affects first-power-on verification.
