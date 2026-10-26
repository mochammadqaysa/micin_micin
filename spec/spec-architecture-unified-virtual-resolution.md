---
title: Technical Specification - Unified Virtual Resolution (400x700) & Natural Physics Calibration
version: 1.0
date_created: 2026-09-07
last_updated: 2026-09-07
owner: Specification Architect
tags: [physics, architecture, rendering, coordinates, calibration]
---

# Introduction

This specification defines the architectural and mathematical overhaul of the coordinate and physics systems in **Micin Micin**. It resolves the collision impenetrability failure where player-drawn barriers fail to block particles entering target cups, and rectifies the gravity acceleration anomaly where particles cross the entire display in only 3 frames (50ms). By establishing a fixed **Unified Virtual Resolution ($400 \times 700$ virtual pixels)** and recalibrating gravity, this specification ensures deterministic collision response, authentic granular fluidity, and consistent cross-device rendering.

---

## 1. Purpose & Scope

The purpose of this specification is to:
1. Standardize all spatial calculations within the physics engine, collision detection routines, level definitions, and user stroke inputs to a fixed $400 \times 700$ virtual coordinate space.
2. Establish a bi-directional transformation adapter (`VirtualCoordinateAdapter`) bridging raw device screen pixels and the virtual coordinate space with letterboxed aspect scaling.
3. Recalibrate gravitational acceleration and velocity clamping constants to produce a natural, silky cascade of granular particles matching the original Flash game feel (~60–75 frames top-to-bottom).
4. Migrate level configuration ingestion and custom painters to operate seamlessly within the unified virtual coordinate space.

---

### 1.1 Out of Scope

- Integrating external physics frameworks such as Box2D, Forge2D, or the Flame engine (rejected per ADR 0001 and discovery analysis).
- Audio synthesis, sound effect asset modifications, or background music mixing.
- Metagame progress serialization schema alterations (`SharedPreferences` storage format remains unchanged).
- Level progression routing, UI menu layouts, or dialog designs.

---

### 1.2 Open Questions & Assumptions

> [!NOTE]
> **ASSUMPTIONS I'M MAKING:**
> 1. **Virtual Canvas Dimensions:** The virtual coordinate space is strictly fixed at $400 \times 700$ virtual units, representing an aspect ratio of $4:7$ (~1:1.75), which natively accommodates modern smartphone viewports with minimal letterboxing.
> 2. **Letterbox Padding:** Any difference between device display aspect ratio and $4:7$ is absorbed by symmetrical horizontal or vertical letterbox bars colored `#101012` matching the game background.
> 3. **Dual Ingestion Backward Compatibility:** `LevelConfig.fromJson` will support both legacy normalized coordinates (`x <= 1.0` and `canvasHeight <= 2.0`) and native $400 \times 700$ coordinates by applying automatic scaling if normalized input is detected.
> 4. **Fixed Timestep:** Physics integration remains bound to Flutter's 60Hz `Ticker` with fixed delta-time step calculations.

---

## 2. Definitions

All terms adhere to the canonical definitions established in [CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md):

- **Particle**: A discrete granular entity of sugar or MSG simulated as an active point in the virtual coordinate space.  
  _Avoid_: Grain, dot, bullet, entity
- **Stroke Barrier**: A player-drawn line path composed of linear geometric segments that deflects falling particles.  
  _Avoid_: Wall, line, pencil, drawing, curve
- **Target Cup**: A receptacle container that collects particles of matching color and increments the level completion score.  
  _Avoid_: Receptacle, bucket, bowl, goal, box
- **Particle Emitter**: A fixed spawn point in the virtual world that periodically releases sugar particles at a configured rate.  
  _Avoid_: Spout, nozzle, dropper, generator
- **Color Filter Gate**: A geometric boundary zone that mutates the color state of particles passing through it.  
  _Avoid_: Filter, portal, dye zone, lens
- **Unified Virtual Resolution**: A standardized internal coordinate space fixed at $400 \times 700$ virtual pixels used for all physics simulation and collision detection.  
  _Avoid_: Screen coordinates, normalized coordinates, pixel space, viewport space

