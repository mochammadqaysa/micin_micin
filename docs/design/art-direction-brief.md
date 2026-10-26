# Art Direction Brief & Style Bible: Micin Micin

**Project:** Micin Micin (Flutter 2D Granular Physics Arcade Puzzle)  
**Style Core:** Chunky Arcade / High-Energy Tactile Physics Puzzle  
**Target Viewport:** $400 \times 700$ Virtual Coordinates (`VirtualCoordinateAdapter`)  
**Document Version:** 2.0.0 (Canonical)  
**Status:** Approved  

---

## 1. Game Frame & High-Level Philosophy

### 1.1 Player Fantasy & Emotional Arc
*Micin Micin* is a high-energy, tactile, and deeply satisfying 2D physics arcade puzzle. The player experiences the playful joy of guiding rushing granular sugar streams into chunky target cups through bold, decisive line strokes. 

Actions feel juicy, crisp, and responsive: every button press has physical extruded depth, every stage completion rewards the player with celebratory pop-scale badges, golden coin tallies, and star ratings, and the visual environment is clean, vibrant, and readable at 60/120 FPS.

### 1.2 Aesthetic Anchors (Chunky Arcade)
- **Chunky Arcade Cabinets & Tactile Toys:** Chunky, beveled extruded button slabs, high-contrast dark indigo canvas backgrounds, glossy specular arcs, and solid 4px drop shadows (`Offset(0, 4)`).
- **Vibrant Candy Palette:** Rich candy colors (Emerald Green, Radiant Amber, Vivid Cyan, Energetic Coral, Royal Purple) codifying intuitive UI affordances.
- **Punchy "Juice" & Micro-Animations:** Immediate tactile depression on pointer press (4px sunk translation), spring-like recovery on release, pop-scale countdown badges, and rhythmic particle emission.

### 1.3 Core Technical Frame
- **Engine & Presentation:** Flutter 3.12+ with Flame Engine bridge and priority-ordered components.
- **Virtual Coordinate Contract:** Strict $400 \times 700$ virtual points (`VirtualCoordinateAdapter`). All visual components, stroke widths, radiuses, and particle physics are authored and scaled within this deterministic box.
- **Aspect Ratio Handling:** Letterboxing / pillarboxing with unified dark midnight indigo background fill (`#110C29`).
- **Framerate Target:** Rock-solid 60/120 FPS on mobile, zero live `BackdropFilter` or runtime GC allocations inside active gameplay paint loops.

---

## 2. Color Architecture & Design Tokens (`CartoonTokens`)

The visual design system is codified under `CartoonTokens` in `micin_micin/lib/core/theme.dart`:

```
+-------------------------------------------------------------------------+
|                              BACKGROUND                                 |
|            Vibrant Midnight Indigo Gradient (#1E1645 -> #110C29)        |
|                                                                         |
|   +-------------------+                     +-----------------------+   |
|   |  ARCADE EMITTER   |                     |    STROKE BARRIER     |   |
|   |  Chunky Nozzle    |                     |   Solid White Stroke  |   |
|   |     (#FFFFFF)     |                     |    (#FFFFFF + Core)   |   |
|   +---------+---------+                     +-----------+-----------+   |
|             |                                           |               |
|             v (Flowing Particles)                       |               |
|       *  *  *  *  * (Powdery Crystalline Grains: #FFFFFF, alpha 0.88-1.0)|
|             |                                                           |
|             v                                                           |
|   +-----------------------------------------------------------------+   |
|   |                    COLOR FILTER GATES                           |   |
|   |   Vivid Coral       Cyan Prism      Radiant Amber    Emerald    |   |
|   |    (#FB7185)        (#38BDF8)         (#FBBF24)     (#4ADE80)   |   |
|   +-----------------------------------------------------------------+   |
|             |                                                           |
|             v (Mutated Granular Sand Mound)                             |
|   +-----------------------------------------------------------------+   |
|   |                       CHUNKY TARGET CUPS                        |   |
|   |  Deep Navy Bevel | Amber/Green Countdown Face | Selective Rim   |   |
|   +-----------------------------------------------------------------+   |
+-------------------------------------------------------------------------+
```

### 2.1 Environmental Canvas (Background & Panels)
- **Canvas Gradient:**
  - `canvasTop`: `#1E1645` (Vibrant deep indigo)
  - `canvasBottom`: `#110C29` (Midnight purple-black)
  - `canvasLight`: `#2C2263` (Accent surface)
- **Arcade Panels & Containers:**
  - `panelBg`: `#241C52` (Solid container base)
  - `panelBorder`: `#45368E` (Crisp 2px outline)
  - `panelCreamBg`: `#FFF9E8` (Chunky celebration cream face)
  - `panelCreamBorder`: `#E8C888`
  - `panelCreamHeader`: `#FDE68A`

### 2.2 3D Beveled Candy Buttons (Faces, Gloss & Sunk Shadows)
Every interactive button features a 3-stop vertical slice (Top face, Bottom face, and Extruded hard shadow):

