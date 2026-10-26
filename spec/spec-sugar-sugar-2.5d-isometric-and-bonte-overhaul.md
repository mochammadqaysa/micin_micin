# Technical Specification: 2.5D Isometric Visuals, Seamless Level Advance & Anti-Slop Layout Overhaul

> **Document ID:** SPEC-20261006-2.5D-OVERHAUL  
> **Status:** ARCHIVED & SUPERSEDED by Chunky Arcade  
> **Version:** 1.0.0  

> [!WARNING]
> **ARCHIVED & SUPERSEDED BY CHUNKY ARCADE**:
> While direct stage flow, anti-slop copy rules, and the headless physics engine remain active, the 2.5D visual styling has been consolidated and superseded by the canonical **Chunky Arcade** design language (`CartoonTokens`, 3D extruded slabs, solid drop shadows, and arcade coin HUD). Refer to [docs/design/art-direction-brief.md](file:///d:/kayzz/flutter/micin/docs/design/art-direction-brief.md) and [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md).
> **Upstream GDD:** [docs/gdd/GDD-sugar-sugar-2.5d-isometric-overhaul.md](file:///d:/kayzz/flutter/micin/docs/gdd/GDD-sugar-sugar-2.5d-isometric-overhaul.md)  
> **Reference File:** [docs/references/sugarsugar.swf](file:///d:/kayzz/flutter/micin/docs/references/sugarsugar.swf)  
> **Active Filter:** `antislop active: during (session override).`  

---

## 1. Scope & Technical Objectives

This specification defines the architectural contracts, data model simplifications, rendering upgrades, and state transitions required to align the application with Bart Bonte's authentic *Sugar, Sugar* design principles and 2.5D isometric vector rendering.

### 1.1 Technical Requirements
* **REQ-001 (2.5D Isometric Vessel & Emitter Rendering):**
  * Target cups in `LevelPainter` shall render with an elliptical opening rim (`Rect.fromCenter` with vertical compression ratio $0.35$), dimensional gradient-shaded sidewalls, and ground contact shadow ellipses at the vessel base.
  * Particle emitters shall render as tapered isometric funnel nozzles with downward elliptical mouth apertures.
  * Internal physics hitboxes (`CupHitbox`) shall remain strictly rectangular in $400 \times 700$ coordinate space to guarantee zero physics desynchronization.
* **REQ-002 (Menu Screen Interactive Line Removal):**
  * `MenuScreen` shall completely decouple `LineController`, touch drag detectors for freehand drawing, and the `CLEAR` button.
  * Main menu interactions shall be strictly limited to tactile navigation buttons: `PLAY`, `LEVELS`, and `AUDIO`.
* **REQ-003 (Seamless Level Advance Without Modal Dialog):**
  * When `GameEngine.isComplete` becomes `true`, `GameScreen` shall trigger a non-blocking 1000ms countdown timer.
  * The victory chime sound shall play immediately at completion onset.
  * `LevelCompleteDialog` overlay shall be removed.
  * At timer expiry, if `levelId < 30`, `GameScreen` shall execute `context.pushReplacement('/game/${levelId + 1}')`. If `levelId == 30`, it shall navigate to `/levels`.
* **REQ-004 (Purge of Poetic AI Slop Text):**
  * Remove all occurrences of "EQUILIBRIUM", "KABUT FAJAR", "zenReflection", and philosophical meditator flavor text from `LevelAmbiance`, `LevelVisualTheme`, and UI labels.
  * Stage identifiers across canvas and navigation shall adhere strictly to standard minimalist numerical conventions (`Level 1` through `Level 30`).
* **REQ-005 (Preservation of Zero-Warning Test Suite):**
  * All tests in `test/` shall be updated to reflect the new architecture, maintaining a 100% pass rate across the full test suite.

---

## 2. Architecture & Data Contracts

### 2.1 2.5D Isometric Cup Geometry Model in `LevelPainter`
```dart
// Coordinate Math for 2.5D Cup Projection
final rect = Rect.fromLTWH(cup.x, cup.y, cup.width, cup.height);

// 1. Ground Contact Shadow (Soft Perspective Base Oval)
final shadowRect = Rect.fromCenter(
  center: Offset(rect.center.dx, rect.bottom + 2.0),
  width: rect.width * 1.05,
  height: 8.0,
);
canvas.drawOval(shadowRect, groundShadowPaint);

// 2. Isometric Vessel Body (Tapered trapezoid sidewalls)
final bodyPath = Path()
  ..moveTo(rect.left, rect.top + 4.0)
  ..lineTo(rect.left + 2.0, rect.bottom - 4.0)
  ..quadraticBezierTo(rect.left + 3.0, rect.bottom, rect.left + 8.0, rect.bottom)
  ..lineTo(rect.right - 8.0, rect.bottom)
  ..quadraticBezierTo(rect.right - 3.0, rect.bottom, rect.right - 2.0, rect.bottom - 4.0)
  ..lineTo(rect.right, rect.top + 4.0)
  ..close();
canvas.drawPath(bodyPath, bodyFillPaint);

// 3. Top Rim Opening (Isometric Ellipse)
final topRimRect = Rect.fromLTWH(
  rect.left,
  rect.top - 2.0,
  rect.width,
  rect.width * 0.28,
);
canvas.drawOval(topRimRect, rimInteriorPaint);
canvas.drawOval(topRimRect, rimStrokePaint);
```

### 2.2 Direct Stage Transition Contract in `GameScreen`
```dart
void _handleLevelCompletion() {
  if (_hasHandledCompletion) return;
  _hasHandledCompletion = true;

  // 1. Play victory chime
  ref.read(audioManagerProvider).playSfx(SoundType.levelComplete);

  // 2. Persist level progress
  ref.read(playerProgressProvider.notifier).unlockLevel(widget.levelId + 1);

  // 3. Automated non-blocking transition after 1000ms
  Future.delayed(const Duration(milliseconds: 1000), () {
    if (!mounted) return;
    if (widget.levelId < kTotalLevels) {
      context.pushReplacement('/game/${widget.levelId + 1}');
    } else {
      context.go('/levels');
    }
  });
}
```

---

## 3. Test Strategy & Verification Matrix

| Test Suite | File | Verification Criteria |
|:---|:---|:---|
| **Menu Screen Tests** | `test/screens/menu_screen_test.dart` | Verify no `LineController` or `CLEAR` button exists. Drag gestures do not paint lines. |
| **Game Screen Tests** | `test/screens/game_screen_test.dart` | Verify `LevelCompleteDialog` is not displayed upon completion; transitions automatically to next level. |
| **Painter Tests** | `test/painters/level_painter_test.dart` | Verify 2.5D isometric geometry paths render without exceptions. |
| **Model Cleanliness Tests** | `test/models/level_ambiance_test.dart` | Verify all 30 stages return clean identifiers (`Level 1`..`30`) without poetic slop. |
