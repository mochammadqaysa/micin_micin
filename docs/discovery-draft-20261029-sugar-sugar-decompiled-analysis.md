---
title: Project Discovery & Architecture Summary - Sugar, Sugar Decompiled Analysis
status: APPROVED (Phase 0)
date_analyzed: 2026-10-29
author: Senior Staff Engineer
---

# Project Discovery Summary: Sugar, Sugar (Bart Bonte) APK Decompiled Analysis

## 1. Project Overview

This discovery document captures the architectural, graphical, physical, and audio reverse-engineering of the official Android APK release of Bart Bonte's classic game ***Sugar, Sugar*** (decompiled from `D:\kayzz\android\sugar_sugar`).

The purpose is to provide the definitive blueprint for migrating **Micin Micin** (currently themed as *Pixel Koi Zen*) into an authentic 1:1 tribute and replica of the original *Sugar, Sugar* mobile experience, utilizing the original extracted audio assets, splash and icon graphics, level geometry coordinates, and minimalist vector chalkboard aesthetic.

---

## 2. Technology Stack & Infrastructure of Original Application

- **Packaging Runtime:** Android APK wrapping Adobe AIR 51.0 with native extensions (`com.distriqt.Application`, Google Play Services, Display Metrics).
- **Core Game Runtime:** ActionScript 3 (AVM2) bytecode embedded in `app/src/main/assets/SugarSugar.swf` (928 KB compressed, 1.33 MB uncompressed).
- **Base Resolution & Aspect Ratio:** $480 \times 762\text{ px}$ base coordinate space running at 30/60 FPS (`aspectRatio: portrait`, `renderMode: gpu`).
- **Core Controller:** `Main.as` and `scene_abbgame.as` orchestrating the state machine:
  - `STATE_FADESCHERM` (10)
  - `STATE_INIT_LEVELSELECT` (90)
  - `STATE_INIT_CREDITS` (94)
  - `STATE_INIT` (100)
  - `STATE_INIT_SANDBOX` (101)
  - `STATE_INIT_GAME` (110)
  - `STATE_INIT_LEVEL` (120)
  - `STATE_LEVEL_LOOP` (130)
  - `STATE_RESET_LEVEL` (140)
  - `STATE_PAUZED` (150)
- **Persistence:** Flash `SharedObject` (`sugar2shared`, key: `sohigh`).

---

## 3. Decompiled Asset & Component Inventory

### 3.1 Audio Assets (Successfully Extracted)
1. **`sugar_song.mp3`** (786,915 bytes):
   - Defined as `DefineSound ID 535` (`SugarSong`).
   - Format: MP3 (Rate 3, Stereo 44.1 kHz).
   - The iconic ambient acoustic guitar soundtrack that loops indefinitely across menu and stages (`sugarSong.play(0, 9999)`).
2. **`ok_sound.mp3`** (15,660 bytes):
   - Defined as `DefineSound ID 26` (`OkSound`).
   - Format: MP3 (Rate 3).
   - Pleasant melodic chime triggered upon cup fullness (`incup`), stage victory (`enddelay == 50`), and primary UI button clicks.

### 3.2 Visual Assets (Android Resources & Vector Primitives)
1. **Raster Assets in `res/`:**
   - `res/drawable-nodpi/splash_portrait.png` ($1242 \times 2208\text{ px}$) — clean minimalist splash screen.
   - `res/drawable/banner.png` ($320 \times 180\text{ px}$) — maroon/slate branding header.
   - `res/mipmap-xxxhdpi/icon.png` ($192 \times 192\text{ px}$) & `ouya_icon.png` ($512 \times 512\text{ px}$) — official application launch icon.
2. **Vector Primitives in SWF (SymbolClass):**
   - **Cups:** `cup` (base outline), `cup_white`, `cup_orange`, `cup_red`, `cup_green`, `cup_blue`, `cup_purple`, two-color hybrid cups (`cup_o_g`, `cup_o_b`, `cup_o_w`, `cup_g_w`, `cup_b_w`), and inverted gravity cups (`cupopkop_*`). Cup counters are centered numerical text fields `tel`.
   - **Beams / Obstacles:** Flat colored horizontal and angled rectangular bars (`balkgroen`, `balkoranje`, `balkrood`, `balkblauw`, `balkroze`).
   - **Sugar Spouts:** Punctuation comma spouts (`swc_kommagroen`, `swc_kommaoranje`, `swc_kommaroze`, `swc_kommablauw`, `swc_kommarood`) where particles emerge directly from `x = komma.x`, `y = komma.y + komma.height + 1`.
   - **Color Mutation Gates:** Ring/tube filters (`filter_r_g`, `filter_r_o`, `filter_g_p`, `filter_b_b`, etc.) transforming passing particle colors.
   - **Teleporters:** Portal pairs (`telein_p` / `teleout_p` for magenta, `telein_b` / `teleout_b` for cyan/blue).
   - **HUD & Controls:** Minimalist circular vector buttons (`swc_buttonreset`, `swc_buttonsoundon`/`off`, `swc_buttonstopsugar`, `swc_buttongravity`, `swc_buttondraw`, `swc_buttoneraser`, `swc_buttonsandbox`, `swc_buttonnext`).
   - **Level Selector:** Numbered continue balls (`swc_conitnuebal` with 125 frames) navigable with left/right arrows (`swc_buttonlinks`, `swc_buttonrechts`).