---

## 3. Requirements, Constraints & Guidelines

### Requirements
- **REQ-001 (Unified Coordinate Space):** All physics simulation entities (particles, emitters, target cups, color filter gates, and stroke barriers) must be initialized, updated, and evaluated strictly within the $400 \times 700$ virtual coordinate system.
- **REQ-002 (Bi-directional Coordinate Transformation):** The system must provide a deterministic transformation utility (`VirtualCoordinateAdapter`) capable of:
  - Converting raw touch coordinates `(x_screen, y_screen)` to virtual space `(x_virtual, y_virtual)`.
  - Calculating viewport scale factor $S = \min(\text{width} / 400.0, \, \text{height} / 700.0)$ and centering translation offsets $(dx, dy)$.
- **REQ-003 (Gravity & Velocity Recalibration):**
  - Default gravitational acceleration `kGravityDefault` must be set to $0.25 \text{ virtual px/frame}^2$ (downward acceleration).
  - Maximum linear velocity magnitude `kMaxSpeed` must be clamped to $8.0 \text{ virtual px/frame}$ along both X and Y axes to eliminate discrete collision tunneling.
- **REQ-004 (Barrier Collision Seal):** When a stroke barrier is drawn across the collection aperture of a target cup, the collision solver must deflect $100\%$ of incoming particles, preventing any particles from registering as captured.
- **REQ-005 (Viewport Transform Rendering):** Custom painters (`LevelPainter`, `ParticlePainter`, `LinePainter`) must render directly in native $400 \times 700$ coordinates under a single transformed canvas context:
  ```dart
  canvas.save();
  canvas.translate(dx, dy);
  canvas.scale(scale);
  // Render virtual elements
  canvas.restore();
  ```
- **REQ-006 (Level Configuration Scaling):** Level configurations must support explicit $400 \times 700$ virtual pixel dimensions. Legacy JSON files containing normalized values `[0.0 .. 1.0]` must be automatically converted during deserialization.

### Constraints
- **CON-001 (Frame Budget):** Particle physics simulation, swept collision detection, and batch drawing of 500 active particles must complete within $16.6\text{ms}$ per frame (60 FPS) on mobile devices.
- **CON-002 (Headless Execution):** Core physics engine (`GameEngine`, `ParticleController`, `LineSegment`) must remain 100% executable in headless Dart unit tests without Flutter UI bindings or `BuildContext` dependencies.

### Guidelines
- **GUD-001 (Allocation Minimization):** The `VirtualCoordinateAdapter` must not allocate new objects during drag gestures or render loops. Reusable static methods and primitive scalar math must be utilized.

---

## 4. Interfaces & Data Contracts

### 4.1 Global Game Constants Contract (`lib/core/constants.dart`)

```dart
/// Virtual coordinate space dimensions.
const double kVirtualWidth = 400.0;
const double kVirtualHeight = 700.0;
const double kVirtualAspectRatio = kVirtualWidth / kVirtualHeight; // 4:7 ≈ 0.5714

/// Calibrated physics parameters in virtual pixels.
const double kGravityDefault = 0.25; // virtual px / frame²
const double kParticleRadius = 2.5;  // virtual px
const double kLineThickness = 5.0;   // virtual px
const double kMaxSpeed = 8.0;        // virtual px / frame
const int kPoolCapacity = 500;
```

---

### 4.2 Coordinate Adapter Contract (`lib/engine/drawing/virtual_coordinate_adapter.dart`)