| Button Role | Top Face | Bottom Face | Hard Shadow | Semantic Purpose |
|---|---|---|---|---|
| **Green** | `#4ADE80` | `#16A34A` | `#15803D` | PLAY, Primary Actions, Next Level |
| **Amber / Gold** | `#FBBF24` | `#D97706` | `#B45309` | LEVELS, Secondary Actions, Coins, Stars |
| **Blue / Cyan** | `#38BDF8` | `#0284C7` | `#0369A1` | RESET, Info, Utility Controls |
| **Red / Coral** | `#FB7185` | `#E11D48` | `#BE123C` | PAUSE, Cancel, Danger Actions |
| **Purple / Violet**| `#C084FC` | `#9333EA` | `#7E22CE` | GRAVITY Toggle, Magic, Credits |

### 2.3 Specular Gloss & Extrusion Shadows
- **Top Gloss Arc:** Semi-translucent white (`glossWhite`: `0x66FFFFFF`) sweeping across the upper 40% of buttons.
- **Extruded 3D Shadow:** Solid non-blurred drop shadow (`Offset(0, 4)`) rendered in the respective button shadow color.
- **Bevel Chamfer:** Subtle dark inner bottom rim (`bevelDark`: `0x4D000000`).
- **Text Drop Shadow:** Crisp 1px drop shadow (`textShadow`: `0x80000000`) ensuring 100% legibility.

---

## 3. Shape Language & Geometry

### 3.1 Component Anatomy
1. **Chunky Target Cups:**
   - Silhouette: Solid U-shaped receptacle with clean outer walls ($W = 2.5\text{ virtual px}$) and rounded base corners ($R = 8.0\text{ virtual px}$).
   - Countdown Display: Centered bold integer numeral (`remaining = max(0, target - settled)`) rendered in Google Fonts `Outfit` Bold. Numerals pulse responsive scale ($1.00 \to 1.06 \to 1.00$) upon grain capture and turn radiant gold upon reaching `0`.
   - Discrete Sand Mound: 1D Discrete Column Heightmap ($2.0\text{ px}$ bins) with Angle of Repose cascade downhill relaxation ($\Delta H_{\max} = 1.4\text{ px} \approx 35^\circ$).

2. **Chunky 3D Buttons (`CartoonButton` / `CartoonIconButton`):**
   - Shape: Rounded rectangle ($R = 16.0\text{ virtual px}$) or circular pill with extruded 3D base.
   - Pressed State: 4px downward translation with reduced shadow height, delivering instant physical click feedback.

3. **Chunky Act Cards (`_ActCard` / `LevelSelectScreen`):**
   - Solid drop-shadow card with colored top accent stripe matching Act theme (Act I Green, Act II Coral, Act III Cyan, Act IV Amber).
   - Solid Roman numeral act badge and level completion progress bar.

4. **Arcade Coin HUD (`GameHud`):**
   - Amber coin badge (`_CoinPainter`) displaying level/coin tally with solid bevel outline.
   - Circular icon buttons with solid hard-shadow depth (`hud_reset`, `hud_pause`, `hud_audio`).
   - Pulsing GRAVITY toggle pill with cyan aura halo.

5. **Countdown & Victory Overlays:**
   - `CountdownOverlay`: Pop-scale `TweenSequence` badge ($3 \to 2 \to 1 \to \text{GO!}$).
   - `LevelCompleteDialog`: Chunky cartoon dialog box (`CartoonPanel`) with golden star ratings, level score, and 3D action buttons.

---

## 4. Explicit Visual Exclusions (Anti-Patterns)

To strictly enforce the **Chunky Arcade** aesthetic, the following patterns are forbidden:
- ❌ **No Fragile Glassmorphism:** Never use live `BackdropFilter` or translucent frosted glass on gameplay hot paths (prevents frame drops on mobile).
- ❌ **No Flat / Desaturated "Zen" Monochrome:** Avoid dull slate grays, washed-out pastels, and pseudo-philosophical meditation flavor text.
- ❌ **No Low-Contrast Soft Neumorphism:** Avoid blurry soft clay shadows that reduce contrast and arcade punch.
- ❌ **No Skeuomorphic Textures:** No realistic wood grain, metal scratches, or dirty chalkboard dust textures.

---

## 5. Rendering Implementation Matrix

| Component | Asset / Technique | Implementation Detail | Justification |
|---|---|---|---|
| **Buttons & Controls** | Flutter Widgets | `CartoonButton`, `CartoonIconButton` (`CartoonTokens`) | Pure declarative 3D button slabs with 4px extruded drop shadows and sunk-in press animation. |
| **In-Game HUD** | Flutter Overlay | `GameHud` (`_CoinPainter` + hard-shadow icon buttons) | Zero GPU blur overhead; crisp arcade contrast over active physics. |
| **Overlays & Dialogs** | Flutter Overlays | `CartoonPanel`, `CountdownOverlay`, `LevelCompleteDialog` | Energetic pop-scale animations, golden star badges, and chunky panels. |
| **Falling Particles** | Flame Component | `ParticleSystemFlameComponent` (`drawPoints`, `StrokeCap.square`) | 60/120 FPS crystalline square sugar grains with zero runtime heap allocations. |
| **Stroke Barrier** | Flame Component | `LineDrawingFlameComponent` (`drawPoints` / segments) | Real-time continuous raycasting collision against falling particles. |
| **Target Cups** | Flame Component | `LevelGeometryFlameComponent` (U-barriers + heightmap) | Deterministic 1D discrete column heightmap sand piling and overflow spill. |
