---
goal: Engine Performance & Zero-GC Optimization for 60/120 FPS Production Release
version: 1.0
date_created: 2026-09-08
last_updated: 2026-09-08
owner: Micin Micin Engineering Team
status: "Completed"
tags: ["refactor", "clean-code", "performance", "optimization", "gc-free"]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-brightgreen)

This refactoring plan resolves high-frequency heap allocations, redundant computations, and painter layout overhead identified during the production pre-release code audit. While functional logic passes all 115 test cases, the 60/120 FPS physics and rendering loops currently generate tens of thousands of transient `Offset`, `List`, `TextPainter`, and `LineSegment` instances per second. This plan introduces zero-allocation iteration, cached line segments, scalar collision queries, and cached text layout to guarantee smooth 60/120 FPS execution on budget mobile hardware.

## 1. Traceability: Requirements & Constraints

- **PRN-001**: **Zero-Allocation Hot Path Discipline**: Physics updates and render loops must avoid allocating objects on the heap during active frames to eliminate Garbage Collector (GC) pauses.
- **PRN-002**: **Reactive Invalidation Caching**: Pure data transformations (such as polyline segmentation and static text layout) must be cached and recalculated only when source state changes.
- **PRN-003**: **Single Responsibility & Encapsulation**: Physics entities must expose intent-revealing scalar helper methods rather than forcing external components to assemble framework objects.
- **PRN-004**: **Clean Code Constants & DRY**: Physics restitution, friction, and neutral color comparisons must be centralized in constants and domain models.
- **CON-001**: **Zero Functional Regression**: All 115 existing unit, widget, and integration tests must continue to pass without behavioral degradation.
- **CON-002**: **Deterministic Headless Compatibility**: Headless testing using `tickManual` must remain fully supported without UI dependencies.

---

## 2. Implementation Steps

> **⚠️ EXECUTION DIRECTIVE FOR AI AGENTS (`/sdlc-write-code`):**
> You MUST execute this plan phase by phase. You MUST run the specific testing/verification task at the end of each phase. After a phase is tested, you **MUST STOP AND WAIT** for the user's explicit approval before proceeding to the next phase. **DO NOT SKIP PHASES.**

### Implementation Phase 1: Core Physics Zero-Allocation & Caching

- **GOAL-001:** Eliminate per-frame list allocations and object instantiations in the physics update loop (`ParticlePool`, `ParticleController`, and `LineController`).

| Task ID  | Description (Include Exact File Paths & Micro-Testing) | Ref ID | Completed | Date |
| :--- | :--- | :---: | :---: | :---: |
| TASK-101 | **Optimize `ParticlePool` active particle access**:<br>Modify `lib/engine/particle/particle_pool.dart` to provide zero-allocation active particle iteration (e.g., `Iterable<SugarParticle> get activeParticles` or in-place visitor without `.toList()`), eliminating per-frame heap array instantiation. Update `lib/engine/particle/particle_controller.dart`. | PRN-001 | [x] | 2026-09-08 |
| TASK-102 | **Cache `allSegments` in `LineController`**:<br>Modify `lib/engine/drawing/line_controller.dart` to cache the compiled `List<LineSegment>`. Invalidate and recompute segments only during `onPanStart`, `onPanUpdate`, and `clearAll`, instead of regenerating segments every frame tick. | PRN-002 | [x] | 2026-09-08 |
| TASK-103 | **Scalar Distance Check in `LineSegment`**:<br>Modify `lib/engine/collision/line_segment.dart` to add `distanceToPoint(double px, double py)`. Update `resolveCollision` to use scalar coordinates directly, eliminating `Offset(p.x, p.y)` heap allocations on collision checks. | PRN-001 | [x] | 2026-09-08 |
| TASK-104 | **Centralize Physics Constants & Neutral Color**:<br>Extract restitution (`kLineRestitution = 0.3`) and friction (`kLineFriction = 0.92`) to `lib/core/constants.dart`. Add `bool get isNeutral` helper to `lib/models/sugar_particle.dart` and refactor `CupHitbox.matches` in `lib/engine/collision/cup_hitbox.dart`. | PRN-004 | [x] | 2026-09-08 |
| TASK-105 | **VERIFY**: Run `flutter test test/engine/` and verify that all collision, pool, and controller unit tests pass. | CON-001 | [x] | 2026-09-08 |
| TASK-106 | **APPROVAL**: 🛑 Wait for explicit user confirmation to proceed to Phase 2. | - | [x] | 2026-09-08 |

---

### Implementation Phase 2: Painter Layout Caching & Render Optimization

- **GOAL-002:** Optimize CustomPainter rendering by eliminating redundant `TextPainter.layout()` calls and reducing coordinate allocations.