```dart
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Provides bi-directional scaling and translation between device screen pixels
/// and the 400x700 Unified Virtual Coordinate space.
class VirtualCoordinateAdapter {
  const VirtualCoordinateAdapter._();

  /// Computes the uniform scale factor to fit 400x700 inside [viewportSize].
  static double computeScale(Size viewportSize) {
    final scaleX = viewportSize.width / kVirtualWidth;
    final scaleY = viewportSize.height / kVirtualHeight;
    return scaleX < scaleY ? scaleX : scaleY;
  }

  /// Computes the centering offset (dx, dy) for letterboxing inside [viewportSize].
  static Offset computeOffset(Size viewportSize, double scale) {
    final dx = (viewportSize.width - kVirtualWidth * scale) / 2.0;
    final dy = (viewportSize.height - kVirtualHeight * scale) / 2.0;
    return Offset(dx, dy);
  }

  /// Converts a physical screen coordinate [screenPoint] to virtual (400x700) space.
  static Offset screenToVirtual(Offset screenPoint, Size viewportSize) {
    final scale = computeScale(viewportSize);
    final offset = computeOffset(viewportSize, scale);
    final vx = (screenPoint.dx - offset.dx) / scale;
    final vy = (screenPoint.dy - offset.dy) / scale;
    return Offset(vx.clamp(0.0, kVirtualWidth), vy.clamp(0.0, kVirtualHeight));
  }

  /// Converts a virtual coordinate [virtualPoint] to physical screen pixel space.
  static Offset virtualToScreen(Offset virtualPoint, Size viewportSize) {
    final scale = computeScale(viewportSize);
    final offset = computeOffset(viewportSize, scale);
    return Offset(
      virtualPoint.dx * scale + offset.dx,
      virtualPoint.dy * scale + offset.dy,
    );
  }
}
```

---

### 4.3 Level Configuration Ingestion Contract (`lib/models/level_config.dart`)

```dart
// Auto-scaling transformation logic during deserialization
factory LevelConfig.fromJson(Map<String, dynamic> json) {
  final double rawCanvasHeight = (json['canvasHeight'] as num?)?.toDouble() ?? 1.0;
  final bool isNormalized = rawCanvasHeight <= 2.0;

  final double scaleX = isNormalized ? kVirtualWidth : 1.0;
  final double scaleY = isNormalized ? kVirtualHeight : 1.0;

  return LevelConfig(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? 'Level ${json['id']}',
    emitters: (json['emitters'] as List<dynamic>?)
            ?.map((e) => EmitterConfig.fromJson(e as Map<String, dynamic>, scaleX: scaleX, scaleY: scaleY))
            .toList() ?? const [],
    cups: (json['cups'] as List<dynamic>?)
            ?.map((c) => CupConfig.fromJson(c as Map<String, dynamic>, scaleX: scaleX, scaleY: scaleY))
            .toList() ?? const [],
    filters: (json['filters'] as List<dynamic>?)
            ?.map((f) => ColorFilterConfig.fromJson(f as Map<String, dynamic>, scaleX: scaleX, scaleY: scaleY))
            .toList() ?? const [],
    totalSugar: (json['totalSugar'] as num?)?.toInt() ?? 100,
    gravity: (json['gravity'] as num?)?.toDouble() ?? kGravityDefault,
    hasGravityToggle: json['hasGravityToggle'] as bool? ?? false,
    canvasHeight: kVirtualHeight,
  );
}
```

---

## 5. Acceptance Criteria

- **AC-001 (Stroke Impenetrability):**  
  **Given** a target cup positioned at `(160, 600, width: 80, height: 70)`,  
  **When** a player draws a horizontal stroke barrier from `(140, 580)` to `(260, 580)`,  
  **Then** zero particles falling from the emitter at `(200, 40)` must penetrate into the cup, and the cup capture count must remain 0.

- **AC-002 (Natural Fall Traversal Time):**  
  **Given** a particle spawned at virtual position `(200, 40)` with initial velocity `(0, 0)`,  
  **When** falling under gravity $g = 0.25 \text{ virtual px/frame}^2$ with terminal velocity $8.0 \text{ virtual px/frame}$ with no obstacles,  
  **Then** the particle must take between 60 and 75 frames (1.0 to 1.25 seconds at 60 FPS) to cross $y = 600$, rendering a continuous stream of distinct particle positions across every intermediate frame.

- **AC-003 (Touch Input Alignment Across Aspect Ratios):**  
  **Given** device viewports with varying aspect ratios (e.g., 9:16, 19.5:9, 4:3),  
  **When** a player touches a point directly on a visible target cup,  
  **Then** `VirtualCoordinateAdapter.screenToVirtual` must yield coordinates falling within the cup's virtual `Rect` bounds.

