# 005 — Electronics and Control

This document specifies how Dexter senses, actuates, and is commanded: the optical encoders, the
stepper and servo actuation, the FPGA joint-servo loop, the controller boards, power, and the command
interface. It implements the electrical/control and interface requirements
([002](002-Requirements.md#5-electrical-and-control-requirements)) and drives the firmware configuration in
[006-Firmware-and-Calibration.md](006-Firmware-and-Calibration.md).

## Control architecture

```mermaid
graph LR
    subgraph Joint["Per arm joint (J1-J5)"]
      Enc[Optical encoder - output side] --> FPGA
      FPGA[FPGA joint servo ~200 ns] --> Drv[Stepper driver] --> Mot[NEMA-17]
      Mot -.reduction.-> Enc
    end
    ARM[ARM core: DexRun firmware] <--> FPGA
    Net[Ethernet / Wi-Fi] <--> ARM
    ARM --> Tool[Tool interface serial bus] --> Dyn[Dynamixel servos]
    Host[DDE / web / Scratch] <--> Net
```

The defining feature is a **fast local closed loop**: each arm joint's output-side encoder feeds the FPGA,
which adjusts the stepper to drive the *measured* joint position to the commanded position, with
encoder-to-motor response on the order of **200 ns** (REQ-CTL-1). The ARM core running **DexRun** sits above
this loop — it generates trajectories, runs onboard kinematics, applies calibration, and serves the network
interface — but does not run the tight servo loop itself. Because the loop is fast relative to the arm's
mechanical bandwidth, small sensor perturbations are filtered out mechanically (motor inertia and
inductance) rather than causing jitter.

*Source: wiki `Gateware.md`, `Joints.md`; system control diagram (`haddingtondynamics.github.io`).*

## Sensing

Each of the five arm joints carries a **custom optical encoder on the output side of the drivetrain**, so it
measures the *true joint angle* after any drivetrain compliance or backlash (REQ-PRE-1). Each encoder is a
printed **code disk** with radial slots read by LED/phototransistor **opto blocks**; interpolation between
slots yields ≈ 10⁶ counts/revolution (≈ 1.3 arcsec/count, REQ-PRE-2). The code-disk slot count differs per
joint — the per-joint values are in [003](003-Kinematics.md#joint-definitions).

- **Index/home sensing.** Beyond incremental counts, the disks carry index features the firmware scans on
  boot to find home ("index eyes"). The mapping from raw eye readings to joint position is established by
  calibration and recorded per unit ([006](006-Firmware-and-Calibration.md#calibration-model)).
- **Eye calibration.** Each opto block has trim potentiometers set so its two phototransistor channels
  trace a centered circle as the disk turns; this centers the "eye" and is part of the factory procedure.
- The encoder→position relationship absorbs imperfect slot geometry: calibration maps commanded position to
  observed reading, so disk imperfections are effectively removed rather than becoming position error.

*Source: wiki `Encoders.md`, `Encoder-Calibration.md`, `Joints.md`.*

## Actuation

| Axis | Actuator | Drive |
|---|---|---|
| J1–J5 | **NEMA-17 stepper, 0.9°/step (400 steps/rev)**, 16× microstepping | Motor Control PCB stepper drivers, closed by the FPGA loop |
| Tool roll, grip | **Dynamixel smart servos** | Serial (Dynamixel) bus over the tool interface |

Steppers are the motive source for all five arm joints; the FPGA's output-side correction is what turns an
open-loop stepper into a precise closed-loop joint. The tool axes use Dynamixel servos with their own
internal control, commanded over the tool interface serial bus. *Source: wiki `Hardware.md`, `Joints.md`,
`End-Effector-Servos.md`.*

## Boards

| Board | Role | Status | Source of record |
|---|---|---|---|
| **Motor Control PCB** | Stepper drivers, power distribution, opto/tool connectors, FPGA carrier interface | `[Provisional]` — reuse the previous version's board | `Hardware/Motor PCB/` gerbers (D3/D4-corrected revision) |
| **MicroZed FPGA/SoC** | Xilinx Zynq module: FPGA fabric (joint servo, gateware) + ARM core (DexRun, Linux) | `[Specified]` | wiki `MicroZed.md` for the exact module part number |
| **Optical boards (×5)** | LED + phototransistor opto pickups, one per joint encoder | `[Specified]` | `Hardware/Opto/` gerbers/BOM |

- **Motor Control PCB — `[Provisional]`.** No Motor Control PCB design of this version's own exists; the
  previous version's "green" board is reused (`09051-00135-A`, the revision carrying the D3/D4 power fix).
  Its gerbers and BOM (`Hardware/Motor PCB/`) define the board of record:

  | Function | Devices | Note |
  |---|---|---|
  | Stepper drivers | 6 × Allegro **A4983** (`Z1–Z6` on `MOT1–MOT6`) | 5 arm joints + 1 spare/External channel |
  | Logic rails | TI **TPS54541** bucks (`U1`, `U2`) | Derived from the motor rail |
  | Boost | **LTC3786** (`U3`) | Sets the board's **38 V** input ceiling |
  | Power rectification | **PDS760** Schottkys (`D3`, `D4`), 60 V | The "D3/D4 fix" that defines this board revision |
  | Per-channel protection | 3.0 A thermal fuses (`F1–F6`) | One per motor channel |
  | Connectors | `J1–J6`/`J24` 4-pin motor screw terminals; `J7–J13` 6-pin opto headers; `J14–J17` 3-pin tool headers; `J19–J21` power | Generic, not tied to a specific robot version |

  The generic connector set is why the reuse is viable: the only known difference from the previous version
  is the wiring-harness reassignment described in [Tool interface wiring](#tool-interface-wiring), not a
  board change. A purpose-built board is a roadmap item ([011](011-Roadmap.md)); what remains to close the
  reuse is [DC-7](009-Design-Completion.md#motor-control-pcb).
- **Gateware.** The FPGA logic (the servo loop and interconnect) is authored in a graphical logic tool
  (Viva/Azido) and deployed as a bitstream; it is largely a compiled artifact rather than edited source.
  Operating "modes" (follow/helping-hand/keep-position, etc.) are FPGA configurations selected at runtime.

## Power

A single DC supply feeds the motor and logic rails through the Motor Control PCB (REQ-CTL-5). The supply of
record is **36 V DC, 4 A (≈144 W)** — a standard laptop-style DC brick with a matching barrel connector.

The **38 V board ceiling** set by the `LTC3786` ([Boards](#boards)) is what bounds the supply from above;
36 V sits just under it with margin, and the board's 50 V-rated input capacitors and 60 V PDS760 Schottkys
support it. The motor rail feeds the six A4983 stepper drivers (≈2 A/phase, fused at 3.0 A per channel);
the TPS54541 bucks derive the logic rails from it. Servo power for the tool is derived on the tool side.

**Under-voltage is a failure mode, not just a slowdown:** a 12 V or 24 V brick causes the arm to grind and
buzz, stall mid-motion, and fail to find home. Do not substitute one. `[Specified]` — *Source: wiki
`Troubleshooting.md`; Motor PCB BOM (`Hardware/Motor PCB/09011-00135-A.BOM`);
[LTC3786 datasheet](https://www.digikey.com/en/products/detail/analog-devices-inc/LTC3786IUD-PBF/2407353).*

## Command interface

Dexter is commanded over the network by the **oplet protocol**: single-letter command primitives sent
over a socket to DexRun (e.g. `a` move-all, `M`/`T` Cartesian moves, `S` set-parameter, `g` get-status,
`r` read, `w` write). The motion oplets are specified in [003](003-Kinematics.md#motion-commands).

| Interface | Description | Requirement |
|---|---|---|
| **Socket / oplet protocol** | Raw TCP socket to DexRun carrying oplets; the lowest-level control interface | REQ-IF-1 |
| **DDE** | Dexter Development Environment: JavaScript kinematics/motion API, GUI + onboard Job Engine for headless runs | REQ-IF-2, REQ-PRG-1 |
| **Onboard web server** | Node.js web server / editor for browser access without installed software | REQ-IF-5 |
| **PhUI** | Physical teach-and-replay; the default startup job, whose effect on network control is specified in [006](006-Firmware-and-Calibration.md#boot-and-phui) | REQ-PRG-2 |
| **Scratch** | Block-coding extension for simple fixed motions | REQ-PRG-3 |
| **SSH / USB console** | Service and calibration access | REQ-IF-3 |

*Source: wiki `DexRun-DDE-communications.md`, `Command-oplet-instruction.md`, `DDE.md`,
`nodejs-webserver.md`, `PhysicalUserInterface.md`, `Scratch-extension.md`.*

## Tool interface wiring

The tool interface connects to the Motor Control PCB through **6 conductors** (REQ-IF-4). Five assignments
are common across versions; **the White conductor changed with this version** and the difference is
safety-relevant.

| Wire | Assignment | Note |
|---|---|---|
| Black | Ground | |
| Red | +5 V logic | |
| Yellow | Unregulated supply power | |
| Blue | Servo data bus | |
| Green | Auxiliary / return serial data | |
| **White** | **Second ground** (2nd-from-top "−" screw terminal) | **On the previous version this same wire can carry regulated servo power (6–8.75 V)** |

**Safety.** On the previous version, White may carry 6–8.75 V; here the same physical wire and terminal are
a second ground. Connecting an older harness to a board configured for this version (or vice versa) without
re-checking this assignment shorts a power rail to ground. Verify the White assignment against the board before first
power-on. `[Specified]` — *Source: wiki `End-Effectors.md` ("Version 2 Wiring").*

## Design-status summary

Each open item's state, priority, and definition of done is in
[009-Design-Completion.md](009-Design-Completion.md).

| Item | Status | Open item |
|---|---|---|
| Optical encoders + opto boards | `[Specified]` | — |
| FPGA joint-servo loop / gateware | `[Specified]` | — |
| Stepper actuation J1–J5 | `[Specified]` | — |
| Tool servo actuation | `[Specified]` | — |
| MicroZed FPGA/SoC | `[Specified]` | Confirm exact module P/N |
| Motor Control PCB | `[Provisional]` | [DC-7](009-Design-Completion.md#motor-control-pcb) |
| Power supply | `[Specified]` | — |
| Tool interface wiring | `[Specified]` | — |
