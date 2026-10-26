# PRD: Chunky Arcade Visual Identity, Arcade Coin HUD, and Act Progression System

## 1. Product Overview

### 1.1 Document Metadata
- **Document Title:** PRD: Chunky Arcade Visual Identity, Arcade Coin HUD, and Act Progression System
- **Document ID:** `PRD-20261019-CHUNKY-ARCADE`
- **Version:** 2.0.0
- **Status:** Approved
- **Author:** Lead Systems Architect & Product Manager
- **Domain Glossary:** [CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md)
- **Art Direction Style Bible:** [docs/design/art-direction-brief.md](file:///d:/kayzz/flutter/micin/docs/design/art-direction-brief.md)
- **Technical Specification:** [spec/spec-zen-game-ui-ux.md](file:///d:/kayzz/flutter/micin/spec/spec-zen-game-ui-ux.md)
- **Architecture Reference:** [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md)

### 1.2 Executive Summary
*Micin Micin* is a high-performance 2D physics puzzle game built with Flutter, Flame, and Dart. While earlier versions experimented with residual Material utility widgets, Zen minimalist minimalism, or fragile glassmorphism overlays, this product specification formally codifies the **Chunky Arcade Visual Identity**.

This release establishes an energetic, juicy, and tactile arcade presentation:
1. **Design Tokens (`CartoonTokens`):** Candy button slabs (Green, Amber, Cyan, Coral, Purple), specular gloss arcs, and solid 4px extruded bottom shadows (`Offset(0, 4)`).
2. **Arcade Coin HUD (`GameHud`):** High-contrast amber coin counter badge (`_CoinPainter`), circular icon buttons with solid 3D depth, and a pulsing cyan gravity indicator pill.
3. **Chunky Stage Progression (`LevelSelectScreen`):** Solid drop-shadow act cards with top colored accent stripes, Roman numeral tab navigator, and 3D beveled `LevelButton` nodes.
4. **Pop-Scale Overlays:** `CountdownOverlay` ($3 \to 2 \to 1 \to \text{GO!}$) and celebratory `LevelCompleteDialog` with golden star awards and chunky cartoon panels.
5. **Zero Fragile Blur Invariant:** Live `BackdropFilter` shaders are banned from active physics/drawing loops to guarantee 60/120 FPS zero-allocation performance on mobile hardware.

---

## 2. Goals & Non-Goals

### 2.1 Business & Design Goals
- **Tactile Indie Arcade Identity:** Deliver an energetic, bold, and juicy mobile game identity that instantly feels premium and playful.
- **Punchy Affordances & Clarity:** Ensure interactive elements look unmistakably pressable through 3D extruded slabs and solid drop shadows.
- **Pacing & Rewarding Progression:** Group the 30 stages into 4 thematic Acts with clear milestone feedback, coin collection, and star rewards.
- **Zero-Allocation 60/120 FPS Performance:** Eliminate all fragile GPU blur filters during active gameplay; use pre-computed solid depth and batch vector primitives.

### 2.2 Non-Goals (Out of Scope)
- **Online Social / Multi-Player:** The game is 100% offline with zero online matchmaking or external telemetry.
- **Aggressive Paywalls / Ads:** Zero banner ads or energy timers interrupting the gameplay flow.
- **Heavy Skeuomorphism:** No photorealistic textures (wood, metal, leather); depth is rendered through clean cartoon vector geometry.

---

## 3. User Personas

1. **The Mobile Arcade Fan (Rian, 24):** Loves crisp, tactile puzzle games with juicy feedback, responsive buttons, and instant restarts. Expects high-contrast visuals that are legible under any lighting.
2. **The Classic Physics Puzzle Enthusiast (Maya, 28):** Passionate about classic Flash physics games (*Sugar, Sugar*). Appreciates clever stage design, color gates, and gravity flips, with clear visual indicators and zero UI distraction.

---

## 4. Functional Requirements

### 4.1 Eradication of Generic Boilerplate & Fragile Blur (REQ-ARCADE-001) [P0]
- **FR-001.1:** Ban generic `AppBar` and system toolbars from gameplay and menus.
- **FR-001.2:** Ban live `BackdropFilter` shaders from active gameplay and hot rendering loops.
- **FR-001.3:** Eradicate `SnackBar` toast messages in favor of tactile audio-visual micro-animations.
- **FR-001.4:** Eradicate washed-out, low-contrast "zen" gray text or pseudo-poetic philosophical flavor text.

### 4.2 Arcade Coin HUD Specification (REQ-ARCADE-002) [P0]
- **FR-002.1:** **Amber Coin Badge:** Render custom-painted amber coin counter badge (`_CoinPainter`) in top-left anchor showing stage/coin metrics with solid beveled borders.
- **FR-002.2:** **Top-Right 3D Action Glyphs:** Render circular action buttons with solid 3D depth for Restart (`hud_reset`), Pause (`hud_pause`), and Audio (`hud_audio`).
- **FR-002.3:** **Bottom-Center Gravity Pill:** For stages with `hasGravityToggle: true`, display an animated dual-chevron pill with glowing cyan aura and clear directional indicators.
- **FR-002.4:** **Diegetic Cup Countdown Face:** Target Cups render bold integer countdowns (`remaining = max(0, target - settled)`) in `Outfit` Bold that scale-pulse ($1.00 \to 1.06 \to 1.00$) upon grain capture and turn radiant gold at `0`.

### 4.3 Chunky Cartoon Pause Overlay (REQ-ARCADE-003) [P0]
- **FR-003.1:** Full-bleed darkened backdrop overlaid with a solid cartoon center panel (`CartoonPanel`) featuring 2px border `#45368E`.
- **FR-003.2:** Prominent 3D extruded action buttons:
  - Resume (Green: `CartoonTokens.greenTop`)
  - Ulangi / Restart (Amber: `CartoonTokens.amberTop`)
  - Kembali / Menu (Cyan: `CartoonTokens.cyanTop`)
- **FR-003.3:** Audio ducking ($-10\text{ dB}$) smoothly applied to background music during pause state.

### 4.4 Pop-Scale Countdown & Celebratory Victory Sequence (REQ-ARCADE-004) [P0]
- **FR-004.1:** **Countdown Overlay:** At stage start, play pop-scale `TweenSequence` animation ($3 \to 2 \to 1 \to \text{GO!}$) using amber and green pill badges.
- **FR-004.2:** **Stage Complete Trigger:** Triggers strictly when all Target Cups reach `remaining == 0`.
- **FR-004.3:** **Celebratory Dialog:** Display `LevelCompleteDialog` featuring golden star ratings, level score, and primary green action button ("Level Berikutnya").

### 4.5 Chunky Act Stage Selector (REQ-ARCADE-005) [P1]
- **FR-005.1:** Organize the 30 stages across 4 Acts using solid drop-shadow act cards (`_ActCard`):
  - **Babak I: Dasar** (Stages 1–7, Green accent)
  - **Babak II: Filter Warna** (Stages 8–15, Coral accent)
  - **Babak III: Inversi Gravitasi** (Stages 16–22, Cyan accent)
  - **Babak IV: Tantangan Akhir** (Stages 23–30, Amber accent)
- **FR-005.2:** Top Roman-numeral tab navigator with hard-shadow on active tab (`[ I ] [ II ] [ III ] [ IV ]`).
- **FR-005.3:** `LevelButton` grid featuring 3D beveled unlock, completed (golden star), and locked states with horizontal micro-shake feedback on locked attempts.

### 4.6 30-Stage Pacing Curriculum (REQ-ARCADE-006) [P0]
- Maintain the 30-stage curriculum with sawtooth difficulty curves across the 4 thematic Acts, teaching basic slopes, color mutation gates, gravity inversions, and multi-receptacle coordination.

### 4.7 Level Geometry & Anti-Slop Constraints (REQ-ARCADE-007) [P0]
- **FR-007.1:** Emitters and cups must never share identical horizontal coordinates ($|x_e - x_c| \ge 40\text{ px}$).
- **FR-007.2:** Total sugar quota equals $150 \times N_{\text{cups}}$ with cup capacity standardized to $100$.
- **FR-007.3:** Unified virtual resolution: all coordinates strictly authored in $400 \times 700$.

### 4.8 Cartoon Tokens Design Token Palette (REQ-ARCADE-008) [P0]
- All UI and overlay widgets must strictly consume centralized `CartoonTokens` in `lib/core/theme.dart`:
  - Canvas: `#1E1645` $\to$ `#110C29`
  - Panels: `#241C52`, border `#45368E`, cream face `#FFF9E8`
  - Candy Buttons: Green (`#4ADE80`), Amber (`#FBBF24`), Cyan (`#38BDF8`), Coral (`#FB7185`), Purple (`#C084FC`)
  - Shadows & Bevels: 4px solid drop shadows (`Offset(0, 4)`), `glossWhite` specular arcs, and `textShadow`.

---

## 5. Non-Functional Requirements

- **Performance:** Rock-solid 60 FPS / 120 FPS on mobile with 500 active granular particles. Zero heap allocations inside `paint()`.
- **Offline Guarantee:** 100% offline-first application with zero network permissions or external telemetry.
- **Test Integrity:** 100% test pass rate across all automated unit, widget, and integration tests (189/189 passing).

---

## 6. Requirements Traceability Matrix

| Requirement ID | Description | Target Module | Upstream Context |
| :--- | :--- | :--- | :--- |
| `REQ-ARCADE-001` | Eradicate Boilerplate & Fragile Blur | App / Screens | Style Bible §4 |
| `REQ-ARCADE-002` | Arcade Coin HUD | `GameHud`, `GameScreen` | Style Bible §3.1 |
| `REQ-ARCADE-003` | Chunky Cartoon Pause Overlay | `PauseOverlay`, `CartoonPanel` | Style Bible §3.1 |
| `REQ-ARCADE-004` | Pop-Scale Countdown & Victory Overlay | `CountdownOverlay`, `LevelCompleteDialog` | Style Bible §3.1 |
| `REQ-ARCADE-005` | Chunky Act Stage Selector | `LevelSelectScreen`, `LevelButton` | Style Bible §3.1 |
| `REQ-ARCADE-006` | 4-Act Stage Curriculum | `assets/levels/*.json` | Style Bible §1.1 |
| `REQ-ARCADE-007` | Anti-Slop & Supply Invariants | `LevelConfig`, `GameEngine` | ADR-0002, ADR-0003 |
| `REQ-ARCADE-008` | CartoonTokens Palette | `lib/core/theme.dart` | Style Bible §2 |
