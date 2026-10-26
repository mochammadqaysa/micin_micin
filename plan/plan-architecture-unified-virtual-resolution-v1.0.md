---
goal: "Migrate Micin Micin to Unified Virtual Resolution (400x700) and Calibrated Natural Physics"
version: "1.0"
date_created: "2026-09-07"
last_updated: "2026-09-07"
owner: "Planner Architect"
status: "Completed"
tags: ["architecture", "refactor", "physics", "coordinates", "rendering"]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-completed-brightgreen)

This Implementation Plan breaks down the migration of **Micin Micin** from fragmented dual coordinate spaces (normalized `[0..1]` physics vs device pixel gestures) into a fixed **Unified Virtual Resolution ($400 \times 700$ virtual pixels)** and calibrated gravity ($g = 0.25\text{ virtual px/frame}^2$, $v_{\max} = 8.0\text{ virtual px/frame}$).

The plan is architected strictly using **Vertical Slicing (Tracer Bullets)** and the **Expand-Contract Pattern** across 4 independently verifiable phases. It directly addresses the two critical gameplay discrepancies:
1. Particles falling across the screen in only 3 frames (50ms) instead of a smooth granular cascade (~1.1s / 67 frames).
2. Player-drawn stroke barriers failing to deflect particles at target cup apertures due to distance mismatch.