- **AC-004 (Performance Consistency):**  
  **Given** 500 active particles interacting with 20 stroke barrier segments and 2 color filter gates,  
  **When** executed over 1000 consecutive simulation frames,  
  **Then** average frame execution time must remain below $8.0\text{ms}$ in headless mode and below $16.6\text{ms}$ in full widget rendering.

---

## 6. Test Automation Strategy & Testing Seams

### Testing Seams
- **Engine Seam (`GameEngine.tickManual`):** Headless integration seam driving physics steps without Flutter widget instantiation or platform bindings.
- **Coordinate Transformation Seam (`VirtualCoordinateAdapter`):** Unit test seam verifying bi-directional mathematical accuracy across edge-case viewport sizes.
- **Collision Seam (`LineSegment.resolveCollision`):** Unit test seam evaluating deflection vectors, restitution, and boundary containment in $400 \times 700$ space.

### Test Levels & Automated Test Commands
- **Unit Tests:**
  - `test/engine/virtual_coordinate_adapter_test.dart`: Validates screen-to-virtual and virtual-to-screen transforms, letterbox offsets, and clamping.
  - `test/engine/line_segment_test.dart`: Validates segment distance, normal orientation, and particle deflection at $400 \times 700$ scale.
  - `test/engine/cup_hitbox_test.dart`: Validates collection detection and color filtering at virtual dimensions.
- **Integration Tests:**
  - `test/engine/game_engine_test.dart`: Validates 67-frame fall duration, level completion, and barrier impermeability.
  - `test/screens/game_screen_test.dart`: Validates touch gesture translation and rendering pipeline.

---

## 7. Project Structure & Commands

### Affected Files
```text
micin_micin/
├── lib/
│   ├── core/
│   │   └── constants.dart                      [MODIFY: Add 400x700 constants, g=0.25, v_max=8.0]
│   ├── engine/
│   │   ├── collision/
│   │   │   ├── cup_hitbox.dart                 [MODIFY: Use 400x700 virtual bounds]
│   │   │   └── line_segment.dart               [MODIFY: Use 400x700 virtual thickness & radius]
│   │   ├── drawing/
│   │   │   ├── virtual_coordinate_adapter.dart [NEW: Bi-directional coordinate translation]
│   │   │   └── line_controller.dart            [MODIFY: Accept virtual coordinates]
│   │   └── particle/
│   │       ├── particle_controller.dart        [MODIFY: Clamp to kVirtualWidth & kVirtualHeight]
│   │       └── particle_emitter.dart           [MODIFY: Spawn in 400x700 coordinates]
│   ├── models/
│   │   ├── level_config.dart                   [MODIFY: Ingestion scaling for 400x700]
│   │   ├── emitter_config.dart                 [MODIFY: Optional scale params]
│   │   ├── cup_config.dart                     [MODIFY: Optional scale params]
│   │   └── color_filter_config.dart            [MODIFY: Optional scale params]
│   └── screens/
│       └── game/
│           ├── game_screen.dart                [MODIFY: Apply VirtualCoordinateAdapter to gestures & canvas]
│           └── painters/
│               ├── level_painter.dart          [MODIFY: Direct 400x700 painting]
│               ├── particle_painter.dart       [MODIFY: Direct 400x700 batch painting]
│               └── line_painter.dart           [MODIFY: Direct 400x700 path painting]
```

### Verification Commands
- **Run Tests:** `flutter test`
- **Lint / Analyze:** `flutter analyze`
- **Launch Development:** `flutter run`

---

## 8. Code Style & Conventions

```dart
// Example of unified canvas transformation in GameScreen rendering
@override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
      final scale = VirtualCoordinateAdapter.computeScale(viewportSize);
      final offset = VirtualCoordinateAdapter.computeOffset(viewportSize, scale);

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          final virtualPoint = VirtualCoordinateAdapter.screenToVirtual(
            details.localPosition,
            viewportSize,
          );
          engine.lineController.onPanStart(virtualPoint);
        },
        onPanUpdate: (details) {
          final virtualPoint = VirtualCoordinateAdapter.screenToVirtual(
            details.localPosition,
            viewportSize,
          );
          engine.lineController.onPanUpdate(virtualPoint);
        },
        onPanEnd: (_) => engine.lineController.onPanEnd(),
        child: CustomPaint(
          painter: TransformedLevelPainter(
            engine: engine,
            scale: scale,
            offset: offset,
          ),
          size: Size.infinite,
        ),
      );
    },
  );
}
```

