# Game Design Document (GDD): Bart Bonte Aesthetic, Particle Dynamics & 30-Level Characteristic Architecture

> **Project:** Micin, Micin (Sugar, Sugar Tribute)  
> **Document Type:** Game Design Document (GDD) & Level Concept Architecture  
> **Status:** ARCHIVED & SUPERSEDED by Chunky Arcade  
> **Version:** 1.0  

> [!WARNING]
> **ARCHIVED & SUPERSEDED BY CHUNKY ARCADE**:
> While the 30-stage layout mechanics and granular physics are preserved, the visual presentation documented here (monochrome chalkboard minimalism) has been superseded by the canonical **Chunky Arcade** design language (`CartoonTokens`, 3D extruded slabs, solid drop shadows, and arcade coin HUD). Refer to [docs/design/art-direction-brief.md](file:///d:/kayzz/flutter/micin/docs/design/art-direction-brief.md) and [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md).
> **Date:** 2026-10-06  
> **Skills Applied:** `openagenticgame-gdd`, `create-game-assets`, `game-feel`, `game-ui-ux`

---

## 1. Executive Summary & Design Vision

### 1.1 The Essence of Bart Bonte's *Sugar, Sugar*
Bart Bonte's *Sugar, Sugar* series achieved legendary status through three core pillars:
1. **Unpretentious Elegance & Pure Minimalism:** Zero bloated HUDs, zero artificial lore, zero unnecessary UI panels. The entire screen *is* the puzzle.
2. **Tactile Granular Physics:** Satisfying crystalline sugar grains that slide down drawn lines and accumulate into organic mounds inside cups.
3. **Every Level as a Distinct Canvas:** Each stage is not a generic grey container; rather, every stage possesses a **bespoke color identity**, a **visual story**, and unique **environmental props/silhouettes** (teaspoons, silhouette hands, teapots, gravity rings, color filters).

### 1.2 Core Design Goals
* **Pixel-Crisp Granular Particles:** Replace generic soft circular points with distinct crystalline square grains (`StrokeCap.square`) that look and behave like real sugar/micin grains.
* **30-Stage Chromatic & Thematic Identity:** Transition from uniform dark backgrounds to a rich, curated 30-level color palette spanning deep navy, forest green, crimson red, ochre, plum, terracotta, and slate.
* **Environmental Storytelling Props:** Introduce minimal vector silhouette props—such as teaspoons, silhouette hands, teapots, and glass funnels—that serve dual roles as physics colliders and artistic landmarks.
* **Canvas-Integrated Diegetic Typography:** Embed clean, bold stage titles (e.g., `level 8`, `sugar, sugar`) directly into the background canvas layer rather than floating detached in an artificial overlay.

---

## 2. Granular Particle Dynamics & Visuals

### 2.1 Crystalline Grain Geometry
* **Render Mode:** Direct batch drawing via `Canvas.drawPoints(PointMode.points, ...)` using `StrokeCap.square`.
* **Grain Size:** $2.2 \times 2.2$ virtual pixels (calibrated for crisp 400×700 virtual canvas).
* **Granular Micro-Variance:** Subtle opacity jitter per particle ($0.88$ to $1.0$) mimicking natural crystalline light refractions without expensive shader overhead.

### 2.2 Nozzle Spawning & Granular Stream Flow
* **Emitter Aperture:** Fixed width nozzle ($16$ px wide) spawning particles in discrete bursts.
* **Stream Micro-Jitter:** A tiny randomized horizontal velocity $\Delta v_x \in [-0.35, 0.35]\text{ px/frame}$ applied at spawn to simulate realistic freefall grain dispersal rather than rigid single-file lines.
* **Flow Density:** 2 to 3 particles emitted per physical step during active flow, totaling up to 500 active simulated grains.

### 2.3 Slope Sliding & Piling Mechanics (Angle of Repose)
* **Surface Rolling:** Particles slide smoothly across player-drawn line segments with restitution $e = 0.08$ and dynamic surface friction $\mu = 0.12$.
* **Mound Formation:** Inside target cups, the 1D discrete column heightmap maintains a natural **Angle of Repose** ($\theta \approx 35^\circ$, $\Delta H_{\max} = 1.4\text{ px}$). Excess grains roll downhill into adjacent columns or spill over cup edges.

### 2.4 Chromatic & Directional Transformations
* **Prismatic Gate Absorption:** When a white grain intersects a `ColorFilterConfig` aperture, its color immediately mutates to the filter's target tint (Red, Green, Blue, Orange, Yellow) with zero delay.
* **Gravity Inverter Dynamics:** Crossing the gravity toggle field inverts the particle's acceleration vector ($g_y \rightarrow -g_y$), propelling grains gracefully towards ceiling-mounted cups.

---

## 3. The 30-Level Signature Matrix: Palette, Narrative & Asset Props

Every stage in *Micin, Micin* is assigned a distinct mood, signature color, thematic prop, and puzzle mechanic.

### 3.1 Act I: The Fundamentals (Levels 1–7)
*Theme: Purity, Gravitational Flow, and Gentle Curvature*

| Level | Name / Concept | Background Color | Hex Code | Environmental Prop / Asset | Target Cups | Mechanics & Story |
|:---|:---|:---|:---|:---|:---|:---|
| **01** | First Pour | Midnight Navy | `#0B2545` | Clean canvas with gentle chalk floor | 1× White (100) | Pure gravity intro. Single cup on floor. |
| **02** | Left Curve | Forest Pine | `#0D3B2E` | Wooden cutting board edge (shelf) | 1× White (80) | Cup shifted left, teaches line slope angles. |
| **03** | Shelf Drop | Terracotta Warmth | `#7A3015` | Terracotta plate rim collider | 1× White (90) | High ledge drop with bounce deceleration. |
| **04** | Dual Streams | Slate Charcoal | `#1E293B` | Central wooden peg divider | 2× White (50, 50) | Splitting a single stream into two cups. |
| **05** | The Teaspoon | Vintage Mustard | `#855A08` | **Silver Teaspoon Silhouette** (deflector) | 1× White (100) | Sugar bounces off spoon bowl into cup. |
| **06** | Narrow Gorge | Dusty Plum | `#4A1E35` | Pair of vertical ceramic pillars | 1× White (70) | Routing grains through a tight obstacle gap. |
| **07** | Cascade Steps | Deep Teal | `#0F3A40` | Three staggered stone stairs | 2× White (60, 40) | Multi-tier cascade routing. |

---

### 3.2 Act II: The Prismatic Spectrum (Levels 8–15)
*Theme: Color Filters, Dyeing Rings, and Intersecting Streams*

| Level | Name / Concept | Background Color | Hex Code | Environmental Prop / Asset | Target Cups | Mechanics & Story |
|:---|:---|:---|:---|:---|:---|:---|
| **08** | Green Spoon | Classic Kelly Green | `#0F511D` | **Green Double Spoons** + Orange Filter | 1× White, 1× Orange | Sugar crosses filter ring, spoons catch overflow. |
| **09** | Crimson Dye | Deep Crimson | `#6A0D18` | Red glass lens portal | 1× Red (100) | All sugar must turn red before entering cup. |
| **10** | Dual Prisms | Midnight Indigo | `#161B40` | Cyan & Rose filter tubes | 1× Cyan (50), 1× Rose (50) | Sorting two colors from a single white emitter. |
| **11** | Cross Pathways | Warm Auburn | `#6E2E10` | Diagonal glass funnel tube | 1× Orange (60), 1× White (60) | Paths must cross without colliding streams. |
| **12** | Emerald Ring | Olive Grove | `#2D4119` | Concentric emerald filter ring | 1× Green (80) | Circular filter positioned midway. |
| **13** | Tricolor Prism | Dark Mauve | `#3B1B36` | Three mini filter gates (R, G, B) | 1× Red, 1× Green, 1× Blue | Complex stream division into three cups. |
| **14** | Selective Sieve | Steel Blue | `#1C3B5E` | Ceramic strainer bar silhouette | 1× White (40), 1× Yellow (60) | Yellow filter hovering over left cup. |
| **15** | Glass Alchemy | Burnt Sienna | `#5C2412` | **Vintage Coffee Grinder Silhouette** | 2× Orange (50, 50) | Grinder wheel obstacle diverting flow. |

---

### 3.3 Act III: Gravity Inversion (Levels 16–22)
*Theme: Weightlessness, Ceiling Cups, and Bipolar Physics*

| Level | Name / Concept | Background Color | Hex Code | Environmental Prop / Asset | Target Cups | Mechanics & Story |
|:---|:---|:---|:---|:---|:---|:---|
| **16** | Zero Gravity | Royal Violet | `#2E114D` | **Central Gravity Toggle Orb (Orange)** | 1× Inverted White (100) | Sugar flows upward into ceiling cup. |
| **17** | Skyward & Earthward | Deep Amethyst | `#381447` | Dual Gravity inverter ring | 1× Down White, 1× Up White | Alternating gravity to fill top and bottom cups. |
| **18** | Upside-Down Spoon | Dark Maroon | `#4D101E` | **Inverted Teaspoon Silhouette** | 1× Up Red (60), 1× Down White (60) | Gravity toggle + color filter synergy. |
| **19** | The Pendulum | Midnight Abyss | `#0B1226` | Suspended swinging weight collider | 1× Up Cyan (80) | Precise line curve catches upward momentum. |
| **20** | Fountain Basin | Deep Pine | `#0E3322` | Stepped stone fountain basin | 2× Up White (50, 50) | Geyser effect propelling sugar into twin cups. |
| **21** | Orbiting Currents | Warm Espresso | `#3B2219` | Central hourglass silhouette | 1× Up Rose, 1× Down Green | Color filters placed in opposing gravity zones. |
| **22** | Floating Teacup | Dark Blackberry | `#240B2B` | **Ceramic Teacup suspended in mid-air** | 1× Up White (70), 1× Down White (70) | Mid-air cup with dual opening mouths. |

---

### 3.4 Act IV: The Master Puzzles (Levels 23–30)
*Theme: Visual Narrative, Silhouette Mastery, and Grand Synthesis*

| Level | Name / Concept | Background Color | Hex Code | Environmental Prop / Asset | Target Cups | Mechanics & Story |
|:---|:---|:---|:---|:---|:---|:---|
| **23** | Hands of the Maker | Blood Crimson | `#540909` | **Black Silhouette Hand pouring sugar** | 1× Silhouette Teacup (100) | Homage to Sugar Sugar Mobile (Image 3). |
| **24** | The Teapot Pour | Vintage Slate | `#1E252D` | **Black Silhouette Teapot Spout** | 2× Porcelain Cups (60, 60) | Sugar pours directly from teacup spout silhouette. |
| **25** | The Hourglass | Dark Ochre | `#422B08` | **Hourglass Frame Silhouette** | 1× Up White, 1× Down Gold | Narrow waist constriction sorting grains. |
| **26** | Prismatic Symphony | Deep Mulberry | `#360F26` | 4 Color Filter Rings in diamond shape | 4× Cups (R, G, B, White: 30 each) | High precision routing into 4 corners. |
| **27** | Twin Hands | Venetian Red | `#591313` | **Two Silhouette Hands holding cups** | 2× White Cups (50, 50) held by hands | Symmetric finger colliders frame the canvas. |
| **28** | The Clockwork | Dark Iron | `#181A20` | Mechanical gear silhouette colliders | 1× Up Orange, 1× Down Cyan | Gear teeth act as dynamic funnel deflectors. |
| **29** | Zenith Inversion | Cosmic Indigo | `#131138` | Gravity Toggle surrounded by 3 filters | 3× Tri-Color Cups | Extreme multi-path routing with gravity flips. |
| **30** | Grand Sugar Canvas | Pure Chalkboard Slate | `#151B24` | **"sugar, sugar" Tribute Emblem Silhouette** | 3× Signature Cups (100 total) | Final master level synthesizing all mechanics. |

---

## 4. Environmental Asset & Silhouette Specifications (`create-game-assets`)

### 4.1 Silhouette Style Bible
* **Form Language:** Clean, flat vector silhouettes without internal gradients, bevels, or textures.
* **Color Role:** 
  * Solid Obsidian / Deep Shadow (`#070A0F` with alpha $0.85$–$0.95$) for organic silhouette props (Hands, Teapots, Teaspoons).
  * High-contrast vibrant accents (e.g., `#E8603C` for gravity inverters, `#FFFFFF` for cups).
* **Collision Role:** Every silhouette prop exposes a simplified convex polygon or line collider registered in `LevelConfig.obstacles` so grains bounce naturally off spoons and teapot spouts.

### 4.2 Asset Inventory
1. `asset_spoon_straight.svg` & `asset_spoon_angled.svg`: Classic metal teaspoon silhouette with spoon bowl concave collider.
2. `asset_hand_pour.svg`: Expressive silhouette hand with pinched fingertips acting as the emitter nozzle.
3. `asset_hand_cup.svg`: Silhouette hand gracefully holding a teacup.
4. `asset_teapot_vintage.svg`: Classical teapot silhouette with spout emitter.
5. `asset_hourglass_frame.svg`: Symmetrical hourglass housing with neck aperture.
6. `asset_gravity_orb.svg`: Orange circular disc with dual vertical arrows ($\boldsymbol{\Delta}/\boldsymbol{\nabla}$).

---

## 5. Diegetic UI & Canvas-Level Typography (`game-ui-ux`)

### 5.1 Elimination of Floating HUD Overlays
Traditional mobile games clutter the screen with artificial header bars, life meters, and shiny plastic badges. Bart Bonte's approach embeds UI directly into the virtual canvas:

```
┌────────────────────────────────────────────────────────┐
│  [ < ]                                          [ ⟳ ]  │  <-- Tiny, quiet circular icons (Top-left & Top-right)
│                                                        │
│                     [ Nozzle ]                         │
│                         :::                            │
│                         :::                            │
│                                                        │
│                    \___________/                       │
│                                                        │
│                                                        │
│                                                        │
│                                                        │
│                                          level 8       │  <-- Giant, quiet canvas typography (Bottom-right)
│           [ Cup 94 ]                                   │
└────────────────────────────────────────────────────────┘
```

### 5.2 Canvas Typography Specs
* **Font Family:** `Outfit` / Bold or Medium.
* **Placement:** Bottom-right corner or embedded subtly behind the obstacle layout.
* **Opacity & Blending:** Color matched to the stage's accent tint with subtle $0.18$–$0.25$ opacity so grains pass legibly over or under it.
* **Content:** Lowercase format (e.g., `level 1`, `level 8`, `sugar, sugar`).

### 5.3 Diegetic Cup Number Feedback (`game-feel`)
* **Numeral Stencil:** Bold sans-serif integer printed directly on the cup's belly.
* **Capture Reaction:** Each grain arrival decrements the integer ($50 \rightarrow 49$).
* **Micro-Juice Feedback:**
  * When a grain lands: Cup numeral triggers a subtle scale-bounce ($1.00 \rightarrow 1.06 \rightarrow 1.00$ over 80ms).
  * Pitch-scaling audio feedback: Audio frequency rises incrementally as remaining quota approaches zero.
  * Cup Completion: When counter reaches `0`, cup glows with a soft white specular pulse and locks its intake.

---

## 6. Game Feel & Audio Landscape (`game-feel`)

### 6.1 Audio ASMR Principles
* **Continuous Pour Sound:** Very soft, warm white-noise hiss ($1.2$ kHz low-pass) modulated slightly by active falling particle count.
* **Granular Contact Ticks:** Crisp micro-transients (2–4 ms clicks) triggered when grains glance off hard obstacles or drawn chalk lines.
* **Pentatonic Chime Scale:** Landing grains trigger gentle vibraphone/music-box tones quantized to pentatonic notes (C5, D5, E5, G5, A5), dynamically ascending as the cup fills.
* **Victory Settle:** When all cups reach `0`, an instant 200ms audio ducking silences the pour, replaced by a warm, resonant chime wash.

---

## 7. Technical Implementation Architecture

### 7.1 Data Model Extensions (`LevelConfig`)
Extend `LevelConfig` and `LevelAmbiance` to support bespoke background palettes and environmental silhouette assets:

```dart
class LevelVisualTheme {
  final Color backgroundColor;
  final Color secondaryColor;
  final String? silhouetteAsset;
  final Offset? silhouettePosition;
  final String canvasLabel; // e.g. "level 8"
  final Color labelColor;
}
```

### 7.2 Painter Layer Refactoring
* `BackgroundPainter`: Updated to accept dynamic `backgroundColor` from the active level theme instead of static obsidian void, with subtle chalkboard paper grain overlay.
* `ParticlePainter`: Updated `Paint.strokeCap = StrokeCap.square` and `strokeWidth = 2.2`.
* `SilhouettePainter`: Lightweight vector painter rendering the stage's environmental asset props (spoons, hands, teapots).

---

## 8. Phased Execution Roadmap

* **Phase 1: Particle Core Polish**
  * Update `ParticlePainter` to crystalline square mode (`StrokeCap.square`).
  * Add emitter horizontal micro-jitter for natural granular dispersal.
* **Phase 2: Chromatic Canvas Engine**
  * Implement dynamic background palette engine in `BackgroundPainter` supporting all 30 stage signature colors.
  * Integrate diegetic canvas typography (`"level X"`) directly into the background paint layer.
* **Phase 3: Environmental Silhouette Asset Props**
  * Implement vector rendering for Teaspoons, Silhouette Hands, and Teapots.
  * Map geometric colliders into `LevelConfig` obstacles for Stages 5, 8, 15, 18, 23, 24, 27.
* **Phase 4: Full 30-Level Migration & Playtesting**
  * Populate all 30 level configuration JSONs with verified colors, props, and cup targets.
  * Validate 100% test pass rate across physics, rendering, and interaction test suites.
