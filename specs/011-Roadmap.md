# 011 — Roadmap

Improvements anticipated beyond the current design, in rough priority order. Each becomes one or more change
requests when a revision is opened, recorded in [CHANGES.md](../CHANGES.md) in the format defined by
[010-Versioning.md](010-Versioning.md#5-change-record-format).

**Scope boundary.** Items that are *decisions required to finish the current design itself* live in
[009-Design-Completion.md](009-Design-Completion.md), not here. The roadmap is for improvements *beyond* a
complete design. An item moves off this roadmap when it is opened as a change request on a revision
branch; it is not deleted until that revision is released.

1. **Validate the current design on a physical build.** Close the `[Provisional]` items in
   [009](009-Design-Completion.md) by building and measuring one unit; feed corrections back into the specs. This is the
   precondition for every later roadmap item.
2. **Validate the strain-wave and differential designs on a build.** Both are now settled on paper
   (DC-1 procurement-confirmed; DC-2 authored as parametric OpenSCAD — see
   [009](009-Design-Completion.md)); item 1's build promotes them to validated designs, including the
   differential first-build checklist under DC-9.
3. **Purpose-built Motor Control PCB.** Replace the board inherited from the previous version (used
   provisionally, see [005](005-Electronics-and-Control.md#boards)) with a board designed to this robot's
   wiring and wrist-drive requirements. **Treat the input ceiling as a design parameter rather than an
   inherited limit.** USB-C PD 3.1 EPR carries 36 V as a standard fixed supply, and a source rated 180 W
   or more offers it at 5 A over an EPR-marked cable — ample against the robot's ≥ 4 A. It does not fit
   the present board: EPR's expected maximum at 36 V nominal is **38.3 V**, above the 38 V this board's
   `LTC3786` permits, and an unclamped disconnect transient reaches **44.3 V**. A ceiling at the
   in-testing "blue" board's 75 V ([DC-8](009-Design-Completion.md#power-supply)) accommodates both, and
   would reduce the supply to a commodity cable in place of the dedicated brick and snap-and-lock inlet
   [DC-11(j)](009-Design-Completion.md#procurement-data) specifies. A board taking EPR power must also
   treat loss of negotiation as a motion fault: EPR holds the contract only
   while the sink keeps talking to the source, and one second of silence drops the rail.
4. **Documented, parametric CAD.** Bring the mechanical design under a single parametric CAD source so link
   lengths and reductions can be re-derived per revision rather than hand-adjusted.
5. **Generalized task programming.** A task-learning layer (policy that generalizes across object
   positions and tasks) on top of the socket/oplet protocol. Out of scope for the base robot; a candidate
   new subsystem specified in its own document if pursued.
6. **Payload, speed, and reach envelope characterization.** Measure and publish the performance figures
   that [002-Requirements.md](002-Requirements.md) currently marks for confirmation, turning derived or
   the open performance numbers into measured ones.
