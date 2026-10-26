---
title: "Technical Specification: Modern Minimalist & Glassmorphism UI Architecture"
version: "1.0.0"
date_created: "2026-10-05"
last_updated: "2026-10-05"
owner: "Specification Architect"
tags: ["spec", "ui-ux", "glassmorphism", "game-feel", "design-system", "flutter", "hud", "bento-grid", "micro-animations"]
---

# Technical Specification: Modern Minimalist & Glassmorphism UI Architecture

> [!WARNING]
> **ARCHIVED & SUPERSEDED BY CHUNKY ARCADE**:
> This specification details a historical visual iteration (Glassmorphism) that has been superseded by the canonical **Chunky Arcade** visual identity (`CartoonTokens`, 3D extruded slabs, solid drop shadows, and arcade coin HUD). Refer to [docs/design/art-direction-brief.md](file:///d:/kayzz/flutter/micin/docs/design/art-direction-brief.md), [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md), and [CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md) for active system specifications.

## Introduction

This Technical Specification establishes the engineering design, component contracts, visual tokens, and micro-animation state machines for the **Modern Minimalist & Glassmorphism UI Overhaul** in **Micin Micin**.

Building on the approved Product Discovery Draft ([docs/discovery-draft-20261005-glassmorphism-ui-overhaul.md](file:///d:/kayzz/flutter/micin/docs/discovery-draft-20261005-glassmorphism-ui-overhaul.md)) and canonical Game Design Document ([docs/gdd/GDD-modern-glassmorphism-ui-overhaul.md](file:///d:/kayzz/flutter/micin/docs/gdd/GDD-modern-glassmorphism-ui-overhaul.md)), this document defines how Flutter declarative widgets, theme tokens, backdrop blur shaders, and touch gesture layers are constructed without compromising the 60/120 FPS zero-allocation physics pipeline.

---

## 1. Purpose & Scope

### 1.1 In-Scope Components
1. **Neo-Glass Design Token Architecture:** Codification of `GlassTokens` and integration into `AppTheme`, establishing frosted glass fills, 1px specular gradient borders, and the refractive neon mineral palette.
2. **Dual Glass Pipeline:** 
   - *Mode A (Live BackdropFilter):* Hardware-accelerated blur ($\sigma=16.0\text{--}24.0$) isolated inside `RepaintBoundary` for modal overlays (`PauseOverlay`, `LevelCompleteDialog`), screen headers, and menu navigation cards.
   - *Mode B (Pre-Composited Frosted Gradients):* Zero-backdrop-filter gradient shaders (`rgba(255,255,255,0.12)`) for high-frequency in-game HUD elements (`GameHud`) to eliminate GPU re-rasterization stalls over 500 active granular particles.
3. **Core Reusable Glass Widgets:** Implementation of `GlassContainer`, `GlassPillButton`, `GlassCard`, and `GlassHudChip`.
4. **Screen-by-Screen Glassmorphic Upgrades:**
   - `SplashScreen`: Ethereal neon sugar stream, glass circular portal, and smooth reveal.
   - `MenuScreen`: Interactive glass sandbox, diegetic glass nozzle, and floating frosted action pills (`PLAY`, `CHAMBERS`, `CREDITS`).
   - `LevelSelectScreen`: 4-Act Glass Bento Grid, $2 \times 1$ wide milestone cards, breathing cyan pulse, and locked micro-shake.
   - `GameHud`: Borderless floating glass glyphs, chamber numeral tag (`0 1`), and dual-chevron luminous gravity toggle pill.
   - `PauseOverlay`: Full-bleed gaussian blur ($\sigma=24.0$), floating breathing glass action glyphs, and soundscape capsule.
   - `LevelCompleteDialog`: Radiant golden bloom wash, dynamic level ambiance, and equilibrium chips.
5. **Tactile Game-Feel & Micro-Animation System:** Spring-based squash-and-pop physics (`Curves.easeOutBack`), overshoot scale morphs, and decaying trauma screen shakes.
6. **Full Backward Compatibility:** 100% adherence to existing widget test finders, keys, and routing contracts (157 passing tests).

### 1.1 Out of Scope
- Modifying core 2D granular physics engine algorithms (`micin_micin/lib/engine/`), particle pool allocation, or CCD line collision math.
- Introducing online multiplayer, analytics, or external asset downloads (game remains 100% offline).
- Altering the $400 \times 700$ virtual coordinate space contract or level JSON schema.
- Introducing an ink capacity reservoir or stroke limit (infinite ink capacity invariant is preserved).

### 1.2 Open Questions & Resolved Decisions

#### RESOLVED ARCHITECTURAL DECISIONS:
- **DECISION-001 (Playfield Vessels & Gates - Option A Selected):** Target cups (`CupHitbox`) and Color Filter Gates are rendered directly via `Canvas` drawing in `LevelPainter` using translucent beveled glass strokes (`alpha: 0.14`), 1px specular gradient outlines, and neon aperture glow halos (Option A). This preserves zero-allocation 60/120 FPS performance, maintains headless physics decoupling, and avoids widget stack composition overhead or letterbox desync.

#### VERIFIED ASSUMPTIONS:
1. **ASSUMPTION-001 (Dual Glass Pipeline):** Full live `BackdropFilter` running on top of 500 continuously updating particles during active gameplay causes significant GPU composition overhead on mid-range Android devices. Therefore, we use **Mode B (Pre-composited translucent frosted glass gradients)** for the in-game `GameHud`, and reserve **Mode A (Live BackdropFilter)** for stationary screens and paused/modal overlays.
2. **ASSUMPTION-002 (Test Finder Preservation):** All existing test finders (`'PLAY'`, `'CHAMBERS'`, `'CREDITS'`, `'Pilih Level'`, `'0/30'`, `'CLEAR'`, `'Babak I'` .. `'Babak IV'`, `'0 1'`, `Key('hud_reset')`, `Key('hud_pause')`) must remain fully functional with zero breaking changes.
3. **ASSUMPTION-003 (Platform Compatibility):** Flutter's standard `BackdropFilter` with `ImageFilter.blur` will be used rather than custom AGSL/GLSL runtime shaders to guarantee 100% cross-platform compatibility across Android (Impeller/Skia), iOS, Web, and Desktop.

> [!NOTE]
> All assumptions and decisions conform to established project invariants recorded in `docs/ARCHITECTURE.md` and `CONTEXT.md`.


---

## 2. Definitions

All terms strictly adhere to the project's Domain Glossary ([CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md)):

- **Glassmorphism:** A modern UI aesthetic characterized by background blur (`BackdropFilter`), multi-layered translucency, 1px specular gradient borders, and subtle outer drop glows.
  - _Avoid:_ `Flat Design`, `Skeuomorphism`, `Material Elevation Shadows`.
- **Dual Glass Pipeline:** An architectural separation where modal overlays use live GPU `BackdropFilter`, while active playfield HUDs use pre-composited linear gradients to preserve 60/120 FPS.
- **Diegetic HUD:** An in-game user interface integrated into the scene canvas without solid toolbars or intrusive frame borders.
  - _Avoid:_ `Status Bar`, `Score Bar`, `Header Strip`.
- **Neo-Glass Mineral Palette:** The updated 5-color luminous mineral palette comprising Obsidian Void, Frosted Glass, Neon Cyan, Neon Rose, Radiant Gold, and Mint Flora.
  - _Avoid:_ `Pastel Flat Tones`, `Earthy Chalkboard Grey`.
- **Tactile Pop:** A spring-eased scale micro-animation featuring an initial 50ms squash followed by a 220ms overshoot bounce (`Curves.easeOutBack`).
  - _Avoid:_ `Linear Tween`, `Instant State Flip`.

---

## 3. Requirements, Constraints & Guidelines

### 3.1 Functional Requirements
- **REQ-001**: The system shall implement `GlassTokens` in `micin_micin/lib/core/theme.dart`, providing centralized constants for glass fills, gradient borders, corner radii, and refractive neon accents.
- **REQ-002**: The system shall provide a reusable `GlassContainer` widget that supports selectable blur sigma, background tint, gradient border, and optional outer glow.
- **REQ-003**: The system shall provide `GlassPillButton` with integrated tactile squash-and-pop physics, supporting custom icons, text labels, and click feedback.
- **REQ-004**: `MenuScreen` shall feature a glass top capsule, an interactive physics sandbox with endless particle recycling, and floating frosted action pills (`PLAY`, `CHAMBERS`, `CREDITS`).
- **REQ-005**: `LevelSelectScreen` shall organize the 30 stages into a 4-Act Asymmetric Glass Bento Grid with $2 \times 1$ wide featured milestone cards, breathing cyan pulse on the next playable stage, and micro-shake on locked stages.
- **REQ-006**: `GameHud` shall float diegetically over the playfield with pre-composited frosted glass chips (`• CHAMBER XX`, `↺`, `❚❚`, and dual-chevron `▲ GRAVITY TOGGLE ▼`).
- **REQ-007**: `PauseOverlay` shall render full-bleed gaussian blur ($\sigma=24.0$) with 3 floating breathing action glyphs (`↺`, `▶`, `⠿`) and a bottom soundscape capsule toggle.
- **REQ-008**: `LevelCompleteDialog` shall render an ambient radial gold bloom wash with equilibrium badge, dynamic level ambiance reflection, and glowing action button.

### 3.2 Performance Constraints
- **CON-001**: Glass blur rendering must NOT allocate heap objects inside `paint()` loops; all painters must reuse static coordinate and color buffers.
- **CON-002**: Any widget utilizing `BackdropFilter` must be wrapped in a `RepaintBoundary` to isolate raster cache invalidation.
- **CON-003**: In-game HUD elements must not invoke `BackdropFilter` during active particle simulation (Dual Glass Pipeline Rule).
- **CON-004**: Touch coordinates must continue passing through `VirtualCoordinateAdapter.screenToVirtual()` clamped to $[0..400] \times [0..700]$.

### 3.3 Security & Offline Invariants
- **SEC-001**: Zero external asset fetching at runtime. Google Fonts (`Outfit`) must load offline from local asset bundles.
- **SEC-002**: Zero network permissions required (`android.permission.INTERNET` remains absent).

---

## 4. Interfaces & Data Contracts

### 4.1 Neo-Glass Design Tokens (`GlassTokens`)

```dart
/// File: micin_micin/lib/core/theme.dart
abstract final class GlassTokens {
  // Base Canvas & Void
  static const Color obsidianVoid = Color(0xFF0B0E14);
  static const Color obsidianVignette = Color(0xFF06080C);

  // Frosted Glass Surfaces (Translucency)
  static const Color surfaceLight = Color(0x14FFFFFF);    // 8% white
  static const Color surfaceSubtle = Color(0x0AFFFFFF);   // 4% white
  static const Color surfaceElevated = Color(0x1FFFFFFF); // 12% white

  // Glass Specular Borders (1px Gradient)
  static const Color borderHighlight = Color(0x3DFFFFFF); // 24% white (Top-Left)
  static const Color borderShadow = Color(0x0DFFFFFF);    // 5% white (Bottom-Right)
  static const Color borderActive = Color(0x6600F2FE);    // Neon Cyan glow border

  // Refractive Neon Accents
  static const Color neonCyan = Color(0xFF00F2FE);
  static const Color neonCyanGlow = Color(0x4D00F2FE);
  static const Color neonRose = Color(0xFFFF6584);
  static const Color radiantGold = Color(0xFFFFD200);
  static const Color radiantGoldGlow = Color(0x66FFD200);
  static const Color mintFlora = Color(0xFF4EECD5);
  static const Color textSpecular = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8E9AA8);

  // Standard Glass Blur Radii
  static const double blurLight = 12.0;
  static const double blurStandard = 18.0;
  static const double blurHeavy = 24.0;

  // Corner Radii
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusPill = 999.0;
}
```

### 4.2 Reusable Glass Component Contracts

```dart
/// Reusable Frosted Glass Container with gradient border
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blurSigma;
  final Color backgroundColor;
  final Gradient? borderGradient;
  final EdgeInsetsGeometry padding;
  final bool enableLiveBlur; // If false, renders Mode B pre-composited glass

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = GlassTokens.radiusMedium,
    this.blurSigma = GlassTokens.blurStandard,
    this.backgroundColor = GlassTokens.surfaceLight,
    this.borderGradient,
    this.padding = EdgeInsets.zero,
    this.enableLiveBlur = true,
  });
}

/// Tactile Glass Pill Button with Squash & Pop micro-animations
class GlassPillButton extends StatefulWidget {
  final Widget? icon;
  final String label;
  final VoidCallback onTap;
  final Color accentGlow;
  final bool isPrimary;
  final double height;
  final EdgeInsetsGeometry padding;

  const GlassPillButton({
    super.key,
    this.icon,
    required this.label,
    required this.onTap,
    this.accentGlow = GlassTokens.neonCyan,
    this.isPrimary = false,
    this.height = 48.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });
}
```

---

## 5. Acceptance Criteria

- **AC-001 (Visual Theme & Palette Compliance):**
  - Given the app boots to any screen (`/`, `/menu`, `/levels`, `/game/:id`),
  - When the screen renders,
  - Then the canvas background is `GlassTokens.obsidianVoid` (`#0B0E14`), and interactive containers display 1px gradient borders with frosted glass translucency.

- **AC-002 (Tactile Pop Feedback):**
  - Given any `GlassPillButton` or interactive glass node,
  - When the user presses down (`PointerDownEvent`),
  - Then the widget squashes to scale `0.92` within $50\text{ ms}$;
  - And when released (`PointerUpEvent`), it springs up to scale `1.08` before settling to `1.00` within $220\text{ ms}$ using `Curves.easeOutBack`, accompanied by the audio cue `click.wav`.

- **AC-003 (Locked Stage Micro-Shake):**
  - Given the player is on `LevelSelectScreen`,
  - When tapping a locked stage node,
  - Then the node undergoes a 4-cycle damped horizontal oscillation ($\pm 6\text{ px}$) over $300\text{ ms}$, without triggering any `SnackBar` or popup dialog.

- **AC-004 (In-Game Diegetic HUD Non-Interference):**
  - Given the player is in `GameScreen` actively drawing chalk lines,
  - When drawing across the canvas,
  - Then the line barrier deflects particles with CCD physics without triggering HUD buttons unless the tap lands inside the Top-Right cluster ($44 \times 44\text{ pt}$ hit test padding).

- **AC-005 (Dual Glass Pipeline 60 FPS Guarantee):**
  - Given an active game level with 500 falling particles,
  - When rendering frames in `GameScreen`,
  - Then `GameHud` elements use Mode B pre-composited gradients without live `BackdropFilter`, maintaining frame rendering latency below $16.6\text{ ms}$ ($>60\text{ FPS}$) with zero new heap allocations per frame.

- **AC-006 (Modal Blur Isolation):**
  - Given active gameplay is paused by tapping `Key('hud_pause')`,
  - When `PauseOverlay` appears,
  - Then a full-bleed `BackdropFilter` ($\sigma=24.0$) blurs the frozen game canvas behind it, wrapped inside an isolated `RepaintBoundary`.

- **AC-007 (Bento Grid Navigation & Milestone Highlighting):**
  - Given `LevelSelectScreen` is loaded,
  - When viewing stages,
  - Then stages 5, 10, 18, 25, and 30 render as $2 \times 1$ wide glass cards with milestone labels, and the next playable stage emits a continuous $2.2\text{s}$ breathing cyan halo.

- **AC-008 (Full Regression Preservation):**
  - Given the entire automated test suite (`flutter test`),
  - When executed,
  - Then all 157 existing tests pass with 100% success rate and zero analyzer issues (`flutter analyze`).

---

## 6. Test Automation Strategy & Testing Seams

### 6.1 Testing Seams
1. **Theme & Token Seam:** Unit tests asserting `GlassTokens` values, color constants, and alpha thresholds.
2. **Component Widget Seams:**
   - `test/widgets/glass_container_test.dart`: Verifies blur sigma, border gradient rendering, and `enableLiveBlur` toggle.
   - `test/widgets/glass_pill_button_test.dart`: Simulates pointer down/up events to verify scale controller values and `onTap` firing.
3. **Screen Widget Seams:**
   - `test/screens/menu_screen_test.dart`: Validates brand header, glass sandbox nozzle, PLAY pill navigation, and CLEAR button.
   - `test/screens/level_select_screen_test.dart`: Validates 4 Act titles, Bento Grid 1x1 and 2x1 tiles, and Quick-Jump scroll navigation.
   - `test/screens/game_screen_test.dart`: Validates diegetic HUD keys (`hud_reset`, `hud_pause`), chamber indicators, and modal pause overlay.

---

## 7. Project Structure & Commands

### 7.1 Component Placement
```text
micin_micin/lib/
├── core/
│   ├── theme.dart                   # Add GlassTokens & update AppTheme
│   └── constants.dart
├── widgets/
│   ├── glass_container.dart         # New reusable frosted glass container
│   ├── glass_pill_button.dart       # New tactile glass action button
│   ├── pause_overlay.dart           # Overhaul to Glassmorphic Blur
│   └── level_complete_dialog.dart   # Overhaul to Ambient Golden Glass
└── screens/
    ├── menu/menu_screen.dart        # Overhaul to Glass Sandbox
    ├── level_select/
    │   ├── level_select_screen.dart # Overhaul to Glass Bento Grid
    │   └── level_button.dart        # Overhaul to Glass Pebble
    └── game/
        ├── game_hud.dart            # Overhaul to Diegetic Glass Chips
        └── game_screen.dart         # Glass overlay orchestration
```

### 7.2 Execution Commands
- **Run Tests:** `flutter test`
- **Run Static Analysis:** `flutter analyze`
- **Run Application Locally:** `flutter run`

---

## 8. Code Style & Conventions

```dart
// Concrete Implementation Pattern for Tactile Glass Pill Button
class _GlassPillButtonState extends State<GlassPillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.92)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.92, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.00)
            .chain(CurveTween(curve: Curves.easeOutSine)),
        weight: 30,
      ),
    ]).animate(_scaleController);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent _) {
    _scaleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: GlassContainer(
            borderRadius: GlassTokens.radiusPill,
            blurSigma: GlassTokens.blurStandard,
            backgroundColor: widget.isPrimary
                ? GlassTokens.surfaceElevated
                : GlassTokens.surfaceLight,
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                GlassTokens.borderHighlight,
                GlassTokens.borderShadow,
              ],
            ),
            padding: widget.padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: GoogleFonts.outfit(
                    color: GlassTokens.textSpecular,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 9. Implementation Boundaries

### Three-Tier Guardrails:
- **Always do:**
  - Preserve all existing widget keys and test text finders so existing tests stay 100% green.
  - Wrap any `BackdropFilter` inside a `RepaintBoundary` to prevent unnecessary raster cache invalidation.
  - Adhere to the Dual Glass Pipeline: use Mode B pre-composited gradients for in-game HUDs over active particles.
  - Run `flutter test` and `flutter analyze` after every code modification.
- **Ask first:**
  - Changing any sound assets, audio bus hierarchy, or audio volume mappings.
  - Modifying the level JSON asset coordinates or quota calculations.
- **Never do:**
  - Introduce an ink gauge, ink capacity limit, or stroke cost (violates the core zen puzzle mechanics).
  - Add third-party UI dependencies (e.g. external blur packages); use Flutter standard framework components.
  - Remove, skip (`.skip`), or weaken existing unit/widget test assertions.

---

## 10. Rationale, Context & Architecture Decisions (ADRs)

- **ADR-0002 (Unified Virtual Resolution):** Preserves the fixed $400 \times 700$ coordinate system. All glass screens and HUD overlays adapt responsively via letterboxing without breaking physics determinism.
- **ADR-0003 (Discrete Column Heightmap Sand Piling):** Target cup vessels maintain authentic granular sand accumulation. The glassmorphism overhaul updates vessel styling to beveled frosted glass with neon aperture glowing rims without altering heightmap calculations.
- **Performance Trade-Off (Dual Glass Pipeline):** Full-screen live backdrop filters during 500-particle physics ticks cost 4–8ms of GPU raster time on budget mobile GPUs. By restricting live `BackdropFilter` to stationary menus and modal overlays and using pre-composited gradient glass for the in-game HUD, we guarantee solid 60/120 FPS across all devices.

---

## 11. Dependencies & External Integrations

### External Systems
- **None**: Game is 100% offline and standalone.

### Third-Party Libraries
- `google_fonts: ^6.2.1`: Bundled offline `Outfit` font weights.
- `flutter_riverpod: ^2.6.1`: State management across progress and audio.
- `go_router: ^14.6.0`: Declarative screen navigation and scene crossfades.
- `audioplayers: ^6.1.0`: Hierarchical sound mixing and stem layering.

---

## 12. Examples & Edge Cases

### Edge Case 1: Ultra-Fast Rapid Tapping
- If players spam a `GlassPillButton`, `_scaleController.forward(from: 0.0)` restarts cleanly without accumulation or visual jitter.

### Edge Case 2: Notch and Dynamic Island Displays
- The in-game `GameHud` is bounded inside `SafeArea`, ensuring that the Top-Left chamber numeral and Top-Right action glyphs are never clipped by display cutouts.

### Edge Case 3: Canvas Drag vs Button Tap Discrimination
- If a user starts drawing a barrier near a HUD button, the movement threshold discriminator ($>4.0\text{ px}$) directs the touch event to the `LineController` rather than triggering button activation.

---

## 13. Validation Criteria

1. `flutter analyze` produces **0 errors, 0 warnings, and 0 lints**.
2. `flutter test` completes with **100% pass rate** across all test suites.
3. UI components render smoothly without visible lag or dropped frames on 60/120Hz displays.
4. Glassmorphism styling (frosted surfaces, 1px gradient borders, neon accents) visually matches the design specifications.

---

## 14. Related Specifications & Upstream Documents

- Canonical GDD: [docs/gdd/GDD-modern-glassmorphism-ui-overhaul.md](file:///d:/kayzz/flutter/micin/docs/gdd/GDD-modern-glassmorphism-ui-overhaul.md)
- Discovery Draft: [docs/discovery-draft-20261005-glassmorphism-ui-overhaul.md](file:///d:/kayzz/flutter/micin/docs/discovery-draft-20261005-glassmorphism-ui-overhaul.md)
- Living Architecture Map: [docs/ARCHITECTURE.md](file:///d:/kayzz/flutter/micin/docs/ARCHITECTURE.md)
- Domain Glossary: [CONTEXT.md](file:///d:/kayzz/flutter/micin/CONTEXT.md)
