# 002 — Requirements

This document specifies **what Dexter must do and be**: the capabilities the rest of the design exists
to deliver. Requirements are the root of the derivation — kinematics (003), mechanics (004), and
electronics/control (005) implement them, and firmware/BOM/assembly (006–008) realize them. Each
requirement has a stable ID so successive revisions can reference and amend it (see
[010-Versioning.md](010-Versioning.md#4-revision-procedure--how-to-derive-the-next-revision)).

Values marked **derived** are computed from the specified design (link lengths, encoder counts, gear
ratios). The **Open item** column names the [009](009-Design-Completion.md) entry a requirement still waits
on, and is empty for the rest; 009 owns what that entry's state and definition of done are
([README.md](README.md#design-status)).

## 1. Functional requirements

| ID | Requirement | Target | Open item | Specified in |
|---|---|---|---|---|
| REQ-DOF-1 | Position and orient a tool in 3D space with an articulated arm | **5 arm axes** | — | [003](003-Kinematics.md#joint-definitions), [004](004-Mechanical-Architecture.md) |
| REQ-DOF-2 | Provide an actuated end effector | **2 tool axes** (roll, grip) via a cross-version tool interface | — | [004](004-Mechanical-Architecture.md#tool-interface-roll--grip), [005](005-Electronics-and-Control.md) |
| REQ-MOT-1 | Move to commanded joint angles | Coordinated point-to-point, ramped across all arm joints | — | [003](003-Kinematics.md#motion-commands) |
| REQ-MOT-2 | Move the tool tip to a Cartesian pose | Onboard inverse kinematics | — | [003](003-Kinematics.md#inverse-kinematics) |
| REQ-MOT-3 | Move in a straight Cartesian line | Coordinated linear interpolation | — | [003](003-Kinematics.md#motion-commands) |
| REQ-PRG-1 | Be programmable by script | Kinematics/motion API, runnable interactively or headless | — | [005](005-Electronics-and-Control.md#command-interface) |
| REQ-PRG-2 | Be teachable by physical demonstration | Record-and-replay of a pose sequence, by hand | — | [006](006-Firmware-and-Calibration.md#boot-and-phui) |
| REQ-PRG-3 | Be programmable by block coding | Block-coding extension for simple fixed motions | — | [005](005-Electronics-and-Control.md#command-interface) |

## 2. Kinematic and workspace requirements

| ID | Requirement | Target | Open item | Specified in |
|---|---|---|---|---|
| REQ-WS-1 | Joint travel, J1 (base) | ≈ ±190° | — | [003](003-Kinematics.md#joint-travel-limits) |
| REQ-WS-2 | Joint travel, J2 (shoulder) | ≈ ±97° | — | [003](003-Kinematics.md#joint-travel-limits) |
| REQ-WS-3 | Joint travel, J3 (elbow) | ≈ ±158° | — | [003](003-Kinematics.md#joint-travel-limits) |
| REQ-WS-4 | Joint travel, J4 (wrist pitch) | ≈ ±108° | — | [003](003-Kinematics.md#joint-travel-limits) |
| REQ-WS-5 | Joint travel, J5 (wrist yaw) | ≈ ±190° | — | [003](003-Kinematics.md#joint-travel-limits) |
| REQ-WS-6 | Maximum reach from base axis | ≈ 0.79 m (derived: L2+L3+L4+L5) | measure on build — [DC-9](009-Design-Completion.md#performance-characterization) | [003](003-Kinematics.md#link-lengths) |
| REQ-WS-7 | Nominal working point | Reliable motion around `[0, 0.5, 0.075]` m (0.5 m out, 75 mm up) | — | [003](003-Kinematics.md#inverse-kinematics) |
| REQ-WS-8 | Reachable envelope | Per the motion-envelope side/top profiles; not a simple sphere (config- and singularity-limited) | measure on build — [DC-9](009-Design-Completion.md#performance-characterization) | [003](003-Kinematics.md#workspace-envelope) |

## 3. Precision and performance requirements

| ID | Requirement | Target | Open item | Specified in |
|---|---|---|---|---|
| REQ-PRE-1 | Output-side joint position sensing | Optical encoder **after** the drivetrain on every arm joint | — | [005](005-Electronics-and-Control.md#sensing) |
| REQ-PRE-2 | Encoder angular resolution | ≈ 10⁶ counts/rev ⇒ ≈ 1.3 arcsec/count (derived) | — | [005](005-Electronics-and-Control.md#sensing) |
| REQ-PRE-3 | Commanded step resolution, J1–J3 | ≈ 3.9 arcsec/step (derived from the base-joint drive constant) | — | [006](006-Firmware-and-Calibration.md#drive-constants-axiscal) |
| REQ-PRE-4 | Theoretical tip resolution at 0.5 m | ≈ 3 µm (derived from REQ-PRE-2 at 0.5 m radius) | confirm on build — [DC-9](009-Design-Completion.md#performance-characterization) | [003](003-Kinematics.md) |
| REQ-PRE-5 | End-to-end positioning repeatability | To be characterized on a physical build | measure on build — [DC-9](009-Design-Completion.md#performance-characterization) | — |
| REQ-PRE-6 | Rated payload at the tool tip | To be characterized on a physical build | measure on build — [DC-9](009-Design-Completion.md#performance-characterization) | — |
| REQ-PRE-7 | Maximum joint/Cartesian speed | Software-limited (`MaxSpeed`, `Acceleration`); envelope to be characterized | measure on build — [DC-9](009-Design-Completion.md#performance-characterization) | [006](006-Firmware-and-Calibration.md) |

**Design rationale (REQ-PRE-1/2).** Precision is delivered by measuring the joint's *true* output angle
with a high-resolution encoder and correcting to it in a fast local loop (REQ-CTL-1), rather than by
building a stiff, zero-backlash drivetrain. Drivetrain compliance is tolerated because the loop closes on
the output, not the motor shaft. This is the defining performance requirement of the machine.

## 4. Structural and mechanical requirements

| ID | Requirement | Target | Open item | Specified in |
|---|---|---|---|---|
| REQ-STR-1 | Lightweight, stiff structure | 3D-printed body stiffened by bonded pultruded carbon fiber | — | [004](004-Mechanical-Architecture.md#materials-and-construction-methods) |
| REQ-STR-2 | Base-joint reduction | **52:1** strain-wave (harmonic) drive on J1–J3 | — | [004](004-Mechanical-Architecture.md#base-joints-j1j3-strain-wave-drive) |
| REQ-STR-3 | Wrist reduction | Belt/pulley reduction driving the J4/J5 differential, **net 13.5:1** | [DC-12](009-Design-Completion.md#wrist-pulley-rework) | [004](004-Mechanical-Architecture.md#wrist-and-differential-j4j5) |
| REQ-STR-4 | Rigid mounting | Bolted base to a stable work surface; doubled base clamp at the base-pivot joint | [DC-4](009-Design-Completion.md#base-plate) | [004](004-Mechanical-Architecture.md#base-j1) |
| REQ-STR-5 | Fabricability | Buildable with desktop CF-capable 3D printing and off-the-shelf components, except the strain-wave set | — | [007](007-Bill-of-Materials.md) |

## 5. Electrical and control requirements

| ID | Requirement | Target | Open item | Specified in |
|---|---|---|---|---|
| REQ-CTL-1 | Fast local closed-loop control | FPGA joint-servo loop, encoder→motor response ≈ 200 ns | — | [005](005-Electronics-and-Control.md#control-architecture) |
| REQ-CTL-2 | Onboard motion computation | Firmware runs trajectory generation and onboard kinematics on the robot | — | [006](006-Firmware-and-Calibration.md) |
| REQ-CTL-3 | Actuation, J1–J5 | Microstepped stepper motors via the Motor Control PCB | — | [005](005-Electronics-and-Control.md#actuation) |
| REQ-CTL-4 | Actuation, tool axes | Smart servos on the tool interface serial bus | — | [005](005-Electronics-and-Control.md#actuation) |
| REQ-CTL-5 | Power | Single DC supply feeding motor and logic rails, **36 V / 4 A** | — | [005](005-Electronics-and-Control.md#power) |
| REQ-CTL-6 | Calibration retained per unit | Calibration recorded onto the individual robot and retained; not re-established in the field | — | [006](006-Firmware-and-Calibration.md#calibration-model) |

## 6. Interface requirements

| ID | Requirement | Target | Open item | Specified in |
|---|---|---|---|---|
| REQ-IF-1 | Network command interface | Ethernet/Wi-Fi socket carrying the command protocol | — | [005](005-Electronics-and-Control.md#command-interface) |
| REQ-IF-2 | Host development environment | Development environment reaching the robot over the network | — | [005](005-Electronics-and-Control.md#command-interface) |
| REQ-IF-3 | Service/console access | SSH and USB serial console for setup and calibration | — | [006](006-Firmware-and-Calibration.md) |
| REQ-IF-4 | Tool electrical interface | **6-conductor** interface to the tool | — | [005](005-Electronics-and-Control.md#tool-interface-wiring) |
| REQ-IF-5 | Web interface | Onboard web server / editor | — | [005](005-Electronics-and-Control.md#command-interface) |

## 7. Environmental and operational requirements

| ID | Requirement | Target | Open item | Specified in |
|---|---|---|---|---|
| REQ-ENV-1 | Operating platform | Linux on the onboard SoC, booting the motion firmware from microSD | — | [006](006-Firmware-and-Calibration.md) |
| REQ-ENV-2 | First-use bring-up | A from-scratch build runs the factory calibration procedure once before first use | — | [006](006-Firmware-and-Calibration.md#factory-calibration-procedure) |
| REQ-ENV-3 | Startup behavior | Boots, finds home, then enters the physical teach interface before accepting network control | — | [006](006-Firmware-and-Calibration.md#boot-and-phui) |
| REQ-ENV-4 | Maintenance | Scheduled strain-wave lubricant replacement; belts adjusted as needed | — | [006](006-Firmware-and-Calibration.md#maintenance) |
| REQ-ENV-5 | Mounting environment | Rigid work surface able to react the arm's full dynamic load through the bolted base | [DC-4](009-Design-Completion.md#base-plate) | [004](004-Mechanical-Architecture.md#base-j1) |

## 8. Traceability

Requirements flow downward: an unclosed performance requirement (REQ-PRE-5/6/7, REQ-WS-6/8) is closed by
either a design decision in [009-Design-Completion.md](009-Design-Completion.md) or a measurement on a
physical build, at which point the measured value replaces the derived one and 009 records the item as
closed. When a requirement changes in a future revision, follow the re-derivation order in
[010](010-Versioning.md#4-revision-procedure--how-to-derive-the-next-revision) so the downstream
mechanics, electronics, and derived artifacts stay consistent with it.