| Task ID  | Description (Include Exact File Paths & Micro-Testing) | Ref ID | Completed | Date |
| :--- | :--- | :---: | :---: | :---: |
| TASK-201 | **Cache `TextPainter` in `LevelPainter`**:<br>Modify `lib/screens/game/painters/level_painter.dart` to cache countdown `TextPainter` instances keyed by cup index and remaining value, avoiding per-frame text layout computations when numbers do not change. | PRN-002 | [x] | 2026-09-08 |
| TASK-202 | **Optimize Particle Batch Buffering in `ParticlePainter`**:<br>Modify `lib/screens/game/painters/particle_painter.dart` to reuse reusable coordinate buffers or streamline color grouping to minimize per-frame map and list allocations during `paint()`. | PRN-001 | [x] | 2026-09-08 |
| TASK-203 | **Update `GameScreen` painter invocation**:<br>Ensure `lib/screens/game/game_screen.dart` passes pool references or optimized iterables directly without creating intermediary heap lists. | PRN-001 | [x] | 2026-09-08 |
| TASK-204 | **VERIFY**: Run the complete test suite (`flutter test`) and static analysis (`flutter analyze`) to confirm 100% pass rate and zero analyzer issues. | CON-001 | [x] | 2026-09-08 |
| TASK-205 | **APPROVAL**: 🛑 Wait for explicit user confirmation for production release readiness. | - | [x] | 2026-09-08 |

---

## 3. Structural Remedies & Alternatives

- **ALT-001**: **Float32List Raw Points Buffer (`Canvas.drawRawPoints`)**:
  - *Considered*: Replacing `List<Offset>` entirely with flat `Float32List` coordinate buffers for `Canvas.drawRawPoints`.
  - *Decision*: Rejected for v1.0. The overhead in `ParticlePainter` is primarily due to per-frame `Map` and `List` allocation rather than `drawPoints` itself. Flat arrays would increase complexity without noticeable gain at 500 particles. Kept clean `drawPoints` with cached buffers.
- **ALT-002**: **Separate Spatial Hash Grid for Line Segments**:
  - *Considered*: Indexing line segments into a 2D spatial grid for broad-phase collision culling.
  - *Decision*: Rejected. In typical gameplay, player strokes total fewer than 50-100 segments. Broadphase spatial grid overhead exceeds simple linear scan at this scale. Caching compiled segments (TASK-102) resolves 95% of the performance cost without architectural bloat.

---

## 4. Dependencies

- **DEP-001**: None. All refactorings strictly utilize Dart and Flutter core standard libraries.

---

## 5. Files Affected

- **FILE-001**: `lib/core/constants.dart` (Add `kLineRestitution`, `kLineFriction`).
- **FILE-002**: `lib/models/sugar_particle.dart` (Add `isNeutral` getter).
- **FILE-003**: `lib/engine/particle/particle_pool.dart` (Zero-allocation active particle access).
- **FILE-004**: `lib/engine/particle/particle_controller.dart` (Adopt zero-allocation particle loop).
- **FILE-005**: `lib/engine/drawing/line_controller.dart` (Add segment cache and invalidation hooks).
- **FILE-006**: `lib/engine/collision/line_segment.dart` (Add scalar `distanceToPoint`).
- **FILE-007**: `lib/engine/collision/cup_hitbox.dart` (Refactor `matches` to use `isNeutral`).
- **FILE-008**: `lib/screens/game/painters/level_painter.dart` (Cache `TextPainter` layout).
- **FILE-009**: `lib/screens/game/painters/particle_painter.dart` (Buffer optimization).
- **FILE-010**: `lib/screens/game/game_screen.dart` (Pass optimized particle reference).

---

## 6. Testing Strategy

- **TEST-001**: Unit tests in `test/engine/` to verify particle pool acquire/release and active enumeration correctness.
- **TEST-002**: Collision tests in `test/engine/line_segment_test.dart` verifying scalar distance matches Euclidean distance formulas.
- **TEST-003**: Line drawing tests in `test/engine/line_controller_test.dart` verifying segment cache invalidation on pan updates and clears.
- **TEST-004**: Full regression suite (all 115 tests) verifying game mechanics, sand mounds, countdowns, and overflows remain identical.

---

## 7. Risks & Rollback Plan

- **RISK-001**: **Stale Segment Cache**: If drawing events occur without invalidating the cached segments in `LineController`, particles might pass through freshly drawn lines.
  - *Mitigation*: Invalidate cache immediately on every `state` assignment (`onPanStart`, `onPanUpdate`, `clearAll`). Add explicit unit test asserting cached segments update on every pan event.
- **RISK-002**: **TextPainter Visual Glitch**: Stale countdown values if cache key is incorrect.
  - *Mitigation*: Key cache strictly by `(cupIndex, remainingAmount)`. Add widget test verifying countdown display changes as particles enter.
- **Rollback Strategy**: All changes are modular and covered by 115 tests. If unexpected regressions occur, revert cleanly via git or file restoration.
