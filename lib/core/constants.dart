/// Global game constants for Micin Micin.
///
/// Derived from the original Sugar Sugar physics engine configuration
/// and technical clarification specifications.
library;


/// Fixed virtual canvas dimensions for Unified Virtual Resolution (ADR 0002).
const double kVirtualWidth = 400.0;
const double kVirtualHeight = 700.0;
const double kVirtualAspectRatio = kVirtualWidth / kVirtualHeight; // 4:7 ≈ 0.5714

/// Default gravity acceleration applied downwards per frame in virtual pixels (0.14 virtual px/frame²).
const double kGravityDefault = 0.14;

/// Particle radius in virtual pixels for collision and rendering.
const double kParticleRadius = 1.1;

/// Default line thickness in virtual pixels for player-drawn collision barriers.
const double kLineThickness = 5.0;

/// Normal restitution (bounce elasticity) for line segment collisions.
const double kLineRestitution = 0.3;

/// Tangential surface sliding friction for line segment collisions.
const double kLineFriction = 0.92;

/// Discrete column heightmap bin width in virtual pixels.
const double kHeightmapBinWidth = 2.0;

/// Maximum slope threshold before sand rolls to adjacent bin (tan(35°) * 2.0px ≈ 1.4px).
const double kReposeSlopeMax = 1.4;

/// Solid boundary wall thickness for target cups.
const double kCupWallThickness = 2.5;

/// Capacity of the reusable particle object pool to eliminate GC pauses.
const int kPoolCapacity = 500;

/// Target canvas aspect ratio (9:16 portrait).
const double kCanvasAspectRatio = 9.0 / 16.0;

/// Maximum allowable velocity magnitude along any axis to prevent tunneling (discrete collision tunneling).
const double kMaxSpeed = 4.8;

/// Total number of playable levels in the v1.0 release.
const int kTotalLevels = 30;

/// Key used to persist player progress in SharedPreferences (matches original Flash SharedObject).
const String kSharedPrefsKey = 'sugarshared';
