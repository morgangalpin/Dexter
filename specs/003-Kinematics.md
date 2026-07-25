# 003 — Kinematics

This document specifies the geometry and motion model of Dexter: coordinate conventions, joint
definitions and travel limits, link lengths, the Denavit–Hartenberg model, and the command set that drives
motion. It implements the kinematic requirements in [002-Requirements.md](002-Requirements.md#2-kinematic-and-workspace-requirements)
and is the reference for the mechanical link dimensions in
[004-Mechanical-Architecture.md](004-Mechanical-Architecture.md) and the firmware link/limit constants in
[006-Firmware-and-Calibration.md](006-Firmware-and-Calibration.md).

## Coordinate frame

Dexter uses a right-handed world frame anchored at the base:

- **Z** is up/down.
- **X** is right/left from the operator's point of view (facing the robot's front).
- **Y** is out/back (away from / toward the base).

Cartesian tool poses are expressed as **position** (X, Y, Z), **direction** (a unit vector giving where the
tool points), and **configuration** (three booleans selecting among equivalent joint solutions). DDE
expresses positions in **meters**; the onboard `M`/`T` kinematics commands express them in **integer
microns**.

## Joint definitions

Five arm joints move the wrist; two tool axes act at the end effector. Each arm joint carries an
output-side optical encoder whose code disk has the slot count shown (relevant to calibration, see
[006](006-Firmware-and-Calibration.md)).

| Joint | Name | Motion | Axis | Encoder slots | Drive |
|---|---|---|---|---|---|
| J1 | Base | Base rotation (yaw about Z) | Vertical | 200 | 52:1 strain-wave |
| J2 | Pivot | Shoulder lift (pitch) | Horizontal | 180 | 52:1 strain-wave |
| J3 | End | Elbow (pitch) | Horizontal | 157 | 52:1 strain-wave |
| J4 | Angle | Wrist pitch (differential DiffA1 with J5) | — | 115 | Belt reduction → differential |
| J5 | Rotate | Wrist yaw (differential DiffA2 with J4) | — | 100 | Belt reduction → differential |
| Roll | Tool roll | End-effector rotation | Tool axis | — | Dynamixel servo |
| Grip | Tool grip | Gripper open/close | — | — | Dynamixel servo |

