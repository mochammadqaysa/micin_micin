---
goal: "Implement Modern Minimalist & Glassmorphism UI Overhaul across All Screens"
version: "1.0"
date_created: "2026-10-05"
last_updated: "2026-10-05"
owner: "Planner Architect"
status: "Planned"
tags: ["plan", "ui-ux", "glassmorphism", "game-feel", "tracer-bullets", "hud", "bento-grid", "flutter"]
---

# Introduction

![Status: Archived](https://img.shields.io/badge/status-archived-lightgrey)

> [!WARNING]
> **ARCHIVED & SUPERSEDED BY CHUNKY ARCADE**:
> This implementation plan details a historical visual iteration (Glassmorphism) that has been superseded by the canonical **Chunky Arcade** visual identity (`CartoonTokens`, 3D extruded slabs, solid drop shadows, and arcade coin HUD). Refer to [docs/design/art-direction-brief.md](file:///d:/kayzz/flutter/micin/docs/design/art-direction-brief.md), [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md), and [CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md) for active execution standards.

This Implementation Plan establishes the historical roadmap that explored the **Modern Minimalist & Glassmorphism UI Overhaul** in **Micin Micin**.

Following the approved Technical Specification ([spec/spec-design-modern-glassmorphism-ui.md](file:///d:/kayzz/flutter/micin/spec/spec-design-modern-glassmorphism-ui.md)) and Clarification Audit Report ([docs/audit/clarification-report-modern-glassmorphism-ui-2026-10-05.md](file:///d:/kayzz/flutter/micin/docs/audit/clarification-report-modern-glassmorphism-ui-2026-10-05.md)), this plan breaks down execution into 4 independently verifiable **Tracer Bullet** phases:
1. **Foundation, Design Tokens & Core Glass Components (Tracer Bullet 1):** Codify `GlassTokens`, create reusable `GlassContainer` (with Dual Glass Pipeline mode toggle) and tactile `GlassPillButton` (with squash & pop micro-animation).
2. **In-Game Diegetic Glass HUD, Vessels & Overlays (Tracer Bullet 2):** Implement Mode B pre-composited frosted glass chips in `GameHud`, Option A pure vector glass vessels in `LevelPainter`, and full-bleed glass blur overlays in `PauseOverlay` and `LevelCompleteDialog`.
3. **Modern Glass Bento Grid Stage Selector & Pebble Nodes (Tracer Bullet 3):** Overhaul `LevelSelectScreen` into an asymmetric 4-Act Glass Bento Grid with $2 \times 1$ wide milestone cards and tactile frosted glass pebble nodes.
4. **Modern Glass Sandbox Main Menu, Splash & Full Regression (Tracer Bullet 4):** Upgrade `MenuScreen` and `SplashScreen` with modern glass styling, diegetic glass nozzle, interactive sandbox, and verify 100% test pass rate across all 157 automated tests.

> **Upstream Specification**: [spec/spec-design-modern-glassmorphism-ui.md](file:///d:/kayzz/flutter/micin/spec/spec-design-modern-glassmorphism-ui.md) (Readiness Score: 100/100, Option A Approved)  
> **GDD Reference**: [docs/gdd/GDD-modern-glassmorphism-ui-overhaul.md](file:///d:/kayzz/flutter/micin/docs/gdd/GDD-modern-glassmorphism-ui-overhaul.md)  
> **Clarification Report**: [docs/audit/clarification-report-modern-glassmorphism-ui-2026-10-05.md](file:///d:/kayzz/flutter/micin/docs/audit/clarification-report-modern-glassmorphism-ui-2026-10-05.md)  
> **Living Architecture Map**: [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md)  
> **Domain Glossary**: [CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md)  

---

## 1. Requirements & Constraints

- **REQ-001**: Codify `GlassTokens` in `lib/core/theme.dart` (Obsidian Void `#0B0E14`, Frosted surfaces, 1px gradient borders, Refractive Neon mineral accents).
- **REQ-002**: Implement `GlassContainer` supporting `BackdropFilter` with `ClipRRect`, `borderGradient`, and `enableLiveBlur` toggle wrapped in `RepaintBoundary`.
- **REQ-003**: Implement `GlassPillButton` with integrated tactile squash-and-pop physics (50ms squash to `0.92`, 220ms spring pop to `1.08` with `Curves.easeOutBack`, audio `click.wav` trigger).
- **REQ-004**: Implement Dual Glass Pipeline: Mode A live blur for stationary menus & overlays; Mode B pre-composited frosted gradients for active playfield HUDs.
- **REQ-005**: Render Target Cups and Filter Gates in `LevelPainter` using Option A (translucent beveled glass vectors `alpha: 0.14` and neon aperture glows) directly on Canvas.
- **REQ-006**: Overhaul `LevelSelectScreen` to a 4-Act Glass Bento Grid with $2 \times 1$ wide featured milestone cards, breathing cyan pulse on the next playable stage, and locked micro-shake.
- **REQ-007**: Overhaul `MenuScreen` with diegetic glass nozzle, interactive sandbox with CCD physics, and frosted action pills (`PLAY`, `CHAMBERS`, `CREDITS`).
- **CON-001**: Steady 60/120 FPS performance (<16.6ms per frame) with 500 active granular particles on mobile hardware (Zero-GC hot path).
- **CON-002**: Strict retention of all existing test keys (`hud_reset`, `hud_pause`, `hud_audio`) and semantic text finders (`'PLAY'`, `'CHAMBERS'`, `'CREDITS'`, `'Pilih Level'`, `'0/30'`, `'CLEAR'`, `'0 1'`) to maintain 100% test suite pass rate.
- **SEC-001**: 100% offline execution; zero external network calls or remote asset fetching.

---

## 2. Implementation Steps

> **EXECUTION DIRECTIVE FOR AI AGENTS:**  
> You MUST execute this plan phase by phase. You MUST run the specific testing/verification task at the end of each phase. After a phase is tested, you **MUST STOP AND WAIT** for the user's explicit approval before proceeding to the next phase.

---

### Implementation Phase 1 — Foundation, Design Tokens & Core Glass Components (Tracer Bullet 1)

- **GOAL-001**: Establish `GlassTokens` design constants in `lib/core/theme.dart`, build reusable `GlassContainer` and tactile `GlassPillButton` with squash & pop animations, and verify with 100% passing component widget tests.

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
|---|---|---|---|---|---|---|---|
| TASK-101 | Add `GlassTokens` abstract final class in `lib/core/theme.dart`: define `obsidianVoid`, `surfaceLight`, `surfaceSubtle`, `surfaceElevated`, `borderHighlight`, `borderShadow`, `neonCyan`, `neonRose`, `radiantGold`, `mintFlora`, blur sigmas, and corner radii. Update `AppTheme.darkTheme` colors to obsidian void. | REQ-001 | AC-001 | - | 1 | [x] | 2026-10-05 |
| TASK-102 | Create reusable `GlassContainer` in `lib/widgets/glass_container.dart`: implement `BackdropFilter` with `ClipRRect`, linear gradient border decoration, padding, and `enableLiveBlur` toggle (Mode A vs Mode B), wrapped inside `RepaintBoundary`. | REQ-002, REQ-004 | AC-001, AC-005 | TASK-101 | 1 | [x] | 2026-10-05 |
| TASK-103 | Create tactile `GlassPillButton` in `lib/widgets/glass_pill_button.dart`: implement `Listener` pointer down/up tracking, `AnimationController` driving 50ms squash to `0.92` and 220ms spring pop overshoot to `1.08` with `Curves.easeOutBack`, and trigger synthesized `click.wav` audio cue. | REQ-003 | AC-002 | TASK-102 | 1 | [x] | 2026-10-05 |
| TASK-104 | Create comprehensive widget tests in `test/widgets/glass_container_test.dart` and `test/widgets/glass_pill_button_test.dart`: verify blur sigma toggle, gradient border rendering, pointer down squash, and `onTap` firing. | REQ-002, REQ-003 | AC-001, AC-002 | TASK-103 | 2 | [x] | 2026-10-05 |
| TASK-105 | **VERIFY**: Run `flutter test test/widgets/` and `flutter analyze` to verify zero test failures and zero analyzer issues. | - | - | TASK-104 | - | [x] | 2026-10-05 |
| TASK-106 | **APPROVAL**: Wait for explicit user confirmation before proceeding to Phase 2. | - | - | TASK-105 | - | [x] | 2026-10-05 |

---

### Implementation Phase 2 — In-Game Diegetic Glass HUD, Vessels & Overlays (Tracer Bullet 2)

- **GOAL-002**: Modernize active gameplay visuals by implementing Mode B pre-composited frosted glass chips in `GameHud`, Option A pure vector glass vessels in `LevelPainter`, and full-bleed glass blur overlays in `PauseOverlay` and `LevelCompleteDialog`.

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
|---|---|---|---|---|---|---|---|
| TASK-201 | Overhaul `GameHud` in `lib/screens/game/game_hud.dart`: implement Mode B pre-composited frosted glass chips for Reset (`Key('hud_reset')`), Pause (`Key('hud_pause')`), and Audio (`Key('hud_audio')`), formatted stage numeral (`0 1`), and dual-chevron gravity pill, strictly preserving all test keys and callbacks. | REQ-004, REQ-006 | AC-004, AC-005 | TASK-106 | 1 | [x] | 2026-10-05 |
| TASK-202 | Update `LevelPainter` in `lib/screens/game/painters/level_painter.dart`: implement Option A Pure Vector Glass for target cups (`alpha: 0.14`, 1px gradient outline, neon aperture glow rim) and chromatic prism filter gates, preserving countdown numeral and heightmap settling. | REQ-005 | AC-005 | TASK-201 | 1 | [x] | 2026-10-05 |
| TASK-203 | Overhaul `PauseOverlay` in `lib/widgets/pause_overlay.dart`: implement full-bleed `BackdropFilter` ($\sigma=24.0$), floating breathing glass circular glyphs (`↺`, `▶`, `⠿`), and bottom frosted soundscape toggle capsule wrapped in `RepaintBoundary`. | REQ-004 | AC-006 | TASK-201 | 1 | [x] | 2026-10-05 |
| TASK-204 | Overhaul `LevelCompleteDialog` in `lib/widgets/level_complete_dialog.dart`: implement ambient golden bloom wash, dynamic level ambiance reflection card, equilibrium badge, and glowing `GlassPillButton` ("Level Berikutnya" / "Kembali ke Menu"). | REQ-004 | AC-001 | TASK-203 | 1 | [x] | 2026-10-05 |
| TASK-205 | Update `BackgroundPainter` in `lib/screens/game/painters/background_painter.dart`: consume `GlassTokens.obsidianVoid` and `GlassTokens.obsidianVignette` for the radial vignette while preserving 3-plane deterministic dust mote parallax. | REQ-001 | AC-001 | TASK-202 | 1 | [x] | 2026-10-05 |
| TASK-206 | Update widget tests in `test/screens/game_screen_test.dart`, `test/screens/level_complete_dialog_test.dart`, and `test/screens/game_hud_test.dart` asserting diegetic glass HUD rendering, pause overlay blur, and zero regressions. | REQ-004, REQ-006 | AC-004, AC-005, AC-006 | TASK-205 | 3 | [x] | 2026-10-05 |
| TASK-207 | **VERIFY**: Run `flutter test test/screens/` and `flutter analyze` to verify zero failures. | - | - | TASK-206 | - | [x] | 2026-10-05 |
| TASK-208 | **APPROVAL**: Wait for explicit user confirmation before proceeding to Phase 3. | - | - | TASK-207 | - | [x] | 2026-10-05 |

---

### Implementation Phase 3 — Modern Glass Bento Grid Stage Selector & Pebble Nodes (Tracer Bullet 3)

- **GOAL-003**: Overhaul `LevelSelectScreen` into an asymmetric 4-Act Glass Bento Grid with $2 \times 1$ wide milestone cards, breathing cyan pulse, floating quick-jump capsule bar, and locked micro-shake feedback.

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
|---|---|---|---|---|---|---|---|
| TASK-301 | Overhaul `LevelButton` in `lib/screens/level_select/level_button.dart`: render frosted glass pebble node with 1px specular border, 2.2s breathing cyan glow pulse on the next playable stage, golden rim on completed stages, and 300ms micro-shake on locked stage taps. | REQ-003, REQ-006 | AC-002, AC-003, AC-007 | TASK-208 | 1 | [x] | 2026-10-05 |
| TASK-302 | Overhaul `LevelSelectScreen` in `lib/screens/level_select/level_select_screen.dart`: implement 4-Act Glass Bento Grid layout, $2 \times 1$ wide featured milestone cards (Stages 5, 10, 18, 25, 30), and floating quick-jump capsule bar (`[ Babak I ]` .. `[ Babak IV ]`), preserving header finders (`'Pilih Level'`, `'0/30'`). | REQ-006 | AC-007 | TASK-301 | 1 | [x] | 2026-10-05 |
| TASK-303 | Update and expand widget tests in `test/screens/level_select_screen_test.dart` and `test/screens/level_button_test.dart`: verify Bento grid arrangement, quick-jump scroll transitions, milestone cards, and locked node micro-shake without SnackBars. | REQ-006 | AC-003, AC-007 | TASK-302 | 2 | [x] | 2026-10-05 |
| TASK-304 | **VERIFY**: Run `flutter test test/screens/level_select_screen_test.dart test/screens/level_button_test.dart` and `flutter analyze` to verify zero failures. | - | - | TASK-303 | - | [x] | 2026-10-05 |
| TASK-305 | **APPROVAL**: Wait for explicit user confirmation before proceeding to Phase 4. | - | - | TASK-304 | - | [x] | 2026-10-05 |

---

### Implementation Phase 4 — Modern Glass Sandbox Main Menu, Splash & Full Regression (Tracer Bullet 4)

- **GOAL-004**: Modernize `MenuScreen` and `SplashScreen` with glassmorphic styling, diegetic glass nozzle, interactive sandbox with CCD physics, frosted action pills (`PLAY`, `CHAMBERS`, `CREDITS`), and achieve 100% pass rate across the full 157-test suite.

| Task | Description | Ref ID | AC Ref | Dep | Files | Completed | Date |
|---|---|---|---|---|---|---|---|
| TASK-401 | Overhaul `SplashScreen` in `lib/screens/splash/splash_screen.dart`: implement central frosted glass circular portal with luminous sugar stream and smooth 550ms crossfade to menu. | REQ-001 | AC-001 | TASK-305 | 1 | [x] | 2026-10-05 |
| TASK-402 | Overhaul `MenuScreen` in `lib/screens/menu/menu_screen.dart`: implement frosted glass top capsule (sound toggle & CLEAR button), brand Outfit typography (tracking +8), suspended primary action `GlassPillButton` ("PLAY • ACT I"), secondary glass chips (`CHAMBERS`, `CREDITS`), and bottom physics status capsule, preserving non-interfering gesture layering. | REQ-003, REQ-007 | AC-001, AC-002 | TASK-401 | 1 | [x] | 2026-10-05 |
| TASK-403 | Update widget tests in `test/screens/splash_screen_test.dart` and `test/screens/menu_screen_test.dart` asserting glass components, interactive line drawing, and button navigation. | REQ-007 | AC-001, AC-008 | TASK-402 | 2 | [x] | 2026-10-05 |
| TASK-404 | Run full regression test suite (`flutter test`) verifying all 157 tests pass with 100% success rate, and run `flutter analyze` verifying 0 warnings, errors, or lints. | - | AC-008 | TASK-403 | - | [x] | 2026-10-05 |
| TASK-405 | Update canonical living architecture map in `docs/ARCHITECTURE.md` and domain glossary in `CONTEXT.md` to reflect the completed Modern Minimalist & Glassmorphism UI architecture. | - | - | TASK-404 | 2 | [x] | 2026-10-05 |
| TASK-406 | **VERIFY**: Run `flutter test` across all test files to ensure 100% green test suite. | - | AC-008 | TASK-405 | - | [x] | 2026-10-05 |
| TASK-407 | **APPROVAL**: Formally present milestone completion and request final user approval. | - | - | TASK-406 | - | [ ] | |

---

## 3. Alternatives

- **ALT-001 (Pure Custom AGSL/GLSL Shaders):** Considered authoring custom fragment shaders (`.frag`) for dynamic backdrop blurring. Rejected because Flutter's `BackdropFilter` with `ImageFilter.blur` provides identical optical quality while guaranteeing 100% cross-platform compatibility across Android (Skia/Impeller), Web, and Desktop without shader compilation discrepancies.
- **ALT-002 (Live Blur Everywhere):** Considered using live `BackdropFilter` on all in-game HUD buttons over the 500-particle canvas. Rejected via the Dual Glass Pipeline (Mode B) because real-time backdrop blur over 500 continuously moving particles creates GPU raster stalls on mobile chipsets.

---

## 4. Dependencies

- **DEP-001**: `flutter/material.dart` and `dart:ui` (`ImageFilter.blur`).
- **DEP-002**: `google_fonts: ^6.2.1` (`Outfit` font family bundled offline).
- **DEP-003**: `flutter_riverpod: ^2.6.1` (reactive audio and progress state).
- **DEP-004**: `go_router: ^14.6.0` (declarative routing and transition curves).
- **DEP-005**: `audioplayers: ^6.1.0` (hierarchical audio bus mixer & woodblock click).

---

## 5. Files

- **FILE-001**: `micin_micin/lib/core/theme.dart` (Add `GlassTokens`, update `AppTheme`)
- **FILE-002**: `micin_micin/lib/widgets/glass_container.dart` (New frosted glass container)
- **FILE-003**: `micin_micin/lib/widgets/glass_pill_button.dart` (New tactile pop button)
- **FILE-004**: `micin_micin/lib/screens/game/game_hud.dart` (Diegetic glass HUD chips)
- **FILE-005**: `micin_micin/lib/screens/game/painters/level_painter.dart` (Option A pure vector glass vessels)
- **FILE-006**: `micin_micin/lib/screens/game/painters/background_painter.dart` (Obsidian void background)
- **FILE-007**: `micin_micin/lib/widgets/pause_overlay.dart` (Full-bleed glass blur pause overlay)
- **FILE-008**: `micin_micin/lib/widgets/level_complete_dialog.dart` (Ambient golden bloom dialog)
- **FILE-009**: `micin_micin/lib/screens/level_select/level_button.dart` (Glass pebble stage node)
- **FILE-010**: `micin_micin/lib/screens/level_select/level_select_screen.dart` (4-Act Glass Bento Grid)
- **FILE-011**: `micin_micin/lib/screens/menu/menu_screen.dart` (Glass sandbox menu)
- **FILE-012**: `micin_micin/lib/screens/splash/splash_screen.dart` (Glass portal splash)

---

## 6. Testing

- **TEST-001**: Component widget tests for `GlassContainer` and `GlassPillButton` verifying blur sigma, border gradients, and squash/pop animations.
- **TEST-002**: Screen widget tests for `GameHud`, `PauseOverlay`, and `LevelCompleteDialog` verifying test key preservation and zero regressions.
- **TEST-003**: Screen widget tests for `LevelSelectScreen` verifying 4-Act Bento Grid, milestone cards, and quick-jump navigation.
- **TEST-004**: Screen widget tests for `MenuScreen` verifying sandbox line drawing, CLEAR action, and button navigation.
- **TEST-005**: Full regression test suite (`flutter test`) verifying 100% pass rate across all 157 existing tests.

---

## 7. Risks & Assumptions

- **RISK-001 (GPU Raster Stalls on Mobile):** Excessive `BackdropFilter` usage can cause frame drops.  
  *Mitigation:* Enforced Dual Glass Pipeline (Mode B pre-composited gradients for playfield HUD) and wrapped all Mode A instances in `RepaintBoundary`.
- **RISK-002 (Test Finder Regressions):** Modifying button widgets might break test finders (`'PLAY'`, `'0 1'`, `'Pilih Level'`).  
  *Mitigation:* Explicit invariant to retain all existing widget keys and text strings unaltered.
- **ASSUMPTION-001:** Option A (Pure Vector Glass in `LevelPainter`) eliminates any need for complex stacked widgets over the virtual canvas.

---

## 8. Related Specifications / Further Reading

- [spec/spec-design-modern-glassmorphism-ui.md](file:///d:/kayzz/flutter/micin/spec/spec-design-modern-glassmorphism-ui.md)
- [docs/gdd/GDD-modern-glassmorphism-ui-overhaul.md](file:///d:/kayzz/flutter/micin/docs/gdd/GDD-modern-glassmorphism-ui-overhaul.md)
- [docs/audit/clarification-report-modern-glassmorphism-ui-2026-10-05.md](file:///d:/kayzz/flutter/micin/docs/audit/clarification-report-modern-glassmorphism-ui-2026-10-05.md)
- [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md)

---

## 9. Rollback / Recovery Plan

If any phase fails or introduces regressions:
1. Revert Git changes on the affected screen or widget (`git checkout HEAD -- lib/screens/...`).
2. Run `flutter test` to ensure the previous baseline (157 passing tests) is restored.
3. Review `test` failure output and refine the specific component without touching the physics engine or level configuration assets.
