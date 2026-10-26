---
goal: "Implement Granular Sand Piling Physics, Countdown Cup, and Overflow Spill"
version: "1.0"
date_created: "2026-09-07"
last_updated: "2026-09-07"
owner: "Planner Architect"
status: "Planned"
tags: ["architecture", "physics", "rendering", "sand-piling", "heightmap", "countdown-cup"]
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-planned-blue)

This Implementation Plan establishes the step-by-step roadmap to implement **Granular Sand Piling Physics, Countdown Cup, and Overflow Spill** in **Micin Micin**.

Following the approval of the Technical Specification ([spec/spec-architecture-sand-piling-physics.md](file:///d:/kayzz/flutter/micin/spec/spec-architecture-sand-piling-physics.md)) and its Clarification Audit ([docs/audit/clarification-report-spec-sand-piling-physics-2026-09-07.md](file:///d:/kayzz/flutter/micin/docs/audit/clarification-report-spec-sand-piling-physics-2026-09-07.md)), this plan executes a total overhaul of the particle visual fidelity, cup containment, and sand mound accumulation mechanics:
1. **Fine Granular Particles & Organic Emitter Dispersal**: Calibration from chunky dots ($r=2.5$, $g=0.25$) to powdery crystals ($r=1.1$, $g=0.14$, $v_{\max}=4.8$, crystalline opacity $\alpha \in [0.85, 1.0]$, emitter velocity/position jitter).
2. **Rigid U-Shaped Target Cup & Pure Countdown HUD**: 3 solid container barriers (left, bottom, right), Option A Color Selective Membrane top aperture, and replacement of the synthetic liquid fill rectangle (`fluidPaint`) with a clean integer countdown ($\text{remaining} = \max(0, \text{target} - \text{settled})$).
3. **1D Discrete Column Heightmap ($O(1)$) & Angle of Repose**: Division of cup width into $2.0$ px bins, natural slope relaxation ($\Delta H_{\max} = 1.4$ px $\approx 35^\circ$), batch point rendering of resting sand mounds, and Option A locked settled sand under gravity inversion.
4. **Overflow Spill Mechanics & 30-Level Quota Migration**: Cascading excess particles over the cup rims when full, and updating all 30 stages to the $150 \times N_{\text{cups}}$ particle supply formula.

> **Upstream Specification**: [spec/spec-architecture-sand-piling-physics.md](file:///d:/kayzz/flutter/micin/spec/spec-architecture-sand-piling-physics.md)  
> **PRD Reference**: [docs/prd-20260907-sand-piling-physics.md](file:///d:/kayzz/flutter/micin/docs/prd-20260907-sand-piling-physics.md)  
> **Clarification Report**: [docs/audit/clarification-report-spec-sand-piling-physics-2026-09-07.md](file:///d:/kayzz/flutter/micin/docs/audit/clarification-report-spec-sand-piling-physics-2026-09-07.md) (Score: 100/100, Option A)  
> **ADR Reference**: [docs/adr/0003-discrete-column-heightmap-sand-piling.md](file:///d:/kayzz/flutter/micin/docs/adr/0003-discrete-column-heightmap-sand-piling.md)  
> **Domain Glossary**: [CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md)  

---

## 1. Requirements & Constraints

- **REQ-001**: Particle radius calibrated to $kParticleRadius = 1.1$ virtual px (stroke width $2.2$ px), with crystalline opacity variation $\alpha \in [0.85, 1.0]$.
- **REQ-002**: Gravitational acceleration calibrated to $kGravityDefault = 0.14$ virtual px/frame², with maximum velocity clamped to $kMaxSpeed = 4.8$ virtual px/frame.
- **REQ-003**: Particle Emitter dispenses particles with horizontal velocity jitter $v_x \in [-0.25, 0.25]$ virtual px/frame and position jitter $x \pm 1.2$ virtual px.
- **REQ-004**: Target Cups feature 3 physical rigid barriers (left wall, floor, right wall) with an open top aperture protected by Option A Color Selective Membrane (matching color penetrates; non-matching deflects sideways with $0.3$ restitution).
- **REQ-005**: Target Cups render a pure countdown integer ($\text{remaining} = \max(0, \text{target} - \text{settledCount})$). The synthetic liquid fill box (`fluidPaint`) must be deleted.
- **REQ-006**: Target Cups implement a 1D Discrete Column Heightmap ($2.0$ px bin width) enforcing an Angle of Repose ($\Delta H_{\max} = 1.4$ px). Settled particles remain rendered as a granular Sand Mound. Settled particles are locked and immune to gravity inversion (Option A).
- **REQ-007**: When a Target Cup is full and the Sand Mound exceeds the rim height, excess particles rolling off the mound cone are ejected as an Overflow Spill ($v_x = \pm 1.0, v_y = 0.5$), regaining active free-fall gravity.
- **REQ-008**: All 30 level configurations provide a total particle supply calculated via $\text{Total Sugar} = 150 \times N_{\text{cups}}$. Stage victory triggers when all cups reach $\text{remaining} == 0$.
- **CON-001**: Steady 60 FPS performance (<16.6ms per frame) with 500 active granular particles on mobile hardware.
- **CON-002**: Pure headless execution of the physics engine in Dart unit tests without Flutter UI bindings.
- **SEC-001**: 100% offline execution; zero network permissions or external telemetry.
- **GUD-001**: Zero heap allocations inside the frame ticker loop. Heightmap bins must use pre-allocated fixed-size arrays (`Float64List`).

---

## 2. Implementation Steps

> **EXECUTION DIRECTIVE FOR AI AGENTS:**  
> You MUST execute this plan phase by phase. You MUST run the specific testing/verification task at the end of each phase. After a phase is tested, you **MUST STOP AND WAIT** for the user's explicit approval before proceeding to the next phase.

---

### Implementation Phase 1 — Granular Particle Kinematics & Organic Emitter Dispersal (Tracer Bullet 1)

- **GOAL-001**: Implement powdery granular particle dimensions ($r=1.1$), soft gravity ($g=0.14$), terminal velocity ($v_{\max}=4.8$), organic emitter velocity/position jitter, and crystalline opacity variation with 100% passing headless unit tests.

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
|---|---|---|---|---|---|---|---|
| TASK-101 | Update core physics constants in `lib/core/constants.dart`: set `kParticleRadius = 1.1`, `kGravityDefault = 0.14`, `kMaxSpeed = 4.8`, `kHeightmapBinWidth = 2.0`, `kReposeSlopeMax = 1.4`, and `kCupWallThickness = 2.5`. | REQ-001, REQ-002 | AC-001, AC-002 | - | 1 | [x] | 2026-09-07 |
| TASK-102 | Update `SugarParticle` in `lib/models/sugar_particle.dart` to add crystalline opacity factor `final double opacity` ($\in [0.85, 1.0]$) and enhance `ParticleEmitter` in `lib/engine/particle/particle_emitter.dart` to spawn particles with horizontal velocity jitter $v_x \in [-0.25, 0.25]$ and position jitter $x \pm 1.2$. | REQ-001, REQ-003 | AC-001 | TASK-101 | 2 | [x] | 2026-09-07 |
| TASK-103 | Update `ParticleController` in `lib/engine/particle/particle_controller.dart` physics update loop: apply soft gravity ($0.14$), clamp velocity magnitude to $4.8$, and update `ParticlePainter` in `lib/screens/game/painters/particle_painter.dart` to render particles with stroke width $2.2$ px and individual opacity. | REQ-001, REQ-002 | AC-001, AC-002 | TASK-102 | 2 | [x] | 2026-09-07 |
| TASK-104 | Update and expand unit tests in `test/engine/particle_controller_test.dart` and `test/engine/particle_emitter_test.dart` asserting: (1) free-fall traversal from $y=50$ to $650$ takes $125 \le \text{frames} \le 145$ (~2.2s at 60 FPS), (2) velocity is clamped to $4.8$, (3) emitter disperses with velocity and position jitter. | REQ-001, REQ-002, REQ-003 | AC-001, AC-002 | TASK-103 | 2 | [x] | 2026-09-07 |
| TASK-105 | **VERIFY**: Run `flutter test test/engine/` and `flutter analyze` to verify zero failures and zero analyzer issues. | - | - | TASK-104 | - | [x] | 2026-09-07 |
| TASK-106 | **APPROVAL**: Wait for explicit user confirmation before proceeding to Phase 2. | - | - | TASK-105 | - | [x] | 2026-09-07 |

---

### Implementation Phase 2 — Rigid U-Shaped Target Cup & Pure Countdown Display (Tracer Bullet 2)

- **GOAL-002**: Establish rigid U-shaped physical container barriers for Target Cups, implement the Option A Color Selective Membrane on the top aperture, and eliminate the synthetic liquid fill rectangle (`fluidPaint`) in favor of a clean countdown integer display.

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
|---|---|---|---|---|---|---|---|
| TASK-201 | Enhance `CupHitbox` in `lib/engine/collision/cup_hitbox.dart` to define 3 rigid solid barrier segments (left wall, floor, right wall) and top aperture Color Selective Membrane: matching colors pass into aperture; non-matching colors deflect upward and outward ($v_y = -v_y \times 0.3, v_x \pm 0.5$). | REQ-004 | AC-003 | TASK-106 | 1 | [x] | 2026-09-07 |
| TASK-202 | Update `LevelPainter` in `lib/screens/game/painters/level_painter.dart`: delete `fluidPaint` rectangle rendering, preserve U-shaped cup boundary line drawing, and render a pure countdown integer $\text{remaining} = \max(0, \text{target} - \text{settledCount})$ centered in the cup (transitioning to gold `#FFD54F` upon reaching 0). | REQ-005 | AC-004 | TASK-201 | 1 | [x] | 2026-09-07 |
| TASK-203 | Update unit tests in `test/engine/cup_hitbox_test.dart` and widget tests in `test/screens/game_screen_test.dart`: verify non-matching color rejection at cup aperture, countdown text updates upon capture, and zero visual liquid box rendering. | REQ-004, REQ-005 | AC-003, AC-004 | TASK-202 | 2 | [x] | 2026-09-07 |
| TASK-204 | **VERIFY**: Run `flutter test test/engine/cup_hitbox_test.dart test/screens/game_screen_test.dart` to verify zero failures and clean visual HUD. | - | - | TASK-203 | - | [x] | 2026-09-07 |
| TASK-205 | **APPROVAL**: Wait for explicit user confirmation before proceeding to Phase 3. | - | - | TASK-204 | - | [x] | 2026-09-07 |

---

### Implementation Phase 3 — Discrete Column Heightmap Sand Mound & Angle of Repose (Tracer Bullet 3)

- **GOAL-003**: Implement high-performance $O(1)$ 1D Discrete Column Heightmap sand piling inside Target Cups, enforce natural Angle of Repose ($\Delta H_{\max} = 1.4$ px $\approx 35^\circ$), render resting sand mounds in GPU batch points, and lock settled sand against gravity inversion (Option A).

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
|---|---|---|---|---|---|---|---|
| TASK-301 | Add heightmap data structures (`Float64List columnHeights`, `List<Offset> settledParticleOffsets`, `binCount`) and implement discrete bin mapping with Angle of Repose slope relaxation algorithm in `CupHitbox.processParticle` in `lib/engine/collision/cup_hitbox.dart`. | REQ-006 | AC-005 | TASK-205 | 1 | [x] | 2026-09-07 |
| TASK-302 | Enforce Option A Locked Settled Sand logic: ensure `columnHeights` and `settledParticleOffsets` in `CupHitbox` remain immutable during gravity inversion events (e.g., Level 21, 24, 27, 30 gravity toggles), keeping settled sand locked inside the cup. | REQ-006 | AC-005 | TASK-301 | 1 | [x] | 2026-09-07 |
| TASK-303 | Update `ParticlePainter` in `lib/screens/game/painters/particle_painter.dart` to batch-render settled sand points stored in each cup's `settledParticleOffsets` via `Canvas.drawPoints(PointMode.points)` with cup color matching active granular particles. | REQ-006 | AC-005 | TASK-302 | 1 | [x] | 2026-09-07 |
| TASK-304 | Create dedicated unit tests in `test/engine/sand_piling_test.dart`: verify (1) single-point stream relaxes symmetrically into a conical sand mound, (2) adjacent column height difference never exceeds $\Delta H_{\max} = 1.4$ px, (3) settled particles remain unchanged when gravity inverts upward. | REQ-006 | AC-005 | TASK-303 | 1 | [x] | 2026-09-07 |
| TASK-305 | **VERIFY**: Run `flutter test test/engine/` to verify all physics and heightmap tests pass with 0 failures. | - | - | TASK-304 | - | [x] | 2026-09-07 |
| TASK-306 | **APPROVAL**: Wait for explicit user confirmation before proceeding to Phase 4. | - | - | TASK-305 | - | [x] | 2026-09-07 |

---

### Implementation Phase 4 — Overflow Spill Mechanics & 30-Level Quota Migration (Tracer Bullet 4)

- **GOAL-004**: Implement Overflow Spill mechanics that eject excess particles over cup rims when full, migrate all 30 level configurations to the $150 \times N_{\text{cups}}$ particle supply formula, verify full end-to-end integration tests, and update living architecture documentation.

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
|---|---|---|---|---|---|---|---|
| TASK-401 | Implement Overflow Spill rim ejection in `CupHitbox.processParticle`: when column height at bin $b$ reaches `bounds.height`, reposition excess particle at the nearest cup rim ($x = \text{bounds.left} - 2.0$ or $\text{bounds.right} + 2.0$, $y = \text{bounds.top} - 1.0$), assign ejection velocity ($v_x = \pm 1.0, v_y = 0.5$), and return `false` to keep particle active in the world. | REQ-007 | AC-006 | TASK-306 | 1 | [x] | 2026-09-07 |
| TASK-402 | Integrate overflow particle cascading in `ParticleController`: ensure spilled particles participate in line collisions, can enter lower cups of matching color, and are recycled at $y > 750.0$. | REQ-007 | AC-006 | TASK-401 | 1 | [x] | 2026-09-07 |
| TASK-403 | Migrate all 30 level configurations in `micin_micin/assets/levels/` (`level_01.json` through `level_30.json`) to the $150 \times N_{\text{cups}}$ quota formula (`totalSugar = 150 * cups.length`, divided equally among active emitters). | REQ-008 | AC-007 | TASK-402 | 30 | [x] | 2026-09-07 |
| TASK-404 | Create comprehensive integration test `test/integration/sand_piling_integration_test.dart` simulating full-stage pouring: validating countdown decrement from target to 0, conical sand mound piling, overflow particle cascading over cup rims, and stage completion. | REQ-006, REQ-007, REQ-008 | AC-005, AC-006, AC-007 | TASK-403 | 1 | [x] | 2026-09-07 |
| TASK-405 | Update living architecture map [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md) to record the Discrete Column Heightmap pipeline, Angle of Repose slope relaxation, and Overflow Spill mechanics. | REQ-006, REQ-007 | - | TASK-404 | 1 | [x] | 2026-09-07 |
| TASK-406 | **VERIFY**: Execute the complete test suite (`flutter test`, expecting $\ge 105$ passing tests with 0 failures) and static analysis (`flutter analyze` with 0 warnings). | CON-001, CON-002 | AC-007 | TASK-405 | - | [x] | 2026-09-07 |
| TASK-407 | **APPROVAL**: Final milestone completion approval. | - | - | TASK-406 | - | [x] | 2026-09-08 |

---

## 3. Alternatives

- **ALT-001 (Full Rigid Body 2D Contact Solver - Box2D / Forge2D):** Rejected. Inter-particle collision across 500+ dynamic bodies requires $O(N^2)$ constraint solving, dropping frame rates to $<20$ FPS on mobile CPUs. The 1D Discrete Column Heightmap achieves authentic sand stacking in deterministic $O(1)$ time.
- **ALT-002 (Smooth Gaussian Heightmap Interpolation):** Rejected. Continuous curve approximation between columns blurs granular edges and increases per-frame floating point math without tangible visual benefit over discrete 2.0px bins.
- **ALT-003 (Option B: Dynamic Settled Sand Resimulation under Gravity Toggle):** Rejected during Clarification Gate. Resimulating settled particles during upward gravity inversion destabilizes achieved player score, violates classic *Sugar, Sugar* puzzle fairness, and introduces severe state churn. Option A (Locked Settled Sand) is formally adopted.

---

## 4. Dependencies

- **DEP-001**: Flutter SDK (3.x) & Dart SDK (3.12+)
- **DEP-002**: `flutter_riverpod` (Game engine lifecycle and reactive state management)
- **DEP-003**: `flutter_test` (Deterministic headless testing harness)

---

## 5. Files

### Created Files
- `micin_micin/test/engine/sand_piling_test.dart`: Unit tests for discrete column heightmap, slope relaxation, and locked settled sand.
- `micin_micin/test/integration/sand_piling_integration_test.dart`: End-to-end multi-frame integration test verifying sand piling, countdown, and overflow spilling.

### Modified Files
- `micin_micin/lib/core/constants.dart`: Updated granular particle and heightmap constants ($kParticleRadius, kGravityDefault, kMaxSpeed, kHeightmapBinWidth, kReposeSlopeMax$).
- `micin_micin/lib/models/sugar_particle.dart`: Added crystalline opacity factor and capture flags.
- `micin_micin/lib/engine/particle/particle_emitter.dart`: Added velocity and position jitter.
- `micin_micin/lib/engine/particle/particle_controller.dart`: Calibrated soft gravity and overflow particle integration.
- `micin_micin/lib/engine/collision/cup_hitbox.dart`: Physical U-shaped barriers, Option A selective membrane, 1D discrete heightmap, slope relaxation, and overflow ejection.
- `micin_micin/lib/screens/game/painters/level_painter.dart`: Deleted `fluidPaint` rect; implemented pure integer countdown text.
- `micin_micin/lib/screens/game/painters/particle_painter.dart`: Updated particle stroke width ($2.2$ px) and batch rendering of resting sand mounds.
- `micin_micin/assets/levels/level_01.json` through `level_30.json`: Migrated 30 level configurations to $150 \times N_{\text{cups}}$ total particle supply.
- `micin_micin/test/engine/particle_controller_test.dart`: Kinematics and fall duration test updates.
- `micin_micin/test/engine/cup_hitbox_test.dart`: Membrane deflection and countdown verification tests.
- `docs/ARCHITECTURE.md`: Living architecture documentation update.

---

## 6. Testing

- **TEST-001 (Kinematics & Free-Fall Traversal):** `test/engine/particle_controller_test.dart` asserting that a particle in free fall from $y=50$ to $650$ takes $125 \le \text{frames} \le 145$ (~2.2s at 60 FPS) with $v_{\max} = 4.8$.
- **TEST-002 (Color Selective Membrane Rejection - Option A):** `test/engine/cup_hitbox_test.dart` asserting non-matching color particles deflect off the top aperture ($v_y < 0$) without incrementing capture score.
- **TEST-003 (Countdown Display Integrity):** `test/engine/cup_hitbox_test.dart` asserting that $\text{remaining}$ starts at $\text{targetAmount}$, decrements strictly as matching particles settle, and clamps at 0.
- **TEST-004 (Angle of Repose & Sand Mound Stacking):** `test/engine/sand_piling_test.dart` asserting that pouring into a single bin expands symmetrically into a conical sand mound with $\Delta H \le 1.4$ px.
- **TEST-005 (Gravity Inversion Settled Sand Immunity - Option A):** `test/engine/sand_piling_test.dart` asserting that settled sand points and heightmap values remain unchanged when gravity inverts upward.
- **TEST-006 (Overflow Spill Ejection):** `test/integration/sand_piling_integration_test.dart` asserting that excess particles roll over the cup rim, retain active physics, and cascade outside the cup.
- **TEST-007 (Level Quota & 100% Regression Suite):** Entire test suite running via `flutter test` with $\ge 105$ passing tests and 0 analyzer warnings (`flutter analyze`).

---

## 7. Risks & Assumptions

- **ASSUMPTION-001**: The discrete column heightmap resolution is fixed at $2.0$ virtual pixels per bin, delivering high visual fidelity with negligible memory footprint.
- **ASSUMPTION-002**: The angle of repose slope threshold is mathematically modeled as $\Delta H_{\max} = \tan(35^\circ) \times \text{binWidth} \approx 0.70 \times 2.0 = 1.4\text{ virtual px}$.
- **ASSUMPTION-003**: Emitter particle supply for multi-emitter levels is divided equally across active emitters.
- **ASSUMPTION-004**: Settled particles inside cups are permanently locked and immune to gravity toggle inversion (Option A).
- **RISK-001 (Frame Stutter During Rapid Settling):** Pre-allocating `Float64List` in `CupHitbox` and reusing particle pool slots avoids heap allocations and GC spikes during intense pouring streams.
- **RISK-002 (Excess Spilled Particle Accumulation):** Spilled particles exiting through the canvas floor ($y > 750.0$) are recycled immediately by `ParticleController`, preventing particle pool exhaustion.

---

## 8. Related Specifications / Further Reading

- [Technical Specification: Sand Piling Physics](file:///d:/kayzz/flutter/micin/spec/spec-architecture-sand-piling-physics.md)
- [PRD: Granular Sand Piling Physics](file:///d:/kayzz/flutter/micin/docs/prd-20260907-sand-piling-physics.md)
- [Clarification Report (Final)](file:///d:/kayzz/flutter/micin/docs/audit/clarification-report-spec-sand-piling-physics-2026-09-07.md)
- [ADR 0003: Discrete Column Heightmap Sand Piling](file:///d:/kayzz/flutter/micin/docs/adr/0003-discrete-column-heightmap-sand-piling.md)
- [Living Architecture Map: docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md)
- [Domain Glossary: CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md)

---

## 9. Rollback / Recovery Plan

1. If physics instability or performance regressions occur during Phase 2 or Phase 3, revert code changes via Git:
   ```bash
   git checkout -- lib/ test/ assets/levels/
   ```
2. If necessary, restore baseline constants in `lib/core/constants.dart`:
   - `kParticleRadius = 2.5`
   - `kGravityDefault = 0.25`
   - `kMaxSpeed = 8.0`
3. Level JSON files can be rolled back to baseline quotas from git history if migration needs revision.
