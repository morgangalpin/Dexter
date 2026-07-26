# 009 — Design Completion

This document is the live list of **open design decisions** that must be closed to make Dexter
fully buildable and to advance its `[Provisional]`/`[TBD]` items to `[Specified]`. Each item states the
requirement it must satisfy, its current state, what closing it requires (definition of done), and what it
blocks. These are design tasks owned by this project — not gaps in knowledge about the robot.

Each item covers only the part of a design that is still **open**. The settled design around it is
specified in the document named in the item's header, and is not repeated here.

Priority reflects lead time and build-blocking impact. Close **P1** items before ordering; **P2** before
cutting/committing structure; **P3** are refinements or characterizations.

| ID | Item | Priority | Blocks | What is still open | Status |
|---|---|---|---|---|---|
| DC-1 | [Strain-wave component set](#strain-wave-component-set) | **P1** | J1–J3 drives | Vendor quote and availability | `[Provisional]` |
| DC-2 | [Differential detail design](#differential-detail-design) | **P1** | J4/J5 wrist | Detail geometry recovery | `[Provisional]` |
| DC-3 | [Wrist reduction ratio](#wrist-reduction-ratio) | P2 | J4/J5 resolution | Tooth-count decomposition | `[Provisional]` |
| DC-4 | [Base plate](#base-plate) | P2 | Base mounting | Robot-side hole transfer from CAD | `[Provisional]` |
| DC-5 | [Link member lengths (L2/L3)](#link-member-lengths) | P2 | Arm Body, End Arm Hub | Socket-seat depth check | `[Provisional]` |
| DC-6 | [Link-length discrepancy (L4)](#link-length-discrepancy-l4) | P2 | Kinematic accuracy | Caliper measurement | `[TBD]` |
| DC-7 | [Motor Control PCB](#motor-control-pcb) | P2 | Electronics | Physical power-on test | `[Provisional]` |
| DC-8 | [Power supply rating](#power-supply) | P2 | Power | — | `[Specified]` ✔ closed |
| DC-9 | [Performance characterization](#performance-characterization) | P3 | REQ-PRE/WS confirmation | Instrumented build | `[TBD]` |
| DC-10 | [From-scratch calibration files](#from-scratch-calibration-files) | P2 | First bring-up | Two job wrappers | `[Provisional]` |
| DC-11 | [Procurement data](#procurement-data) | P2 | Ordering, printing | Five unpinned part identities | `[Provisional]` |

**Completion progress.** DC-8 is closed. Every other item except DC-6 and DC-9 has been narrowed to the
single remaining gap named in the table above — in each case a procurement action, a CAD or measurement
check, or a physical test, rather than an undecided design. DC-6 and DC-9 are inherently physical (caliper
measurement / instrumented build) and cannot be closed from the design record alone.

---

## Strain-wave component set
**DC-1 · P1 · Requirement: REQ-STR-2 · Specified in [004](004-Mechanical-Architecture.md#base-joints-j1j3-strain-wave-drive)**

**Open:** procurement. The part is identified and the printed adapter interfaces are cut to it; what is not
yet in hand is a live quote and confirmed availability.

**Vendor options.**

- **Original source — HanZhen (hanzh.com):** request *"the **number 14 component set**"*. It is **not listed
  on their website** — contact them directly; they reply quickly. Ratio **52:1**, **9–12 week lead time**,
  bare component set (not a housed unit), not sold retail. *Source: `Hardware/README.md`.*
- **Later / alternate source — Cone Drive:** the CAD model carries Cone-Drive-specific mounting geometry
  (`HDI-311-006B_J2StatorHolder_ConeDrive`, `HDI-311-006C_J2StatorHolderCap_ConeDrive`,
  `HDI-610-002B_StatorGear` in `dde/HDIMeterModel.gltf`), and the maintenance schedule specifies Cone Drive
  lubricant ([006](006-Firmware-and-Calibration.md#maintenance)). The design is built around the Cone Drive
  variant of this set.

**Definition of done:** a confirmed price, lead time, and current availability from HanZhen (#14 set) or the
Cone Drive equivalent, for three bare 52:1 flex-spline / wave-generator / circular-gear sets compatible with
the printed `_ConeDrive` stator-holder and Wave Gen Coupler interfaces. This is the highest-risk,
longest-lead item — start vendor contact before ordering anything else. If neither set is procurable, this
becomes a drive-redesign task (e.g. cycloidal), which is a new revision, not a completion item.
`[Provisional]`.

## Differential detail design
**DC-2 · P1 · Requirement: REQ-DOF-1, REQ-STR-3 · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4j5)**

**Open:** the differential's detail geometry. Its *function* is specified in 004; the build uses the previous
version's differential geometry as a working substitute until the detail design is recovered.

**Recovery source narrowed.** The CAD model shipped in `dde` (`HDIMeterModel.gltf`,
also `dde/sim2/HDIMeterModel.gltf`) is a **kinematic + outer-skin** model: it contains the differential
*covers* (`HDI-940-001_DiffCover`, `HDI-940-002_DiffCoverCap`) and the `DexterHDI_Link4/5/6/7_KinematicAssembly`
frames, but **not** the differential mechanism internals (the 700-series Split Gear, Diff Body A/B, Diff Gear
Shaft/Axle, Diff End Pulley). It therefore confirms the outer envelope and axis frames but is
insufficient to recover the flex/pivot detail geometry. The remaining recovery source is the **OnShape CAD**
(linked in `Hardware/README.md`) or direct measurement of a physical differential.

**Definition of done:** the differential detail geometry (flex/pivot dimensions, pulley integration,
wiring bore) recovered from the OnShape source or a physical unit and validated, replacing the substitute.
Until then, build the previous version's differential; an incorrect flex/pivot geometry risks binding a
joint that also
routes the tool wiring through its bore. Status `[Provisional]`.

## Wrist reduction ratio
**DC-3 · P2 · Requirement: REQ-STR-3, REQ-PRE (J4/J5) · Specified in [004](004-Mechanical-Architecture.md#wrist-and-differential-j4j5), [006](006-Firmware-and-Calibration.md#drive-constants-axiscal)**

**Open:** the tooth-count decomposition. The **net** wrist reduction is fixed and specified; which pulleys
realize it is not.

**The net ratio is derivable from the firmware.** Only the *individual tooth counts* are unpinned — the
net motor→joint reduction is fully determined by `AxisCal`:

- `AxisCal = gear_ratio × motor_steps × microstepping`. With a 400-step motor at 16× microstepping,
  one motor revolution = 6400 microsteps.
- **J4/J5 (this version):** `AxisCal` = 86400 ⇒ **net wrist reduction = 86400 / 6400 = 13.5:1.** Corroborated
  independently by this unit's `Firmware/AxisCal.txt` (J4/J5 line = 0.0666667 = 13.5 × 6400 / 1 296 000) and
  by its `ANGLE_END_RATIO` term (−4 529 848 = −round(13.5 / 50 × 2²⁴); the base-joint `50` there vs the
  authoritative `52` is a separate stale-file note in
  [006](006-Firmware-and-Calibration.md#drive-constants-axiscal)).
- **J4/J5 (previous version):** `AxisCal` = 36000 ⇒ net wrist reduction = 36000 / 6400 = **5.625:1**, which is exactly its
  belt stage **90T / 16T** documented in the wiki (`Joints.md`, `Firmware.md`: motor pulley 16T → joint-3
  pulley 90T).

⚠️ **Correctness fix.** The firmware expects **13.5:1**, but the previously documented 16T→90T pulleys give only
**5.625:1** — 2.4× short. **Building the wrist with that pulley set unchanged and running it against the
`AxisCal` specified here would produce a 2.4× wrist-scale error.** The wrist must therefore net **13.5:1** (revised
differential and/or re-toothed pulleys — 13.5 = 2.4 × the earlier 90/16 stage), *or* the firmware `AxisCal` must
be set to the as-built ratio. The 16T motor pulley in [007.9](007-Bill-of-Materials.md#0079-external-gear-mount--differential-motors)
is retained; the driven side is what changes. The differential bevels are ≈1:1 (the previous version's
net 5.625:1 equals its
belt stage alone), so the added 2.4× lives in the belt/pulley stages.

**Definition of done:** the J4/J5 tooth-count decomposition (which pulleys realize the 13.5:1 net,
recovered from OnShape CAD or measurement) and belt lengths, validated so firmware `AxisCal`/`Interpolation`
produce correct joint resolution and range with acceptable backlash. Status `[Provisional]`: **the target net
ratio (13.5:1) is fixed and specified**; only the tooth-count split is open. Do **not** ship the previous
version's 16T/90T
driven set against this firmware without re-checking the net ratio.

## Base plate
**DC-4 · P2 · Requirement: REQ-STR-4, REQ-ENV-5 · Specified in [004](004-Mechanical-Architecture.md#base-j1)**

**Open:** the plate's **robot-side hole pattern**. The plate's material, thickness, footprint, work-surface
pattern, and the stability analysis that requires it to be bolted down are all specified in
[004 § Base mounting plate](004-Mechanical-Architecture.md#base-mounting-plate).

The pattern itself is not unknown — it matches the existing mounting bosses on
`HDI-110-001_BaseMountBottom`, the same ones the previous version's feet bolted to. What remains is
transferring the exact hole coordinates out of the OnShape/GLTF part and onto a plate drawing, and
confirming the resulting bolt size and count (which the [007.2](007-Bill-of-Materials.md#0072-base) row
currently leaves open).

**Definition of done:** a plate drawing carrying the robot-side hole coordinates transferred from CAD, the
resulting hardware quantities added to [007.2](007-Bill-of-Materials.md#0072-base), and a build confirming
the mounted plate reacts full dynamic load without walking or tipping. `[Provisional]`.

## Link member lengths
**DC-5 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths), [004](004-Mechanical-Architecture.md)**

L2 (+18.4 mm) and L3 (−22.7 mm) differ from the previous version by more than build tolerance, so the Arm
Body 1″ CF tube and
End Arm Hub 0.75″ CF tube need new cut lengths.

**Resolution — cut lengths computed.** If the printed sockets that set the axis positions — the Arm
Body and End Arm Hub — keep the same tube seat depth as the previous version, then the entire
axis-to-axis link delta appears
in the tube: `tube_new = tube_previous + link_delta`, giving:

| Span | Previous tube | Link delta (from [003](003-Kinematics.md#link-lengths)) | **Computed cut length** |
|---|---|---|---|
| L2 — Arm Body, 1″ CF square tube | 264 mm | +18.41 mm | **282.4 mm** |
| L3 — End Arm Hub, 0.75″ CF square tube | 237 mm | −22.70 mm | **214.3 mm** |

Adopt these as the cut lengths of record. **Caveat:** the CAD model shows the printed bodies are *renumbered*
(`HDI-310-001_ArmBody`, `HDI-500-001_EndArmHub` in `dde/HDIMeterModel.gltf`), so the socket seat
depth is not guaranteed identical. **Confirm the socket seat depth against the CAD model (or measure
the printed socket bottoms) before committing the tubes.** Getting L2/L3 wrong shifts where the links land
relative to encoder zero and shows up as a Cartesian-accuracy error, not an assembly failure. `[Provisional]`
(computed value; one narrow CAD/measurement check remaining).

## Link-length discrepancy (L4)
**DC-6 · P2 · Requirement: REQ-WS-6 · Specified in [003](003-Kinematics.md#link-lengths)**

Two link-length sets disagree: the firmware file (`Defaults.make_ins`) gives L4 = 59.50 mm and
L5 = 82.44 mm; the wiki gives L4 = 50.95 mm and L5 = 82.55 mm. This specification treats the firmware file as
authoritative.

**State.** This cannot be closed from the design record. The measured DH model of HDI-007010
([003](003-Kinematics.md#denavithartenberg-model)) does not adjudicate it: the wrist axes intersect
(`a`≈0 on J4/J5), so L4 is carried in frame `d` offsets (J4 `d` = 39.3 mm, J5 `d` = 55.6 mm) that do not map
1:1 to either candidate. Resolution requires a **caliper measurement of L4/L5 on a built or serialized unit**.

**Definition of done:** measure L4/L5 physically, set the authoritative values, and update
[003](003-Kinematics.md#link-lengths) and firmware. Until then the firmware file (L4 = 59.50 mm) stands.
`[TBD]`.

## Motor Control PCB
**DC-7 · P2 · Requirement: REQ-CTL-3, REQ-IF-4 · Specified in [005](005-Electronics-and-Control.md#boards)**

**Open:** a physical power-on test. No purpose-built Motor Control PCB exists, so the previous version's
"green" board is reused. Its contents have been confirmed against the gerbers and BOM and are specified in
[005 § Boards](005-Electronics-and-Control.md#boards); that review is what established the reuse as viable,
since the board's connector set is generic and the only known difference is the harness White-wire
reassignment. What has *not* happened is running a unit on it.

**Definition of done:** confirm the inherited board drives a unit correctly with this wiring harness on a
physical power-on test. Full closure (a purpose-built board) is a roadmap item
([011](011-Roadmap.md)), not a blocker here. If a unit shows power-related faults absent on earlier builds,
revisit this reuse assumption first. `[Provisional]`.

## Power supply
**DC-8 · P2 · Requirement: REQ-CTL-5 · Specified in [005](005-Electronics-and-Control.md#power)** — ✔ **closed**

**Closed.** The supply rating was open because the board's input ceiling had not been established. It has
been: the `LTC3786` boost controller sets a 38 V limit, which places the supply at **36 V / 4 A** with
margin. The rating, the reasoning behind it, and the under-voltage failure mode are now specified in
[005 § Power](005-Electronics-and-Control.md#power), and the part is listed in
[007.10](007-Bill-of-Materials.md#00710-wire-harness). REQ-CTL-5 is `[Specified]`.

*(The in-testing "blue" board would raise the ceiling to 75 V — out of scope for this design.)*

## Performance characterization
**DC-9 · P3 · Requirements: REQ-PRE-5/6/7, REQ-WS-6/8**

End-to-end repeatability, rated payload, maximum speed, and the reachable envelope are derived or unknown,
not measured. This is inherently a **physical, instrumented-build** item and cannot be closed from the design
record.

**Definition of done:** measured repeatability, payload, speed envelope, and reachable workspace on a
physical build, replacing derived values and advancing the requirements to `[Specified]`. This is the
main content of roadmap item 1 ([011](011-Roadmap.md)). `[TBD]`.

## From-scratch calibration files
**DC-10 · P2 · Requirement: REQ-ENV-2, REQ-CTL-6 · Specified in [006](006-Firmware-and-Calibration.md#factory-calibration-procedure)**

**Open:** two job files. The [factory calibration procedure](006-Firmware-and-Calibration.md#factory-calibration-procedure)
a from-scratch build must run references calibration jobs that shipped in a factory bundle. Most of that
bundle is recoverable from public repos; two wrappers are not.

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

## Procurement data
**DC-11 · P2 · Requirement: buildability · Specified in [007.1](007.1-Parts-Catalog.md), [007.2](007.2-Printed-Parts.md)**

**Open:** five part identities that the parts catalog could not pin from the design record. Everything else
in [007.1](007.1-Parts-Catalog.md) resolves to an orderable product with a supplier link; these five do not,
and each is `[Provisional]` there.

| # | Item | What is open | Consequence if wrong |
|---|---|---|---|
| a | **Stepper motor identity** ([C-101](007.1-Parts-Catalog.md#c-101--nema-17-stepper-09step)) | The legacy list gives only *"25 mm shaft, 0.9°, 0.52 N·m"* — no manufacturer part number. The recommended `17HM19-2004S` is 0.46 N·m with a 24 mm shaft: it meets every stated requirement but is not a proven identity match | Body or shaft length mismatch against the printed Motor End Cap; five motors ordered wrong |
| b | **Cooling fan** ([C-716](007.1-Parts-Catalog.md#7-electronics-and-wiring)) | No size, voltage, or part number anywhere in the design record — only a printed Fan Bracket (`#800-005`) and a CAD body (`HDI-730-005_Fan`) | Fan does not fit the bracket, or fouls the MicroZed USB connector |
| c | **Belt Director type** ([#210-004/005](007.2-Printed-Parts.md#arm-body-and-belt-directors--0075)) | [007.5](007-Bill-of-Materials.md#0075-arm-body) types them "Fabricate"; [008.5](008-Assembly.md) treats them as printed bodies that accept pressed MR128 bearings and printed caps | Three parts either printed that should be machined, or absent from the print list |
| d | **Print parameters** ([007.2 § Material](007.2-Printed-Parts.md#material)) | Layer height, wall count, infill, and orientation were never published — the originals were produced on Markforged equipment | Bearing bores and CF strake slots out of tolerance; press and bond fits fail |
| e | **CAD-vs-BOM mismatches** ([007.2](007.2-Printed-Parts.md#model-vs-bom-discrepancies)) | `HDI-311-006C_J2StatorHolderCap_ConeDrive` is in the CAD model but has no BOM row; `HDI-610-006_MotorShaftCoupler` is instanced 4× where the BOM calls for 3 | A missing printed part discovered mid-assembly |

**Also open: the model archives are off-repository.** Every printed part's geometry lives in Thingiverse
archives and an OnShape document outside this repository
([007.2 § Model file sources](007.2-Printed-Parts.md#model-file-sources)). That is a single point of failure
for the whole build, and it is why [007.2](007.2-Printed-Parts.md) can give per-*archive* links but not
per-*part* ones.

**Definition of done:** (a) a confirmed stepper part number verified against the printed Motor End Cap
envelope; (b) fan size, voltage, and part number specified against the Fan Bracket; (c) the Belt Director
type settled and the affected rows corrected in [007](007-Bill-of-Materials.md)/[007.2](007.2-Printed-Parts.md);
(d) a published print profile validated on a bearing bore and a strake slot; (e) both CAD-vs-BOM mismatches
adjudicated against the model set; and the STL set mirrored into `Hardware/STL/` so
[007.2](007.2-Printed-Parts.md) can carry per-part model links. None of these blocks starting the long-lead
items in [DC-1](#strain-wave-component-set). `[Provisional]`.