J4 and J5 are not independent single-axis joints: they are the two outputs of a **differential** (see
[004](004-Mechanical-Architecture.md#wrist-and-differential-j4-j5)). Together they form the wrist. A
non-arm "External" (J6) channel exists on the controller but is not an arm joint.

### Positive joint directions and encoder notes

- J1 rotates counter-clockwise (viewed from above) for negative values (`right_arm` = 0 places J1 negative,
  i.e. to the robot's right).
- J3 is the elbow: positive = elbow up (away from the table), negative = elbow down.
- The joint-controller channel numbering in the FPGA is not sequential with the joint numbers (FPGA
  development began "in the middle"); firmware and calibration files account for this by swapping specific
  rows when reading per-joint encoder data (`AdcCenters.txt`). This is a firmware/calibration concern, not
  a kinematic one — see [006](006-Firmware-and-Calibration.md#calibration-model).

*Source: wiki `Joints.md`, `Kinematics.md`.*

## Joint travel limits

Travel is bounded in firmware, expressed as arcseconds from center. The degree equivalents are derived
(arcsec ÷ 3600).

| Joint | Firmware boundary (arcsec) | ≈ Travel from center | Requirement |
|---|---|---|---|
| J1 | ±684010 | **±190.0°** | REQ-WS-1 |
| J2 | ±350010 | **±97.2°** | REQ-WS-2 |
| J3 | ±570010 | **±158.3°** | REQ-WS-3 |
| J4 | ±390010 | **±108.3°** | REQ-WS-4 |
| J5 | ±684010 | **±190.0°** | REQ-WS-5 |

`[Specified]` — *Source: `Firmware/Defaults.make_ins` (`J*BoundryHigh/Low`).* These are the firmware
constants of record; the physical range must not be commanded beyond them (and the mechanical
range must accommodate them — confirm on build).

## Link lengths

Link lengths define the distances between joint axes used by both onboard and host kinematics. The order in
firmware is **L5 first, L1 last**.

| Link | Span | Value | Previous version | Delta |
|---|---|---|---|---|
| L1 | Base mount → J2 axis | 235.20 mm | 228.60 mm | +6.60 mm |
| L2 | J2 → J3 axis | 339.09 mm | 320.68 mm | +18.42 mm |
| L3 | J3 → J4 axis | 307.50 mm | 330.20 mm | −22.70 mm |
| L4 | J4 → J5 axis | 59.50 mm | 50.80 mm | +8.70 mm |
| L5 | J5 axis → tool tip | 82.44 mm | 82.55 mm | −0.11 mm |

`[Specified]` — *Source of record: `Firmware/Defaults.make_ins` (`S, LinkLengths, 82440, 59500, 307500, 339092, 235200`).*

**Design notes.**
- L5 is essentially identical across versions, consistent with the tool interface being cross-version
  compatible ([004](004-Mechanical-Architecture.md#tool-interface)).
- The L2 (+18.4 mm) and L3 (−22.7 mm) deltas are far larger than build tolerance and drive the CF tube cut
  lengths in [004](004-Mechanical-Architecture.md) and [007](007-Bill-of-Materials.md). If the printed sockets
  keep the previous version's seat depth, the full link delta falls in the tube: Arm Body **282.4 mm**, End Arm Hub
  **214.3 mm** — confirm against the CAD model, as the printed bodies are renumbered
  ([DC-5](009-Design-Completion.md#link-member-lengths)). Not carried over from the previous version unchanged.
- **Discrepancy to resolve:** an alternate link-length set appears in the wiki (`set-parameter-oplet.md`)
  with L4 = 50.95 mm and L5 = 82.55 mm, differing from the firmware file above (L4 = 59.50 mm). This
  specification treats the firmware file as authoritative; reconciling the two against a physical measurement is a
  [009](009-Design-Completion.md) item. Getting L2/L3/L4 wrong shifts where the links land relative to
  encoder zero and shows up as a Cartesian-accuracy error, not an assembly failure.

### Link masses (for dynamics)

Per-link masses used by the gravity/torque model, useful for sizing, dynamics, and the payload requirement
(REQ-PRE-6):

| Link | Mass |
|---|---|
| Link 1 | 1.838 kg |
| Link 2 | 2.520 kg |
| Link 3 | 0.288 kg |
| Link 4 | 0.100 kg |
| Link 5 | 0.044 kg |

`[Provisional]` — *Source: `dde/math/DH.js` `torques_gravity` default masses; gravity 9.81 m/s².* Moving-link
mass totals ≈ 4.79 kg above the base. Confirm against a physical build.

## Denavit–Hartenberg model

The reference kinematic model is the DH parameter set measured from a serialized production unit,
**HDI-007010**. Each row is `[d, θ, a, α]` as consumed by the kinematics code (`DH.sub.dh_to_T`):

- **d** — link offset along the previous joint's Z axis (meters).
- **θ** — joint-angle offset about Z at home (degrees); the commanded joint variable adds to this.
- **a** (`r`) — link length along the common-normal X axis (meters).
- **α** — link twist about X (degrees).

| Frame | d (m) | θ (deg) | a (m) | α (deg) |
|---|---|---|---|---|
| J1 | 0.250101 | 91.5939 | −0.003545 | 85.3581 |
| J2 | 0.088342 | 89.4231 | 0.339865 | 180.4306 |
| J3 | 0.061460 | −0.0183 | 0.311780 | 0.8072 |
| J4 | 0.039300 | 86.6728 | −0.000049 | 89.7567 |
| J5 | 0.055616 | 94.5697 | 0.000000 | 90.0000 |
| Tool | 0.082950 | 0.0000 | 0.000000 | −90.0000 |

`[Specified]` — *Source: `dde/math/DH.js` ("DH params from Dexter HDI-007010 (meters and degrees)").*

**Notes.**
- This is a *measured* model of a specific calibrated unit; the `a` and `d` terms cross-check the nominal
  link lengths above (a₂ = 340 mm ≈ L2, a₃ = 312 mm ≈ L3, d_tool = 83 mm ≈ L5). Per-unit values will differ
  slightly after that unit's calibration; the nominal link lengths above are the design targets, and this
  DH set is the reference for validating kinematics math and seeding IK.
- Forward kinematics compose the six frame transforms `T_i(d, θ+q_i, a, α)`; inverse kinematics solve for
  joint angles `q` given a tool pose (`DH.forward_kinematics` / `DH.inverse_kinematics`).

## Inverse kinematics

To reach a Cartesian tool pose, the five arm joint angles are solved from **position + direction +
configuration**:

- **Position** `[X, Y, Z]` — the destination of the tool tip (dependent on a correct L5). Not every pose is
  reachable, and a path between two reachable poses can cross unreachable regions or exceed a joint's speed
  limit.
- **Direction** — a unit vector for where the tool points (e.g. `[0, 0, −1]` = straight down). Non-unit
  vectors are normalized. In DDE, a 2-element `[pitch, roll]` form is also accepted.
- **Configuration** — three booleans selecting one solution among equivalents:
  - `right_arm` (base rotation): 0/LEFT puts J1 negative (robot's right, CCW from above); 1/RIGHT is CW.
  - `elbow_up` (J3): 1 = elbow up (J3 positive), 0 = elbow down (J3 negative).
  - `wrist_out` (J4): whether the wrist points out (away from base) or in.

**Singularities.** Poses with infinitely many solutions cause errors or large joint excursions and must be
avoided — e.g. the tool axis coincident with J1's axis (X = Y = 0, pointing straight down), or specifying
`[90, 90]` for both wrist pitch and roll. Near-singular poses can produce large joint motions; plan paths to
avoid them.

IK may be computed on the host (DDE reads the robot's `LinkLengths` to stay consistent) or **onboard** via
the `M`/`T` commands.

## Forward kinematics

Given joint angles, the tool Cartesian pose is obtained by composing the DH frame transforms. The current
Cartesian position and orientation are readable from the robot via the `r` read command with the `#POM`
keyword.

## Motion commands

Motion is issued as **oplets** (single-letter command primitives; see
[005](005-Electronics-and-Control.md#command-interface)). The primary motion set:

| Command | Meaning | Input | Properties |
|---|---|---|---|
| `a` | Move all joints | 5–7 joint angles (arcsec) | Coordinated, trapezoidal-ramped J1–J5; works without calibration at reduced precision |
| `M` | Move to (onboard IK) | XYZ (µm), direction, configuration | Onboard kinematics; point-to-point (not a straight line) |
| `T` | Move to, straight | XYZ (µm), direction, configuration | Onboard kinematics; coordinated straight-line Cartesian path |
| `P` | PID move all joints | 5–7 joint angles (arcsec) | Immediate execution, PID-ramped; requires calibration |
| `C` | PID move to | XYZ (µm), direction, configuration | Onboard IK + PID; requires calibration |

Motion shaping applies through `Acceleration`, `MaxSpeed`, `StartSpeed`, and `CartesianSpeed` parameters.
In DDE, the high-level `move_to(X, Y, Z, direction, config)` wraps these, taking meters. The commanded
position from `a`/`M` is summed with the PID offset from `P`/`C`. *Source: wiki `Kinematics.md`,
`Command-oplet-instruction.md`.*

## Workspace envelope

The reachable envelope is bounded by the joint travel limits above, the link lengths, configuration
constraints, and singularity avoidance — it is not a simple sphere. Maximum reach from the base axis is
≈ 0.79 m (derived: L2 + L3 + L4 + L5), and reliable motion is available around the nominal working point
`[0, 0.5, 0.075]` m. The motion envelope is documented as measured side-view and top-view profiles
(wiki `Kinematics.md`); characterizing the envelope on a physical build closes REQ-WS-6/WS-8
([009](009-Design-Completion.md)).
