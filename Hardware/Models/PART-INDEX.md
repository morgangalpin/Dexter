# Printed-part index

Every part in [007.2](../../specs/007.2-Printed-Parts.md#printed-parts), grouped the way the files are laid
out on disk. Generated — see [README.md](README.md#regenerating).

Files are named `<PBS>_<PartName>.<ext>`, so a row's file is findable from its part number alone. Where a
part has more than one format, the stem is shared: `920-001_StaticFinger.step` and `.f3d` are the same part.

**A row means a model file plausibly matching that part exists here. It is not a verified identity.** The
upstream archives did not name parts the way [007](../../specs/007-Bill-of-Materials.md) does; several
matches rest on naming convention alone. Check the geometry before committing filament to a flagged part.

## 100-Base — Base

[007.2 §](../../specs/007.2-Printed-Parts.md#base--0072)

| PBS # | Part | Qty | File | |
|---|---|---|---|---|
| #100-001 | Base Clamp | 2 | `100-001_BaseClamp.stl` |  |
| #100-002 | Base Code Disc | 1 | `100-002_BaseCodeDisc.stl` |  |
| #100-003 | Pivot Skirt | 1 | `100-003_PivotSkirt.stl` | ⚠️ |
| #110-001 | Base Mount Bottom | 1 | `110-001_BaseMountBottom.stl` |  |
| #110-002 | Base Stator Holder | 1 | `110-002_BaseStatorHolder.stl` |  |
| #120-001 | Base Long | 1 | `120-001_BaseLong.stl` |  |

## 200-ArmBody — Arm body and belt directors

[007.2 §](../../specs/007.2-Printed-Parts.md#arm-body-and-belt-directors--0075)

| PBS # | Part | Qty | File | |
|---|---|---|---|---|
| #200-001 | Arm Body | 1 (+1 tooling) | `200-001_ArmBody.stl` |  |
| #200-002 | Pivot Stator Holder | 1 | `200-002_PivotStatorHolder.stl` |  |
| #200-003 | Stator Balancer | 4 | `200-003_StatorBalancer.stl` |  |
| #200-006 | Calibration Arrows | 2 | `200-006_CalibrationArrows.stl` |  |
| #210-001 | Belt Director Caps | 3 | `210-001_IdlerPlug.stl` | ⚠️ |
| #210-002 | Belt Director Pulley | 1 | `210-002_BeltDirectorPulley.stl` |  |
| #210-003 | Idler Plug | 1 | `210-001_IdlerPlug.stl` | ⚠️ |
| #210-004 | Small Belt Director | 2 | `210-004_SmallBeltDirector.stl` |  |
| #210-005 | Large Belt Director | 1 | `210-005_LargeBeltDirector.stl` |  |

## 300-Pivot — Main pivot and motor end caps

[007.2 §](../../specs/007.2-Printed-Parts.md#main-pivot-and-motor-end-caps--0073-0074)

| PBS # | Part | Qty | File | |
|---|---|---|---|---|
| #300-001 | Main Pivot | 1 | `300-001_MainPivot.stl` |  |
| #300-002 | Pivot Code Disk | 1 | `300-002_PivotCodeDisk.stl` |  |
| #311-001 | Motor End Cap (Base) | 1 | `311-001_MotorEndCapBase.stl` |  |
| #312-001 | Motor End Cap (Pivot) | 1 | `312-001_MotorEndCapPivot.stl` |  |

## 400-EndArm — End arm hub and pulleys

[007.2 §](../../specs/007.2-Printed-Parts.md#end-arm-hub-and-pulleys--0077)

| PBS # | Part | Qty | File | |
|---|---|---|---|---|
| #410-001 | Axis Intersection Half | 2 (+2 tooling) | `410-001_AxisIntersectionHalf.stl` |  |
| #410-002 | New Belt Pulley | 1 | `410-002_NewBeltPulley.stl` |  |
| #410-003 | End Arm Code Disk | 1 | `410-003_EndArmCodeDisk.stl` |  |
| #420-001 | End Arm Hub | 1 (+1 tooling) | `420-001_EndArmHub.stl` | ⚠️ |
| #420-002 | End Arm Hub Cap | 1 | `420-002_EndArmHubCap.stl` |  |
| #421-001 | Internal Outer Pulley | 1 | `421-001_InternalOuterPulley.stl` |  |
| #421-002 | Internal Inner Pulley | 1 | `421-002_InternalInnerPulley.stl` |  |
| #421-006 | Pulley Spacer | 2 | `421-006_PulleySpacer.stl` |  |
| #430-001 | External Outer Pulley | 1 | `430-001_ExternalOuterPulley.stl` |  |
| #430-002 | External Inner Pulley | 1 | `430-002_ExternalInnerPulley.stl` |  |

## 500-ExternalGear — External gear and mount

[007.2 §](../../specs/007.2-Printed-Parts.md#external-gear-and-mount--0078-0079)

| PBS # | Part | Qty | File | |
|---|---|---|---|---|
| #510-001 | External Gear | 1 | `510-001_ExternalGear.stl` |  |
| #511-001 | Ex Gear Motor End Cap | 1 | `511-001_ExGearMotorEndCap.stl` |  |
| #511-002 | Ex Gear Stator Holder | 1 | `511-002_ExGearStatorHolder.stl` |  |
| #520-001 | Ex Gear Mount | 1 (+1 tooling) | `520-001_ExGearMount.stl` |  |
| #520-002 | Ex Gear Mount Top | 1 | `520-002_ExGearMountTop.stl` |  |
| #520-003 | Nut Holder A | 1 | `520-003_ExGearNutHold.stl` | ⚠️ |
| #520-004 | Nut Holder B | 1 | `520-003_ExGearNutHold.stl` | ⚠️ |

## 600-StrainWave — Strain-wave drive adapters

[007.2 §](../../specs/007.2-Printed-Parts.md#strain-wave-drive-adapters--0073-0078)

| PBS # | Part | Qty | File | |
|---|---|---|---|---|
| #630-004 | Wave Gen Coupler | 3 | `630-004_WaveGenCoupler.stl` |  |
| #630-005 | Flex Spline Attach | 3 | `630-005_FlexSplineAttach.stl` |  |
| #630-006 | Flex Spline Cap | 3 | `630-006_FlexSplineCap.stl` |  |

## 700-Differential — Differential

[007.2 §](../../specs/007.2-Printed-Parts.md#differential--0076)

This is the one group whose files are `.scad`, not `.stl`: the source of record is parametric and the
printable mesh is rendered from it by [`render-all.rs`](700-Differential/render-all.rs) into
`700-Differential/out/`, which is not tracked. Each part's original mesh is kept as what the render is
measured against, under [`Reference/meshes/700-Differential/`](Reference/meshes/700-Differential/) on the
shared stem.

| PBS # | Part | Qty | File | |
|---|---|---|---|---|
| #710-001 | Split Gear Top | 1 | `710-001_SplitGearTop.scad` | rendered |
| #710-002 | Split Gear Bottom | 1 | `710-002_SplitGearBottom.scad` | rendered |
| #710-003 | Diff Keeper | 2 | `710-003_DiffKeeper.scad` | rendered |
| #710-004 | Rotate Code Disk | 1 | `710-004_RotateCodeDisk.scad` | rendered |
| #720-001 | Diff Gear Shaft | 1 | `720-001_DiffGearShaft.scad` | rendered |
| #720-002 | Diff Gear Axle | 1 | `720-002_DiffGearAxle.scad` | rendered |
| #720-003 | Diff End Pulley | 1 | `720-003_DiffEndPulley.scad` | rendered |
| #730-001 | Diff Body A | 1 | `730-001_DiffBodyA.scad` | rendered |
| #730-002 | Diff Body B | 1 | `730-002_DiffBodyB.scad` | rendered |

## 800-Harness — Wire harness

[007.2 §](../../specs/007.2-Printed-Parts.md#wire-harness--00710)

| PBS # | Part | Qty | File | |
|---|---|---|---|---|
| #800-001 | Wire Entry Left | 1 | `800-001_WireEntryLeft.stl` |  |
| #800-002 | Wire Entry Right | 1 | `800-002_WireEntryRight.stl` |  |
| #800-003 | Main Pivot Plug A | 1 | `800-003_MainPivotPlugA.stl` |  |
| #800-004 | Main Pivot Plug B | 1 | `800-004_MainPivotPlugB.stl` |  |
| #800-005 | Fan Bracket | 1 | `800-005_FanBracket.stl` |  |
| #800-006 | PCB Bracket | 2 | `800-006_PCBBracket.stl` |  |
| #800-007 | PCB Spacer | 4 | `800-007_PCBSpacer.stl` |  |
| #810-001 | 6-pin strain relief, top | 10 | `810-001_6PinStrainReliefTop.stl` |  |
| #810-002 | 6-pin strain relief, bottom | 10 | `810-002_6PinStrainReliefBottom.stl` |  |
| #821 | Photointerrupter shroud — base | 1 | `821_PhotointerrupterShroudBase_A.stl` | ⚠️ |
| #822 | Photointerrupter shroud — pivot | 1 | `822_PhotointerrupterShroudPivot_A.stl` | ⚠️ |
| #823 | Photointerrupter shroud — end arm | 1 | `823_PhotointerrupterShroudEndArm.stl` |  |
| #824 | Photointerrupter shroud — angle | 1 | `824_PhotointerrupterShroudAngle.stl` |  |
| #825 | Photointerrupter shroud — rotate | 1 | `825_PhotointerrupterShroudRotate_A.stl` | ⚠️ |

## 900-ToolInterface — Tool interface and gripper

[007.2 §](../../specs/007.2-Printed-Parts.md#tool-interface-and-gripper--00711)

| PBS # | Part | Qty | File | |
|---|---|---|---|---|
| #900-001 | Tool Interface Body | 1 | `900-001_ToolInterfaceBody.f3d` |  |
| #911-001 | Roll Body | 1 | `911-001_RollBody.stl` |  |
| #911-002 | Roll Driver | 1 | `911-002_RollDriver.stl` |  |
| #912-001 | Span Mount | 1 | `912-001_SpanMount.stl` |  |
| #912-002 | Span Driver | 1 | `912-002_SpanDriver.stl` |  |
| #920-001 | Static Finger | 1 | `920-001_StaticFinger.f3d` | ⚠️ |
| #920-002 | Dynamic Finger | 1 | `920-002_DynamicFinger.stl` |  |
| #920-003 | Finger Cap | 1 | `920-003_FingerCap.stl` |  |

## 950-Tooling — Tooling

[007.2 §](../../specs/007.2-Printed-Parts.md#tooling--solder-jigs)

| PBS # | Part | Qty | File | |
|---|---|---|---|---|
| #830-001 | Solder jig — 6-pin holder | 2 | `830-001_SolderJig6PinHolder.stl` |  |
| #830-002 | Solder jig — LED rig | 1 | `830-002_SolderJigLEDRig.stl` |  |

## One geometry, two part numbers

Two files each satisfy two BOM lines. They are stored once, under the lower number:

| File | Also serves | Status |
|---|---|---|
| `200-ArmBody/210-001_IdlerPlug.stl` | #210-003 Idler Plug | No file named "Belt Director Cap" exists in any archive; `IdlerPlug` is the assumed geometry ([008.5](../../specs/008-Assembly.md) presses caps in behind the bearings). Whether #210-001 and #210-003 are one part or two is **unresolved** |
| `500-ExternalGear/520-003_ExGearNutHold.stl` | #520-004 Nut Holder B | Only one `ExGearNutHold` geometry exists for the two BOM lines |

## Parts shipped as an A/B pair

[007.2](../../specs/007.2-Printed-Parts.md) counts one photointerrupter shroud per joint, but three of them
ship as two halves. **Both halves must be printed.** They are stored as `_A` and `_B`:

- `800-Harness/821_PhotointerrupterShroudBase_A.stl` + `_B.stl`
- `800-Harness/822_PhotointerrupterShroudPivot_A.stl` + `_B.stl`
- `800-Harness/825_PhotointerrupterShroudRotate_A.stl` + `_B.stl`

## Flagged rows

- **#100-003 Pivot Skirt** — The only source was the Dropbox in-work folder; it appears in neither
  Thingiverse set.
- **#420-001 End Arm Hub** — `EndArmHubJoined` was selected. `EndAxisHubXLSolidDeCant` was the other
  candidate and has been discarded; recover it from
  [thing:3781990](https://www.thingiverse.com/thing:3781990) if the hub does not fit.
- **#920-001 Static Finger** — **No mesh exists in any archive.** It ships only as `.f3d` and `.step`.
  Export an STL from `900-ToolInterface/920-001_StaticFinger.step` before printing. This is the one part in
  the build list that cannot be sliced as delivered.

## Glue-rig jigs — not in 007.2

`950-Tooling/` holds eight jig bodies that [007.2's tooling
section](../../specs/007.2-Printed-Parts.md#tooling--glue-rig) does not account for. That section states the
glue rig needs *"extra copies of parts already listed above — not new geometry"*, but these are distinct
geometry shipped in the HD sets:

`GlueRig_ArmBodyToEndArmHub_A/B/C`, `GlueRig_ArmBodyToExGear`, `GlueRig_EndArmHubToDiff_A/B`,
`GlueRig_EpoxyHolder`, `GlueRig_EpoxyPlunger`

They are kept because a glue rig that needs them cannot be built from extra copies alone. **Either 007.2's
tooling table is incomplete or these are orphans from a superseded rig design** — unresolved, tracked under
[DC-11](../../specs/009-Design-Completion.md#procurement-data).
