# Micin Micin Domain Context

Domain glossary and ubiquitous language definitions for the Micin Micin physics puzzle game engine.

## Language

**Particle**:
A discrete granular entity of sugar or MSG simulated as an active point in the virtual coordinate space.
_Avoid_: Grain, dot, bullet, entity

**Stroke Barrier**:
A player-drawn line path composed of linear geometric segments that deflects falling particles.
_Avoid_: Wall, line, pencil, drawing, curve

**Target Cup**:
A receptacle container that collects particles of matching color and increments the level completion score.
_Avoid_: Receptacle, bucket, bowl, goal, box

**Particle Emitter**:
A fixed spawn point in the virtual world that periodically releases sugar particles at a configured rate.
_Avoid_: Spout, nozzle, dropper, generator

**Color Filter Gate**:
A geometric boundary zone that mutates the color state of particles passing through it.
_Avoid_: Filter, portal, dye zone, lens

**Unified Virtual Resolution**:
A standardized internal coordinate space fixed at 400x700 virtual pixels used for all physics simulation and collision detection.
_Avoid_: Screen coordinates, normalized coordinates, pixel space, viewport space

**Sand Mound**:
A physical accumulation of settled particles inside a Target Cup shaped by gravitational stacking and natural angle of repose.
_Avoid_: Liquid level, fluid bar, pile, heap, progress fill

**Angle of Repose**:
The maximum physical slope angle that granular particles can sustain before rolling or sliding down to adjacent height columns.
_Avoid_: Slope limit, roll angle, tilt

**Overflow Spill**:
The phenomenon where excess particles atop a full Sand Mound roll over the cup rim and resume active free-fall physics into the game world.
_Avoid_: Leaking, splash, excess dump

**Diegetic HUD**:
An in-game user interface integrated directly into the physical scene and corner anchors without status bars, fraction strings, or debug counters.
_Avoid_: HUD bar, status bar, scorecard, overlay text

**Chunky Arcade Visual Identity**:
The official high-contrast, playful arcade visual language featuring 3D extruded slabs, solid drop shadows, candy palettes, glossy highlights, coin badges, and tactile responsive controls.
_Avoid_: Glassmorphism, Zen minimalism, Neumorphism, flat design, blurred overlays on hot paths

**Cartoon Tokens (`CartoonTokens`)**:
The centralized design token architecture codifying candy button slabs (Green, Amber, Cyan, Coral, Purple), specular gloss highlights, 4px solid drop shadows (`Offset(0, 4)`), and midnight indigo canvas gradients.
_Avoid_: GlassTokens, ZenPalette, NeuTokens, soft-blur tokens, pastel monochrome

**Chunky 3D Extruded Button (`CartoonButton` / `CartoonIconButton`)**:
A tactile, bouncy mobile game button featuring a 3D beveled face, specular gloss arc, and solid extruded bottom shadow with animated sunk-in press feedback.
_Avoid_: GlassPillButton, flat text button, borderless icon, blur container

**3D Beveled Level Node (`LevelButton`)**:
A tactile square arcade stage selector node with 3D beveled edges, distinct unlock (green/amber/cyan), completed (golden star & solid depth), and locked (debossed grey slab with lock badge) states.
_Avoid_: Glass pebble, floating circle mote, translucent chip, flat tile

**Chunky Drop-Shadow Act Card (`_ActCard` / `LevelSelectScreen`)**:
A solid rectangular act milestone card featuring a colored top accent stripe, BABAK Roman numeral badge, progress bar, and hard-shadow depth anchoring the 4 acts.
_Avoid_: Glass bento grid, translucent glass card, floating text card

**Arcade Coin HUD (`GameHud`)**:
An energetic in-game HUD featuring a custom-painted amber coin counter badge (`_CoinPainter`), circular icon buttons with solid 3D depth, and a pulsing cyan gravity indicator pill.
_Avoid_: Minimalist basalt icons, frosted glass chips, borderless floating glyphs

**Pop-Scale Countdown & Victory Overlay (`CountdownOverlay` / `LevelCompleteDialog`)**:
High-energy arcade celebration sequences featuring pop-scale TweenSequence animations, golden star badges, and chunky cartoon dialog panels.
_Avoid_: Ambient golden wash, tranquil line dissolution, zen reflection modal

**Crystalline Square Particle**:
A discrete granular sugar grain rendered with `StrokeCap.square` at 2.2x2.2 virtual pixels with bounded stream micro-jitter and crystalline refraction opacity.
_Avoid_: Soft dot, round particle, fuzzy grain, sprite particle

**Level Visual Theme (`LevelVisualTheme`)**:
A bespoke chromatic profile and visual narrative assigning signature background chalkboard hues, diegetic canvas typography, and environmental silhouette props to each of the 30 stages.
_Avoid_: Level skin, color theme, background asset, stage texture

**Silhouette Prop (`SilhouettePropConfig`)**:
A procedural flat vector shadow element (e.g., teaspoon, silhouette hand, teapot spout) rendered on the canvas plane and coupled to rigid line colliders for physical grain deflection.
_Avoid_: Background sprite, decoration, obstacle icon, visual gimmick

**Diegetic Canvas Typography**:
Minimalist, quiet stage branding (e.g., "level 8", "sugar, sugar") painted directly onto the background canvas plane with harmonized opacity (0.18–0.25) behind falling particles.
_Avoid_: HUD header, floating label, overlay text, watermark banner

