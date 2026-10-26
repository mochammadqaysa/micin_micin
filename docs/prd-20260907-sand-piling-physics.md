# PRD: Granular Sand Piling Physics, Countdown Cup, and Overflow Spill

## 1. Product overview

### 1.1 Document title and version

- PRD: Granular Sand Piling Physics, Countdown Cup, and Overflow Spill
- Version: 1.0
- Date: 2026-09-07
- Status: Approved (Readiness Score: 100/100)
- Upstream Discovery: [docs/discovery-draft-20260907-sand-piling-physics.md](file:///d:/kayzz/flutter/micin/docs/discovery-draft-20260907-sand-piling-physics.md)
- Clarification Report: [docs/audit/clarification-report-sand-piling-physics-2026-09-07.md](file:///d:/kayzz/flutter/micin/docs/audit/clarification-report-sand-piling-physics-2026-09-07.md)

### 1.2 Product summary

Micin Micin is an offline 2D physics puzzle game celebrating Bart Bonte's classic *Sugar, Sugar*. While earlier iterations achieved a mathematically robust Unified Virtual Resolution ($400 \times 700$) and continuous collision detection for stroke barriers, player feedback identified critical fidelity gaps: particles feel too bulky and fast, target cups display an artificial fluid bar rather than granular accumulation, and cups do not exhibit authentic sand mounding or physical spilling when overloaded.

This product release overhauls the physics and visual presentation to deliver authentic granular sand behavior. Key enhancements include:
1. Refining particle dimensions to crystalline granularity (diameter 2.2px) with soft gravitational acceleration and emitter dispersion.
2. Replacing the artificial liquid progress box with rigid U-shaped Target Cup physical walls and a pure countdown integer display.
3. Implementing physical Sand Mound accumulation inside Target Cups governed by a natural Angle of Repose ($\approx 35^\circ$).
4. Enabling realistic Overflow Spill mechanics when Target Cups are overloaded, supported by a 150% surplus particle supply formula.

---

## 2. Goals

### 2.1 Business goals

- **Authentic Nostalgic Fidelity:** Deliver 100% faithful mechanics matching Bart Bonte's original *Sugar, Sugar*, increasing player satisfaction, retention, and positive organic word-of-mouth.
- **Offline Perfection:** Maintain zero external network dependencies, ensuring an uninterrupted premium tactile experience across diverse Android devices.
- **Performance Excellence:** Maintain a steady 60 FPS frame rate on mobile hardware while simulating up to 500 active granular particles simultaneously.

### 2.2 User goals

- **Tactile Gratification:** Experience the relaxing visual and auditory sensation of powdery sugar/sand flowing organically from emitters and cascading along drawn stroke barriers.
- **Visual Clarity:** Easily read remaining quotas via an intuitive countdown number on each Target Cup without distracting liquid fill animations.
- **Emergent Physics Play:** Enjoy seeing sugar naturally stack into a conical Sand Mound and realistically cascade over cup rims during an Overflow Spill.

### 2.3 Non-goals (Out of Scope)

- **3D Fluid Dynamics:** This release does not implement Navier-Stokes fluid simulations; all behavior remains 2D granular sand simulation.
- **Custom Cup Skins:** Customizable or skinnable cup textures are deferred to future cosmetic updates.
- **Multiplayer / Online Leaderboards:** The game remains strictly single-player and 100% offline.

---

## 3. User personas

### 3.1 Key user types

- **Nostalgic Web Gamer:** Players who loved the original Flash web games of the 2010s and expect exact tactile fidelity, granular sand piling, and audio-visual charm.
- **Casual Mobile Puzzler:** Commuters and casual gamers looking for bite-sized, relaxing, and mentally engaging offline physics puzzles.

### 3.2 Basic persona details

- **Dimas (28, Software Engineer & Retro Gaming Enthusiast):** Grew up playing Bart Bonte games on Kongregate/Newgrounds. He notices immediately when "sugar" moves like heavy bullets or fills up like syrup, and appreciates fine granular simulation.
- **Rina (22, University Student):** Plays casually between lectures. Prefers clean, unmistakable visual goals (a crisp countdown number) and finds watching sand pile up and spill deeply soothing.

### 3.3 Role-based access

- **Single Local Player:** All game features, stages, and physics settings are locally stored; no authentication, accounts, or elevated roles exist.

---

## 4. Functional requirements

### 4.1 Fine Granular Particle Simulation (Priority: P0 - Critical)
- Particles must render with a fine radius of 1.1 virtual pixels (visual diameter 2.2px).
- Particles must experience calibrated soft gravity ($g = 0.14$ virtual px/frame²) with terminal velocity clamped at $v_{\max} = 4.8$ virtual px/frame.
- Particle Emitters must release particles with horizontal jitter ($v_x \in [-0.25, 0.25]$ virtual px/frame) and position offset ($x \pm 1.2$ virtual px) with crystalline opacity variation ($\alpha \in [0.85, 1.0]$) to eliminate rigid laser-line emission.

### 4.2 Rigid Physical Target Cup Boundary & Color Selective Membrane (Priority: P0 - Critical)
- Each Target Cup must possess 3 rigid physical collision boundaries: Left Wall, Floor, and Right Wall.
- The top aperture of the Target Cup features a **Color Selective Membrane** (Option A):
  - Particles with matching color penetrate the membrane freely, entering the cup interior to settle onto the Sand Mound.
  - Particles with non-matching color (e.g., undyed white particles falling toward a red cup) are physically rejected at the mouth aperture, deflecting off the top boundary with normal restitution ($0.3$) and sliding sideways to prevent cup contamination.
- Non-matching colored particles hitting exterior cup walls must physically bounce or slide off rather than passing through or triggering false captures.

### 4.3 Target Cup Countdown Display (Priority: P0 - Critical)
- The synthetic liquid fill bar (`fluidPaint`) must be completely removed.
- Each Target Cup must display a centered integer representing remaining quota: $\text{remaining} = \max(0, \text{targetAmount} - \text{settledCount})$.
- When $\text{remaining} = 0$, the cup must visually transition to a satisfied state (e.g., golden rim glow or completion indicator).

### 4.4 Granular Sand Mound Accumulation (Priority: P0 - Critical)
- Particles entering the cup must settle on top of previously resting particles inside the cup volume.
- Stacking must follow a discrete column heightmap with an Angle of Repose ($\approx 35^\circ$ slope limit). Particles exceeding the slope threshold must roll to adjacent lower columns.
- Settled particles must remain rendered inside the cup as a textured, physical Sand Mound.

### 4.5 Overflow Spill Mechanics (Priority: P1 - High)
- When a Target Cup is full and the Sand Mound exceeds the rim height ($H \ge \text{cupHeight}$), excess particles rolling down the mound must spill past the cup's outer rims.
- Spilled particles must be ejected from the cup, regain active world gravity, and cascade freely into the stage.

### 4.6 150% Particle Supply Surplus (Priority: P0 - Critical)
- To accommodate natural spilling during Overflow Spills, each level's total particle supply must follow the formula:
  $$\text{Total Sugar} = (100 \times N_{\text{cups}}) + \frac{100 \times N_{\text{cups}}}{2} = 150 \times N_{\text{cups}}$$
- For 1 Cup: 150 particles (100 target, 50 spill buffer).
- For 2 Cups: 300 particles (200 target, 100 spill buffer).
- For 3 Cups: 450 particles (300 target, 150 spill buffer).
- Stage victory must trigger immediately when all Target Cups satisfy $\text{remaining} == 0$, regardless of remaining unspent emitter particles.

---

## 5. User experience

### 5.1 Entry points & first-time user flow

- Players launch the game, select a stage from the Level Select screen, and enter the Game Screen.
- The stage displays Particle Emitters, Target Cups showing their initial quotas (e.g., `100`), and any Color Filter Gates.

### 5.2 Core experience

1. **Draw & Direct:** The player draws a Stroke Barrier across the screen.
2. **Observe Flow:** Powdery sugar pours from the Particle Emitter in an organic, shimmering stream, cascading gently along the barrier.
3. **Cup Accumulation:** Sugar enters the Target Cup. Instead of an artificial colored liquid rising, players watch authentic sand grains pile up into a triangular Sand Mound.
4. **Countdown Feedback:** The integer on the cup face ticks down (`99, 98... 12, 0`).
5. **Overfill & Spill:** If excess sugar continues to enter a full cup, it forms a peak above the rim and spills over the edges, bouncing harmlessly off obstacles below.
6. **Victory:** Once all Target Cups reach `0`, the completion fanfare sounds, and the Level Complete modal appears.

### 5.3 UI/UX highlights & Edge cases

- **Ultra-Tall / Tablet Viewports:** Letterboxing (`#101012`) guarantees identical physics and Sand Mound slope on any aspect ratio.
- **Fast Continuous Stream:** Particles entering the cup in high density must settle without stacking into unnatural single-pixel vertical needles (guaranteed by Angle of Repose slope relaxation).
- **Zero Quota Edge Case:** When a cup reaches `0`, subsequent particles do not decrement below 0; they simply pile onto the Sand Mound and overflow.

---

## 6. Narrative

Sarah opens Micin Micin on her train ride home. She selects Level 14. As particles pour from the top emitter, she immediately smiles: the grains no longer look like clunky dots shooting downwards, but soft, crystalline sugar drifting gracefully through the air. She sketches an elegant slope guiding the stream toward the white cup. As the grains enter, they do not vanish into a fake water tank; instead, they settle and stack into a lovely, authentic mound of sugar. The countdown number ticks down to zero with a satisfying snap. Even as stray particles spill over the rim and tumble down the cup's outer wall, the stage completes with a golden chime. The game finally feels exactly like the beloved classic she remembered.

---

## 7. Success metrics

### 7.1 User-centric metrics

- **Player Satisfaction Rating:** Subjective gameplay feel feedback rated $>4.8/5.0$ in playtesting regarding sand tactile authenticity.
- **Visual Clarity:** 100% of tested users understand the countdown number without requiring a tutorial.

### 7.2 Business metrics

- **Level Completion Rate:** Maintain healthy completion rates across all 30 stages with the 150% particle supply buffer preventing premature failures due to spillage.
- **Zero Bug Regressions:** Zero reported regressions in stroke barrier deflection or level completion unlocks.

### 7.3 Technical metrics

- **Frame Rate:** Steady 60 FPS on mid-range Android devices with 500 active particles.
- **Computation Overhead:** $O(1)$ heightmap bin lookup and relaxation per particle per frame.
- **Test Pass Rate:** 100% test pass rate across the entire automated test suite.

---

## 8. Technical considerations (Input for Engineering Team)

### 8.1 Integration points

- **`ParticleController` & `ParticlePool`:** Update kinematics integration with new gravity constants ($g = 0.14, v_{\max} = 4.8$) and integrate cup heightmap settling without exceeding the 500-particle pool boundary.
- **`CupContainer` (formerly `CupHitbox`):** Evolve `CupHitbox` into a container supporting 3 physical boundary segments and a 1D discrete column heightmap.
- **`LevelPainter`:** Remove `fluidPaint` rect drawing; render countdown text and resting sand mound profiles.
- **`ParticlePainter`:** Update stroke width to match $kParticleRadius = 1.1$ and crystalline alpha jitter.
- **`LevelConfig`:** Migrate all 30 level asset files to reflect the $1.5 \times$ `totalSugar` quota formula.

### 8.2 Data storage & privacy

- Game remains 100% offline. No analytics, tracking, or network permissions required. Player progress continues using local `SharedPreferences`.

### 8.3 Scalability & potential technical challenges

- **Angle of Repose Complexity:** Avoid recursive inter-particle collision. Use a 1-step discrete column slope relaxation algorithm ($O(1)$) to guarantee steady 60 FPS.
- **Particle Pool Lifetime:** Ensure spilled particles falling below the virtual canvas boundary ($y > 750.0$) are recycled cleanly into `ParticlePool`.

---

## 9. Milestones & sequencing

### 9.1 Project estimate & Team composition

- **Project Size:** Medium Feature Refactor (3-4 Days)
- **Team Composition:** Senior Software Engineer (Engine & Physics), UI/UX Specialist (Painters & HUD), QA Engineer (Deterministic Testing).

### 9.2 Suggested phases

- **Phase 1 (Particle Kinematics & Emitter Dispersal):** Calibrate radius (1.1px), gravity ($0.14$), terminal velocity ($4.8$), and organic emitter jitter.
- **Phase 2 (Physical Cup Boundary & Countdown Display):** Implement 3-wall rigid cup boundaries, remove liquid bar, and implement remaining quota countdown display.
- **Phase 3 (Sand Mound Stacking & Angle of Repose):** Implement discrete column heightmap, slope relaxation, and resting sand particle rendering.
- **Phase 4 (Overflow Spill & 30-Level Quota Migration):** Implement overflow spilling mechanics, update 30 level JSONs with 150% particle supply, and run full test regression.

---

## 10. User stories & Acceptance Criteria

### 10.1. Soft Granular Flow and Organic Emitter
- **ID**: US-001
- **Story**: As a player, I want particles to pour softly with gentle dispersion and small crystalline grain size, so that the sugar feels like authentic powdery MSG rather than heavy bullets.
- **Acceptance criteria**:
  - [ ] Particle radius is calibrated to $1.1$ virtual pixels (visual stroke diameter $2.2$ px).
  - [ ] Default gravity is calibrated to $0.14$ virtual px/frame² with terminal velocity clamped at $4.8$ virtual px/frame.
  - [ ] Emitter disperses particles with randomized horizontal velocity $v_x \in [-0.25, 0.25]$ virtual px/frame and position jitter $x \pm 1.2$ virtual px.
  - [ ] Particle color includes slight crystalline opacity variation $\alpha \in [0.85, 1.0]$.

### 10.2. Target Cup Countdown and Physical Boundaries
- **ID**: US-002
- **Story**: As a player, I want Target Cups to have solid physical walls, a color-selective top aperture, and display a pure countdown number, so that I have clear objective feedback without synthetic liquid filling up or wrong colors contaminating the cup.
- **Acceptance criteria**:
  - [ ] The synthetic fluid rectangle (`fluidPaint`) is completely removed from cup rendering.
  - [ ] Target Cups display remaining quota counting down: $\text{remaining} = \max(0, \text{targetAmount} - \text{settledCount})$.
  - [ ] Target Cups possess 3 physical barrier boundaries (Left Wall, Floor, Right Wall) with a color-selective top aperture.
  - [ ] Non-matching colored particles hitting the top aperture or exterior walls are deflected sideways with restitution $0.3$, preventing cup contamination.
  - [ ] When $\text{remaining} == 0$, the cup visually indicates fulfillment.

### 10.3. Discrete Sand Mound Stacking
- **ID**: US-003
- **Story**: As a player, I want sugar entering the cup to physically accumulate into a conical pile, so that I experience the authentic tactile satisfaction of sand stacking.
- **Acceptance criteria**:
  - [ ] Particles entering the Target Cup settle on the floor or atop existing settled particles in discrete column bins (2px bin width).
  - [ ] Stacking enforces a natural Angle of Repose ($\approx 35^\circ$ maximum slope between adjacent columns), rolling particles downward if the slope threshold is exceeded.
  - [ ] Settled particles remain rendered within the Target Cup forming a visible granular Sand Mound.
  - [ ] Settling computation executes in $O(1)$ time per particle without inter-particle contact solvers.

### 10.4. Overflow Spill and Particle Supply Buffer
- **ID**: US-004
- **Story**: As a player, I want overloaded cups to let excess sugar cascade over the rim, and I want enough sugar supply so that spillage does not cause unfair level failure.
- **Acceptance criteria**:
  - [ ] When a Target Cup is full and the Sand Mound height exceeds the rim, subsequent particles roll over the rim and resume active free-fall into the stage.
  - [ ] Particles falling below $y = 750.0$ are cleanly recycled back to `ParticlePool`.
  - [ ] Total particle supply per stage is updated to $(100 \times N_{\text{cups}}) + \frac{100 \times N_{\text{cups}}}{2} = 150 \times N_{\text{cups}}$.
  - [ ] Level victory triggers immediately when all Target Cups have satisfied their quotas ($\text{remaining} == 0$), even if emitter particles remain unspent.
  - [ ] Full automated test suite passes with 100% pass rate and zero linter warnings.
