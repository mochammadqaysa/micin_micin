---
title: "Technical Specification: Granular Sand Piling Physics, Countdown Cup, and Overflow Spill"
version: "1.0"
date_created: "2026-09-07"
last_updated: "2026-09-07"
owner: "Specification Architect"
tags: ["architecture", "physics", "rendering", "sand-piling", "heightmap", "countdown-cup"]
---

# Introduction

This Technical Specification establishes the engineering design, mathematical algorithms, data contracts, and verification criteria for **Granular Sand Piling Physics, Countdown Cup, and Overflow Spill** in **Micin Micin**.

Following the approval of [docs/prd-20260907-sand-piling-physics.md](file:///d:/kayzz/flutter/micin/docs/prd-20260907-sand-piling-physics.md) and the Clarification Quality Gate in [docs/audit/clarification-report-sand-piling-physics-2026-09-07.md](file:///d:/kayzz/flutter/micin/docs/audit/clarification-report-sand-piling-physics-2026-09-07.md) (Readiness Score: 100/100, Option A Selected), this document formalizes the transition from instantaneous particle absorption and synthetic fluid boxes to authentic granular sand piling with a 1D discrete column heightmap, a countdown target display, and overflow spilling mechanics.

---

## 1. Purpose & Scope

The purpose of this specification is to provide developer agents with unambiguous architectural blueprints to implement:
1. Fine granular particle geometry ($r = 1.1$ virtual px) and calibrated soft gravity ($g = 0.14$ virtual px/frame², $v_{\max} = 4.8$ virtual px/frame).
2. Organic emitter dispersion with horizontal velocity and position jitter.
3. Rigid U-shaped Target Cup boundaries (left wall, floor, right wall) with an open top aperture protected by a Color Selective Membrane (Option A).
4. Pure countdown integer display on Target Cups ($\text{remaining} = \max(0, \text{target} - \text{settled})$) and complete removal of the synthetic `fluidPaint` fluid rectangle.
5. High-performance $O(1)$ Discrete Column Heightmap sand piling inside Target Cups, enforcing a natural Angle of Repose ($\approx 35^\circ$ maximum slope).
6. Overflow Spill mechanics that eject excess particles over the cup rim back into the stage.
7. Migration of all 30 level configurations to the 150% particle supply formula ($\text{Total Sugar} = 150 \times N_{\text{cups}}$).

### 1.1 Out of Scope

- **3D Particle Meshing:** Partikel remain 2D circular points rendered via `Canvas.drawPoints(PointMode.points)`.
- **Destructible Cup Obstacles:** Target Cups remain static rigid containers; walls cannot be broken or drawn over.
- **Dynamic Cup Physics:** Cups do not rotate or translate during gameplay.

### 1.2 Open Questions & Assumptions

- **ASSUMPTION-001:** The discrete column heightmap resolution is fixed at $2.0$ virtual pixels per bin. For a standard cup width of $36.0$ virtual px, this yields exactly $18$ bins, delivering high visual fidelity with negligible memory footprint.
- **ASSUMPTION-002:** The angle of repose slope threshold is mathematically modeled as $\Delta H_{\max} = \tan(35^\circ) \times \text{binWidth} \approx 0.70 \times 2.0 = 1.4\text{ virtual px}$.
- **ASSUMPTION-003:** Emitter particle supply for multi-emitter levels (e.g., Level 11) is divided equally across active emitters.

---

## 2. Definitions

All technical terms strictly adhere to [CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md):

- **Particle**: A discrete granular entity of sugar or MSG simulated as an active point in the virtual coordinate space.  
  _Avoid_: Grain, dot, bullet, entity.
- **Stroke Barrier**: A player-drawn line path composed of linear geometric segments that deflects falling particles.  
  _Avoid_: Wall, line, pencil, drawing, curve.
- **Target Cup**: A receptacle container that collects particles of matching color and increments the level completion score.  
  _Avoid_: Receptacle, bucket, bowl, goal, box.
- **Particle Emitter**: A fixed spawn point in the virtual world that periodically releases sugar particles at a configured rate.  
  _Avoid_: Spout, nozzle, dropper, generator.
- **Color Filter Gate**: A geometric boundary zone that mutates the color state of particles passing through it.  
  _Avoid_: Filter, portal, dye zone, lens.
- **Unified Virtual Resolution**: A standardized internal coordinate space fixed at $400 \times 700$ virtual pixels used for all physics simulation and collision detection.  
  _Avoid_: Screen coordinates, normalized coordinates, pixel space, viewport space.
- **Sand Mound**: A physical accumulation of settled particles inside a Target Cup shaped by gravitational stacking and natural angle of repose.  
  _Avoid_: Liquid level, fluid bar, pile, heap, progress fill.
- **Angle of Repose**: The maximum physical slope angle that granular particles can sustain before rolling or sliding down to adjacent height columns.  
  _Avoid_: Slope limit, roll angle, tilt.
- **Overflow Spill**: The phenomenon where excess particles atop a full Sand Mound roll over the cup rim and resume active free-fall physics into the game world.  
  _Avoid_: Leaking, splash, excess dump.

---

## 3. Requirements, Constraints & Guidelines

### Functional Requirements
- **REQ-001**: Particle radius must be calibrated to $kParticleRadius = 1.1$ virtual px (stroke width $2.2$ px), with crystalline opacity variation $\alpha \in [0.85, 1.0]$.
- **REQ-002**: Gravitational acceleration must be calibrated to $kGravityDefault = 0.14$ virtual px/frame², with maximum velocity clamped to $kMaxSpeed = 4.8$ virtual px/frame.
- **REQ-003**: Particle Emitter must dispense particles with horizontal velocity jitter $v_x \in [-0.25, 0.25]$ virtual px/frame and position jitter $x \pm 1.2$ virtual px.
- **REQ-004**: Target Cups must provide 3 physical rigid barriers (left wall, floor, right wall) with an open top aperture protected by a Color Selective Membrane (Option A).
- **REQ-005**: Target Cups must render a pure countdown integer ($\text{remaining} = \max(0, \text{target} - \text{settledCount})$). The synthetic liquid fill box (`fluidPaint`) must be eliminated.
- **REQ-006**: Target Cups must implement a 1D Discrete Column Heightmap ($2.0$ px bin width) enforcing an Angle of Repose ($\Delta H_{\max} = 1.4$ px). Settled particles must remain rendered as a granular Sand Mound.
- **REQ-007**: When a Target Cup is full and the Sand Mound exceeds the rim height, excess particles rolling off the mound cone must be ejected as an Overflow Spill, regaining active free-fall gravity.
- **REQ-008**: All 30 level configurations must provide a total particle supply calculated via $\text{Total Sugar} = 150 \times N_{\text{cups}}$. Stage victory triggers when all cups reach $\text{remaining} == 0$.

### Non-Functional Constraints
- **CON-001**: Steady 60 FPS performance (<16.6ms per frame) with 500 active granular particles on mobile hardware.
- **CON-002**: Headless testability: the entire sand mound heightmap, particle settling, and overflow logic must run in pure Dart unit tests without Flutter UI bindings.
- **SEC-001**: 100% offline execution; zero network permissions or external telemetry.
- **GUD-001**: Zero heap allocations inside the frame ticker loop. Heightmap bins must use pre-allocated fixed-size arrays.

---

## 4. Interfaces & Data Contracts

### 4.1 Global Constants Updates (`lib/core/constants.dart`)

```dart
// Refined Granular Physics Constants
const double kParticleRadius = 1.1; // Visual diameter: 2.2px
const double kGravityDefault = 0.14; // Soft fall: ~0.14 virtual px/frame^2
const double kMaxSpeed = 4.8; // Terminal velocity: 4.8 virtual px/frame

// Sand Mound Heightmap Constants
const double kHeightmapBinWidth = 2.0; // 2 virtual px per bin
const double kReposeSlopeMax = 1.4; // tan(35°) * 2.0px ≈ 1.4px
const double kCupWallThickness = 2.5; // Solid wall thickness
```

### 4.2 Cup Container Contract (`lib/engine/collision/cup_hitbox.dart`)

The `CupHitbox` class is enhanced into a physical container supporting boundary deflection, heightmap settling, and overflow ejection:

```dart
class CupHitbox {
  final Rect bounds;
  final Color color;
  final int targetAmount;
  int capturedCount;

  // Discrete Column Heightmap
  final int binCount;
  final Float64List columnHeights;
  final List<Offset> settledParticleOffsets;

  CupHitbox({
    required this.bounds,
    required this.color,
    required this.targetAmount,
    this.capturedCount = 0,
  })  : binCount = (bounds.width / kHeightmapBinWidth).ceil(),
        columnHeights = Float64List((bounds.width / kHeightmapBinWidth).ceil()),
        settledParticleOffsets = [];

  /// Remaining quota required to satisfy the cup.
  int get remaining => (targetAmount - capturedCount).clamp(0, targetAmount);

  /// True when the cup has met its target quota.
  bool get isFull => capturedCount >= targetAmount;

  /// Determines if a falling particle matches the cup's color.
  bool matches(SugarParticle particle);

  /// Handles particle interaction with the cup:
  /// - If non-matching color at top mouth: deflecting off selective membrane.
  /// - If matching color entering aperture: settling onto heightmap with angle of repose.
  /// - Returns true if particle was swallowed/settled, false if still active in world.
  bool processParticle(SugarParticle p);

  /// Resets heightmap and capture counters.
  void reset();
}
```

### 4.3 Heightmap Settling & Slope Relaxation Algorithm

```dart
bool processParticle(SugarParticle p) {
  // 1. Boundary check: Within horizontal bounds of cup mouth?
  if (p.x < bounds.left || p.x > bounds.right) return false;

  // 2. Color selective membrane check (Option A)
  if (!matches(p)) {
    // If hitting top mouth aperture, deflect upward and outward
    if ((p.y - bounds.top).abs() < 4.0 && p.vy > 0) {
      p.vy = -p.vy * 0.3;
      p.vx += (p.x < bounds.center.dx ? -0.5 : 0.5);
    }
    return false;
  }

  // 3. Map x to heightmap bin index
  int b = ((p.x - bounds.left) / kHeightmapBinWidth).floor().clamp(0, binCount - 1);
  double currentHeight = columnHeights[b];
  double surfaceY = bounds.bottom - currentHeight;

  // Has the particle reached the surface of the sand mound?
  if (p.y >= surfaceY) {
    // 4. Angle of Repose Slope Relaxation (Check adjacent bins)
    // Try rolling left if slope exceeds threshold
    if (b > 0 && (columnHeights[b] - columnHeights[b - 1]) > kReposeSlopeMax) {
      b--;
    } 
    // Else try rolling right if slope exceeds threshold
    else if (b < binCount - 1 && (columnHeights[b] - columnHeights[b + 1]) > kReposeSlopeMax) {
      b++;
    }

    // 5. Overflow Spill Check:
    // If the mound at this column has exceeded the cup rim, eject the particle!
    if (columnHeights[b] >= bounds.height) {
      // Eject particle over the nearest rim
      p.x = b < binCount / 2 ? bounds.left - 2.0 : bounds.right + 2.0;
      p.y = bounds.top - 1.0;
      p.vx = b < binCount / 2 ? -1.0 : 1.0;
      p.vy = 0.5;
      return false; // Particle remains active in world!
    }

    // 6. Settle Particle
    columnHeights[b] += (kParticleRadius * 1.5);
    settledParticleOffsets.add(Offset(
      bounds.left + b * kHeightmapBinWidth + (kHeightmapBinWidth / 2),
      bounds.bottom - columnHeights[b],
    ));

    capturedCount++;
    p.isCaptured = true;
    return true;
  }

  return false;
}
```

---

## 5. Acceptance Criteria

- **AC-001 (Particle Dimension & Opacity):**  
  Given an active particle, when rendered, then its visual radius equals $1.1$ virtual px (stroke width $2.2$ px) and its opacity varies randomly in $\alpha \in [0.85, 1.0]$.
- **AC-002 (Kinematic Free-Fall Traversal):**  
  Given a particle in free fall from $y = 50$ to $y = 650$, when simulated with $g = 0.14$ and $v_{\max} = 4.8$, then total elapsed frames must be between $125$ and $145$ frames (~2.2s at 60 FPS), exhibiting smooth powdery flow.
- **AC-003 (Color Selective Membrane Rejection - Option A):**  
  Given an undyed white particle falling toward a red cup, when the particle contacts the top mouth aperture, then it is deflected sideways with $v_y < 0$ and $0$ particles are added to `capturedCount`.
- **AC-004 (Countdown Display Accuracy):**  
  Given a Target Cup with `targetAmount = 100` and $30$ settled particles, when rendered by `LevelPainter`, then the cup displays text `"70"`. When $100$ particles settle, the cup displays `"0"` and indicates satisfied status.
- **AC-005 (Sand Mound Stacking & Angle of Repose):**  
  Given incoming particles falling into a single column $b$, when particles stack, then the height difference between adjacent columns never exceeds $\Delta H_{\max} = 1.4\text{ px}$, forming a conical sand mound.
- **AC-006 (Overflow Spill):**  
  Given a full cup whose column heights exceed `bounds.height`, when additional particles enter, then the excess particles roll over the rim, retain active physics, and cascade outside the cup boundaries.
- **AC-007 (150% Particle Supply & Regression Pass):**  
  Given any of the 30 stages, when loaded, then `totalSugar == 150 * cups.length`. When all cups reach `remaining == 0`, the level completes successfully. Full test suite passes 100% (98+ tests).

---

## 6. Test Automation Strategy & Testing Seams

### Testing Seams
- **`GameEngine` & `ParticleController` Seam:** Pure headless execution of physics updates, emitter ticks, and heightmap settling without Flutter UI bindings.
- **`CupHitbox` Seam:** Unit testing bin calculations, slope relaxation, color membrane deflection, and overflow ejection.
- **`VirtualCoordinateAdapter` Seam:** Verification that screen coordinates translate into native $400 \times 700$ virtual points.

### Required Test Suites
1. `test/engine/cup_hitbox_test.dart`:
   - Validates discrete bin mapping and column height accumulation.
   - Validates Angle of Repose slope relaxation rolling.
   - Validates Color Selective Membrane deflection (Option A).
   - Validates Overflow Spill particle ejection when $H \ge \text{bounds.height}$.
2. `test/engine/particle_controller_test.dart`:
   - Validates soft gravity ($0.14$) and terminal velocity ($4.8$).
   - Validates out-of-bounds recycling at $y > 750.0$.
3. `test/integration/sand_piling_integration_test.dart`:
   - Validates multi-frame particle stream pouring into a cup, verifying countdown decrement from $100 \to 0$, conical sand mound formation, and subsequent overflow spilling.
4. `test/data/level_repository_test.dart`:
   - Validates that all 30 levels load with `totalSugar == 150 * cups.length`.

---

## 7. Project Structure & Commands

### Affected Files
- `micin_micin/lib/core/constants.dart`: Updated physics constants ($kParticleRadius, kGravityDefault, kMaxSpeed, kHeightmapBinWidth$).
- `micin_micin/lib/engine/collision/cup_hitbox.dart`: Transformed into physical container with discrete column heightmap and membrane.
- `micin_micin/lib/engine/particle/particle_emitter.dart`: Organic jitter velocity and position dispersion.
- `micin_micin/lib/engine/particle/particle_controller.dart`: Soft gravity and overflow particle integration.
- `micin_micin/lib/screens/game/painters/level_painter.dart`: Pure countdown text and removal of `fluidPaint`.
- `micin_micin/lib/screens/game/painters/particle_painter.dart`: Updated stroke width (2.2px) and resting sand mound batch rendering.
- `micin_micin/assets/levels/level_01.json` .. `level_30.json`: Migrated to 150% quota supply.

### Commands
```bash
# Run unit and integration tests
flutter test

# Run linter and static analysis
flutter analyze
```

---

## 8. Code Style & Conventions

```dart
// Example: Pure countdown string calculation inside LevelPainter
final remaining = (cup.targetAmount - currentCaptured).clamp(0, cup.targetAmount);
final textSpan = TextSpan(
  text: '$remaining',
  style: TextStyle(
    color: remaining == 0 ? const Color(0xFFFFD54F) : cup.color,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  ),
);
```

---

## 9. Implementation Boundaries

- **Always do:**
  - Enforce $O(1)$ heightmap lookups per particle.
  - Maintain 100% headless testability for `CupHitbox` and `ParticleController`.
  - Recycle all spilled particles exiting through the canvas floor ($y > 750.0$).
- **Ask first:**
  - Altering the $150\%$ quota formula.
  - Changing the $2.0$ px bin resolution or $\approx 35^\circ$ angle of repose.
- **Never do:**
  - Introduce $O(N^2)$ contact solvers or heavy third-party physics libraries.
  - Re-introduce synthetic fluid rectangle boxes into `LevelPainter`.
  - Add network dependencies or permissions to `AndroidManifest.xml`.

---

## 10. Rationale, Context & Architecture Decisions (ADRs)

- **ADR-0001:** Geometric Collision Detection for Stroke Barriers ([docs/adr/0001-geometric-collision-detection.md](file:///d:/kayzz/flutter/micin/docs/adr/0001-geometric-collision-detection.md)).
- **ADR-0002:** Unified Virtual Resolution $400 \times 700$ Pipeline ([docs/adr/0002-unified-virtual-resolution.md](file:///d:/kayzz/flutter/micin/docs/adr/0002-unified-virtual-resolution.md)).
- **ADR-0003:** Discrete Column Heightmap Sand Piling and Overflow Spilling ([docs/adr/0003-discrete-column-heightmap-sand-piling.md](file:///d:/kayzz/flutter/micin/docs/adr/0003-discrete-column-heightmap-sand-piling.md)).

---

## 11. Dependencies & External Integrations

- **`flutter_riverpod`**: Game loop and reactive state coordination.
- **`dart:ui` & `CustomPainter`**: Pure canvas batch rendering.
- **Offline Guarantee**: 100% offline, zero network APIs or third-party engines.

---

## 12. Examples & Edge Cases

### Edge Case: High-Density Column Ingestion
When multiple particles hit the same bin in a single frame, each particle relaxes to the lowest adjacent bin before the next particle is processed, ensuring the conical peak expands outward symmetrically rather than producing vertical needle artifacts.

### Edge Case: Gravity Inversion & Settled Sand Stability (Option A)
On stages featuring Gravity Toggle portals (e.g., Level 21, 24, 27, 30), reversing gravity upward affects only active falling particles in the world. Particles that have already settled into a `CupHitbox` and formed a `Sand Mound` remain locked and immune to gravitational inversion. The heightmap columns and settled point coordinates do not dislodge or float out of the cup, preserving achieved stage progression and ensuring $O(1)$ heightmap determinism.


---

## 13. Validation Criteria

1. 100% test pass rate across `flutter test` (expected: $\ge 105$ tests).
2. 0 linter warnings across `flutter analyze`.
3. Steady 60 FPS verified with 500 active granular particles.
4. Conical Sand Mound and Overflow Spill visually confirmed in GameScreen.

---

## 14. Related Specifications / Further Reading

- [docs/prd-20260907-sand-piling-physics.md](file:///d:/kayzz/flutter/micin/docs/prd-20260907-sand-piling-physics.md)
- [docs/adr/0003-discrete-column-heightmap-sand-piling.md](file:///d:/kayzz/flutter/micin/docs/adr/0003-discrete-column-heightmap-sand-piling.md)
- [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md)