---

## 4. Reverse-Engineered Physics & Simulation Heuristics

1. **Dual-Buffer Cellular / Raster Sampling:**
   - In `Main.as`, lines and static obstacles are drawn onto `screenSprite` and rasterized into `screenBmp` (`BitmapData`).
   - Active particles are stored in array `suiker` and rendered to `suikerBmp`.
2. **Per-Particle Movement Algorithm (`levelLoop`):**
   - Each particle checks:
     $$\text{pixel} = \text{screenBmp.getPixel}(x + \text{slip}, y + \text{gravitatie})$$
   - If pixel is background color (`backkleur`), the particle falls unimpeded:
     $$y \leftarrow y + \text{gravitatie}$$
   - If pixel is an obstacle or drawn barrier (`colortest(pixel)` evaluates RGB channel $> 140$):
     - Particle attempts lateral slope sliding: checks $x - 1$ and $x + 1$.
     - When resting against a surface, applies micro-slip jitter:
       $$\text{slip} = \text{int}(\text{Math.random}() \times 3 - 1.5) \in \{-1, 0, 1\}$$
3. **Cup Filling Condition:**
   - Particles entering the cup aperture ($x \in [\text{cup.x}, \text{cup.x} + \text{tasmondbreedte}]$, $y \approx \text{cup.y}$) match cup color.
   - On match, `incup = true`, target counter `tel` decrements.
   - When all cups reach 0, `leveldone = true`, playing `ok_sound.mp3` and displaying `spr_buttonnext`.

---

## 5. Architectural Assessment of `micin_micin` & Gap Analysis

### Strengths in Existing `micin_micin`:
- **Headless & Deterministic:** `GameEngine` with `ParticleController` and `ParticlePool` provides high-performance, GC-free $60/120\text{ FPS}$ execution on mobile.
- **Flame Component Modular Pipeline:** `MicinGame` cleanly separates level geometry, line drawing, and particle rendering into priority-ordered Flame components.
- **Unified Virtual Resolution:** Letterboxed $400 \times 700$ virtual coordinate space ensures 100% deterministic physics on any screen aspect ratio.

### Current Gaps & Tech Debt to Resolve:
1. **Art Direction Drift:** Current code has strayed into Japanese Zen / 16-bit pixel art (`PixelTerrainTokens`, `terrain_pixel.png`, elevation contours, stippling texture) rather than Bart Bonte's clean vector chalkboard style.
2. **Audio Disconnect:** Current synthesizer/chime audio lacks the authentic nostalgic acoustic guitar soundtrack (`sugar_song.mp3`) and crisp completion chime (`ok_sound.mp3`).
3. **HUD & Controls Inconsistency:** HUD uses heavy pixelated beveled boxes instead of the iconic circular minimalist glyph buttons.
4. **Level Geometry Synchronization:** Need to ensure all 30 stages faithfully represent the original Bart Bonte stage layouts (color sequences, obstacle positions, comma spouts, and cup targets).

---

## 6. Handoff Notes for Specification & Planning

1. **Option A (Total Overhaul) Approved:** User explicitly commanded Option A — completely replace the *Pixel Koi Zen* theme and assets with 100% authentic Bart Bonte *Sugar, Sugar* styling.
2. **Flame Component Bridge Preserved:** Maintain `MicinGame` (`FlameGame`) as the rendering bridge for stable 60 FPS performance, but render components using flat vector drawing paths and solid color palettes rather than 16-bit pixel textures.
3. **Asset Migration Plan:**
   - Copy `sugar_song.mp3` and `ok_sound.mp3` to `assets/audio/`.
   - Copy `icon.png`, `splash_portrait.png`, and `banner.png` from `D:\kayzz\android\sugar_sugar\app\src\main\res` to appropriate Flutter assets and Android platform launcher paths.
   - Update `pubspec.yaml` asset declarations.
4. **Transition:** With discovery approved, proceed immediately to Technical Specification (`/spec/spec-design-sugar-sugar-decompiled-overhaul.md`) and Implementation Planning (`/plan/plan-sugar-sugar-decompiled-overhaul.md`).

