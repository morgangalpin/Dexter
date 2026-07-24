# 002 — Requirements (Dexter HDI Rev A)

This document specifies **what Dexter HDI must do and be**: the capabilities the rest of the design exists
to deliver. Requirements are the root of the derivation — kinematics (003), mechanics (004), and
electronics/control (005) implement them, and firmware/BOM/assembly (006–008) realize them. Each
requirement has a stable ID so successive revisions can reference and amend it (see
[010-Versioning-and-Roadmap.md](010-Versioning-and-Roadmap.md#3-revision-model--how-to-derive-the-next-version)).

Status markers (`[Specified]`, `[Provisional]`, `[TBD]`) are defined in [README.md](README.md#design-status).
Values marked **derived** are computed from the specified design (link lengths, encoder counts, gear
ratios); values marked **measure** require characterization on a physical build before they are
`[Specified]`.

## 1. Functional requirements

| ID | Requirement | Target | Status | Specified in |
|---|---|---|---|---|
| REQ-DOF-1 | Position and orient a tool in 3D space with an articulated arm | **5 arm axes** (J1 base rotation, J2 shoulder pitch, J3 elbow pitch, J4 wrist pitch, J5 wrist yaw) | `[Specified]` | [003](003-Kinematics.md), [004](004-Mechanical-Architecture.md) |
| REQ-DOF-2 | Provide an actuated end effector | **2 tool axes** (roll, grip) via a cross-generation tool interface | `[Specified]` | [004](004-Mechanical-Architecture.md#tool-interface), [005](005-Electronics-and-Control.md) |
| REQ-MOT-1 | Move to commanded joint angles | Coordinated point-to-point, trapezoidal-ramped J1–J5 | `[Specified]` | [003](003-Kinematics.md#motion-commands) |
| REQ-MOT-2 | Move the tool tip to a Cartesian pose | Onboard inverse kinematics: position + direction + configuration | `[Specified]` | [003](003-Kinematics.md#inverse-kinematics) |
| REQ-MOT-3 | Move in a straight Cartesian line | Coordinated linear interpolation (`T` move) | `[Specified]` | [003](003-Kinematics.md#motion-commands) |
| REQ-PRG-1 | Be programmable by script | JavaScript kinematics/motion API (DDE), runnable headless via onboard Job Engine | `[Specified]` | [005](005-Electronics-and-Control.md#command-interface) |
| REQ-PRG-2 | Be teachable by physical demonstration | PhUI record-and-replay of a pose sequence; default HDI startup behavior | `[Specified]` | [006](006-Firmware-and-Calibration.md#boot-and-phui) |
| REQ-PRG-3 | Be programmable by block coding | Scratch extension for simple fixed motions | `[Specified]` | [005](005-Electronics-and-Control.md#command-interface) |

## 2. Kinematic and workspace requirements

| ID | Requirement | Target | Status | Specified in |
|---|---|---|---|---|
| REQ-WS-1 | Joint travel, J1 (base) | ≈ ±190° | `[Specified]` (firmware boundary) | [003](003-Kinematics.md#joint-travel-limits) |
| REQ-WS-2 | Joint travel, J2 (shoulder) | ≈ ±97° | `[Specified]` (firmware boundary) | [003](003-Kinematics.md#joint-travel-limits) |
| REQ-WS-3 | Joint travel, J3 (elbow) | ≈ ±158° | `[Specified]` (firmware boundary) | [003](003-Kinematics.md#joint-travel-limits) |
| REQ-WS-4 | Joint travel, J4 (wrist pitch) | ≈ ±108° | `[Specified]` (firmware boundary) | [003](003-Kinematics.md#joint-travel-limits) |
| REQ-WS-5 | Joint travel, J5 (wrist yaw) | ≈ ±190° | `[Specified]` (firmware boundary) | [003](003-Kinematics.md#joint-travel-limits) |
| REQ-WS-6 | Maximum reach from base axis | ≈ 0.79 m (derived: L2+L3+L4+L5) | `[Provisional]` derived — **measure** | [003](003-Kinematics.md#link-lengths) |
| REQ-WS-7 | Nominal working point | Reliable motion around `[0, 0.5, 0.075]` m (0.5 m out, 75 mm up) | `[Specified]` | [003](003-Kinematics.md#inverse-kinematics) |
| REQ-WS-8 | Reachable envelope | Per the HDI motion-envelope side/top profiles; not a simple sphere (config- and singularity-limited) | `[Provisional]` — **measure** | [003](003-Kinematics.md#workspace-envelope) |

## 3. Precision and performance requirements

| ID | Requirement | Target | Status | Specified in |
|---|---|---|---|---|
| REQ-PRE-1 | Output-side joint position sensing | Optical encoder **after** the drivetrain on every arm joint | `[Specified]` | [005](005-Electronics-and-Control.md#sensing) |
| REQ-PRE-2 | Encoder angular resolution | ≈ 10⁶ counts/rev ⇒ ≈ 1.3 arcsec/count (derived) | `[Specified]` (architecture) | [005](005-Electronics-and-Control.md#sensing) |
| REQ-PRE-3 | Commanded step resolution, J1–J3 | 332800 steps/joint-rev ⇒ ≈ 3.9 arcsec/step (derived: 52 × 400 × 16) | `[Specified]` | [006](006-Firmware-and-Calibration.md#drive-constants-axiscal) |
| REQ-PRE-4 | Theoretical tip resolution at 0.5 m | ≈ 3 µm (derived from REQ-PRE-2 at 0.5 m radius) | `[Provisional]` derived | [003](003-Kinematics.md) |
| REQ-PRE-5 | End-to-end positioning repeatability | To be characterized on a physical build | `[TBD]` — **measure** ([009](009-Design-Completion.md)) | — |
| REQ-PRE-6 | Rated payload at the tool tip | To be characterized on a physical build | `[TBD]` — **measure** ([009](009-Design-Completion.md)) | — |
| REQ-PRE-7 | Maximum joint/Cartesian speed | Software-limited (`MaxSpeed`, `Acceleration`); envelope to be characterized | `[TBD]` — **measure** | [006](006-Firmware-and-Calibration.md) |

**Design rationale (REQ-PRE-1/2).** Precision is delivered by measuring the joint's *true* output angle
with a high-resolution encoder and correcting to it in a fast local loop (REQ-CTL-1), rather than by
building a stiff, zero-backlash drivetrain. Drivetrain compliance is tolerated because the loop closes on
the output, not the motor shaft. This is the defining performance requirement of the machine.

## 4. Structural and mechanical requirements

| ID | Requirement | Target | Status | Specified in |
|---|---|---|---|---|
| REQ-STR-1 | Lightweight, stiff structure | 3D-printed Onyx / carbon-fiber body stiffened by bonded pultruded CF strakes and tubes | `[Specified]` | [004](004-Mechanical-Architecture.md) |
| REQ-STR-2 | Base-joint reduction | 52:1 strain-wave (harmonic) drive, backlash-free, on J1–J3 | `[Specified]` (ratio) | [004](004-Mechanical-Architecture.md#base-joints-j1-j3-strain-wave-drive) |
| REQ-STR-3 | Wrist reduction | Belt/pulley reduction driving the J4/J5 differential | `[Provisional]` (ratio [TBD]) | [004](004-Mechanical-Architecture.md#wrist-and-differential-j4-j5) |
| REQ-STR-4 | Rigid mounting | Bolted base to a stable work surface; doubled base clamp at the base-pivot joint | `[Provisional]` (plate [TBD]) | [004](004-Mechanical-Architecture.md#base-j1) |
| REQ-STR-5 | Fabricability | Buildable with desktop CF-capable 3D printing and off-the-shelf components, except the strain-wave set | `[Specified]` | [007](007-Bill-of-Materials.md) |

## 5. Electrical and control requirements

| ID | Requirement | Target | Status | Specified in |
|---|---|---|---|---|
| REQ-CTL-1 | Fast local closed-loop control | FPGA joint-servo loop, encoder→motor response ≈ 200 ns | `[Specified]` | [005](005-Electronics-and-Control.md#control-architecture) |
| REQ-CTL-2 | Onboard motion computation | ARM-core firmware (DexRun) runs trajectory generation and onboard kinematics | `[Specified]` | [006](006-Firmware-and-Calibration.md) |
| REQ-CTL-3 | Actuation, J1–J5 | 0.9°/step NEMA-17 steppers, 16× microstepping, via the Motor Control PCB | `[Specified]` | [005](005-Electronics-and-Control.md#actuation) |
| REQ-CTL-4 | Actuation, tool axes | Dynamixel smart servos on the tool interface serial bus | `[Specified]` | [005](005-Electronics-and-Control.md#actuation) |
| REQ-CTL-5 | Power | Single DC supply feeding motor and logic rails | `[Provisional]` (rating [TBD]) | [005](005-Electronics-and-Control.md#power), [009](009-Design-Completion.md) |
| REQ-CTL-6 | Calibration retained per unit | Factory-recorded encoder centers and index mapping stored on the robot; not re-calibrated in the field | `[Specified]` | [006](006-Firmware-and-Calibration.md#calibration-model) |

## 6. Interface requirements

| ID | Requirement | Target | Status | Specified in |
|---|---|---|---|---|
| REQ-IF-1 | Network command interface | Ethernet/Wi-Fi socket carrying the oplet command protocol | `[Specified]` | [005](005-Electronics-and-Control.md#command-interface) |
| REQ-IF-2 | Host development environment | DDE (Dexter Development Environment) over the network | `[Specified]` | [005](005-Electronics-and-Control.md#command-interface) |
| REQ-IF-3 | Service/console access | SSH and USB serial console for setup and calibration | `[Specified]` | [006](006-Firmware-and-Calibration.md) |
| REQ-IF-4 | Tool electrical interface | 6-conductor interface to the tool (ground, +5 V logic, unregulated supply, servo data, aux serial, 2nd ground) | `[Specified]` | [005](005-Electronics-and-Control.md#tool-interface-wiring) |
| REQ-IF-5 | Web interface | Onboard Node.js web server / editor | `[Specified]` | [005](005-Electronics-and-Control.md#command-interface) |

## 7. Environmental and operational requirements

| ID | Requirement | Target | Status | Specified in |
|---|---|---|---|---|
| REQ-ENV-1 | Operating platform | Ubuntu 16.04 LTS on the MicroZed SoC, booting DexRun from microSD | `[Specified]` | [006](006-Firmware-and-Calibration.md) |
| REQ-ENV-2 | First-use bring-up | A from-scratch build runs the factory calibration procedure once before first use | `[Specified]` | [006](006-Firmware-and-Calibration.md#factory-calibration-procedure) |
| REQ-ENV-3 | Startup behavior | Boots, finds home via index eyes, then enters PhUI (does not accept DDE control until PhUI is exited) | `[Specified]` | [006](006-Firmware-and-Calibration.md#boot-and-phui) |
| REQ-ENV-4 | Maintenance | Strain-wave lubricant replaced at 100 h and 2000 h; belts adjusted as needed | `[Specified]` | [006](006-Firmware-and-Calibration.md#maintenance) |
| REQ-ENV-5 | Mounting environment | Rigid work surface able to react the arm's full dynamic load through the bolted base | `[Provisional]` | [004](004-Mechanical-Architecture.md#base-j1) |

## 8. Traceability

Requirements flow downward: a `[TBD]` performance requirement (REQ-PRE-5/6/7, REQ-WS-6/8) is closed by
either a design decision in [009-Design-Completion.md](009-Design-Completion.md) or a measurement on a
physical build, at which point its status advances to `[Specified]` and the measured value replaces the
derived one. When a requirement changes in a future revision, follow the re-derivation order in
[010](010-Versioning-and-Roadmap.md#3-revision-model--how-to-derive-the-next-version) so the downstream
mechanics, electronics, and derived artifacts stay consistent with it.