> **Upstream Specification**: [spec/spec-architecture-unified-virtual-resolution.md](file:///d:/kayzz/flutter/micin/spec/spec-architecture-unified-virtual-resolution.md)  
> **Clarification Report**: [docs/audit/clarification-report-unified-virtual-resolution-2026-09-07.md](file:///d:/kayzz/flutter/micin/docs/audit/clarification-report-unified-virtual-resolution-2026-09-07.md) (Score: 100/100, Option A Selected)  
> **ADR Reference**: [docs/adr/0002-unified-virtual-resolution.md](file:///d:/kayzz/flutter/micin/docs/adr/0002-unified-virtual-resolution.md)  
> **Domain Glossary**: [CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md)  

---

## 1. Requirements & Constraints

- **REQ-001**: All physics entities ([SugarParticle](file:///d:/kayzz/flutter/micin/micin_micin/lib/models/sugar_particle.dart), [CupHitbox](file:///d:/kayzz/flutter/micin/micin_micin/lib/engine/collision/cup_hitbox.dart), [LineSegment](file:///d:/kayzz/flutter/micin/micin_micin/lib/engine/collision/line_segment.dart), [ParticleEmitter](file:///d:/kayzz/flutter/micin/micin_micin/lib/engine/particle/particle_emitter.dart), [ColorFilterZone](file:///d:/kayzz/flutter/micin/micin_micin/lib/engine/color_filter/color_filter_zone.dart)) must operate in a standardized $400 \times 700$ virtual coordinate space.
- **REQ-002**: Bi-directional transformation utility (`VirtualCoordinateAdapter`) converting between physical screen pixels and virtual $400 \times 700$ space with aspect-ratio scaling and letterboxing.
- **REQ-003**: Calibrated physics constants: `kGravityDefault = 0.25 virtual px/frame²`, `kMaxSpeed = 8.0 virtual px/frame`, `kParticleRadius = 2.5`, `kLineThickness = 5.0`. Free-fall traversal must take 60–75 frames (~1.1s).
- **REQ-004**: Barrier collision impenetrability: 100% of particles hitting a stroke barrier must be deflected, preventing penetration into target cups when blocked.
- **REQ-005**: Viewport transformation rendering: Custom painters must draw directly in native $400 \times 700$ coordinates under a single transformed canvas context (`canvas.translate(dx, dy)` and `canvas.scale(scale)`).
- **REQ-006**: Dual Ingestion Compatibility in [LevelConfig.fromJson](file:///d:/kayzz/flutter/micin/micin_micin/lib/models/level_config.dart) + permanent migration of all 30 `level_*.json` asset files to integer $400 \times 700$ coordinates (Option A).
- **CON-001**: Steady 60 FPS performance with 500 active particles (<16.6ms per frame).
- **CON-002**: Pure headless execution of physics engine in Dart unit tests without Flutter UI bindings.
- **GUD-001**: Zero heap allocations in the frame ticker loop or gesture conversion callbacks.

---

## 2. Implementation Steps

> **EXECUTION DIRECTIVE FOR AI AGENTS:**  
> You MUST execute this plan phase by phase. You MUST run the specific testing/verification task at the end of each phase. After a phase is tested, you **MUST STOP AND WAIT** for the user's explicit approval before proceeding to the next phase.

---

### Implementation Phase 1 — Foundation & Coordinate Adapter (Tracer Bullet 1)

- **GOAL-001**: Establish the mathematical coordinate adapter and core virtual dimension constants with 100% unit test coverage across multiple aspect ratios.

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
|---|---|---|---|---|---|---|---|
| TASK-101 | Add $400 \times 700$ virtual canvas dimensions and update calibrated physics constants (`kVirtualWidth = 400.0`, `kVirtualHeight = 700.0`, `kGravityDefault = 0.25`, `kMaxSpeed = 8.0`, `kParticleRadius = 2.5`, `kLineThickness = 5.0`) in `lib/core/constants.dart`. | REQ-001, REQ-003 | AC-002 | - | 1 | [x] | 2026-09-07 |
| TASK-102 | Implement `VirtualCoordinateAdapter` in `lib/engine/drawing/virtual_coordinate_adapter.dart` providing `computeScale`, `computeOffset`, `screenToVirtual`, and `virtualToScreen` with boundary clamping $[0..400] \times [0..700]$. | REQ-002 | AC-003 | TASK-101 | 1 | [x] | 2026-09-07 |
| TASK-103 | Create unit test suite in `test/engine/virtual_coordinate_adapter_test.dart` validating scale, letterbox centering offsets, touch transformation accuracy, and clamping across 9:16, 19.5:9, and 4:3 screen aspect ratios. | REQ-002 | AC-003 | TASK-102 | 1 | [x] | 2026-09-07 |
| TASK-104 | **VERIFY**: Run `flutter test test/engine/virtual_coordinate_adapter_test.dart` and `flutter analyze` to ensure zero failures and zero analyzer issues. | - | - | TASK-103 | - | [x] | 2026-09-07 |
| TASK-105 | **APPROVAL**: Wait for explicit user confirmation before proceeding to Phase 2. | - | - | TASK-104 | - | [ ] | |

---

### Implementation Phase 2 — Headless Physics Engine & Collision Recalibration (Tracer Bullet 2)

- **GOAL-002**: Re-anchor all core physics models, collision boundaries, and kinematics integration to $400 \times 700$ virtual coordinates, verifying smooth 67-frame fall duration and 100% stroke collision impenetrability in headless unit tests.

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
|---|---|---|---|---|---|---|---|
| TASK-201 | Update `CupHitbox.fromConfig`, `LineSegment`, and `ColorFilterZone.fromConfig` to evaluate bounds and distances natively in $400 \times 700$ virtual coordinates without normalization scaling. | REQ-001, REQ-004 | AC-001 | TASK-105 | 3 | [x] | 2026-09-07 |
| TASK-202 | Update `ParticleController` physics loop: apply calibrated gravity ($0.25$), clamp velocity to $\pm 8.0$, and tighten out-of-bounds recycling boundaries to $x \in [-50.0, 450.0]$ and $y \in [-50.0, 750.0]$. | REQ-001, REQ-003 | AC-002 | TASK-201 | 1 | [x] | 2026-09-07 |
| TASK-203 | Implement Option A Dual Ingestion in `LevelConfig.fromJson`, `EmitterConfig.fromJson`, `CupConfig.fromJson`, and `ColorFilterConfig.fromJson` with automatic scaling ($400 \times 700$) if input coordinates are normalized (`canvasHeight <= 2.0`). | REQ-006 | AC-001 | TASK-202 | 4 | [x] | 2026-09-07 |
| TASK-204 | Update and expand headless unit tests in `test/engine/line_segment_test.dart`, `test/engine/cup_hitbox_test.dart`, and `test/engine/game_engine_test.dart` verifying: (1) free-fall traversal takes 60–75 frames (~1.1s), (2) a barrier drawn across cup mouth deflects 100% of particles, (3) matching particles increment score. | REQ-001, REQ-003, REQ-004 | AC-001, AC-002 | TASK-203 | 3 | [x] | 2026-09-07 |
| TASK-205 | **VERIFY**: Run `flutter test test/engine/` to ensure all engine and collision tests pass with 0 failures. | - | - | TASK-204 | - | [x] | 2026-09-07 |
| TASK-206 | **APPROVAL**: Wait for explicit user confirmation before proceeding to Phase 3. | - | - | TASK-205 | - | [x] | 2026-09-07 |

---

### Implementation Phase 3 — Viewport Rendering & Touch Gesture Integration (Tracer Bullet 3)

- **GOAL-003**: Connect presentation layer rendering and user touch gestures to the unified virtual coordinate space, delivering a fully interactive game loop where strokes block particles on screen.

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
|---|---|---|---|---|---|---|---|
| TASK-301 | Update `LinePainter`, `ParticlePainter`, and `LevelPainter` to render all elements natively in $400 \times 700$ coordinates, removing ad-hoc `p.x * size.width` multiplications. | REQ-005 | AC-001, AC-003 | TASK-206 | 3 | [x] | 2026-09-07 |
| TASK-302 | Update `GameScreen`: wrap touch gesture callbacks (`onPanStart`, `onPanUpdate`) with `VirtualCoordinateAdapter.screenToVirtual`, apply letterboxed canvas root transform (`canvas.translate` + `canvas.scale`), and render letterbox margins with `#101012`. | REQ-002, REQ-005 | AC-001, AC-003 | TASK-301 | 1 | [x] | 2026-09-07 |
| TASK-303 | Update and run widget test suite in `test/screens/game_screen_test.dart` and `test/widget_test.dart` validating touch translation and rendered element visibility across different device viewport constraints. | REQ-002, REQ-005 | AC-003 | TASK-302 | 2 | [x] | 2026-09-07 |
| TASK-304 | **VERIFY**: Run `flutter test` across all unit and widget tests to verify zero regressions. | - | - | TASK-303 | - | [x] | 2026-09-07 |
| TASK-305 | **APPROVAL**: Wait for explicit user confirmation before proceeding to Phase 4. | - | - | TASK-304 | - | [x] | 2026-09-07 |

---

### Implementation Phase 4 — 30-Level Asset Migration & Quality Verification (Tracer Bullet 4)

- **GOAL-004**: Complete Option A execution by migrating all 30 level JSON files to integer $400 \times 700$ coordinates, verifying full regression test suite pass rate, and updating documentation.

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
|---|---|---|---|---|---|---|---|
| TASK-401 | Systematically migrate all 30 level JSON files in `micin_micin/assets/levels/` (`level_01.json` through `level_30.json`) to native $400 \times 700$ integer coordinates (`canvasHeight = 700.0`, emitter/cup coordinates scaled by 400 and 700). | REQ-006 | AC-001 | TASK-305 | 30 | [x] | 2026-09-07 |
| TASK-402 | Update `test/data/level_repository_test.dart` and `test/integration/level_progression_test.dart` to validate loading and serialization of native $400 \times 700$ level assets. | REQ-006 | AC-001 | TASK-401 | 2 | [x] | 2026-09-07 |
| TASK-403 | Execute full test suite (`flutter test`) and linter analysis (`flutter analyze`), ensuring all tests pass with 0 failures, 0 skipped assertions, and 0 warnings. | CON-001, CON-002 | AC-004 | TASK-402 | - | [x] | 2026-09-07 |
| TASK-404 | Update living architecture map [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md) to record the Unified Virtual Resolution coordinate system and `VirtualCoordinateAdapter` pipeline. | REQ-001 | - | TASK-403 | 1 | [x] | 2026-09-07 |
| TASK-405 | **VERIFY**: Confirm full test suite passes with 0 failures (`flutter test`) and zero linter warnings (`flutter analyze`). | - | - | TASK-404 | - | [x] | 2026-09-07 |
| TASK-406 | **APPROVAL**: Final milestone completion approval. | - | - | TASK-405 | - | [x] | 2026-09-07 |

---

## 3. Alternatives

- **ALT-001 (Flame / Forge2D Engine):** Rejected. Evaluated in Discovery Phase 0; Forge2D rigid-body constraint solvers introduce prohibitive CPU overhead ($O(N^2)$) on 500+ dynamic particles, causing severe FPS drops on mobile devices, and alters the authentic granular sand physics.
- **ALT-002 (Dynamic Viewport Sizing Without Letterboxing):** Rejected. Allows level objects to stretch or shift across non-standard aspect ratios, which introduces variable physics trajectories on different phone models. A fixed $400 \times 700$ virtual canvas ensures identical physics on all devices.
- **ALT-003 (Runtime Normalization Multiplication without JSON Migration - Option B):** Rejected. Leaves assets in fractional floats that are confusing for level design and requires ongoing runtime conversion heuristics.

---

## 4. Dependencies

- **DEP-001**: Flutter SDK (3.x) & Dart SDK (3.12+)
- **DEP-002**: `flutter_riverpod` (State management & game engine lifecycle)
- **DEP-003**: `flutter_test` (Deterministic headless testing harness)

---

## 5. Files

### Created Files
- `micin_micin/lib/engine/drawing/virtual_coordinate_adapter.dart`: Bi-directional coordinate scaling and translation adapter.
- `micin_micin/test/engine/virtual_coordinate_adapter_test.dart`: Unit tests for scale factor, letterboxing offsets, and clamping.

### Modified Files
- `micin_micin/lib/core/constants.dart`: Virtual resolution dimensions and recalibrated physics constants.
- `micin_micin/lib/engine/collision/line_segment.dart`: Virtual coordinate thickness and deflection calculation.
- `micin_micin/lib/engine/collision/cup_hitbox.dart`: Direct $400 \times 700$ bounding box instantiation.
- `micin_micin/lib/engine/color_filter/color_filter_zone.dart`: Direct $400 \times 700$ filter zone instantiation.
- `micin_micin/lib/engine/particle/particle_controller.dart`: Gravitational integration, velocity clamp, and recycling bounds.
- `micin_micin/lib/models/level_config.dart`: Dual ingestion backward compatibility.
- `micin_micin/lib/models/emitter_config.dart`: Dual ingestion scaling helper.
- `micin_micin/lib/models/cup_config.dart`: Dual ingestion scaling helper.
- `micin_micin/lib/models/color_filter_config.dart`: Dual ingestion scaling helper.
- `micin_micin/lib/screens/game/game_screen.dart`: Viewport letterboxing and touch gesture transformation.
- `micin_micin/lib/screens/game/painters/level_painter.dart`: Unified $400 \times 700$ canvas painting.
- `micin_micin/lib/screens/game/painters/particle_painter.dart`: Unified $400 \times 700$ batch point painting.
- `micin_micin/lib/screens/game/painters/line_painter.dart`: Unified $400 \times 700$ path painting.
- `micin_micin/assets/levels/level_01.json` through `level_30.json`: 30 level configurations migrated to integer $400 \times 700$ coordinates.
- `docs/ARCHITECTURE.md`: Living architecture documentation update.

---

## 6. Testing

- **TEST-001 (Coordinate Math Tests):** `test/engine/virtual_coordinate_adapter_test.dart` verifying bi-directional mapping across 16:9, 19.5:9, and 4:3 aspect ratios.
- **TEST-002 (Kinematics & Fall Duration Tests):** `test/engine/game_engine_test.dart` asserting that a particle in free fall reaches $y = 600$ in $60 \le \text{frames} \le 75$ (~1.1s).
- **TEST-003 (Barrier Collision Impenetrability Tests):** `test/engine/line_segment_test.dart` asserting that drawing a stroke barrier over a cup mouth completely blocks particles and prevents cup collection count increment.
- **TEST-004 (Full Regression Suite):** Entire test suite running via `flutter test` with zero failures and zero analyzer warnings (`flutter analyze`).

---

## 7. Risks & Assumptions

- **ASSUMPTION-001**: Modern mobile devices will render dark letterbox bars (`#101012`) symmetrically when aspect ratio deviates from $4:7$, preserving visual aesthetics.
- **ASSUMPTION-002**: Existing level geometries when scaled by $400 \times 700$ retain identical relative obstacle spacings and playability across all 30 stages.
- **RISK-001 (Gesture Lag on High-Latency Touch Screens):** Mitigated by keeping `VirtualCoordinateAdapter.screenToVirtual` allocation-free with inline scalar arithmetic.
- **RISK-002 (Particle Stacking on Flat Lines):** Particles resting on flat lines slide under restitution ($0.3$) and friction ($0.92$). Particle-particle jamming is avoided by natural emitter rate dispersion.

---

## 8. Related Specifications / Further Reading

- [Technical Specification: Unified Virtual Resolution](file:///d:/kayzz/flutter/micin/spec/spec-architecture-unified-virtual-resolution.md)
- [Clarification Report (Final)](file:///d:/kayzz/flutter/micin/docs/audit/clarification-report-unified-virtual-resolution-2026-09-07.md)
- [ADR 0001: Geometric Collision Detection](file:///d:/kayzz/flutter/micin/docs/adr/0001-geometric-collision-detection.md)
- [ADR 0002: Unified Virtual Resolution](file:///d:/kayzz/flutter/micin/docs/adr/0002-unified-virtual-resolution.md)
- [Domain Glossary: CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md)

---

## 9. Rollback / Recovery Plan

1. If physics regressions occur during Phase 2 or Phase 3, revert code changes via Git:
   ```bash
   git checkout -- lib/ test/ assets/levels/
   ```
2. Because `LevelConfig.fromJson` implements Dual Ingestion, legacy normalized level files continue to load safely even if asset files are partially converted.
3. If necessary, restore baseline constants in `lib/core/constants.dart` (`kGravityDefault = 0.2`, `kMaxSpeed = 6.0`).
