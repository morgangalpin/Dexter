# 007 — Bill of Materials

This document lists the parts that realize the mechanical architecture ([004](004-Mechanical-Architecture.md))
and electronics ([005](005-Electronics-and-Control.md)). It is a **derived artifact**: when the design
changes, regenerate this list. Parts are organized by subassembly; subassembly numbers match the assembly
steps in [008-Assembly.md](008-Assembly.md). Legacy Product Breakdown Structure (PBS) part numbers are
retained in the `PBS #` column for traceability to the source parts library.

Status markers per [README.md](README.md#design-status). Open design items (`[TBD]`) are cross-referenced to
[009-Design-Completion.md](009-Design-Completion.md). Order fasteners and bearings in excess — the aggregate
totals below carry no slack, and several rows depend on `[Provisional]`/`[TBD]` items being finalized.

## Subassembly summary

| # | Subassembly | PBS | Status |
|---|---|---|---|
| [007.1](#0071-glue-rig-assembly) | Glue Rig (tooling) | F | `[Provisional]` |
| [007.2](#0072-base) | Base | A | `[Provisional]` — bolted base + double clamp; plate design specified, CAD hole transfer ([DC-4](009-Design-Completion.md#base-plate)) |
| [007.3](#0073-harmonic-drive-motors) | Harmonic Drive Motors (J1, J2) | D | `[Specified]` except strain-wave set `[Provisional]` — part identified ([DC-1](009-Design-Completion.md#strain-wave-component-set)) |
| [007.4](#0074-main-pivot) | Main Pivot (J2) | C | `[Specified]` |
| [007.5](#0075-arm-body) | Arm Body (L2) | B | `[Provisional]` — L2 tube 282.4 mm, confirm socket seat ([DC-5](009-Design-Completion.md#link-member-lengths)) |
| [007.6](#0076-differential) | Differential (J4/J5) | H | `[Provisional]` — substitute from the previous version ([DC-2](009-Design-Completion.md#differential-detail-design)) |
| [007.7](#0077-end-arm-hub) | End Arm Hub (L3) | E | `[Provisional]` — L3 tube 214.3 mm, confirm socket seat ([DC-5](009-Design-Completion.md#link-member-lengths)) |
| [007.8](#0078-external-gear) | External Gear (J3 drive) | G | `[Specified]` except strain-wave set `[Provisional]` — part identified ([DC-1](009-Design-Completion.md#strain-wave-component-set)) |
| [007.9](#0079-external-gear-mount--differential-motors) | Ex Gear Mount + Diff Motors (J4/J5) | I | `[Specified]` motor pulley; driven set nets 13.5:1 ([DC-3](009-Design-Completion.md#wrist-reduction-ratio)) |
| [007.10](#00710-wire-harness) | Wire Harness | J | `[Provisional]` — PCB reuse from the previous version ([DC-7](009-Design-Completion.md#motor-control-pcb)); PSU 36 V/4 A `[Specified]` ([DC-8](009-Design-Completion.md#power-supply)) |
| [007.11](#00711-tool-interface--gripper) | Tool Interface / Gripper | K–O | `[Specified]` |

## Strain-wave component set (applies to 007.3 and 007.8)

Each 52:1 strain-wave drive (J1, J2, J3 — three total) requires a **flex spline**, a **wave generator**, and
a **circular/stator gear**. `[Provisional]` — the part is identified but not yet quoted: the **HanZhen
"number 14" 52:1 component set** (not listed on their site — contact direct; 9–12 wk lead) or the **Cone
Drive** equivalent that the CAD stator holders (`HDI-311-006B_..._ConeDrive`) are cut to. This is the
highest-risk, longest-lead item in the build; resolve [DC-1](009-Design-Completion.md#strain-wave-component-set)
before ordering anything else. The identical J1–J3 `AxisCal`
([006](006-Firmware-and-Calibration.md#drive-constants-axiscal)) confirms the same 52:1 gearing on all three.

---

## 007.1 Glue Rig Assembly
Tooling (epoxy jigs), not a robot part. Reuses parts also listed in their real subassemblies below — order
the extra quantity, do not double-order. `[Provisional]`.

| Part | Qty | Notes |
|---|---|---|
| Arm Body (printed) | 1 | Shared with [007.5](#0075-arm-body) |
| 1" × 264 mm CF square tube | 1 | Shared with [007.5](#0075-arm-body) — verify against the L2 length note before cutting |
| Axis Intersection Half (printed) | 2 | Shared with [007.7](#0077-end-arm-hub) |
| End Arm Hub (printed) | 1 | Shared with [007.7](#0077-end-arm-hub) |
| 0.75" × 237 mm CF square tube | 1 | Shared with [007.7](#0077-end-arm-hub) — verify against the L3 length note before cutting |
| Ex Gear Mount (printed) | 1 | Shared with [007.9](#0079-external-gear-mount--differential-motors) |
| 1" × 68 mm CF square tube | 1 | Shared with [007.9](#0079-external-gear-mount--differential-motors) |
| 6703 bearing | 2 | Shared |

## 007.2 Base
Realizes the bolted base ([004](004-Mechanical-Architecture.md#base-j1)). `[Provisional]` — the base plate
and its hardware are `[TBD]` ([DC-4](009-Design-Completion.md#base-plate)). The doubled Base Clamp is
consistent with the +6.6 mm L1 delta ([003](003-Kinematics.md#link-lengths)).

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #100-001 | Base Clamp | 3D print | **2** | Doubled per the double-clamp design; stacked at the base-pivot joint |
| #100-002 | Base Code Disc | 3D print | 1 | |
| #100-003 | Pivot Skirt | 3D print | 1 | |
| #110-001 | Base Mount Bottom | 3D print | 1 | |
| #110-002 | Base Stator Holder | 3D print | 1 | |
| #110-003 | 133 × 12.6 × 3.2 mm CF strake | Fabricate | 3 | dragonplate.com pID=697 |
| — | **Base Mounting Plate** | Machine (metal) | 1 | **6061-T6 aluminium, 9.5 mm (3/8″), ≈200 × 200 mm** ([DC-4](009-Design-Completion.md#base-plate)). Replaces the previous version's 6 feet + aluminium strakes; robot-side pattern matches the Base Mount Bottom holes (transfer from CAD); 4 × M6 work-surface through-holes. Onyx under-strength |
| — | M6 bolts + washers/nuts (plate to work surface) | Off the shelf | 4 | Through-bolt to bench (or T-slot clamp) ([DC-4](009-Design-Completion.md#base-plate)) |
| — | Robot-side bolts (Base Mount Bottom to plate) | Off the shelf | per CAD pattern | Match the existing Base Mount Bottom hole size (M3/M4); count from CAD transfer |
| #120-001 | Base Long | 3D print | 1 | |
| #120-002 | 133 × 12.6 × 3.2 mm CF strake | Fabricate | 3 | dragonplate.com pID=697 |
| #120-003 | 107 mm M3 all-thread | Fabricate | 3 | |
| #620-006 | 6810 bearing | Off the shelf | 2 | one per Base row |
| #660-002 | M3 nuts | Off the shelf | 7 (+ clamp hardware) | Recompute against the doubled clamp |
| #642-004 | M3 × 20 mm socket head screw | Off the shelf | 1 (+1 for 2nd clamp) | |
| #670-003 | #6 washers | Off the shelf | 3 | |

*(The previous version's #111-001 Foot ×6 and #111-002 aluminum strake ×6 are removed, replaced by the Base Mounting
Plate.)*

## 007.3 Harmonic Drive Motors
Builds the **base (J1)** and **pivot (J2)** motor assemblies — 2 of the 3 strain-wave drives (the 3rd is in
[007.8](#0078-external-gear)). Quantities are **per motor** (×2). `[Specified]` except the strain-wave set
(`[TBD]`, see above).

| PBS # | Part | Type | Qty (per motor) | Notes |
|---|---|---|---|---|
| #311-001 / #312-001 | Motor End Cap (Base / Pivot) | 3D print | 1 | |
| #610-001 | NEMA-17 stepper, 0.9°/step | Off the shelf | 1 | |
| #620-006 | 6810 bearing | Off the shelf | 1 | |
| #630-001 | **Flex Spline** | Special order | 1 | `[TBD]` [DC-1](009-Design-Completion.md#strain-wave-component-set) |
| #630-002 | **Wave Generator** | Special order | 1 | `[TBD]` [DC-1](009-Design-Completion.md#strain-wave-component-set) |
| #630-003 | **Stator Gear** | Special order | 1 | `[TBD]` [DC-1](009-Design-Completion.md#strain-wave-component-set) |
| #630-004 | Wave Gen Coupler | 3D print | 1 | |
| #630-005 | Flex Spline Attach | 3D print | 1 | |
| #630-006 | Flex Spline Cap | 3D print | 1 | |
| #641-002 | M2 × 12 mm bolts | Off the shelf | 6 | |
| #641-003 | M2 × 20 mm bolts | Off the shelf | 4 | |
| #642-003 | M3 × 12 mm socket head screws | Off the shelf | 6 | |
| #642-006 | M3 × 8 mm hex cap bolt | Off the shelf | 2 | |
| #660-001 | M2 nuts | Off the shelf | 10 | |
| #670-001 | M2 washers | Off the shelf | 4 | |
| #670-003 | #6 washers | Off the shelf | 4 | |

## 007.4 Main Pivot
J2 shoulder structure ([004](004-Mechanical-Architecture.md#main-pivot-j2-and-arm-body-j3-support--l2)).
`[Specified]`.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #300-001 | Main Pivot (printed body) | 3D print | 1 | |
| #300-002 | Pivot Code Disk | 3D print | 1 | |
| #300-003 | 126 × 12.6 × 3.2 mm CF strake | Fabricate | 4 | dragonplate.com pID=697. Contributes to L1 (+6.6 mm); this specification attributes the L1 delta to the doubled Base Clamp, not a strake change |
| #300-004 | 146 × 12.6 × 3.2 mm CF strake | Fabricate | 4 | dragonplate.com pID=697 |
| #660-002 | M3 nuts | Off the shelf | 5 | |

Also consumes the two motor assemblies from [007.3](#0073-harmonic-drive-motors), a 6810 bearing, and the
Base Code Disk / Base Stator Holder from [007.2](#0072-base) — see [008.4](008-Assembly.md#0084-main-pivot).

## 007.5 Arm Body
L2 span (J2→J3) plus belt-director sub-unit. `[Provisional]` — the L2 tube length is specific to this version.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #200-001 | Arm Body (printed) | 3D print | 1 | Also referenced by the glue rig |
| #200-002 | Pivot Stator Holder | 3D print | 1 | |
| #200-003 | Stator Balancer | 3D print | 4 | |
| #200-005 | 1" CF square tube | Fabricate | 1 | **This span is L2 (+18.4 mm versus the previous version). Cut length `[Provisional]`: 282.4 mm (264 mm + 18.41 mm; delta falls in the tube if the socket seat is unchanged). The printed body is renumbered — confirm socket seat vs CAD before cutting — [DC-5](009-Design-Completion.md#link-member-lengths).** |
| #200-006 | Calibration Arrows | 3D print | 2 | |
| #620-006 | 6810 bearing | Off the shelf | 1 | |
| #210-001 | Belt Director Caps | 3D print | 3 | |
| #210-002 | Belt Director Pulley | 3D print | 1 | |
| #210-003 | Idler Plug | 3D print | 1 | |
| #210-004 | Small Belt Director | Fabricate | 2 | |
| #210-005 | Large Belt Director | Fabricate | 1 | |
| #620-001 | MR85 bearing | Off the shelf | 1 | |
| #620-002 | MR128 bearing | Off the shelf | 6 | |
| #641-003 | M2 × 20 mm bolt | Off the shelf | 1 | |
| #660-001 | M2 nut | Off the shelf | 1 | |
| #670-001 | M2 washer | Off the shelf | 1 | |

The belt directors are part of the J4/J5 drive path whose **net reduction must be 13.5:1**
([DC-3](009-Design-Completion.md#wrist-reduction-ratio)); the tooth-count split across the directors and
End Arm Hub pulleys is the open part. Verify wrist resolution empirically after build.

## 007.6 Differential
J4/J5 wrist. `[Provisional]` — the previous version's differential is built as a working substitute pending the
differential detail design ([DC-2](009-Design-Completion.md#differential-detail-design)); its flex/pivot
geometry carries the tool wiring through its bore, so it is not a good candidate to guess at.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #710-001 | Split Gear Top | 3D print | 1 | |
| #710-002 | Split Gear Bottom | 3D print | 1 | |
| #710-003 | Diff Keeper | 3D print | 2 | |
| #710-004 | Rotate Code Disk | 3D print | 1 | |
| #710-005 | 25 × 5.6 × 2.5 mm CF strake | Fabricate | 3 | dragonplate.com carbon-strip-rectangle-092 |
| #710-006 | AXK0819 thrust bearing (1/4") | Off the shelf | 1 | |
| #710-007 | AS thrust races | Off the shelf | 2 | |
| #720-001 | Diff Gear Shaft | 3D print | 1 | |
| #720-002 | Diff Gear Axle | 3D print | 1 | |
| #720-003 | Diff End Pulley | 3D print | 1 | |
| #720-005 | 60 × 4.4 × 1.5 mm CF strake | Fabricate | 5 | dragonplate.com pID=693 |
| #720-006 | 96 × 8 × 6 mm CF rod | Fabricate | 1 | |
| #730-001 | Diff Body A | 3D print | 1 | |
| #730-002 | Diff Body B | 3D print | 1 | |
| #620-001 | MR85 bearing | Off the shelf | 1 | |
| #620-002 | MR128 bearing | Off the shelf | 2 | |
| #620-003 | 6703 bearing | Off the shelf | 5 | |
| #620-004 | 6705 bearing | Off the shelf | 1 | |
| #642-005 | M3 × 6 mm set screws | Off the shelf | 3 | |
| #680-001 | 1" #19 finishing nail | Off the shelf | 4 | Locking dowels |

Consumables: cyanoacrylate, hot glue, a small zip tie, epoxy.

## 007.7 End Arm Hub
L3 span (J3→J4), axis intersection, internal/external pulleys. `[Provisional]` — the L3 tube length is
specific to this version.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #410-001 | Axis Intersection Half | 3D print | 2 | Also referenced by the glue rig |
| #410-002 | New Belt Pulley | 3D print | 1 | |
| #410-003 | End Arm Code Disk | 3D print | 1 | |
| #410-004 | 45 × 5.6 × 2.5 mm CF strake | Fabricate | 2 | dragonplate.com pID=695 |
| #410-005 | 48 × 5.6 × 2.5 mm CF strake | Fabricate | 2 | dragonplate.com pID=695 |
| #410-006 | M3 × 107 mm all-thread | Fabricate | 4 | |
| #420-001 | End Arm Hub (printed) | 3D print | 1 | Also referenced by the glue rig |
| #420-002 | End Arm Hub Cap | 3D print | 1 | |
| #420-003 | 0.75" CF square tube | Fabricate | 1 | **This span is L3 (−22.7 mm versus the previous version). Cut length `[Provisional]`: 214.3 mm (237 mm − 22.70 mm; delta falls in the tube if the socket seat is unchanged). The printed body is renumbered — confirm socket seat vs CAD before cutting — [DC-5](009-Design-Completion.md#link-member-lengths).** |
| #421-001 | Internal Outer Pulley | 3D print | 1 | |
| #421-002 | Internal Inner Pulley | 3D print | 1 | |
| #421-003 | 113 × 8 × 6 mm stainless steel rod | Fabricate | 1 | |
| #421-004 | 81 × 4.4 × 1.5 mm CF strake | Fabricate | 3 | dragonplate.com carbon-strip-rectangle-057 |
| #421-005 | 90 cm × 6 mm GT2 belt | Off the shelf | 2 | |
| #421-006 | Pulley Spacer | 3D print | 2 | |
| #430-001 | External Outer Pulley | 3D print | 1 | |
| #430-002 | External Inner Pulley | 3D print | 1 | |
| #430-004 | 112 cm × 6 mm GT2 belt | Off the shelf | 2 | |
| #620-002 | MR128 bearing | Off the shelf | 2 | |
| #620-003 | 6703 bearing | Off the shelf | 3 | |
| #620-005 | 6807 bearing | Off the shelf | 2 | |
| #620-001 | MR85 bearing | Off the shelf | 1 | |
| #642-005 | M3 × 6 mm set screws | Off the shelf | 6 | |
| #660-002 | M3 nuts | Off the shelf | 18 | |
| #670-002 | M3 washers | Off the shelf | 8 | |

## 007.8 External Gear
Builds the **3rd strain-wave drive (J3 elbow)** plus the external gear housing. `[Specified]` except the
strain-wave set (`[TBD]`, see above).

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #510-001 | External Gear (printed) | 3D print | 1 | |
| #510-002 | 132 cm × 9 mm GT2 belt | Off the shelf | 2 | |
| #511-001 | Ex Gear Motor End Cap | 3D print | 1 | |
| #511-002 | Ex Gear Stator Holder | 3D print | 1 | |
| #511-003 | 73 × 12.6 × 3.2 mm CF strake | Fabricate | 3 | dragonplate.com carbon-strip-rectangle-125 |
| #610-001 | NEMA-17 stepper | Off the shelf | 1 | |
| #620-006 | 6810 bearing | Off the shelf | 2 | |
| #630-001/2/3 | **Flex Spline / Wave Generator / Stator Gear** | Special order | 1 each | `[TBD]` [DC-1](009-Design-Completion.md#strain-wave-component-set) |
| #630-004 | Wave Gen Coupler | 3D print | 1 | |
| #630-005 | Flex Spline Attach | 3D print | 1 | |
| #630-006 | Flex Spline Cap | 3D print | 1 | |
| #641-002 | M2 × 12 mm bolts | Off the shelf | 6 | |
| #641-003 | M2 × 20 mm bolts | Off the shelf | 4 | |
| #642-003 | M3 × 12 mm socket head screws | Off the shelf | 6 | |
| #642-006 | M3 × 8 mm hex cap bolt | Off the shelf | 2 | |
| #660-001 | M2 nuts | Off the shelf | 10 | |
| #660-002 | M3 nuts | Off the shelf | 6 | |
| #670-001 | M2 washers | Off the shelf | 4 | |
| #670-003 | #6 washers | Off the shelf | 4 | |

## 007.9 External Gear Mount + Differential Motors
Mounts the two plain **J4/J5 (angle + rotate) steppers** that drive the differential. `[Specified]`.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #520-001 | Ex Gear Mount (printed) | 3D print | 1 | Also referenced by the glue rig |
| #520-002 | Ex Gear Mount Top | 3D print | 1 | |
| #520-003 | Nut Holder A | 3D print | 1 | |
| #520-004 | Nut Holder B | 3D print | 1 | |
| #520-005 | M3 × 46 mm all-thread | Fabricate | 2 | |
| #520-006 | 1" × 68 mm CF square tube | Fabricate | 1 | Also referenced by the glue rig |
| #620-006 | 6810 bearing | Off the shelf | 1 | |
| #642-003 | M3 × 12 mm socket head screws | Off the shelf | 4 | |
| #660-002 | M3 nuts | Off the shelf | 4 | |
| #670-003 | #6 washers | Off the shelf | 2 | |
| #610-001 | NEMA-17 stepper (angle + rotate) | Off the shelf | 2 | Plain steppers, no strain-wave drive |
| #642-004 | M3 × 8 mm bolts | Off the shelf | 8 | |
| #670-002 | M3 washers | Off the shelf | 8 | |
| #6A0-001 | 16T × 5 mm GT2 pulley (motor) | Off the shelf | 2 | Motor pulley (retained). The **driven** side must net **13.5:1** — do not reuse the previous version's 90T set, which gives 5.625:1 and a 2.4× wrist error ([DC-3](009-Design-Completion.md#wrist-reduction-ratio)) |

## 007.10 Wire Harness
Electronics and connectorization ([005](005-Electronics-and-Control.md)). `[Provisional]` — reuses the
previous version's Motor Control PCB ([DC-7](009-Design-Completion.md#motor-control-pcb)); the White-wire
assignment is this version's change; the power supply rating is `[TBD]`
([DC-8](009-Design-Completion.md#power-supply)).

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #800-001/002 | Wire Entry Left / Right | 3D print | 1 each | |
| #800-003/004 | Main Pivot Plug A / B | 3D print | 1 each | |
| #800-005 | Fan Bracket | 3D print | 1 | |
| #800-006 | PCB Bracket | 3D print | 2 | |
| #800-007 | PCB Spacer | 3D print | 4 | |
| #800-008 | End Effector Wire Set | Off the shelf | 1 m each | Black, Red, Blue, White, Green, Yellow, 28 AWG — **White is a 2nd ground** ([005](005-Electronics-and-Control.md#tool-interface-wiring)) |
| #642-002 | M3 × 20 mm bolts | Off the shelf | 4 | |
| #651-001 | **Motor Control Board** | Fabricate | 1 | `[Provisional]` — the previous version's board (D3/D4-corrected), gerbers in `Hardware/Motor PCB/` ([DC-7](009-Design-Completion.md#motor-control-pcb)) |
| #651-002 | **FPGA Board (MicroZed)** | Off the shelf | 1 | Confirm module P/N via wiki `MicroZed` |
| #651-003 | Optical Board | Fabricate | 5 | One per joint encoder; gerbers/BOM in `Hardware/Opto/` |
| #652-001 | Fan | Off the shelf | 1 | |
| #652-002 | LED | Off the shelf | 10 | Digikey LTE-4206 |
| #652-003 | Phototransistor | Off the shelf | 10 | Digikey LTR-4206E |
| #652-004 | 2-pin connector | Off the shelf | 1 | |
| #652-005 | 6-pin connector | Off the shelf | 10 | |
| #652-006 | EEIO connector | Off the shelf | 1 | |
| #652-007 | Square pins | Off the shelf | 6 | |
| #680-001 | 1" #19 finishing nail | Off the shelf | 7 | Opto-board alignment dowels |
| #810-001/002 | 6-pin strain relief top / bottom | 3D print | as needed | |
| #821–825 | Photointerrupter shrouds (base/pivot/end/angle/rotate) | 3D print | per joint | |
| #830-001/002 | Solder jigs (6-pin holder, LED rig) | 3D print | 2 / 1 | |
| #840-001 | Power connector wires | Off the shelf | 244 cm | Red + black, 24 AWG |
| #840-002 | Power connector | Off the shelf | 1 | |
| #650-001 | **Power Supply** | Off the shelf | 1 | **36 V DC, 4 A (≈144 W)** laptop-style brick with matching barrel/DC plug ([DC-8](009-Design-Completion.md#power-supply)). Board rated 38 V; do not substitute a 12/24 V brick (stalls, home-find failure) |

## 007.11 Tool Interface / Gripper
2-axis roll + grip; cross-version compatible. `[Specified]`.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #900-001 | Tool Interface Body | 3D print | 1 | |
| #900-002 | 3-pin connector | Off the shelf | 1 | Made from a cut 6-pin connector |
| #610-002 | Dynamixel XL-320 servo | Off the shelf | 2 | Roll + span axes |
| #641-002 | M2 × 16 mm bolts | Off the shelf | 4 | |
| — | M3 × 10 mm bolts | Off the shelf | 3 | |
| #660-001 | M2 nuts | Off the shelf | 4 | |
| #660-002 | M3 nuts | Off the shelf | 3 | |
| #911-001 | Roll Body | 3D print | 1 | |
| #911-002 | Roll Driver | 3D print | 1 | |
| #620-003 | 6703 bearing | Off the shelf | 2 | |
| #641-001 | M2 × 12 mm bolts | Off the shelf | 2 | |
| #641-003 | M2 × 20 mm bolts | Off the shelf | 4 | |
| #660-001 | M2 nuts | Off the shelf | 6 | |
| #670-001 | M2 washers | Off the shelf | 6 | |
| #912-001 | Span Mount | 3D print | 1 | |
| #912-002 | Span Driver | 3D print | 1 | |
| #912-003 | 28 × 5.6 × 2.5 mm CF strake | Fabricate | 1 | dragonplate.com pID=695 |
| #920-001 | Static Finger | 3D print | 1 | |
| #920-002 | Dynamic Finger | 3D print | 1 | |
| #920-003 | Finger Cap | 3D print | 1 | |
| #920-004 | MR128 bearing | Off the shelf | 2 | |
| #641-002 | M2 × 16 mm bolts | Off the shelf | 1 | |
| #670-001 | M2 washers | Off the shelf | 1 | |

Optional alternates (baseline build qty 0): Parallel/3-Prong fingers, A6 Torque Link, skin/board brackets,
gripper wire cover. Two pieces of yoga mat provide the finger grip pads.

---

## Aggregate hardware quantities (whole robot)

Totals reflect the current design (doubled Base Clamp; the previous version's feet/aluminum strakes
removed; excludes the `[TBD]` Base Mounting Plate hardware). No slack included — order in excess.

| Part | Total |
|---|---|
| M2 nuts | 43 |
| M3 nuts | 43 (+ doubled-clamp hardware) |
| M2 washers | 22 |
| M3 washers | 16 |
| M2 × 12 mm bolts | 22 |
| M2 × 16 mm bolts | 5 |
| M2 × 20 mm bolts | 17 |
| M3 × 12 mm socket head screws | 22 |
| M3 × 6 mm set screws | 9 |
| M3 × 8 mm bolts | 10 |
| M3 × 8 mm hex cap bolt | 6 |
| #6 washers | 14 |
| 6703 bearing | 12 |
| 6810 bearing | 7 |
| MR128 bearing | 15 |
| MR85 bearing | 3 |
| 6705 / 6807 bearing | 1 / 2 |
| NEMA-17 stepper (0.9°/step) | 5 |
| Strain-wave component sets (flex spline / wave generator / stator gear) | 3 each — `[Provisional]` (HanZhen #14 / Cone Drive) |
| Power supply, 36 V / 4 A DC brick | 1 |
| Dynamixel XL-320 servo | 2 |
| Optical Board | 5 |
| 6-pin connector | 10 |
| 1" #19 finishing nail | 11 |

## Sourcing notes

- **CF strakes/tubes** — pultruded carbon-fiber from Dragonplate.com (pIDs in the tables) or any equivalent
  supplier of matching cross-section. Confirm the L2/L3 lengths ([DC-5](009-Design-Completion.md#link-member-lengths))
  before cutting.
- **Bearings** — standard metric trade sizes (68xx/67xx/MRxxx); source by ID/OD/width from any supplier.
- **Strain-wave sets** — the long-lead, high-risk item ([DC-1](009-Design-Completion.md#strain-wave-component-set));
  the part is the **HanZhen "number 14" 52:1 set** (email direct; 9–12 wk lead) or the Cone Drive
  equivalent — start vendor contact first.
- **Motor Control / Opto PCBs** — fabricate from gerbers in `Hardware/Motor PCB/` (`09051-00135-A`) and
  `Hardware/Opto/`.
- **MicroZed** — confirm the SoM part number (wiki `MicroZed`) before ordering.
- **Power supply** — a **36 V / 4 A** laptop-style DC brick ([DC-8](009-Design-Completion.md#power-supply));
  the board is rated 38 V. Do not use a 12/24 V brick.
- **Base Mounting Plate** — 6061-T6 aluminium, 9.5 mm, ≈200 × 200 mm; transfer the robot-side hole pattern
  from the Base Mount Bottom CAD ([DC-4](009-Design-Completion.md#base-plate)).
- **Wrist driven pulleys** — must net 13.5:1, not the previous version's 90/16 (5.625:1)
  ([DC-3](009-Design-Completion.md#wrist-reduction-ratio)).
