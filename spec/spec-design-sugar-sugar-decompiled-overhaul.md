---
title: "Technical Specification: 1:1 Sugar, Sugar (Bart Bonte) Complete Overhaul & Asset Integration"
version: "1.0.0"
date_created: "2026-10-29"
last_updated: "2026-10-29"
owner: "Specification Architect"
tags: ["spec", "bart-bonte", "sugar-sugar", "decompiled-assets", "flame-game", "minimalist-vector", "audio-integration"]
---

# Technical Specification: 1:1 Sugar, Sugar (Bart Bonte) Complete Overhaul & Asset Integration

## Introduction

This Technical Specification establishes the engineering requirements, data schemas, rendering contracts, and integration interfaces for transitioning **Micin Micin** from the *Pixel Koi Zen* theme into an authentic, pixel-faithful 1:1 recreation of Bart Bonte's official mobile game ***Sugar, Sugar***.

This specification builds directly upon the approved discovery document ([docs/discovery-draft-20261029-sugar-sugar-decompiled-analysis.md](file:///d:/kayzz/flutter/micin/docs/discovery-draft-20261029-sugar-sugar-decompiled-analysis.md)), user-approved **Option A (Total Visual Overhaul)**, and the retention of the **Flame Game Engine Bridge** (`MicinGame`).

---

## 1. Purpose & Scope

### 1.1 In-Scope Components

1. **Asset Integration (Original Decompiled Media):**
   - Copy and wire original audio files into `assets/audio/`:
     - `sugar_song.mp3` (BGM: 44.1 kHz acoustic guitar loop).
     - `ok_sound.mp3` (SFX: level clear and button tap chime).
   - Copy and replace application launcher icons and graphics from `D:\kayzz\android\sugar_sugar\app\src\main\res`:
     - `android/app/src/main/res/mipmap-*/icon.png` and `ic_launcher`.
     - `assets/images/branding/banner.png` and `splash_portrait.png`.
2. **Visual Aesthetics & Style Migration (Option A - Total Overhaul):**
   - Remove/deprecate `PixelTerrainTokens`, topographic contour elevation shelves, and 16-bit texture stippling from `BackgroundFlameComponent`.
   - Implement clean, flat solid background colors per level matrix (e.g. Level 1: Pine Green `#076B07`, Menu: Deep Blue `#07456B`) matching the decompiled ActionScript values (`backkleur`).
   - Refactor `LevelGeometryFlameComponent` to render flat vector primitives:
     - **Cups:** Minimalist outline cup with stencil mouth and centered dynamic numerical text (`tel`), shifting to gold upon reaching 0.
     - **Beams / Obstacles:** Flat rounded rectangular bars (`balkgroen`, `balkoranje`, `balkrood`, `balkblauw`, `balkroze`) with subtle 1px stroke.
     - **Sugar Spout:** Iconic typographical comma (`,`) spout where particles stream from the comma tip.
     - **Filter Gates:** Two-tone optical ring filters with color-coded entry/exit markers.
     - **Portals / Teleporters:** Concentric vector portal rings in magenta (`telein_p` / `teleout_p`) and cyan (`telein_b` / `teleout_b`).
3. **HUD & Control System Overhaul:**
   - Redesign `GameHud` to match the original circular vector buttons:
     - Reset (`⟳`), Sugar Flow Pause/Play (`⏸`/`▶`), Gravity Switch (`⇅`), and Audio Toggle (`🔊`/`🔇`).
     - Level indicator displayed diegetically on the bottom bar (`LEVEL 1`).
     - Centered victory banner (`spr_buttonnext` / OK button) fading in upon level completion.
4. **Particle Calibration:**
   - Fine-tune particle rendering to crisp white square grains ($2.0 \times 2.0\text{ px}$) matching original `suiker` visual density.

### 1.2 Out of Scope

- Rewriting the headless `GameEngine` or `ParticlePool` architecture (the existing high-performance engine is preserved).
- Changing the virtual resolution coordinate system contract ($400 \times 700$ virtual space).
- Adding online networking, analytics, or ads (game remains 100% offline).

---

## 2. Definitions & Domain Alignment

Terminology strictly adheres to `CONTEXT.md` and the decompiled ActionScript symbols:

| Canonical Term | Definition | _Avoid_ |
|:---|:---|:---|
| **Comma Spout** | The typographical comma (`,`) serving as the particle emitter source. | *Pipe*, *Nozzle*, *Emitter Box* |
| **Obstacle Beam** | Flat rounded rectangular barrier (`balk`) that deflects particles. | *Terrain Shelf*, *Platform Tile* |
| **Color Gate** | Optical filter zone that mutates passing particle color (`filter_*_*`). | *Color Portal*, *Tint Chamber* |
| **Sugar Grain** | Individual white or tinted granular particle (`suiker`). | *Dot*, *Koi Pellet*, *Sand Spec* |
| **Cup Vessel** | Minimalist flat outlined cup container with countdown number (`cup_*`). | *Bucket*, *Pot*, *Goal Zone* |

---

## 3. Requirements, Constraints & Guidelines

### 3.1 Functional Requirements (REQ)

* **REQ-001 (Audio Ingestion):** The game MUST loop `sugar_song.mp3` as the primary background music across Menu, Level Select, and Active Gameplay, pausing and resuming cleanly during app lifecycle events.
* **REQ-002 (Victory Chime):** When all cups reach zero remaining particles, the game MUST play `ok_sound.mp3` once and present the centered `NEXT` button.
* **REQ-003 (Solid Stage Backgrounds):** Each stage MUST render a solid background color corresponding to its decompiled `backkleur` hex value.
* **REQ-004 (Typographical Comma Emitter):** All stages MUST render the sugar emitter as an iconic serif/sans comma symbol (`,`), emitting grains from its bottom tip.
* **REQ-005 (Flat Vector Cups):** Target cups MUST be drawn as minimalist vector outlines with an open mouth aperture and centered countdown number that updates in real time.
* **REQ-006 (HUD Controls Replication):** The in-game HUD MUST provide circular icon buttons for Reset, Sugar Flow Pause/Play, Audio Toggle, and (where applicable) Gravity Switch.
* **REQ-007 (Level Progression Alignment):** All 30 stages MUST preserve sequential unlock progression under key `sugarshared` in `SharedPreferences`.

### 3.2 Technical Constraints (CON)

* **CON-001 (60/120 FPS Zero-Allocation Hot Path):** Neither Flame components (`LevelGeometryFlameComponent`, `ParticleSystemFlameComponent`) nor custom painters may instantiate objects on the heap during the frame loop.
* **CON-002 (Unified Virtual Resolution):** All coordinates for cups, obstacles, spouts, and filters MUST remain strictly mapped to the $400 \times 700$ virtual coordinate space via `VirtualCoordinateAdapter`.
* **CON-003 (Asset Size & Offline Invariant):** All assets MUST be bundled locally with zero runtime network fetching.

---

## 4. Interfaces & Data Contracts

### 4.1 Audio System Contract (`AudioManager`)

```dart
enum SoundType {
  buttonClick,
  grainCaptured,
  levelComplete, // triggers ok_sound.mp3
  gravityFlip,
  portalWhoosh,
}

abstract class IAudioManager {
  Future<void> playBgm(); // loops sugar_song.mp3
  Future<void> stopBgm();
  Future<void> playSfx(SoundType type);
  void setSoundEnabled(bool enabled);
}
```

### 4.2 Stage Visual Theme Contract (`StageVisualTheme`)

```dart
class StageVisualTheme {
  final Color backgroundColor;
  final Color obstacleColor;
  final Color lineColor;
  final Color accentColor;

  const StageVisualTheme({
    required this.backgroundColor,
    required this.obstacleColor,
    required this.lineColor,
    required this.accentColor,
  });

  // Example mappings extracted from SWF:
  static const StageVisualTheme stage1 = StageVisualTheme(
    backgroundColor: Color(0xFF076B07), // Pine Green
    obstacleColor: Color(0xFF30D30B),
    lineColor: Color(0xFF30D30B),
    accentColor: Color(0xFFFFFFFF),
  );
  
  static const StageVisualTheme menu = StageVisualTheme(
    backgroundColor: Color(0xFF07456B), // Deep Blue Slate
    obstacleColor: Color(0xFF00ADB5),
    lineColor: Color(0xFFEEEEEE),
    accentColor: Color(0xFFF38181),
  );
}
```

### 4.3 Level Geometry Flame Component Contract

```dart
class LevelGeometryFlameComponent extends PositionComponent with HasGameRef<MicinGame> {
  // Renders:
  // 1. Typographical comma spouts at emitter positions
  // 2. Flat rounded obstacle beams (balk)
  // 3. Vector outline cups with centered text counter
  // 4. Color filter gates and portal rings
  // 5. Diegetic "LEVEL X" text
}
```

---

## 5. Acceptance Criteria

- **AC-001**: Given active gameplay, when the user launches the app or enters a level, then `sugar_song.mp3` plays smoothly in an infinite loop without audio clipping.
- **AC-002**: Given all cups reaching target count ($0$), when the stage completes, then `ok_sound.mp3` triggers once and the center Next button appears.
- **AC-003**: Given any stage from 1 to 30, when rendered, then the background displays the authentic solid stage color without any Japanese Zen contour textures or stippling.
- **AC-004**: Given the in-game HUD, when viewing the top/side controls, then minimalist circular buttons (Reset, Sound, Pause, Gravity) are clearly interactive and responsive.
- **AC-005**: Given the sugar dispenser, when sugar falls, then grains originate directly from the tip of the typographical comma spout.

---

## 6. Project Structure & Asset Paths

```text
micin_micin/
├── assets/
│   ├── audio/
│   │   ├── sugar_song.mp3       <-- Extracted from decompiled SWF ID 535
│   │   └── ok_sound.mp3         <-- Extracted from decompiled SWF ID 26
│   └── images/
│       ├── branding/
│       │   ├── banner.png       <-- From res/drawable/banner.png
│       │   └── splash.png       <-- From res/drawable-nodpi/splash_portrait.png
│       └── icons/
│           └── icon.png         <-- From res/mipmap-xxxhdpi/icon.png
├── lib/
│   ├── core/
│   │   ├── stage_visual_theme.dart  <-- Authentic stage color palettes
│   │   └── theme.dart               <-- Minimalist vector design tokens
│   ├── flame_game/
│   │   ├── components/
│   │   │   ├── background_flame_component.dart   <-- Solid stage color renderer
│   │   │   ├── level_geometry_component.dart     <-- Flat vector cups, beams, commas
│   │   │   └── particle_system_component.dart    <-- Crisp square sugar grains
│   │   └── micin_game.dart
│   └── screens/
│       ├── game/
│       │   └── game_hud.dart        <-- Minimalist circular glyph buttons
│       ├── menu/
│       │   └── menu_screen.dart     <-- "sugar, sugar" title & falling grains
│       └── levels/
│           └── level_select_screen.dart <-- Stage select with continue ball
```

---

## 7. Implementation Boundaries

- **Always do:** Preserve zero-allocation hot paths; test all screen sizes on the $400 \times 700$ virtual canvas; run `flutter test` before committing.
- **Ask first:** Modifying core physics constants ($g = 0.14$, $v_{\max} = 4.8$) or altering save data schema.
- **Never do:** Commit proprietary credentials; re-introduce heavy pixel textures into hot render loops; break existing unit tests.

