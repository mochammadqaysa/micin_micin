---
title: "Technical Specification: Bart Bonte Aesthetic, Granular Square Particles & 30-Level Characteristic Architecture"
version: "1.0.0"
date_created: "2026-10-06"
last_updated: "2026-10-06"
owner: "Specification Architect"
tags: ["spec", "granular-physics", "bart-bonte", "sugar-sugar", "level-matrix", "silhouettes", "canvas-typography", "game-feel", "asmr"]
---

# Technical Specification: Bart Bonte Aesthetic, Granular Square Particles & 30-Level Characteristic Architecture

> [!WARNING]
> **ARCHIVED & SUPERSEDED BY CHUNKY ARCADE**:
> While the granular square particle math, continuous collision detection, and silhouette prop colliders remain active in the headless engine, the visual presentation (chalkboard minimalism) has been superseded by the canonical **Chunky Arcade** design language (`CartoonTokens`, 3D extruded slabs, solid drop shadows, and arcade coin HUD). Refer to [docs/design/art-direction-brief.md](file:///d:/kayzz/flutter/micin/docs/design/art-direction-brief.md) and [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md).

## Introduction

This Technical Specification establishes the engineering design, data schemas, rendering contracts, and architectural interfaces for the **Bart Bonte Aesthetic, Granular Square Particles & 30-Level Characteristic Architecture** in **Micin Micin**.

Building on the approved Game Design Document ([docs/gdd/GDD-bonte-aesthetic-and-level-design.md](file:///d:/kayzz/flutter/micin/docs/gdd/GDD-bonte-aesthetic-and-level-design.md)), this document defines how Flutter's CustomPainter canvas pipeline, headless particle physics, dynamic background palette engine, vector silhouette prop colliders, and diegetic canvas typography are constructed while preserving the strict 60/120 FPS zero-allocation performance budget and 100% test suite regression integrity.

---

## 1. Purpose & Scope

### 1.1 In-Scope Components
1. **Granular Crystalline Square Particle Pipeline:**
   - Upgrade `ParticlePainter` from `StrokeCap.round` to `StrokeCap.square` with $2.2 \times 2.2$ virtual pixel dimensions.
   - Introduce spawn stream micro-jitter ($\Delta v_x \in [-0.35, 0.35]\text{ px/frame}$) in `EmitterConfig` / `ParticleEmitter` to simulate realistic granular dispersal.
   - Micro-opacity jitter ($0.88$ to $1.0$) for subtle crystalline refraction without shader overhead.
2. **30-Stage Signature Palette & Canvas Background Engine:**
   - Model `LevelVisualTheme` defining curated background colors (Midnight Navy, Forest Pine, Kelly Green, Deep Crimson, Terracotta, Mustard, Royal Violet, Blood Crimson, etc.) across all 30 stages.
   - Refactor `BackgroundPainter` to ingest dynamic stage background colors while preserving subtle chalkboard grain and multi-plane starlight sand dust.
3. **Canvas-Integrated Diegetic Typography:**
   - Render bold, quiet lowercase stage titles (e.g. `level 8`, `sugar, sugar`) directly on the virtual canvas background floor at $0.18$–$0.25$ harmonized opacity.
4. **Environmental Silhouette Asset Props & Colliders:**
   - Implement `SilhouettePainter` and vector silhouette models for iconic environmental props:
     - Teaspoons (`asset_spoon_straight`, `asset_spoon_angled`) acting as angled deflectors.
     - Silhouette Hands (`asset_hand_pour`, `asset_hand_cup`) framing the pour and holding cups.
     - Teapot Spouts and Glass Funnel tubes.
   - Integrate geometric segment colliders into `LevelConfig.obstacles` so falling grains bounce and slide naturally off props.
5. **Minimalist Diegetic HUD & ASMR Game Feel:**
   - Clean, quiet circular icon buttons: Back (`<`) and Reset (`⟳`), eliminating bulky top bars.
   - Diegetic cup integer countdown with $1.06\times$ scale-pulse feedback on grain capture.
   - Pitch-ascending pentatonic audio chime scaling.
6. **Full Backward Compatibility:**
   - 100% preservation of all existing widget test finders, keys (`Key('hud_reset')`, `Key('hud_pause')`), and router contracts.

### 1.1 Out of Scope
- Modifying the headless physics engine's core continuous raycasting collision solver (`GameEngine`).
- Altering the $400 \times 700$ Unified Virtual Resolution coordinate system contract.
- Introducing online backend features, network dependencies, or external asset downloads (game remains 100% offline).
- Altering player line stroke drawing mechanics or line capacity limits (infinite ink capacity invariant is preserved).

### 1.2 Open Questions & Resolved Decisions

#### RESOLVED ARCHITECTURAL DECISIONS:
- **DECISION-001 (Procedural Prop Collider Injection - Option A Approved):** Line colliders for environmental silhouette props (e.g., Teaspoons in Levels 5/8, Silhouette Hands in Level 23) are injected procedurally through `LevelVisualTheme.silhouetteProps` into `GameEngine` at stage load time. Level JSON asset files (`level_*.json`) remain clean, decoupled, and protected from visual-collider desynchronization.
- **DECISION-002 (Procedural Vector Path Rendering - Option A Approved):** Silhouette props are rendered directly onto the `Canvas` using procedural Dart `Path`s in `SilhouettePainter`. This requires zero external dependencies (no `flutter_svg`), eliminates disk I/O loading latency for instant 120 FPS frame starts, and guarantees 100% mathematical alignment between visual artwork and physical collider boundaries.

#### VERIFIED ASSUMPTIONS:
1. **ASSUMPTION-001 (Zero-Allocation Point Batching):** `Canvas.drawPoints(PointMode.points, ...)` using `StrokeCap.square` with `strokeWidth = 2.2` executes on native Skia / Impeller as rectangular point primitives, maintaining identical zero-allocation batch performance to circular points.
2. **ASSUMPTION-002 (Dual Layer Canvas Typography):** Canvas-integrated typography (e.g., `"level 8"`) is painted in the background virtual canvas plane (`LevelPainter` or `BackgroundPainter`) behind falling particles and player lines, ensuring grains pass naturally over the text.
3. **ASSUMPTION-003 (Vector Silhouette Colliders):** Environmental props (teaspoons, teapots, hands) are defined geometrically as collections of line segments and arcs mapped into `LevelConfig.obstacles` rather than heavy pixel-mask collision, preserving $O(N)$ raycasting efficiency.
4. **ASSUMPTION-004 (Theme Ingestion Fallback):** If a stage configuration lacks an explicit `LevelVisualTheme`, it automatically falls back to default `GlassTokens.obsidianVoid` (`#0A0D14`) to guarantee complete backward compatibility with custom or legacy level files.
5. **ASSUMPTION-005 (Floor Grain Drainage):** Particles that miss cups and fall below the virtual canvas boundary ($y > 700$) despawn and are returned to the reusable object pool, preventing pool exhaustion and maintaining 60/120 FPS zero-GC stability without screen clutter.

---

## 2. Definitions

All terminology conforms to `CONTEXT.md` and Bart Bonte's canonical game mechanics:

| Term | Definition | _Avoid_ |
|:---|:---|:---|
| **Crystalline Square Grain** | A granular particle rendered with `StrokeCap.square` ($2.2\text{ px}$) representing a discrete grain of sugar/micin. | *Soft Circle*, *Fuzzy Dot* |
| **Angle of Repose** | The maximum stable slope angle ($\theta \approx 35^\circ$) of granular sand mounds before grains slide downhill. | *Sand Heap*, *Static Block* |
| **Level Visual Theme** | The bespoke visual profile (background color, accent tint, silhouette props, and canvas typography) assigned to a level. | *Chamber Skin*, *Level Filter* |
| **Silhouette Prop** | A flat vector shadow asset (e.g. teaspoon, hand, teapot) functioning simultaneously as background art and rigid collider. | *Obstacle Sprite*, *Visual Gimmick* |
| **Canvas-Integrated Typography** | Stage numbering or branding rendered directly into the canvas background plane at harmonized opacity. | *HUD Overlay*, *Header Label* |

---

## 3. Requirements, Constraints & Guidelines

### 3.1 Functional Requirements (REQ)
* **REQ-001 (Square Crystalline Rendering):** The particle renderer MUST draw active particles and resting sand mounds using `StrokeCap.square` with a calibrated width of $2.2$ virtual pixels.
* **REQ-002 (Nozzle Stream Micro-Jitter):** Emitters MUST inject a deterministic or bounded random horizontal velocity component $\Delta v_x \in [-0.35, 0.35]\text{ px/frame}$ upon particle spawning to prevent unnatural single-pixel vertical column lines.
* **REQ-003 (30-Stage Signature Palette):** The game MUST support bespoke background colors for all 30 stages as defined in the GDD Matrix, transitioning smoothly across chapters.
* **REQ-004 (Diegetic Canvas Typography):** During active gameplay, the current stage indicator (e.g. `level 8`) MUST be rendered directly onto the canvas plane with harmonized opacity ($0.18$–$0.25$), scaling with virtual canvas resolution.
* **REQ-005 (Silhouette Prop Colliders):** Stages featuring thematic props (Levels 5, 8, 15, 18, 23, 24, 27) MUST register the prop's geometric contours as rigid obstacles in the collision engine.
* **REQ-006 (Minimalist Diegetic HUD):** The HUD MUST provide quiet, unobtrusive controls: Back (`<`), Reset (`⟳`), and optional Gravity Toggle (`⇅`), keeping the playfield free of visual clutter.
* **REQ-007 (Cup Countdown Pulse):** When a grain is captured, the cup's numeral stencil MUST decrement and trigger a brief $1.06\times$ scale pulse over $80$ ms.

### 3.2 Technical Constraints (CON)
* **CON-001 (Zero-Allocation Hot Path):** No heap allocations (e.g. `.toList()`, instantiating new `Offset`s or `Paint`s) are permitted within the 60/120 FPS render loop (`ParticlePainter.paint`).
* **CON-002 (Unified Virtual Resolution):** All silhouette props, colliders, emitters, and cups MUST be defined in the canonical $400 \times 700$ virtual coordinate space.
* **CON-003 (Deterministic Frame Rate):** The physics engine MUST remain deterministic and decoupled from screen refresh rates via fixed-step simulation ($dt = 1/60\text{ s}$).

### 3.3 Audio & Game-Feel Guidelines (GUD)
* **GUD-001 (Chime Quantization):** Particle capture audio feedback MUST scale ascending pitch frequencies using pentatonic intervals (C5, D5, E5, G5, A5) relative to the cup's filling ratio.
* **GUD-002 (Non-Intrusive Ambience):** Background chalk texture and starlight dust MUST maintain an alpha $\le 0.05$ to prevent distraction from falling particles.

---

## 4. Interfaces & Data Contracts

### 4.1 LevelVisualTheme Contract

```dart
/// Defines the unique chromatic palette, environmental silhouettes, and
/// diegetic canvas typography for a stage.
class LevelVisualTheme {
  final int levelId;
  final String stageLabel; // e.g., "level 8", "sugar, sugar"
  final Color backgroundColor;
  final Color canvasLabelColor;
  final double canvasLabelOpacity;
  final Offset canvasLabelPosition;
  final List<SilhouettePropConfig> silhouetteProps;

  const LevelVisualTheme({
    required this.levelId,
    required this.stageLabel,
    required this.backgroundColor,
    required this.canvasLabelColor,
    this.canvasLabelOpacity = 0.22,
    this.canvasLabelPosition = const Offset(280.0, 640.0),
    this.silhouetteProps = const [],
  });

  /// Factory resolving the canonical theme for a given levelId.
  static LevelVisualTheme forLevel(int levelId) {
    return _themes[levelId] ?? _defaultTheme(levelId);
  }

  static LevelVisualTheme _defaultTheme(int id) => LevelVisualTheme(
    levelId: id,
    stageLabel: 'level $id',
    backgroundColor: const Color(0xFF0B2545), // Midnight Navy
    canvasLabelColor: const Color(0xFFFFFFFF),
  );

  static final Map<int, LevelVisualTheme> _themes = {
    // Act I: Fundamentals
    1: const LevelVisualTheme(
      levelId: 1,
      stageLabel: 'sugar, sugar',
      backgroundColor: Color(0xFF0B2545), // Midnight Navy
      canvasLabelColor: Color(0xFFE2E8F0),
      canvasLabelPosition: Offset(60.0, 360.0),
    ),
    2: const LevelVisualTheme(
      levelId: 2,
      stageLabel: 'level 2',
      backgroundColor: Color(0xFF0D3B2E), // Forest Pine
      canvasLabelColor: Color(0xFFA7F3D0),
    ),
    5: const LevelVisualTheme(
      levelId: 5,
      stageLabel: 'level 5',
      backgroundColor: Color(0xFF855A08), // Vintage Mustard
      canvasLabelColor: Color(0xFFFDE68A),
      silhouetteProps: [
        SilhouettePropConfig(
          type: SilhouetteType.teaspoon,
          origin: Offset(120.0, 420.0),
          rotationDegrees: -15.0,
          scale: 1.0,
        ),
      ],
    ),
    // Act II: Prismatic Spectrum
    8: const LevelVisualTheme(
      levelId: 8,
      stageLabel: 'level 8',
      backgroundColor: Color(0xFF0F511D), // Kelly Green
      canvasLabelColor: Color(0xFF4ADE80),
      canvasLabelPosition: Offset(240.0, 620.0),
      silhouetteProps: [
        SilhouettePropConfig(
          type: SilhouetteType.teaspoonDouble,
          origin: Offset(80.0, 480.0),
          scale: 1.1,
        ),
      ],
    ),
    9: const LevelVisualTheme(
      levelId: 9,
      stageLabel: 'level 9',
      backgroundColor: Color(0xFF6A0D18), // Deep Crimson
      canvasLabelColor: Color(0xFFFCA5A5),
    ),
    // Act III: Gravity Inversion
    16: const LevelVisualTheme(
      levelId: 16,
      stageLabel: 'level 16',
      backgroundColor: Color(0xFF2E114D), // Royal Violet
      canvasLabelColor: Color(0xFFD8B4FE),
    ),
    // Act IV: Master Puzzles & Silhouettes
    23: const LevelVisualTheme(
      levelId: 23,
      stageLabel: 'level 23',
      backgroundColor: Color(0xFF540909), // Blood Crimson
      canvasLabelColor: Color(0xFFFECACA),
      silhouetteProps: [
        SilhouettePropConfig(
          type: SilhouetteType.handPouring,
          origin: Offset(260.0, 60.0),
          scale: 1.2,
        ),
        SilhouettePropConfig(
          type: SilhouetteType.handHoldingCup,
          origin: Offset(40.0, 360.0),
          scale: 1.2,
        ),
      ],
    ),
    30: const LevelVisualTheme(
      levelId: 30,
      stageLabel: 'sugar, sugar',
      backgroundColor: Color(0xFF151B24), // Chalkboard Slate
      canvasLabelColor: Color(0xFFF8FAFC),
      canvasLabelPosition: Offset(100.0, 620.0),
    ),
  };
}
```

### 4.2 SilhouettePropConfig Contract

```dart
enum SilhouetteType {
  teaspoon,
  teaspoonDouble,
  handPouring,
  handHoldingCup,
  teapotSpout,
  hourglassFrame,
}

class SilhouettePropConfig {
  final SilhouetteType type;
  final Offset origin;
  final double rotationDegrees;
  final double scale;
  final Color shadowColor;

  const SilhouettePropConfig({
    required this.type,
    required this.origin,
    this.rotationDegrees = 0.0,
    this.scale = 1.0,
    this.shadowColor = const Color(0xD905070B), // 85% solid obsidian
  });

  /// Returns the line segment colliders to register into the physics engine.
  List<LineSegment> generateColliders() {
    // Generates geometric colliders transformed by origin, scale, and rotation.
    return SilhouetteColliderFactory.create(type, origin, scale, rotationDegrees);
  }
}
```

---

## 5. Acceptance Criteria

* **AC-001 (Square Granular Rendering):**
  - **Given** active particles falling on screen or settled inside a cup,
  - **When** rendered by `ParticlePainter`,
  - **Then** `paint.strokeCap` is `StrokeCap.square` and `paint.strokeWidth` is $2.2\text{ px}$.
* **AC-002 (Natural Stream Dispersal):**
  - **Given** a particle spawned by `ParticleEmitter`,
  - **When** initialized,
  - **Then** its initial horizontal velocity includes random jitter $\Delta v_x \in [-0.35, 0.35]\text{ px/frame}$.
* **AC-003 (30-Stage Signature Background):**
  - **Given** any stage ID from 1 to 30,
  - **When** `GameScreen` mounts and initializes `BackgroundPainter`,
  - **Then** `BackgroundPainter.backgroundColor` matches the exact hex code specified in the 30-Level Characteristic Matrix.
* **AC-004 (Diegetic Canvas Typography):**
  - **Given** Level 8 is loaded,
  - **When** the canvas renders,
  - **Then** `"level 8"` is drawn directly onto the canvas floor in bold Outfit typography at opacity $0.22 \pm 0.05$.
* **AC-005 (Silhouette Collider Deflection):**
  - **Given** Level 5 or Level 8 containing a Teaspoon prop,
  - **When** sugar particles fall onto the spoon's contour,
  - **Then** particles deflect and slide across the spoon surface into the target cup without passing through.
* **AC-006 (Zero-Crash & Regression Invariant):**
  - **Given** the full test suite running via `flutter test`,
  - **Then** 100% of tests pass (minimum 171 passed tests) with 0 analyzer issues (`flutter analyze`).

---

## 6. Test Automation Strategy & Testing Seams

### 6.1 Testing Seams
* **Seam 1: `ParticlePainter` Unit Tests:** Verify `PointMode.points` batching with `StrokeCap.square`, color grouping, and settled sand mounds.
* **Seam 2: `LevelVisualTheme` Configuration Tests:** Verify that all 30 stage IDs resolve valid non-null background colors, labels, and bounding coordinates.
* **Seam 3: `SilhouetteColliderFactory` Geometric Tests:** Verify that silhouette colliders produce valid non-degenerate `LineSegment`s and properly detect raycasting intersections.
* **Seam 4: `GameScreen` Widget Integration Tests:** Verify seamless mounting of `GameScreen` with custom themes, diegetic HUD buttons, and cup integer pulse updates.

### 6.2 Coverage Requirements
* 100% coverage across new theme models (`LevelVisualTheme`) and painters (`SilhouettePainter`, modified `ParticlePainter`, modified `BackgroundPainter`).
* Zero flaky async timers or unbounded render loops.

---

## 7. Project Structure & Commands

### Project Structure
```text
micin_micin/lib/
  ├── core/
  │   └── theme.dart                     // Color tokens & typography
  ├── models/
  │   ├── level_visual_theme.dart        // 30-Level chromatic & silhouette theme
  │   └── silhouette_prop_config.dart    // Vector prop configuration
  ├── engine/
  │   ├── collision/
  │   │   └── silhouette_collider_factory.dart // Geometric line colliders for props
  │   └── particle_emitter.dart          // Stream micro-jitter emission
  └── screens/
      └── game/
          ├── game_hud.dart              // Minimalist diegetic HUD (< and ⟳)
          ├── game_screen.dart           // Screen orchestration
          └── painters/
              ├── background_painter.dart // Dynamic chromatic chalkboard painter
              ├── particle_painter.dart   // Square crystalline particle renderer
              └── silhouette_painter.dart // Vector prop shadow renderer
```

### Commands
- **Analyze:** `flutter analyze`
- **Unit & Widget Tests:** `flutter test`
- **Targeted Test:** `flutter test test/screens/game_screen_test.dart`

---

## 8. Code Style & Conventions

Concrete implementation pattern for `ParticlePainter` square grain batching:

```dart
class ParticlePainter extends CustomPainter {
  final Iterable<SugarParticle> particles;
  final List<CupHitbox>? cups;

  ParticlePainter(this.particles, {this.cups});

  @override
  void paint(Canvas canvas, Size size) {
    final hasParticles = particles.isNotEmpty;
    final hasSettled = cups != null && cups!.any((c) => c.settledParticleOffsets.isNotEmpty);
    if (!hasParticles && !hasSettled) return;

    // Zero-allocation Paint configuration for crisp square crystalline grains
    final paint = Paint()
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.square;

    if (hasParticles) {
      for (final list in _sharedColorBatches.values) {
        list.clear();
      }

      for (final p in particles) {
        if (!p.isActive || p.isCaptured) continue;
        final colorKey = p.color.toARGB32();
        var batch = _sharedColorBatches[colorKey];
        if (batch == null) {
          batch = <Offset>[];
          _sharedColorBatches[colorKey] = batch;
        }
        batch.add(Offset(p.x, p.y));
      }

      for (final entry in _sharedColorBatches.entries) {
        if (entry.value.isEmpty) continue;
        paint.color = Color(entry.key);
        canvas.drawPoints(ui.PointMode.points, entry.value, paint);
      }
    }

    if (hasSettled) {
      for (final cup in cups!) {
        if (cup.settledParticleOffsets.isNotEmpty) {
          paint.color = cup.color;
          canvas.drawPoints(ui.PointMode.points, cup.settledParticleOffsets, paint);
        }
      }
    }
  }

  static final Map<int, List<Offset>> _sharedColorBatches = {};

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
```

---

## 9. Implementation Boundaries

* **Always do:**
  - Maintain the zero-allocation hot path invariant in all CustomPainters.
  - Test all 30 stage theme resolutions in unit tests.
  - Preserve all existing router navigation keys and widget test finders.
* **Ask first:**
  - Modifying the underlying continuous collision raycasting math in `LineSegment`.
  - Adding external raster image asset files (`.png`, `.jpg`) instead of pure vector/canvas drawing.
* **Never do:**
  - Re-introduce cluttered HUD overlays or artificial lore.
  - Disable or skip existing test assertions.
  - Break the $400 \times 700$ virtual coordinate space decoupling.

---

## 10. Rationale, Context & Architecture Decisions (ADRs)

* **ADR-0001 (Geometric Collision Resolution):** Retained. Continuous line segment raycasting is preserved for all silhouette colliders.
* **ADR-0002 (Unified Virtual Resolution 400×700):** Retained. All vector silhouettes and canvas typography are calibrated to virtual coordinates.
* **ADR-0003 (1D Discrete Column Heightmap Sand Piling):** Retained. Piling dynamics inside cups and bottom mounds operate identically with square grain drawing.
* **Decisions Made:**
  - *Square vs Round StrokeCap:* `StrokeCap.square` accurately reflects Bart Bonte's crystalline pixel aesthetics without impacting performance.
  - *Vector Silhouettes vs Bitmaps:* Drawing silhouettes as pure canvas paths or SVG paths maintains crisp rendering at any resolution with zero asset load latency.

---

## 11. Dependencies & External Integrations

* **Framework:** Flutter SDK (`>=3.44.8`).
* **State Management:** Flutter Riverpod (`^2.6.1`).
* **Audio:** Audioplayers (`^6.6.0`).
* **Icons:** `flutter/material.dart` (`Icons.arrow_back_rounded`, `Icons.refresh_rounded`).

---

## 12. Examples & Edge Cases

* **Edge Case 1 (Stage with No Props):** Stages 1, 2, 3, 4 have empty `silhouetteProps: []`. `SilhouettePainter` returns immediately without invoking draw calls.
* **Edge Case 2 (Particle Falling Exactly on Prop Seam):** Silhouette colliders use continuous overlap resolution identical to player lines (`dot > 0 => n = -n`), preventing particles from tunneling through convex corners.
* **Edge Case 3 (Extreme Aspect Ratios):** Canvas typography is anchored to virtual coordinates $(x_v, y_v)$ inside the letterboxed $400 \times 700$ box, guaranteeing it never stretches or clips on ultrawide or tablet screens.

---

## 13. Validation Criteria

1. `flutter analyze` runs with **0 issues found**.
2. `flutter test` passes with **100% green pass rate** across all unit, widget, and integration tests.
3. Visual verification confirms square granular crystalline particles and correct background palettes across Act I through Act IV.

---

## 14. Related Specifications & Upstream Documents

* [GDD: Bart Bonte Aesthetic, Particle Dynamics & 30-Level Characteristic Architecture](file:///d:/kayzz/flutter/micin/docs/gdd/GDD-bonte-aesthetic-and-level-design.md)
* [Architecture Map](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md)
* [Domain Glossary](file:///d:/kayzz/flutter/micin/CONTEXT.md)
