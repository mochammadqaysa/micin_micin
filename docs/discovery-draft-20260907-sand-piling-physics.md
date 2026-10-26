---
title: Project Discovery & Architecture Summary: Granular Sand Piling Physics & Countdown Cup Overhaul
status: DRAFT (Phase 0)
date_analyzed: 2026-09-07
---

# Project Discovery Summary

## 1. Project Overview

**Micin Micin** is a high-performance 2D physics puzzle game built with Flutter and Dart, serving as an offline tribute to Bart Bonte's classic *Sugar, Sugar*. Players draw lines to route falling granular sugar/MSG particles from emitters into colored target cups across 30 progressively challenging stages.

While the fundamental Unified Virtual Resolution ($400 \times 700$) and line barrier continuous collision detection are mathematically solid, current gameplay exhibits three critical fidelity discrepancies compared to the original Flash game:
1. **Particle Size & Speed:** Particles are rendered with a chunky diameter of 5.0px (`kParticleRadius = 2.5`) and fall too aggressively ($g = 0.25$, $v_{\max} = 8.0$), behaving like heavy bullets rather than soft, powdery granular sugar/sand.
2. **Artificial Fluid Bar vs. Authentic Sand Mound:** Target cups currently destroy captured particles on contact and render a synthetic semi-transparent fluid box (`fluidPaint`) that rises like water in a glass. In the original *Sugar, Sugar*, cups accumulate actual resting granular particles, forming a conical **Sand Mound** with a natural **Angle of Repose** ($\approx 35^\circ$).
3. **Cup Display & Overflow Mechanics:** The cup currently renders a `0/100` progress string and absorbs infinite particles without physical interaction. In the authentic game, the cup displays a pure countdown number ($\text{remaining} = \text{target} - \text{captured}$), and when the cup is full or overloaded, excess particles cascade and spill over the cup rims (**Overflow Spill**), resuming free-fall into the stage.

This discovery establishes the architectural and mathematical blueprint for calibrating granular physics, implementing a high-performance discrete column heightmap for sand mounds, adding physical cup boundaries with overflow spilling, and transitioning cup progress to a pure countdown display with a 150% particle supply buffer.

---

## 2. Technology Stack & Infrastructure

*(Reference: [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md))*

- **Core Framework/Language:** Dart 3.12+ / Flutter 3.x (Headless Physics Engine + CustomPainter rendering)
- **Virtual Coordinate Pipeline:** Unified $400 \times 700$ virtual canvas via `VirtualCoordinateAdapter` with aspect-ratio letterboxing
- **State Management:** Riverpod 2.6 (`StateNotifier`, `FutureProvider`)
- **Particle Architecture:** Pre-allocated `ParticlePool` (capacity: 500 particles) with zero heap allocations during the ticker loop
- **Batch Rendering Paradigm:** `CustomPainter` with `Canvas.drawPoints(PointMode.points)` batching by color
- **Local Persistence & Routing:** `SharedPreferences` (`sugarshared`) and `GoRouter 14.6`
- **Dependencies:** 100% offline, zero network permissions (`android.permission.INTERNET` absent)

---

## 3. Current Architecture Assessment

### Strengths
1. **Headless & Deterministic Simulation:** `micin_micin/lib/engine/` is completely decoupled from Flutter widgets and runs deterministically in headless CLI tests (98 passing automated tests, 0 failures).
2. **Batch Point Rendering:** `ParticlePainter` avoids hundreds of individual `Canvas.drawCircle` calls by grouping particle offsets by ARGB color key and executing single `Canvas.drawPoints` calls per color batch.
3. **Unified Coordinate Contract:** All internal physics, obstacle coordinates, and screen touch conversions operate strictly within the $400 \times 700$ virtual coordinate space, preventing multi-device scaling drift.

### Tech Debt & Gaps
1. **Instant Particle Annihilation in Target Cups:** `ParticleController.update()` sets `p.isCaptured = true` immediately upon intersecting `CupHitbox`, hiding the particle from `ParticlePainter`. This forces `LevelPainter` to render an artificial liquid fill rectangle instead of granular sand accumulation.
2. **Missing Rigid Boundaries on Cups:** `CupHitbox` is a single pass-through bounding box `Rect`. It lacks physical walls (left wall, right wall, bottom floor) to deflect non-matching particles or retain settled particles.
3. **Rigid Zero-Jitter Particle Emitter:** `ParticleEmitter` spawns particles with strictly $v_x = 0.0$ and $v_y = 0.0$ at an exact coordinate point, creating an unnatural single-pixel laser stream rather than a soft, organic sugar flow.
4. **Tight Particle Quota vs. Overflow Spilling:** Level JSON assets currently define `totalSugar = sum(cup.targetAmount)`. If particles can spill over the cup rims or bounce off barriers, players will face premature level failure unless a surplus buffer is provided.

