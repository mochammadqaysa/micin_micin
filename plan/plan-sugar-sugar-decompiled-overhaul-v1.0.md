---
goal: 1:1 Sugar, Sugar (Bart Bonte) Complete Overhaul & Asset Integration Plan
version: 1.0.0
date_created: 2026-10-29
last_updated: 2026-10-30
owner: Planner Architect
status: 'Completed'
tags: ["plan", "sugar-sugar", "bart-bonte", "asset-integration", "visual-overhaul", "flame-game"]
---

# Introduction

![Status: Completed](https://img.shields.io/badge/status-Completed-green)

This Implementation Plan breaks down the execution of the approved Technical Specification ([spec/spec-design-sugar-sugar-decompiled-overhaul.md](file:///d:/kayzz/flutter/micin/spec/spec-design-sugar-sugar-decompiled-overhaul.md)) into deterministic, vertically sliced Tracer Bullet tasks. 

Following the user's explicit selection of **Option A (Total Visual Overhaul)** and retaining the **Flame Component Bridge**, this plan transitions the entire game into a 1:1 authentic replica of Bart Bonte's official mobile game *Sugar, Sugar*, integrating the original extracted BGM/SFX audio, branding graphics, flat vector rendering, comma spouts, and minimalist circular HUD.

---

## 1. Requirements & Constraints

- **REQ-001**: Loop `sugar_song.mp3` as primary background music across menu and gameplay.
- **REQ-002**: Trigger `ok_sound.mp3` on stage completion and button interactions.
- **REQ-003**: Render solid stage backgrounds based on original `backkleur` palette without Zen terrain stippling.
- **REQ-004**: Render sugar emitters as typographical comma spouts (`,`).
- **REQ-005**: Render target cups as minimalist flat outlines with dynamic centered numerical countdowns.
- **REQ-006**: Replace HUD with minimalist circular vector glyph buttons.
- **CON-001**: 60/120 FPS zero-allocation render loop constraint.
- **CON-002**: Unified $400 \times 700$ virtual coordinate space invariant.

---

## 2. Implementation Steps

> **EXECUTION DIRECTIVE FOR AI AGENTS:**
> You MUST execute this plan phase by phase. You MUST run the specific testing/verification task at the end of each phase. After a phase is tested, you **MUST STOP AND WAIT** for the user's explicit approval before proceeding to the next phase.

### Implementation Phase 1: Original Audio & Platform Assets Integration

- GOAL-001: Extract, bundle, and wire original audio (`sugar_song.mp3`, `ok_sound.mp3`), launcher icons, and splash graphics into the Flutter project.

| Task     | Description                                                                                                   | Ref ID  | AC Ref | Dep | Files | Completed | Date |
| -------- | ------------------------------------------------------------------------------------------------------------- | ------- | ------ | --- | ----- | --------- | ---- |
| TASK-001 | Copy extracted `sugar_song.mp3` and `ok_sound.mp3` into `assets/audio/`, and update `pubspec.yaml` assets.    | REQ-001 | AC-001 | -   | 2-3   | [x]       | 2026-10-29 |
| TASK-002 | Wire `AudioManager` to play `sugar_song.mp3` in infinite loop and configure `ok_sound.mp3` for `levelComplete`. | REQ-001 | AC-001 | TASK-001 | 1-2 | [x]       | 2026-10-29 |
| TASK-003 | Copy application icons and splash graphics from decompiled `res/` into Flutter and Android launcher directories. | REQ-002 | AC-001 | -   | 4-5   | [x]       | 2026-10-29 |
| TASK-004 | **VERIFY**: Run `flutter test test/audio/audio_manager_test.dart` to verify audio playback contracts.         | -       | -      | TASK-002 | - | [x]       | 2026-10-29 |
| TASK-005 | **APPROVAL**: Wait for explicit user confirmation to proceed to Phase 2.                                      | -       | -      | TASK-004 | - |           |      |

---

### Implementation Phase 2: Visual Style Overhaul (Flat Bart Bonte Aesthetic)

- GOAL-002: Replace Pixel Koi Zen elevation contours and pixel art textures with authentic flat vector primitives and solid stage palettes.

| Task     | Description                                                                                                   | Ref ID  | AC Ref | Dep | Files | Completed | Date |
| -------- | ------------------------------------------------------------------------------------------------------------- | ------- | ------ | --- | ----- | --------- | ---- |
| TASK-006 | Create `StageVisualTheme` mapping authentic stage background colors (`backkleur`) and obstacle colors.       | REQ-003 | AC-003 | TASK-002 | 1-2 | [x]       | 2026-10-29 |
| TASK-007 | Refactor `BackgroundFlameComponent` to render clean, flat solid background colors per active stage theme.    | REQ-003 | AC-003 | TASK-006 | 1   | [x]       | 2026-10-29 |
| TASK-008 | Refactor `LevelGeometryFlameComponent` to render flat vector cups with centered countdown number and flat beams. | REQ-005 | AC-004 | TASK-006 | 1-2 | [x]       | 2026-10-29 |
| TASK-009 | Implement typographical comma spout (`,`) rendering in `LevelGeometryFlameComponent` for sugar emission.     | REQ-004 | AC-005 | TASK-008 | 1   | [x]       | 2026-10-29 |
| TASK-010 | **VERIFY**: Run `flutter test test/flame_game/` to verify level geometry rendering and zero-allocation integrity. | -       | -      | TASK-009 | - | [x]       | 2026-10-29 |
| TASK-011 | **APPROVAL**: Wait for explicit user confirmation to proceed to Phase 3.                                      | -       | -      | TASK-010 | - |           |      |

---

### Implementation Phase 3: HUD, Menus & Level Completion Flow Overhaul

- GOAL-003: Overhaul HUD into minimalist circular vector glyph buttons and replicate the original level completion sequence and menu title.

| Task     | Description                                                                                                   | Ref ID  | AC Ref | Dep | Files | Completed | Date |
| -------- | ------------------------------------------------------------------------------------------------------------- | ------- | ------ | --- | ----- | --------- | ---- |
| TASK-012 | Redesign `GameHud` with circular icon buttons (Reset, Pause Sugar, Audio Toggle, Gravity Flip) & bottom level tag. | REQ-006 | AC-004 | TASK-008 | 1-2 | [x]       | 2026-10-30 |
| TASK-013 | Update level complete sequence to trigger `ok_sound.mp3` and display centered Next button dialog.              | REQ-002 | AC-002 | TASK-012 | 1-2 | [x]       | 2026-10-30 |
| TASK-014 | Update `MenuScreen` to render "sugar, sugar" typography, acoustic BGM autoplay, and falling grains background.  | REQ-001 | AC-001 | TASK-012 | 1-2 | [x]       | 2026-10-30 |
| TASK-015 | **VERIFY**: Run `flutter test test/screens/` to ensure HUD interactions and screen transitions pass without errors. | -    | -      | TASK-014 | - | [x]       | 2026-10-30 |
| TASK-016 | **APPROVAL**: Wait for explicit user confirmation to proceed to Phase 4.                                      | -       | -      | TASK-015 | - |           |      |

---

### Implementation Phase 4: Stage Geometry Calibration & Final Polish

- GOAL-004: Validate all 30 level configurations against decompiled SWF bytecode and execute full macro test suite.

| Task     | Description                                                                                                   | Ref ID  | AC Ref | Dep | Files | Completed | Date |
| -------- | ------------------------------------------------------------------------------------------------------------- | ------- | ------ | --- | ----- | --------- | ---- |
| TASK-017 | Audit and align stage obstacle/cup coordinates in `assets/levels/` with decompiled `initIndivLevel` bytecode. | REQ-007 | AC-005 | TASK-012 | 2-4 | [x]       | 2026-10-30 |
| TASK-018 | Tune granular square particle size and stream velocity to match authentic Flash sugar dispersal feel.        | REQ-004 | AC-005 | TASK-017 | 1-2 | [x]       | 2026-10-30 |
| TASK-019 | **VERIFY**: Execute complete macro test suite (`flutter test`) verifying zero failures across all test files. | -       | -      | TASK-018 | - | [x]       | 2026-10-30 |
| TASK-020 | **APPROVAL**: Final phase review and sign-off.                                                                | -       | -      | TASK-019 | - | [x]       | 2026-10-30 |

---

## 3. Files Affected

- `assets/audio/sugar_song.mp3` (New: extracted BGM)
- `assets/audio/ok_sound.mp3` (New: extracted SFX)
- `assets/images/branding/banner.png` (New: branding header)
- `assets/images/branding/splash_portrait.png` (New: splash screen)
- `pubspec.yaml` (Asset declarations)
- `lib/services/audio_manager.dart` (BGM & SFX player wiring)
- `lib/core/stage_visual_theme.dart` (New: solid stage color palettes)
- `lib/flame_game/components/background_flame_component.dart` (Solid background rendering)
- `lib/flame_game/components/level_geometry_component.dart` (Vector cups, beams, and comma spouts)
- `lib/screens/game/game_hud.dart` (Circular minimalist glyph HUD)
- `lib/screens/menu/menu_screen.dart` (Menu typography & sugar rain)

---

## 4. Risks & Assumptions

- **ASSUMPTION-001**: Extracted MP3s (`sugar_song.mp3`, `ok_sound.mp3`) decode cleanly with `audioplayers` 6.1 on iOS, Android, and desktop. *(Verified: clean standard MP3 frames with sync word 0xFFFB)*.
- **ASSUMPTION-002**: Retaining Flame `GameWidget` with procedural `Canvas.drawRect` and `Canvas.drawPath` avoids sprite texture loading latency and guarantees instant 60/120 FPS execution.
- **RISK-001**: Existing widget tests that expect `pixel_ui` or `PixelBox` finders may fail if keys are changed. *(Mitigation: Retain all existing semantic keys such as `Key('hud_reset')`, `Key('hud_pause')`)*.

---

## 5. Rollback / Recovery Plan

If any phase encounters critical blockers:
1. Revert Git commits: `git checkout HEAD~1`
2. Restore previous assets via `git checkout assets/`
3. Rerun `flutter test` to ensure baseline integrity.

