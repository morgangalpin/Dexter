# 009 — Design Completion (Dexter HDI Rev A)

This document is the live list of **open design decisions** that must be closed to make Dexter HDI Revision A
fully buildable and to advance its `[Provisional]`/`[TBD]` items to `[Specified]`. Each item states the
requirement it must satisfy, its current state, what closing it requires (definition of done), and what it
blocks. These are design tasks owned by this project — not gaps in knowledge about the robot.

Priority reflects lead time and build-blocking impact. Close **P1** items before ordering; **P2** before
cutting/committing structure; **P3** are refinements or characterizations.

| ID | Item | Priority | Blocks | Status |
|---|---|---|---|---|
| DC-1 | [Strain-wave component set](#strain-wave-component-set) | **P1** | J1–J3 drives | `[Provisional]` — part identified (HanZhen #14 / Cone Drive); procurement open |
| DC-2 | [Differential detail design](#differential-detail-design) | **P1** | J4/J5 wrist | `[Provisional]` |
| DC-3 | [Wrist reduction ratio](#wrist-reduction-ratio) | P2 | J4/J5 resolution | `[Provisional]` — net ratio fixed at **13.5:1**; tooth decomposition open |
| DC-4 | [Base plate](#base-plate) | P2 | Base mounting | `[Provisional]` — design specified; CAD hole transfer + build open |
| DC-5 | [Link member lengths (L2/L3)](#link-member-lengths) | P2 | Arm Body, End Arm Hub | `[Provisional]` — cut lengths computed (282.4 / 214.3 mm); confirm HDI socket seat |
| DC-6 | [Link-length discrepancy (L4)](#link-length-discrepancy-l4) | P2 | Kinematic accuracy | `[TBD]` — needs measurement |
| DC-7 | [Motor Control PCB](#motor-control-pcb) | P2 | Electronics | `[Provisional]` |
| DC-8 | [Power supply rating](#power-supply) | P2 | Power | `[Specified]` — **36 V, 4 A** ✔ closed |
| DC-9 | [Performance characterization](#performance-characterization) | P3 | REQ-PRE/WS confirmation | `[TBD]` — needs physical build |
| DC-10 | [From-scratch calibration files](#from-scratch-calibration-files) | P2 | First bring-up | `[Provisional]` — engine + PHUI2RCP recovered; 2 job wrappers open |

**Rev A completion progress.** DC-8 is closed. DC-4 is resolved to a design of record pending a CAD hole
transfer and build confirmation; DC-5 is resolved to computed cut lengths pending an HDI socket-seat check.
DC-3 is resolved to a fixed net wrist ratio (with a correctness fix, below) pending the tooth-count
decomposition. DC-1, DC-2, DC-7, and DC-10 are advanced with the specific remaining gap named.
DC-6 and DC-9 are inherently physical (caliper measurement / instrumented build) and cannot be closed from
the design record alone.

---

## Strain-wave component set
**DC-1 · P1 · Requirement: REQ-STR-2 · Specified in [004](004-Mechanical-Architecture.md#base-joints-j1-j3-strain-wave-drive)**

The 52:1 strain-wave drives on J1–J3 require a **flex spline, wave generator, and circular ("stator")
gear** — three sets total.

**Resolution (Rev A).** The component set is now identified to a specific vendor part:

- **Original source — HanZhen (hanzh.com):** request *"the **number 14 component set**"*. It is **not listed
  on their website** — contact them directly; they reply quickly. Ratio **52:1**, **9–12 week lead time**,
  bare component set (not a housed unit), not sold retail. *Source: `Hardware/README.md`.*
- **Later / alternate source — Cone Drive:** the HDI CAD carries Cone-Drive-specific mounting geometry
  (`HDI-311-006B_J2StatorHolder_ConeDrive`, `HDI-311-006C_J2StatorHolderCap_ConeDrive`,
  `HDI-610-002B_StatorGear` in `dde/HDIMeterModel.gltf`), and the maintenance schedule specifies Cone Drive
  lubricant ([006](006-Firmware-and-Calibration.md#maintenance)). HDI is designed around the Cone Drive
  variant of this set; the printed Wave Gen Coupler / Flex Spline Attach / Stator Holder interfaces are cut
  to it.

**Definition of done:** a confirmed price, lead time, and current availability from HanZhen (#14 set) or the
Cone Drive equivalent, for a bare 52:1 flex-spline / wave-generator / circular-gear set compatible with the
printed `_ConeDrive` stator-holder and Wave Gen Coupler interfaces; three sets. This remains the highest-risk,
longest-lead item — start vendor contact first. If neither set is procurable, this becomes a drive-redesign
task (e.g. cycloidal), which is a new revision, not a Rev A completion. Status is `[Provisional]`: the part is
identified and the CAD is built around it; only the live procurement quote is open.

## Differential detail design
**DC-2 · P1 · Requirement: REQ-DOF-1, REQ-STR-3 · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4-j5)**

The differential is described as significantly revised on HDI. Rev A specifies the differential *function*
and provisionally builds the HD differential geometry as a working substitute.

**Resolution (Rev A) — recovery source narrowed.** The HDI CAD model shipped in `dde` (`HDIMeterModel.gltf`,
also `dde/sim2/HDIMeterModel.gltf`) is a **kinematic + outer-skin** model: it contains the HDI differential
*covers* (`HDI-940-001_DiffCover`, `HDI-940-002_DiffCoverCap`) and the `DexterHDI_Link4/5/6/7_KinematicAssembly`
frames, but **not** the differential mechanism internals (the 700-series Split Gear, Diff Body A/B, Diff Gear
Shaft/Axle, Diff End Pulley). It therefore confirms the HDI outer envelope and axis frames but is
insufficient to recover the flex/pivot detail geometry. The remaining recovery source is the **OnShape CAD**
(linked in `Hardware/README.md`) or direct measurement of a physical HDI differential.

**Definition of done:** the HDI differential detail geometry (flex/pivot dimensions, pulley integration,
wiring bore) recovered from the OnShape source or a physical unit and validated, replacing the HD substitute.
Until then, build the HD differential; an incorrect flex/pivot geometry risks binding a joint that also
routes the tool wiring through its bore. Status `[Provisional]`.

## Wrist reduction ratio
**DC-3 · P2 · Requirement: REQ-STR-3, REQ-PRE (J4/J5) · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4-j5), [006](006-Firmware-and-Calibration.md#drive-constants-axiscal)**

HDI resolves J4/J5 by a physical belt/pulley reduction (`Interpolation` = 1, and a J4/J5 `AxisCal` that
differs from HD).

**Resolution (Rev A) — net ratio is derivable, and a correctness fix.** The prior spec said the wrist ratio
was "not derivable from the firmware constants." That is true only of the *individual tooth counts*; the
**net motor→joint reduction is fully determined by `AxisCal`**:

- `AxisCal = gear_ratio × motor_steps × microstepping`. With a 400-step motor at 16× microstepping,
  one motor revolution = 6400 microsteps.
- **HDI J4/J5:** `AxisCal` = 86400 ⇒ **net wrist reduction = 86400 / 6400 = 13.5:1.** Corroborated
  independently by this unit's `Firmware/AxisCal.txt` (J4/J5 line = 0.0666667 = 13.5 × 6400 / 1 296 000) and
  by its `ANGLE_END_RATIO` term (−4 529 848 = −round(13.5 / 50 × 2²⁴); the base-joint `50` there vs the
  authoritative `52` is a separate stale-file note in
  [006](006-Firmware-and-Calibration.md#drive-constants-axiscal)).
- **HD J4/J5:** `AxisCal` = 36000 ⇒ net wrist reduction = 36000 / 6400 = **5.625:1**, which is exactly the
  HD belt stage **90T / 16T** documented in the wiki (`Joints.md`, `Firmware.md`: motor pulley 16T → joint-3
  pulley 90T).

⚠️ **Correctness fix.** HDI's firmware expects **13.5:1**, but the HD-documented 16T→90T pulleys give only
**5.625:1** — 2.4× short. **Building the wrist with the HD pulley set unchanged and running it against the
HDI `AxisCal` would produce a 2.4× wrist-scale error.** The wrist must therefore net **13.5:1** (revised
differential and/or re-toothed pulleys — 13.5 = 2.4 × the HD 90/16 stage), *or* the firmware `AxisCal` must
be set to the as-built ratio. The 16T motor pulley in [007.9](007-Bill-of-Materials.md#0079-external-gear-mount--differential-motors)
is retained; the driven side is what changes. The differential bevels are ≈1:1 (HD's net 5.625:1 equals its
belt stage alone), so the added 2.4× lives in the belt/pulley stages.

**Definition of done:** the HDI J4/J5 tooth-count decomposition (which pulleys realize the 13.5:1 net,
recovered from OnShape CAD or measurement) and belt lengths, validated so firmware `AxisCal`/`Interpolation`
produce correct joint resolution and range with acceptable backlash. Status `[Provisional]`: **the target net
ratio (13.5:1) is fixed and specified**; only the tooth-count split is open. Do **not** ship the HD 16T/90T
driven set against HDI firmware without re-checking the net ratio.

## Base plate
**DC-4 · P2 · Requirement: REQ-STR-4, REQ-ENV-5 · Specified in [004](004-Mechanical-Architecture.md#base-j1)**

The bolted base replaces HD's six free-standing legs with a plate bolted to the Base Mount Bottom and through
to a work surface.

**Resolution (Rev A) — design of record.** The HDI CAD confirms the bolted base is real: the base part is
modeled as `BaseMountBottom_Bolted` / `HDI-110-001_BaseMountBottom` (dropping HD's `#111-001` feet ×6 and
`#111-002` aluminium strakes ×6). The plate is specified as follows:

- **Material:** **6061-T6 aluminium plate** (recommended). Steel is an acceptable alternative and adds
  desirable mass; printed Onyx is **not** acceptable for a load-bearing bolted plate. `[Specified]`.
- **Thickness:** **9.5 mm (3/8″)** aluminium — stiff against deflection under the arm's overturning moment
  and thick enough to tap the robot-side holes. (≈6 mm if steel.) `[Specified]`.
- **Footprint:** **≈200 × 200 mm** (square or the base's bolt-circle diameter + clearance). Sizing rationale
  below. `[Specified]`.
- **Robot-side bolt pattern:** matches the existing mounting holes on `HDI-110-001_BaseMountBottom` (the same
  bosses HD's feet bolted to). Transfer the exact hole coordinates from the OnShape/GLTF part. `[Provisional]`
  — the pattern is defined in CAD; only the coordinate transfer to the plate drawing remains.
- **Work-surface bolt pattern:** **4 × M6 clearance holes** near the plate corners for through-bolting to a
  bench (or T-slot clamping). `[Specified]`.

**Stability rationale (answers the open question).** Worst-case static overturning moment (arm fully
extended, moving-link mass ≈ 4.79 kg lumped at ≈0.4 m, plus ~0.5 kg payload at 0.79 m reach, ×2 dynamic
factor) ≈ **45 N·m**. A free-standing plate that merely *rests* on the bench would need impractical mass to
resist this (a 250 × 250 × 10 mm steel plate ≈ 4.9 kg gives only ≈6 N·m of restoring moment — it tips).
Therefore **the plate must be bolted to the work surface**, and when it is, the moment reacts as trivial bolt
tension (≈45 N·m / 0.15 m span ≈ 300 N per far bolt — well within an M6's capacity). **Design intent: the
plate is a permanent bench fixture; the robot base bolts onto it via the robot-side pattern and can be
removed as a unit while the plate stays fixed.**

**Definition of done:** the plate drawing with the robot-side hole coordinates transferred from CAD, plus the
plate and its work-surface hardware added to [007](007-Bill-of-Materials.md#0072-base) (done — provisional
M6 count), validated on a build to react full dynamic load without walking or tipping.

## Link member lengths
**DC-5 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths), [004](004-Mechanical-Architecture.md)**

L2 (+18.4 mm) and L3 (−22.7 mm) differ from HD by more than build tolerance, so the Arm Body 1″ CF tube and
End Arm Hub 0.75″ CF tube need HDI-specific cut lengths.

**Resolution (Rev A) — cut lengths computed.** If the printed sockets that set the axis positions — the Arm
Body and End Arm Hub — keep the same tube seat depth as HD, then the entire axis-to-axis link delta appears
in the tube: `tube_HDI = tube_HD + link_delta`, giving:

| Span | HD tube | Link delta (from [003](003-Kinematics.md#link-lengths)) | **Computed HDI cut length** |
|---|---|---|---|
| L2 — Arm Body, 1″ CF square tube | 264 mm | +18.41 mm | **282.4 mm** |
| L3 — End Arm Hub, 0.75″ CF square tube | 237 mm | −22.70 mm | **214.3 mm** |

Adopt these as the cut lengths of record. **Caveat:** the HDI CAD shows the printed bodies are *renumbered*
for HDI (`HDI-310-001_ArmBody`, `HDI-500-001_EndArmHub` in `dde/HDIMeterModel.gltf`), so the socket seat
depth is not guaranteed identical to HD. **Confirm the HDI socket seat depth against the HDI CAD (or measure
the printed socket bottoms) before committing the tubes.** Getting L2/L3 wrong shifts where the links land
relative to encoder zero and shows up as a Cartesian-accuracy error, not an assembly failure. `[Provisional]`
(computed value; one narrow CAD/measurement check remaining).

## Link-length discrepancy (L4)
**DC-6 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths)**

Two HDI link-length sets disagree: the firmware file (`Defaults.make_ins`) gives L4 = 59.50 mm and
L5 = 82.44 mm; the wiki gives L4 = 50.95 mm and L5 = 82.55 mm. Rev A treats the firmware file as
authoritative.

**State.** This cannot be closed from the design record. The measured DH model of HDI-007010
([003](003-Kinematics.md#denavit–hartenberg-model)) does not adjudicate it: the wrist axes intersect
(`a`≈0 on J4/J5), so L4 is carried in frame `d` offsets (J4 `d` = 39.3 mm, J5 `d` = 55.6 mm) that do not map
1:1 to either candidate. Resolution requires a **caliper measurement of L4/L5 on a built or serialized unit**.

**Definition of done:** measure L4/L5 physically, set the authoritative values, and update
[003](003-Kinematics.md#link-lengths) and firmware. Until then the firmware file (L4 = 59.50 mm) stands.
`[TBD]`.

## Motor Control PCB
**DC-7 · P2 · Requirement: REQ-CTL-3, REQ-IF-4 · Specified in [005](005-Electronics-and-Control.md#boards)**

No HDI-native Motor Control PCB exists; Rev A reuses the HD "green" board (D3/D4-corrected) with the
White-wire harness reassignment.

**Resolution (Rev A) — board contents confirmed from the gerbers/BOM.** The board
(`Hardware/Motor PCB/`, `09051-00135-A`) carries **6 × Allegro A4983 microstepping stepper drivers**
(`Z1–Z6`, one per motor channel `MOT1–MOT6` = 5 arm joints + 1 spare/External), TI **TPS54541** buck
regulators (`U1`, `U2`), an **LTC3786** boost controller (`U3`, which sets the board's 38 V rating), the
**PDS760** power Schottkys that are the "D3/D4 fix" (`D3`, `D4`), and per-channel **3.0 A thermal fuses**
(`F1–F6`). The connector set is generic, not HD-specific: `J1–J6/J24` 4-pin motor screw terminals,
`J7–J13` 6-pin opto/encoder headers, `J14–J17` 3-pin tool/servo headers, `J19–J21` power headers — which is
why the HDI reuse is viable and the only known HDI difference is the harness White-wire reassignment
([005](005-Electronics-and-Control.md#tool-interface-wiring)).

**Definition of done (Rev A):** confirm the HD board drives an HDI unit correctly with the HDI wiring harness
(a **physical power-on test** — the residual open). Full closure (an HDI-native board) is a roadmap item, not
a Rev A blocker. If an HDI unit shows power-related faults absent on HD builds, revisit this reuse assumption
first. `[Provisional]`.

## Power supply
**DC-8 · P2 · Requirement: REQ-CTL-5 · Specified in [005](005-Electronics-and-Control.md#power)** — ✔ **closed**

**Resolution (Rev A).** The Dexter supply is a **36 V DC, 4 A (≈144 W) laptop-style brick**. The "green"
Motor Control PCB is **rated for 38 V** (the limit is the `LTC3786` boost controller;
[Digikey LTC3786IUD-PBF](https://www.digikey.com/en/products/detail/analog-devices-inc/LTC3786IUD-PBF/2407353)),
so 36 V sits just under the board ceiling with margin, and the 50 V-rated input caps and PDS760 (60 V)
Schottkys support it. **Under-voltage is not merely slow — it stalls motions and fails home-finding** (a 12 V
or 24 V brick makes the arm grind/buzz and lose position). *Source: wiki `Troubleshooting.md`; Motor PCB BOM.*

The selected supply is a **36 V / 4 A DC adapter** with the matching barrel/DC connector, added to
[007.10](007-Bill-of-Materials.md#00710-wire-harness). This advances REQ-CTL-5 to `[Specified]`. (The
in-testing "blue" board would raise the ceiling to 75 V — out of scope for Rev A.)

## Performance characterization
**DC-9 · P3 · Requirements: REQ-PRE-5/6/7, REQ-WS-6/8**

End-to-end repeatability, rated payload, maximum speed, and the reachable envelope are derived or unknown,
not measured. This is inherently a **physical, instrumented-build** item and cannot be closed from the design
record.

**Definition of done:** measured repeatability, payload, speed envelope, and reachable workspace on a
physical Rev A build, replacing derived values and advancing the requirements to `[Specified]`. This is the
main content of roadmap item 1 ([010](010-Versioning-and-Roadmap.md#roadmap)). `[TBD]`.

## From-scratch calibration files
**DC-10 · P2 · Requirement: REQ-ENV-2, REQ-CTL-6 · Specified in [006](006-Firmware-and-Calibration.md#factory-calibration-procedure)**

A from-scratch build must run the full factory calibration once; the procedure references calibration job
files that ship in a factory bundle.

**Resolution (Rev A) — most of the bundle is recoverable from public repos; two wrappers remain.**

| File | Role | Availability |
|---|---|---|
| `PHUI2RCP.js` | Default PhUI startup job | **Present** — `Firmware/dde_apps/PHUI2RCP.js` (and `DDE/examples/PHUI2RCP.dde`) |
| Calibration engine | Optical-encoder calibration routines the job files call | **Present** — `dde/low_level_dexter/` (`Calibrate_Encoders_Function.dde`, `calibrate_optical.js`, `calibrate_build_tables.js`, `calibrate_ui.js`, `ViewEyeRealTime.js`, `ViewEye_Support_Functions.js`) |
| `Setup_Find_Index_Home_HDI*.dde` | Step 2 eye-calibration job wrapper | **Missing** from the public repo (referenced only) |
| `Find_Index_Pulses_HDI.dde` | Boot home-finding job wrapper | **Missing** — named in `Firmware/RunDexRun` (commented boot line) but not shipped |

Because the calibration **engine** is public, the two missing `.dde` wrappers are thin jobs over it and can
be **reconstructed** against `Calibrate_Encoders_Function.dde` / `calibrate_optical.js`, or requested from
Haddington Dynamics.

**Definition of done:** obtain or reconstruct the two missing job wrappers, verify they drive the engine
through [006](006-Firmware-and-Calibration.md#factory-calibration-procedure) end-to-end on a new unit, and
confirm the resulting `post_cal_info.JSON` gives correct home-finding. `[Provisional]`.
