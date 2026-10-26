# 0001 - Geometric Collision Detection vs Pixel Sampling

**Date:** 2026-09-07  
**Status:** Accepted  

## Context
The original Sugar Sugar ActionScript 3 (Flash Player 10) game implementation relies on bitmap pixel-sampling (`BitmapData.getPixel()`) on the canvas buffer to detect collisions between falling sugar particles and drawn lines or cups. In Flutter, rendering is handled declaratively via `CustomPainter`, which does not expose rendered pixel buffers to the CPU without asynchronous and prohibitively expensive `toImage()` raster calls that would destroy 60fps frame budgets.

## Decision
We choose geometric segment distance calculation (`distanceTo` from particle center to line segments and Axis-Aligned Bounding Box containment for cups) instead of pixel-sampling or importing heavy external game engines (e.g., Flame/Forge2D).

## Consequences
Collision testing is completely deterministic, CPU-bound, headless testable in pure Dart unit tests, and maintains 60fps performance without frame drops. As a trade-off, drawn lines must be decomposed into linear segments (`LineSegment`), and sub-5px line segments must be handled carefully to avoid degenerate geometry.