---

## 4. Operational Workflow

### Workflow A: Organic Granular Particle Flow
1. `ParticleEmitter.tick()` spawns a particle with:
   - Fine radius: `kParticleRadius = 1.1` virtual px (diameter $\approx 2.2$ px).
   - Horizontal velocity jitter: $v_x \in [-0.25, 0.25]$ virtual px/frame.
   - Position jitter: $x \pm 1.2$ virtual px.
   - Visual crystalline opacity: $\alpha \in [0.85, 1.0]$.
2. `ParticleController.update()` applies soft gravity:
   - Calibrated gravity: $g = 0.14$ virtual px/frame².
   - Soft terminal velocity: $v_{\max} = 4.8$ virtual px/frame.
3. Falling particles cascade smoothly down player-drawn `LineSegment` barriers, preserving tactile, fluid deflection.

### Workflow B: Cup Countdown, Discrete Sand Mound, & Overflow Spill
1. **Physical Cup Boundary:** The cup is bounded by 3 solid physical segments:
   - Left Wall: $(x, y) \to (x, y + h)$
   - Floor: $(x, y + h) \to (x + w, y + h)$
   - Right Wall: $(x + w, y + h) \to (x + w, y)$
   - Top Mouth: $(x \to x + w, y)$ remains open.
2. **Discrete Column Heightmap:** The cup interior (width $W$) is discretized into $M$ columns (e.g., bin width = 2.0 px; 18 bins for a 36px cup).
3. **Particle Ingestion & Angle of Repose:**
   - When a particle enters the cup mouth, its horizontal position maps to bin $b = \lfloor (p.x - x_{\text{cup}}) / \text{binWidth} \rfloor$.
   - The particle settles atop the existing column height $H[b]$.
   - If $|H[b] - H[b \pm 1]| > \Delta H_{\max}$ (slope exceeding the $\approx 35^\circ$ **Angle of Repose**), the particle rolls to the adjacent lower bin.
   - Upon settling, the cup decrement counter updates: $\text{remaining} = \max(0, \text{target} - \text{settledCount})$.
4. **Sand Mound Rendering:** Settled particles remain rendered as granular dots filling the cup, forming an authentic triangular/curved sand mound. The fake liquid bar is eliminated.
5. **Overflow Spill:**
   - Once all bins reach the cup rim ($H \ge \text{cupHeight}$), additional particles rolling down the mound slope past the leftmost ($b < 0$) or rightmost ($b \ge M$) bin boundary are ejected from the cup.
   - Ejected particles regain active free-fall gravity ($v_x = \pm 1.0, v_y = 0.5$) and cascade over the outer cup walls back into the stage.

---

## 5. Handoff Notes for Product Manager (/sdlc-draft-prd)

Before drafting the Product Requirements Document (PRD), the Product Manager must note the following architectural and mathematical constraints:

1. **Surplus Particle Supply Formula:**
   To accommodate the physical possibility of particles spilling over the rim during an **Overflow Spill**, the total particle supply per level must follow the user-approved 150% rule:
   $$\text{Total Sugar} = (100 \times N_{\text{cups}}) + \frac{100 \times N_{\text{cups}}}{2} = 150 \times N_{\text{cups}}$$
   - 1 Cup (Target 100): Emitter emits 150 particles (50 spill buffer).
   - 2 Cups (Target 200): Emitter emits 300 particles (100 spill buffer).
   - 3 Cups (Target 300): Emitter emits 450 particles (150 spill buffer).
   This fits comfortably within the existing 500-particle pre-allocated `ParticlePool` without increasing heap memory.
2. **Countdown Display Specification:**
   The cup HUD text must render strictly as a countdown integer ($\text{remaining} = \text{target} - \text{captured}$). When $\text{remaining} = 0$, the cup is satisfied (with a subtle golden checkmark or glowing rim) while still physically supporting overflow of excess particles.
3. **Performance Boundary Constraint ($O(1)$ Heightmap Lookups):**
   The sand mound simulation MUST NOT use $O(N^2)$ inter-particle collision solvers. The discrete column heightmap with 1-step slope relaxation guarantees $O(1)$ computation per particle per frame, strictly maintaining the 60 FPS mobile requirement.
4. **Color Filtering Compatibility:**
   When colored particles enter a matching cup, they settle into the heightmap with their dyed color. White particles entering a colored cup are rejected by the cup mouth or bounce off the cup walls.
5. **Level JSON Asset Migration:**
   All 30 level JSON files will need their `totalSugar` attribute updated to match the $1.5 \times$ quota formula, while level completion logic in `GameEngine` checks `cups.every((c) => c.isFull)`.
