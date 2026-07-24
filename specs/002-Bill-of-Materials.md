# 002 - Bill of Materials (Dexter HDI)

## Verification status
No structured Product Breakdown Structure or BOM spreadsheet for Dexter HDI exists in any source consulted for
this spec set (see [001-Overview.md](001-Overview.md) for what was checked). This BOM is therefore built from the
upstream **"Dexter HD - Product Breakdown Structure (WIP)"** Google Sheet — the best-documented physical parts
list available for this arm architecture — with every row that is known, from a real HDI-specific source, to
differ marked and corrected. Rows with no known HDI-specific source are carried over from the HD PBS unchanged and
marked **INHERITED FROM HD, UNCONFIRMED FOR HDI**. Sections proposing a design where none exists upstream are
marked **FORK PROPOSAL** (see [001-Overview.md](001-Overview.md#verification-status) for what that means).

The HD PBS spreadsheet itself carries this disclaimer verbatim:
> SOME HARDWARE MAY BE MISSING. IF YOU'RE USING THIS AS A BOM TO BUILD A DEXTER, ORDER IN EXCESS.

That applies here even more strongly than it did for the HD-targeted draft of this spec: treat every row as "best
available data," not a verified-complete parts order, and treat every FORK PROPOSAL row as a first-draft design
that has not been built. Sections are numbered to match the corresponding assembly steps in
[003-Assembly.md](003-Assembly.md).

**Do not use** the older "Base Assembly Parts List" spreadsheet (the one titled with "Total Bots: 40") for this
build — that sheet is for the original **Dexter 1** contest-kit generation (PLA parts, different joint design)
and its part numbers do not correspond to the PBS numbers used here.

## Why the HD PBS is still the right baseline for HDI
Confirmed by direct evidence, not assumption (see [001-Overview.md](001-Overview.md) and
[004-Firmware-and-Calibration.md](004-Firmware-and-Calibration.md) for sourcing):
- The `AxisCal` values for joints 1-3 are byte-for-byte identical between HD and HDI firmware defaults, confirming
  the harmonic-drive-geared joints (base, pivot, external gear) use the same 52:1 Cone Drive gearing in both
  generations.
- The Tool Interface Fusion 360 CAD model is explicitly cross-compatible across Dexter 1, HD, and HDI per
  `official/README.md`, and `LinkLengths` L5 (tool interface + end effector) is identical between HD and HDI.
- The wiki documents HDI deltas as *changes from* the HD design (differential "improvement," base "instead of"
  HD's legs, wiring "instead of" HD's extra line) rather than as an unrelated architecture — i.e., HDI is
  described everywhere as a revision of HD, not a different robot.

## Critical gap: harmonic drive components are not fully specified upstream (unchanged for HDI)
Across every subassembly that uses a harmonic (strain-wave) drive, three components are flagged in the source HD
PBS with **STATUS = "N - NOT DESIGNED"** and **PROJECT OWNER = "YOU : CONCEPT"**:

- `FLEX SPLINE`
- `WAVE GENERATOR`
- `STATOR GEAR`

This is not a data-entry gap — it reflects that Haddington Dynamics never committed these to a specific, orderable
part number in the public BOM, for HD **or** HDI. The wiki's Hardware page separately states the drives were
originally sourced from HanZhen (hanzh.com) as an unlisted, special-order "number 14 component gear set, 52:1
ratio," with a 9-12 week lead time, and that production later moved to **Cone Drive (USA)** (see
https://conedrive.com/products/harmonic-2/ — this is also why the upstream branch is named
`Stable_2020_02_04_ConeDrive`). The factory HDI calibration PDFs (see
[004-Firmware-and-Calibration.md](004-Firmware-and-Calibration.md#0043-factory-calibration-procedure-from-scratch-builds-only))
independently confirm Cone Drive harmonic drives are used on production HDI units — their maintenance note reads
*"Cone drive lubricant needs to be replaced after 100 hours and again at 2000 hours."* Three drives are required
per robot (2 for the base/pivot motors, 1 for the external-gear motor — see [002.3](#0023-harmonic-drive-motors)
and [002.8](#0028-external-gear)).

**OPEN QUESTION before ordering:** Contact Cone Drive directly to get current pricing, lead time, and an equivalent
part number for the "component gear set" configuration (bare flex spline + wave generator + circular/stator gear,
not a housed unit) at a 52:1 ratio compatible with the existing 3D-printed mounts. This is the single
highest-risk, longest-lead-time item in the whole build — start this conversation before ordering anything else.
This fork treats it as an open question rather than a proposal because a wrong physical harmonic-drive geometry
is not something a first-draft design can safely guess at; get a real part number from the vendor.

## Subassembly summary (build order)

| # | Subassembly | PBS letter(s) | HDI status |
|---|---|---|---|
| [002.1](#0021-glue-rig-assembly) | Glue Rig Assembly | F | Inherited from HD, unconfirmed |
| [002.2](#0022-base) | Base | A | **FORK PROPOSAL** — bolted base + double base clamp, redesigned from HD's 6-leg strake base |
| [002.3](#0023-harmonic-drive-motors) | Harmonic Drive Motors | D | Inherited from HD (confirmed unchanged via `AxisCal`) |
| [002.4](#0024-main-pivot) | Main Pivot | C | Inherited from HD; strake lengths flagged for L1 delta |
| [002.5](#0025-arm-body) | Arm Body | B | Inherited from HD; strake/tube lengths flagged for L2 delta |
| [002.6](#0026-differential) | Differential | H | Inherited from HD; wiki says HDI version is "significantly improved" but undocumented — see gap note |
| [002.7](#0027-end-arm-hub) | End Arm Hub | E | Inherited from HD; strake lengths flagged for L3 delta |
| [002.8](#0028-external-gear) | External Gear | G | Inherited from HD (confirmed unchanged via `AxisCal`) |
| [002.9](#0029-external-gear-mount--differential-motors) | External Gear Mount + Differential Motors | I | Inherited from HD, unconfirmed |
| [002.10](#00210-wire-harness) | Wire Harness | J | Inherited from HD, with a confirmed wiring-assignment change and a **FORK PROPOSAL** to reuse the HD Motor Control PCB |
| [002.11](#00211-tool-interface--gripper) | Tool Interface / Gripper | K, L, M, N, O | Inherited from HD; confirmed cross-generation compatible |

---

## 002.1 Glue Rig Assembly
A fixture used to hold parts square while epoxy cures; not a permanent part of the robot. **INHERITED FROM HD,
UNCONFIRMED FOR HDI** — no HDI-specific source discusses jigging. Reuses one each of several printed parts and CF
tubes that are also listed in their "real" subassemblies below (order the extra quantity, don't double order). If
the [002.2 Base](#0022-base) FORK PROPOSAL below is adopted, the glue-rig steps that jig the HD foot/strake base
do not apply — see [003.1](003-Assembly.md#0031-glue-rig-assembly).

| Part | Qty | Notes |
|---|---|---|
| Arm Body (printed) | 1 | Shared with [002.5](#0025-arm-body) |
| 1" x 264mm CF square tube | 1 | Shared with [002.5](#0025-arm-body) — **VERIFY length against the L2 delta note there before cutting** |
| Axis Intersection Half (printed) | 2 | Shared with [002.7](#0027-end-arm-hub) |
| End Arm Hub (printed) | 1 | Shared with [002.7](#0027-end-arm-hub) |
| 0.75" x 237mm CF square tube | 1 | Shared with [002.7](#0027-end-arm-hub) — **VERIFY length against the L3 delta note there before cutting** |
| Ex Gear Mount (printed) | 1 | Shared with [002.9](#0029-external-gear-mount--differential-motors) |
| 1" x 68mm CF square tube | 1 | Shared with [002.9](#0029-external-gear-mount--differential-motors) |
| 6703 bearing | 2 | Shared |

## 002.2 Base
PBS letter **A**. #100-000 through #120-003 in the HD PBS numbering, reused here where unaffected.

**FORK PROPOSAL.** Wiki `Dynamics.md` states two confirmed, load-bearing differences from HD (VERIFIED, quoted
directly): *"Double base clamp (affects the link lengths and overall height of every z measurements)"* and
*"Bolted base instead of 6 legged aluminum strake base."* No upstream source gives a bolted-base part list or
drawing, so this section proposes one. Reasoning: the `LinkLengths` L1 delta (HD 228600 µm → HDI 235200 µm, +6.6mm,
see [004-Firmware-and-Calibration.md](004-Firmware-and-Calibration.md#link-length-deltas-and-what-they-imply-for-structural-members))
is consistent with a second stacked Base Clamp adding height at the base-to-Main-Pivot joint — so this proposal
doubles the Base Clamp part rather than inventing an unrelated clamp redesign. The bolted base replaces the HD
foot+strake subassembly with a printed baseplate bolted directly to a work surface, consistent with the wiki
`Dexter-Setup.md` unpacking instructions' existing guidance that the base "must be mounted to a stable surface by
... screwing, or clamping" — HDI's design is read here as making that the primary mounting method rather than an
owner option layered on top of free-standing legs.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #100-001 | Base Clamp | 3D print | **2** (was 1 on HD) | FORK PROPOSAL: doubled per "double base clamp," stacked at the Base Mount/Main Pivot joint |
| #100-002 | Base Code Disc | 3D print | 1 | Inherited from HD |
| #100-003 | Pivot Skirt | 3D print | 1 | Inherited from HD |
| #110-001 | Base Mount Bottom | 3D print | 1 | Inherited from HD |
| #110-002 | Base Stator Holder | 3D print | 1 | Inherited from HD |
| #110-003 | 133mm x 12.6mm x 3.2mm CF strake | Fabricate | 3 | Inherited from HD; dragonplate.com pID=697 |
| ~~#111-001~~ | ~~Foot~~ | ~~3D print~~ | ~~6~~ | **Removed for HDI** — replaced by baseplate row below |
| ~~#111-002~~ | ~~165mm x 20mm x 5mm aluminum strake~~ | ~~Fabricate~~ | ~~6~~ | **Removed for HDI** — replaced by baseplate row below |
| — | **Base Mounting Plate** | 3D print or machine (FORK PROPOSAL) | 1 | New part, not in any upstream source. Flat plate replacing the 6-leg foot/strake assembly; bolts directly to Base Mount Bottom in place of the 6 Feet, and bolts through to the work surface. **OPEN QUESTION**: exact bolt pattern, plate material (printed Onyx likely under-strength for a bolted-through base carrying the full arm's dynamic load — aluminum or steel plate recommended), and thickness are undesigned; treat as a placeholder to engineer, not a buildable part, until confirmed against the `cfry/dde`-hosted HDI kinematic model or Haddington Dynamics' private HDI documentation (referenced in the `Stable_Conedrive` branch README as sent to purchasers). |
| — | Base mounting bolts (to work surface) | Off the shelf (FORK PROPOSAL) | 4-6, size TBD | Depends on Base Mounting Plate bolt pattern above and the target work surface — no fixed count until that part is engineered |
| #120-001 | Base Long | 3D print | 1 | Inherited from HD |
| #120-002 | 133mm x 12.6mm x 3.2mm CF strake | Fabricate | 3 | Inherited from HD; dragonplate.com pID=697 |
| #120-003 | 107mm M3 all-thread | Fabricate | 3 | Inherited from HD |
| #620-006 | 6810 bearing | Off the shelf | 2 | one per Base row (#100, #120) |
| #660-002 | M3 nuts | Off the shelf | 7, **+ however many the doubled Base Clamp needs** | Recompute against the doubled #100-001 row |
| #642-004 | M3 x 20mm socket head screw | Off the shelf | 1, **+ 1 for second clamp** | Recompute against the doubled #100-001 row |
| #670-003 | #6 washers | Off the shelf | 3 | Inherited from HD |

## 002.3 Harmonic Drive Motors
PBS letter **D**. Builds the **base motor** and **pivot motor** — 2 of the robot's 3 harmonic-drive assemblies. The
3rd is built as part of [002.8 External Gear](#0028-external-gear). Each of the two rows below is one complete
motor+drive assembly; quantities are **per motor** (multiply by 2 for this subassembly's total). **Inherited from
HD; confirmed unchanged for HDI** via the identical J1-J3 `AxisCal` values (see gap note above).

| PBS # | Part | Type | Qty (per motor) | Notes |
|---|---|---|---|---|
| #311-001 / #312-001 | Motor End Cap (Base / Pivot variant) | 3D print | 1 | |
| #610-001 | NEMA-17 stepper motor, 0.9°/step | Off the shelf | 1 | |
| #620-006 | 6810 bearing | Off the shelf | 1 | |
| #630-001 | **Flex Spline** | Off the shelf | 1 | **NOT DESIGNED upstream — see gap note above** |
| #630-002 | **Wave Generator** | Off the shelf | 1 | **NOT DESIGNED upstream — see gap note above** |
| #630-003 | **Stator Gear** | Off the shelf | 1 | **NOT DESIGNED upstream — see gap note above** |
| #630-004 | Wave Gen Coupler | 3D print | 1 | |
| #630-005 | Flex Spline Attach | 3D print | 1 | |
| #630-006 | Flex Spline Cap | 3D print | 1 | |
| #641-002 | M2 x 12mm bolts | Off the shelf | 6 | |
| #641-003 | M2 x 20mm bolts | Off the shelf | 4 | |
| #642-003 | M3 x 12mm socket head screws | Off the shelf | 6 | |
| #642-006 | M3 x 8mm hex cap bolt | Off the shelf | 2 | |
| #660-001 | M2 nuts | Off the shelf | 10 | |
| #670-001 | M2 washers | Off the shelf | 4 | |
| #670-003 | #6 washers | Off the shelf | 4 | |

## 002.4 Main Pivot
PBS letter **C**. Inherited from HD.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #300-001 | Main Pivot (printed body) | 3D print | 1 | |
| #300-002 | Pivot Code Disk | 3D print | 1 | |
| #300-003 | 126mm x 12.6mm x 3.2mm CF strake | Fabricate | 4 | dragonplate.com pID=697. **VERIFY**: this span contributes to `LinkLengths` L1, which is +6.6mm on HDI — see [002.2 Base](#0022-base) FORK PROPOSAL; this fork attributes that delta to the doubled Base Clamp, not to a Main Pivot strake-length change, but has not confirmed this against a physical build |
| #300-004 | 146mm x 12.6mm x 3.2mm CF strake | Fabricate | 4 | dragonplate.com pID=697 |
| #660-002 | M3 nuts | Off the shelf | 5 | |

Note: assembly of the Main Pivot also consumes the two harmonic-drive motor assemblies from
[002.3](#0023-harmonic-drive-motors), plus a 6810 bearing and Base Code Disk/Base Stator Holder pulled from
[002.2](#0022-base) — see [003.4](003-Assembly.md#0034-main-pivot) for how these come together.

## 002.5 Arm Body
PBS letter **B**. Includes the belt director sub-unit. Inherited from HD, with one flagged length.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #200-001 | Arm Body (printed) | 3D print | 1 | Also referenced by the glue rig |
| #200-002 | Pivot Stator Holder | 3D print | 1 | |
| #200-003 | Stator Balancer | 3D print | 4 | |
| #200-005 | 1" x 264mm CF square tube | Fabricate | 1 | Also referenced by the glue rig. **This span is `LinkLengths` L2, which is +18.4mm on HDI (320676→339092 µm). FORK PROPOSAL: lengthen to ~282mm (264mm + 18.4mm) as a starting point; confirm against the HDI kinematic model before cutting — see [004-Firmware-and-Calibration.md](004-Firmware-and-Calibration.md#link-length-deltas-and-what-they-imply-for-structural-members).** |
| #200-006 | Calibration Arrows | 3D print | 2 | |
| #620-006 | 6810 bearing | Off the shelf | 1 | |
| #210-001 | Belt Director Caps | 3D print | 3 | |
| #210-002 | Belt Director Pulley | 3D print | 1 | |
| #210-003 | Idler Plug | 3D print | 1 | |
| #210-004 | Small Belt Director | Fabricate | 2 | |
| #210-005 | Large Belt Director | Fabricate | 1 | |
| #620-001 | MR85 bearing | Off the shelf | 1 | |
| #620-002 | MR128 bearing | Off the shelf | 6 | |
| #641-003 | M2 x 20mm bolt | Off the shelf | 1 | |
| #660-001 | M2 nut | Off the shelf | 1 | |
| #670-001 | M2 washer | Off the shelf | 1 | |

**OPEN QUESTION**: the belt directors and their pulleys are part of the J4/J5 resolution path where HD and HDI
firmware `AxisCal`/`Interpolation` values diverge (see
[004-Firmware-and-Calibration.md](004-Firmware-and-Calibration.md)). This spec set does not propose new pulley
tooth counts — see that spec for why — and instead recommends building this section as specified above and
verifying resolution/backlash empirically.

## 002.6 Differential
PBS letter **H**. Inherited from HD.

**Gap note (not a FORK PROPOSAL — flagged as OPEN QUESTION per the user-selected policy for high-risk mechanical
items)**: wiki `Differential-Joint.md` states, VERIFIED and quoted in full: *"Note: The HDI version of the
differential is a significant improvement over the HD version shown here."* No dimensions, STL files, or part
list for the HDI differential were found in `official/`, `official-wiki/`, `dde/`, or `zalo-gui/`. The `dde/`
repo's simulator code (`sim2/App.js`) references a mesh named `HDI_DiffSkins_v371`, confirming a distinct HDI
differential CAD assembly exists somewhere, but no dimensional data was recoverable from that reference alone.
This fork does **not** propose an original differential redesign — an incorrect flex/pivot geometry here risks
binding or premature wear in a joint that carries the full end-effector wiring bundle through its bore, and there
is not enough real information to design against. **Build the HD differential below as a working substitute**,
and treat locating Haddington Dynamics' private HDI differential documentation (referenced in the
`Stable_Conedrive` branch README as sent to purchasers) as a prerequisite to closing this gap properly.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #710-001 | Split Gear Top | 3D print | 1 | |
| #710-002 | Split Gear Bottom | 3D print | 1 | |
| #710-003 | Diff Keeper | 3D print | 1 | Two used in this subassembly total ("Diff Keeper" appears twice in build notes — confirm during build) |
| #710-004 | Rotate Code Disk | 3D print | 1 | |
| #710-005 | 25mm x 5.6mm x 2.5mm CF strake | Fabricate | 3 | dragonplate.com carbon-strip-rectangle-092 |
| #710-006 | AXK0819 bearing (1/4" thrust bearing) | Off the shelf | 1 | |
| #710-007 | AS thrust races | Off the shelf | 2 | |
| #720-001 | Diff Gear Shaft | 3D print | 1 | |
| #720-002 | Diff Gear Axle | 3D print | 1 | |
| #720-003 | Diff End Pulley | 3D print | 1 | |
| #720-005 | 60mm x 4.4mm x 1.5mm CF strake | Fabricate | 5 | dragonplate.com pID=693 |
| #720-006 | 96mm x 8mm x 6mm CF rod | Fabricate | 1 | |
| #730-001 | Diff Body A | 3D print | 1 | |
| #730-002 | Diff Body B | 3D print | 1 | |
| #620-001 | MR85 bearing | Off the shelf | 1 | |
| #620-002 | MR128 bearing | Off the shelf | 2 | |
| #620-003 | 6703 bearing | Off the shelf | 5 | (2 + 3 across split-gear and body rows) |
| #620-004 | 6705 bearing | Off the shelf | 1 | |
| #642-005 | M3 x 6mm set screws | Off the shelf | 3 | |
| #680-001 | 1" #19 finishing nail | Off the shelf | 4 | Used as a locking dowel, not a fastener into wood |

Consumables also needed here per the build notes: cyanoacrylate ("super") glue, hot glue, a small zip tie, and
epoxy — not tracked as PBS line items but required to complete this subassembly.

## 002.7 End Arm Hub
PBS letter **E**. Includes axis intersection, internal pulleys, and external pulleys. Inherited from HD, with one
flagged length.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #410-001 | Axis Intersection Half | 3D print | 2 | Also referenced by the glue rig |
| #410-002 | New Belt Pulley | 3D print | 1 | |
| #410-003 | End Arm Code Disk | 3D print | 1 | |
| #410-004 | 45mm x 5.6mm x 2.5mm CF strake | Fabricate | 2 | dragonplate.com pID=695 |
| #410-005 | 48mm x 5.6mm x 2.5mm CF strake | Fabricate | 2 | dragonplate.com pID=695 |
| #410-006 | M3 x 107mm all-thread | Fabricate | 4 | |
| #420-001 | End Arm Hub (printed) | 3D print | 1 | Also referenced by the glue rig |
| #420-002 | End Arm Hub Cap | 3D print | 1 | |
| #420-003 | 0.75" x 237mm CF square tube | Fabricate | 1 | Also referenced by the glue rig. **This span is `LinkLengths` L3, which is -22.7mm on HDI (330201→307500 µm). FORK PROPOSAL: shorten to ~214mm (237mm - 22.7mm) as a starting point; confirm against the HDI kinematic model before cutting — see [004-Firmware-and-Calibration.md](004-Firmware-and-Calibration.md#link-length-deltas-and-what-they-imply-for-structural-members).** |
| #421-001 | Internal Outer Pulley | 3D print | 1 | |
| #421-002 | Internal Inner Pulley | 3D print | 1 | |
| #421-003 | 113mm x 8mm x 6mm stainless steel rod | Fabricate | 1 | |
| #421-004 | 81mm x 4.4mm x 1.5mm CF strake | Fabricate | 3 | dragonplate.com carbon-strip-rectangle-057 |
| #421-005 | 90cm x 6mm GT2 belt | Off the shelf | 2 | |
| #421-006 | Pulley Spacer | 3D print | 2 | (1 internal + 1 external, same part number) |
| #430-001 | External Outer Pulley | 3D print | 1 | |
| #430-002 | External Inner Pulley | 3D print | 1 | |
| #430-004 | 112cm x 6mm GT2 belt | Off the shelf | 2 | |
| #620-002 | MR128 bearing | Off the shelf | 2 | |
| #620-003 | 6703 bearing | Off the shelf | 3 | |
| #620-005 | 6807 bearing | Off the shelf | 2 | |
| #620-001 | MR85 bearing | Off the shelf | 1 | |
| #642-005 | M3 x 6mm set screws | Off the shelf | 6 | |
| #660-002 | M3 nuts | Off the shelf | 18 | |
| #670-002 | M3 washers | Off the shelf | 8 | |

## 002.8 External Gear
PBS letter **G**. Builds the 3rd harmonic-drive motor assembly (the "external gear motor") plus the external gear
housing itself. **Inherited from HD; confirmed unchanged for HDI** via the identical J1-J3 `AxisCal` values.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #510-001 | External Gear (printed) | 3D print | 1 | |
| #510-002 | 132cm x 9mm GT2 belt | Off the shelf | 2 | |
| #511-001 | Ex Gear Motor End Cap | 3D print | 1 | |
| #511-002 | Ex Gear Stator Holder | 3D print | 1 | |
| #511-003 | 73mm x 12.6mm x 3.2mm CF strake | Fabricate | 3 | dragonplate.com carbon-strip-rectangle-125 |
| #610-001 | NEMA-17 stepper motor | Off the shelf | 1 | |
| #620-006 | 6810 bearing | Off the shelf | 2 | |
| #630-001 | **Flex Spline** | Off the shelf | 1 | **NOT DESIGNED upstream — see gap note above** |
| #630-002 | **Wave Generator** | Off the shelf | 1 | **NOT DESIGNED upstream — see gap note above** |
| #630-003 | **Stator Gear** | Off the shelf | 1 | **NOT DESIGNED upstream — see gap note above** |
| #630-004 | Wave Gen Coupler | 3D print | 1 | |
| #630-005 | Flex Spline Attach | 3D print | 1 | |
| #630-006 | Flex Spline Cap | 3D print | 1 | |
| #641-002 | M2 x 12mm bolts | Off the shelf | 6 | |
| #641-003 | M2 x 20mm bolts | Off the shelf | 4 | |
| #642-003 | M3 x 12mm socket head screws | Off the shelf | 6 | |
| #642-006 | M3 x 8mm hex cap bolt | Off the shelf | 2 | |
| #660-001 | M2 nuts | Off the shelf | 10 | |
| #660-002 | M3 nuts | Off the shelf | 6 | |
| #670-001 | M2 washers | Off the shelf | 4 | |
| #670-003 | #6 washers | Off the shelf | 4 | |

## 002.9 External Gear Mount + Differential Motors
PBS letter **I**. Inherited from HD, unconfirmed for HDI.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #520-001 | Ex Gear Mount (printed) | 3D print | 1 | Also referenced by the glue rig |
| #520-002 | Ex Gear Mount Top | 3D print | 1 | |
| #520-003 | Nut Holder A | 3D print | 1 | |
| #520-004 | Nut Holder B | 3D print | 1 | |
| #520-005 | M3 x 46mm all-thread | Fabricate | 2 | |
| #520-006 | 1" x 68mm CF square tube | Fabricate | 1 | Also referenced by the glue rig |
| #620-006 | 6810 bearing | Off the shelf | 1 | |
| #642-003 | M3 x 12mm socket head screws | Off the shelf | 4 | |
| #660-002 | M3 nuts | Off the shelf | 4 | |
| #670-003 | #6 washers | Off the shelf | 2 | |
| #610-001 | NEMA-17 stepper motor (angle + rotate) | Off the shelf | 2 | These are plain steppers, no harmonic drive |
| #642-004 | M3 x 8mm bolts | Off the shelf | 8 | |
| #670-002 | M3 washers | Off the shelf | 8 | |
| #6A0-001 | 16T x 5mm GT2 pulley | Off the shelf | 2 | |

## 002.10 Wire Harness
PBS letter **J**. Electronics and connectorization. Inherited from HD, with one confirmed wiring-assignment change
and one significant open item on the Motor Control Board.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #800-001 / #800-002 | Wire Entry Left / Right | 3D print | 1 each | |
| #800-003 / #800-004 | Main Pivot Plug A / B | 3D print | 1 each | |
| #800-005 | Fan Bracket | 3D print | 1 | |
| #800-006 | PCB Bracket | 3D print | 2 | |
| #800-007 | PCB Spacer | 3D print | 4 | |
| #800-008 | End Effector Wire Set | Off the shelf | 1m each | Black, Red, Blue, White, Green, Yellow, 28 AWG — **see wiring note below: the White wire is assigned differently on HDI** |
| #642-002 | M3 x 20mm bolts | Off the shelf | 4 | |
| #651-001 | **Motor Control Board** | Off the shelf / fabricate | 1 | **See "Motor Control Board" note below — this is the largest unresolved item in this section.** |
| #651-002 | **FPGA Board (MicroZed)** | Off the shelf | 1 | See wiki `MicroZed` page for exact carrier/SoM part numbers |
| #651-003 | Optical Board | Off the shelf | 5 | One per joint encoder; gerbers/BOM in `Hardware/Opto/` in this repo |
| #652-001 | Fan | Off the shelf | 1 | |
| #652-002 | LED | Off the shelf | 10 | Digikey LTE-4206 (see wiki Hardware page) |
| #652-003 | Phototransistor | Off the shelf | 10 | Digikey LTR-4206E (see wiki Hardware page) |
| #652-004 | 2-pin connector | Off the shelf | 1 | |
| #652-005 | 6-pin connector | Off the shelf | 10 | (2 per each of 5 opto/connector rows) |
| #652-006 | EEIO connector | Off the shelf | 1 | |
| #652-007 | Square pins | Off the shelf | 6 | |
| #680-001 | 1" #19 finishing nail | Off the shelf | 7 | Used as opto-board alignment dowels |
| #810-001 / #810-002 | 6-pin strain relief top / bottom | 3D print | as needed | |
| #821-002 / #821-003 | Base photointerrupter A / B | 3D print | 1 each | |
| #822-002 / #822-003 | Pivot photointerrupter A / B | 3D print | 1 each | |
| #823-002 | End Arm photointerrupter | 3D print | 1 | |
| #824-002 | Angle photointerrupter | 3D print | 1 | |
| #825-002 / #825-003 | Rotate photointerrupter A / B | 3D print | 1 each | |
| #830-001 | 6-pin holder (solder jig) | 3D print | 2 | |
| #830-002 | LED rig (solder jig) | 3D print | 1 | |
| #840-001 | Power connector wires | Off the shelf | 244cm | Red + black, 24 AWG |
| #840-002 | Power connector | Off the shelf | 1 | |
| #650-001 | **Power Supply** | Off the shelf | 1 | Voltage/current rating not specified in source BOM — **OPEN QUESTION**, check `Firmware`/wiki for motor driver voltage before selecting |

**Wiring assignment change (VERIFIED, wiki `End-Effectors.md`, "Version 2 Wiring" section)**: of the 6 signals
between the Motor Control PCB and Tool Interface, 5 are unchanged between HD and HDI (Black=ground, Red=+5V logic,
Yellow=unregulated supply power, Blue=servo data bus, Green=aux/return serial data). The White wire differs:

> "The Dexter HD has 1 additional wire which could be used for the servo power (6 - 8.75V) if we want to route
> that separately from the main supply power. On the HDI, it is used as a second ground wire via the 2nd from the
> top slot, labeled '-' on the small screw terminal on the side near the top of the motor board."

**This is a safety-relevant wiring difference, not just a labeling change** — on HD, White can carry a regulated
servo-power voltage (6-8.75V); on HDI, the same physical wire and terminal are repurposed as a second ground.
Connecting an HD wiring harness to an HDI-configured board (or vice versa) without re-checking this assignment
risks shorting logic ground to a power rail. Flagged again in [003.10](003-Assembly.md#00310-wire-harness).

**Motor Control Board — OPEN QUESTION plus FORK PROPOSAL**: this repo's `Hardware/Motor PCB/` directory (36
gerber/drill/BOM files) is explicitly captioned, VERIFIED from `Hardware/README.md` on this branch: *"This is the
version for Dexter 1 and Dexter HD robots. The prior version is at: [kgallspark/Dexter]... but it has a serious
error on D3 and D4 of the power supply section."* No HDI-specific Motor Control Board schematic was found in any
source — the upstream `Stable_Conedrive` branch (self-titled "Dexter HDI") is **missing the entire `Motor PCB/`
directory** that exists on the HD-titled branch. **FORK PROPOSAL**: use this repo's existing HD Motor Control
Board (the D3/D4-corrected version) for an HDI build, since it is the only Motor Control Board schematic available
anywhere in the sources consulted, and the connector pinout it implements (J19-21, as documented in wiki
`Motor-Control-PCB.md` and `End-Effectors.md`) is described generically, not as HD-specific. The one known
required change is the White-wire reassignment above, which is a wiring-harness change, not a PCB redesign — no
trace/connector on the board itself needs to change for that. This proposal has not been tested; if an HDI unit
exhibits power-related faults not seen on HD builds, revisit this assumption first.

## 002.11 Tool Interface / Gripper
PBS letters **K, L, M, N, O** (Tool Interface body, Roll motor, Span motor, Finger attachment). **Inherited from
HD; confirmed cross-generation compatible** — `official/README.md` explicitly lists the Tool Interface Fusion 360
model as compatible with "Dexter 1, HD, and HDI," and `LinkLengths` L5 (tool interface + end effector span) is
identical between HD and HDI.

| PBS # | Part | Type | Qty | Notes |
|---|---|---|---|---|
| #900-001 | Tool Interface Body | 3D print | 1 | |
| #900-002 | 3-pin connector | Off the shelf | 1 | Made by cutting a 6-pin connector in half |
| #610-002 | Dynamixel XL-320 servo | Off the shelf | 2 | Roll + span axes |
| #641-002 | M2 x 16mm bolts | Off the shelf | 4 | |
| — | M3 x 10mm bolts | Off the shelf | 3 | No PBS # in source row |
| #660-001 | M2 nuts | Off the shelf | 4 | |
| #660-002 | M3 nuts | Off the shelf | 3 | |
| #911-001 | Roll Body | 3D print | 1 | |
| #911-002 | Roll Driver | 3D print | 1 | |
| #620-003 | 6703 bearing | Off the shelf | 2 | |
| #641-001 | M2 x 12mm bolts | Off the shelf | 2 | |
| #641-003 | M2 x 20mm bolts | Off the shelf | 4 | |
| #660-001 | M2 nuts | Off the shelf | 6 | |
| #670-001 | M2 washers | Off the shelf | 6 | |
| #912-001 | Span Mount | 3D print | 1 | |
| #912-002 | Span Driver | 3D print | 1 | |
| #912-003 | 28mm x 5.6mm x 2.5mm CF strake | Fabricate | 1 | dragonplate.com pID=695 |
| #920-001 | Static Finger | 3D print | 1 | CAD flagged "CLEAN" (needs cleanup) in source |
| #920-002 | Dynamic Finger | 3D print | 1 | CAD flagged "CLEAN" (needs cleanup) in source |
| #920-003 | Finger Cap | 3D print | 1 | CAD flagged "NO" in source (issue unspecified) |
| #920-004 | MR128 bearing | Off the shelf | 2 | |
| #641-002 | M2 x 16mm bolts | Off the shelf | 1 | |
| #670-001 | M2 washers | Off the shelf | 1 | |

Additional items listed in the source BOM with quantity "0" (i.e., alternate/optional parts, not required for the
baseline build): Parallel Dynamic Finger, Parallel Static Finger, 3-Prong Dynamic Finger, A6 Torque Link, L3 Skin
Bracket, Gripper Wire Cover, L2 Board Bracket, L2 Skin Bracket. Two pieces of yoga mat (cut to fit) are also needed
per the build notes for the finger grip surfaces — not a PBS line item.

---

## Aggregate hardware order quantities (whole robot)
Summed across all subassemblies above **as specified for HDI** (i.e., reflecting the doubled Base Clamp and
removed Foot/aluminum-strake rows in [002.2](#0022-base); excludes the undesigned Base Mounting Plate hardware).
Verify against the "order in excess" warning — these are BOM totals with no slack built in, and several rows above
carry open lengths/quantities pending the FORK PROPOSAL items being finalized.

| Part | Total qty |
|---|---|
| M2 nuts | 43 |
| M3 nuts | 43 (+ doubled Base Clamp hardware, TBD) |
| M2 washers | 22 |
| M3 washers | 16 |
| M2 x 12mm bolts | 22 |
| M2 x 16mm bolts | 5 |
| M2 x 20mm bolts | 17 |
| M3 x 12mm socket head screws | 22 |
| M3 x 6mm set screws | 9 |
| M3 x 8mm bolts | 10 |
| M3 x 8mm hex cap bolt | 6 |
| #6 washers | 14 |
| 6703 bearing | 12 |
| 6810 bearing | 7 |
| MR128 bearing | 15 |
| MR85 bearing | 3 |
| 6705 bearing | 1 |
| 6807 bearing | 2 |
| NEMA-17 stepper motor (0.9°/step) | 5 |
| Flex Spline / Wave Generator / Stator Gear (harmonic drive sets) | 3 each |
| Dynamixel XL-320 servo | 2 |
| Optical Board | 5 |
| 6-pin connector | 10 |
| 1" #19 finishing nail | 11 |

Removed from the HD total for HDI: 6x Foot, 6x 165mm aluminum strake (see [002.2](#0022-base)). Not yet
quantifiable pending the Base Mounting Plate design: bolts/hardware to mount the plate to the Base Mount Bottom
and to the work surface.

## Sourcing notes
- **CF strakes/tubes**: original design sources from Dragonplate.com (links preserved in the per-section tables
  above); any equivalent pultruded carbon-fiber square tube/strip supplier of matching cross-section will work.
  Three lengths (Arm Body tube, End Arm Hub tube, and indirectly the Main Pivot strakes) are flagged above as
  likely needing HDI-specific adjustment — confirm before cutting.
- **Bearings**: identified upstream only by trade size (e.g. "6810", "MR128") — these are standard metric bearing
  part numbers and can be sourced from any bearing supplier (e.g. McMaster-Carr, VXB) by ID/OD/width.
- **Harmonic drives**: see the Critical Gap section above — this is the long-lead, high-risk item, unchanged from
  HD to HDI.
- **Motor Control Board / Opto boards**: this fork proposes reusing the HD Motor Control Board (see
  [002.10](#00210-wire-harness)) — gerbers and BOM CSVs are in this repo under `Hardware/Motor PCB/`. Opto board
  gerbers/BOM are in `Hardware/Opto/`. Have both fabricated by any PCB house (e.g. JLCPCB, OSH Park) rather than
  sourcing as an off-the-shelf part.
- **MicroZed FPGA carrier**: see the wiki `MicroZed` page for the specific SoM part number before ordering.
- **Power supply**: voltage/current not specified in the source BOM — cross-reference the Motor Control Board
  schematic (`Hardware/Motor PCB/09011-00135-A.PDF` in this repo) for the required rail before selecting one.
- **Base Mounting Plate** ([002.2](#0022-base)): not sourceable yet — this is a FORK PROPOSAL placeholder pending
  design.
