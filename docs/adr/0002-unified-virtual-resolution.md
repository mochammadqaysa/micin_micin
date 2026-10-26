# 0002 - Unified Virtual Resolution (400x700) and Calibrated Gravity

**Date:** 2026-09-07  
**Status:** Accepted  

## Context
The game previously ran in a fragmented coordinate space where physics particles, target cups, and emitters were defined in normalized coordinates `[0.0 .. 1.0]`, while player touch inputs were recorded in device logical pixels (e.g., `200px .. 800px`). This discrepancy caused player-drawn barriers to completely miss particles in the physics engine, allowing particles to penetrate lines and enter cups. Furthermore, applying an unscaled gravity acceleration ($g = 0.2$ screen heights per frame) caused particles to fall across the screen in just 3 frames (~50ms), producing an unnatural jumping visual artifact instead of a smooth granular stream.

## Decision
We establish a fixed Unified Virtual Resolution of $400 \times 700$ virtual pixels for all physics simulation, obstacle geometry, and touch input coordinates. Device screen touches are mapped bi-directionally into this virtual space using letterboxed scaling (`BoxFit.contain`), and gravity is calibrated to $g = 0.25 \text{ virtual px/frame}^2$ with terminal velocity $v_{\max} = 8.0 \text{ virtual px/frame}$.

## Consequences
All 30 levels and physics components operate deterministically on identical coordinate dimensions regardless of device screen size or DPI. Non-standard display aspect ratios display minimal letterboxing. Free-fall screen traversal increases from 3 frames (~50ms) to ~67 frames (~1.1s), restoring the authentic granular flow of the original game while ensuring 100% barrier collision impenetrability.