---

## 9. Implementation Boundaries

- **Always do:**
  - Execute `flutter test` and `flutter analyze` after every code change.
  - Retain all existing unit and widget tests, updating baseline expectations to virtual coordinates.
  - Isolate coordinate transformation logic strictly within `VirtualCoordinateAdapter`.
- **Ask first:**
  - Altering the virtual resolution aspect ratio away from $400 \times 700$.
  - Modifying the level progress SharedPreferences persistence contract.
- **Never do:**
  - Introduce third-party physics packages (`flame`, `forge2d`, `box2d`).
  - Pass raw un-transformed `details.localPosition` directly into `LineController`.
  - Add test suppression annotations (`@ts-ignore`, `// ignore:`, `skip: true`) to bypass failing assertions.

---

## 10. Rationale, Context & Architecture Decisions (ADRs)

- [ADR 0001 - Geometric Collision Detection vs Pixel Sampling](file:///d:/kayzz/flutter/micin/docs/adr/0001-geometric-collision-detection.md): Established continuous mathematical raycasting over expensive pixel buffer reading.
- [ADR 0002 - Unified Virtual Resolution (400x700) and Calibrated Gravity](file:///d:/kayzz/flutter/micin/docs/adr/0002-unified-virtual-resolution.md): Establishes the fixed $400 \times 700$ virtual canvas and recalibrated gravity constants to eliminate dual coordinate mismatches and frame skipping.

---

## 11. Dependencies & External Integrations

### External Systems
- None (100% offline self-contained mobile architecture).

### Third-Party Services
- None.

### Infrastructure Dependencies
- Flutter Framework (Rendering engine, Ticker loop, CustomPainter pipeline).

### Data Dependencies
- Level configuration assets (`assets/levels/level_*.json`) bundled with the application package.

---

## 12. Examples & Edge Cases

### Edge Case 1: Ultra-Tall Aspect Ratios (e.g., 21:9 Sony Xperia)
- `scale` is constrained by width ($scale = \text{width} / 400.0$).
- Vertical offset $dy = (\text{height} - 700 \times scale) / 2 > 0$.
- Screen regions outside the $400 \times 700$ virtual canvas are filled with the dark background color `#101012`. Touch events in the letterbox margins are clamped to virtual edges $[0, 700]$.

### Edge Case 2: Ultra-Wide Aspect Ratios (Tablets, Foldables, Landscape)
- `scale` is constrained by height ($scale = \text{height} / 700.0$).
- Horizontal offset $dx = (\text{width} - 400 \times scale) / 2 > 0$.
- Virtual world is centered horizontally with dark letterbox pillars on left and right borders.

---

## 13. Validation Criteria

1. **Barrier Integrity:** $100\%$ of sugar particles emitted above a continuous drawn barrier covering a target cup aperture are deflected and do not enter the cup.
2. **Fall Duration:** Particles take $60–75$ simulation ticks to traverse from $y = 40$ to $y = 600$ in free-fall.
3. **Zero Test Regressions:** All 81 existing tests pass without modification or after being updated to $400 \times 700$ dimensions.
4. **Static Analysis:** `flutter analyze` reports zero errors and zero warnings.

---

## 14. Related Specifications / Further Reading

- [Project Discovery Draft](file:///d:/kayzz/flutter/micin/docs/discovery-draft-20260907-unified-virtual-resolution.md)
- [Repository Architecture Map](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md)
- [ADR 0001 - Geometric Collision Detection](file:///d:/kayzz/flutter/micin/docs/adr/0001-geometric-collision-detection.md)
- [ADR 0002 - Unified Virtual Resolution](file:///d:/kayzz/flutter/micin/docs/adr/0002-unified-virtual-resolution.md)
