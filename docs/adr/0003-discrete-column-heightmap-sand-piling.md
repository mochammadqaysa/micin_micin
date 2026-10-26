# 0003 - Discrete Column Heightmap Sand Piling and Overflow Spilling

**Date:** 2026-09-07  
**Status:** Accepted  

## Context
Target Cups previously destroyed incoming particles upon entering a collision bounding box and rendered an artificial rising liquid rectangle. To authentically match the beloved tactile physics of Bart Bonte's *Sugar, Sugar*, particles must physically accumulate into a visible Sand Mound governed by a natural Angle of Repose ($\approx 35^\circ$), and overloaded cups must allow excess particles to spill over the rims.

## Decision
We explicitly decide to implement a 1D Discrete Column Heightmap (2.0 virtual pixels per bin) with one-step slope relaxation within each Target Cup, accompanied by a Color Selective Membrane at the cup's top aperture that deflects non-matching colored particles. We explicitly reject full $O(N^2)$ rigid-body particle-to-particle collision solvers and full 2D cellular automata grid allocation.

## Consequences
Achieves deterministic $O(1)$ settling and overflow computation per particle per frame, strictly maintaining the 60 FPS mobile performance envelope with 500 active granular particles. Target Cups transition from invisible bounding boxes into U-shaped containers with physical walls (left wall, floor, right wall), a pure countdown display, and realistic rim overflow spilling.

## Considered Options
- **Full Rigid-Body Particle-to-Particle Solvers (Box2D / Forge2D):** Rejected due to prohibitive $O(N^2)$ contact constraint solver overhead on 500 dynamic particles causing severe frame drops on mobile CPUs.
- **2D Cellular Automata (Falling Sand Grid):** Rejected due to additional 2D grid memory structures and iteration loops inside the Flutter render cycle when a 1D column heightmap produces visually indistinguishable sand mounds and spilling.
