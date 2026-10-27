import 'dart:ui' as ui;
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';

/// Preloads and caches pixel art sprite assets for [MicinGame].
///
/// Wraps Flame's [Images] cache with null-safe synchronous accessors
/// and graceful procedural fallback for headless test environments.
class PixelSprites {
  PixelSprites._();

  static const String cupPath = 'vessels/cup_pixel.png';
  static const String emitterPath = 'emitters/emitter_pixel.png';
  static const String filterPath = 'gates/filter_pixel.png';
  static const String gravityPath = 'gates/gravity_pixel.png';
  static const String terrainPath = 'terrain/terrain_pixel.png';

  // Animated Spritesheets
  static const String emitterSheetPath = 'spritesheets/emitter_strip6.png';
  static const String vortexSheetPath = 'spritesheets/vortex_strip6.png';
  static const String cupSheetPath = 'spritesheets/cup_strip8.png';
  static const String filterSheetPath = 'spritesheets/filter_strip6.png';
  static const String zenLogoPath = 'spritesheets/zen_pixel_logo.png';

  static bool _isLoaded = false;
  static bool get isLoaded => _isLoaded;

  /// Loads all pixel art sprites and spritesheets into Flame's image cache.
  static Future<void> loadAll() async {
    try {
      await Future.wait([
        Flame.images.load(cupPath),
        Flame.images.load(emitterPath),
        Flame.images.load(filterPath),
        Flame.images.load(gravityPath),
        Flame.images.load(terrainPath),
        Flame.images.load(emitterSheetPath),
        Flame.images.load(vortexSheetPath),
        Flame.images.load(cupSheetPath),
        Flame.images.load(filterSheetPath),
        Flame.images.load(zenLogoPath),
      ]);
      _isLoaded = true;
    } catch (e) {
      // In headless unit tests or environments without asset bundle,
      // silently retain _isLoaded = false to enable procedural fallback.
      debugPrint('PixelSprites.loadAll skipped/fallback: $e');
    }
  }

  /// Synchronously retrieves the target cup image from cache, or null if unloaded.
  static ui.Image? get cup {
    try {
      return Flame.images.fromCache(cupPath);
    } catch (_) {
      return null;
    }
  }

  /// Synchronously retrieves the emitter funnel image from cache, or null if unloaded.
  static ui.Image? get emitter {
    try {
      return Flame.images.fromCache(emitterPath);
    } catch (_) {
      return null;
    }
  }

  /// Synchronously retrieves the color filter gate image from cache, or null if unloaded.
  static ui.Image? get filter {
    try {
      return Flame.images.fromCache(filterPath);
    } catch (_) {
      return null;
    }
  }

  /// Synchronously retrieves the gravity vortex switch image from cache, or null if unloaded.
  static ui.Image? get gravity {
    try {
      return Flame.images.fromCache(gravityPath);
    } catch (_) {
      return null;
    }
  }

  /// Synchronously retrieves the terrain texture image from cache, or null if unloaded.
  static ui.Image? get terrain {
    try {
      return Flame.images.fromCache(terrainPath);
    } catch (_) {
      return null;
    }
  }

  /// Synchronously retrieves the 6-frame bamboo water spout spritesheet, or null if unloaded.
  static ui.Image? get emitterSheet {
    try {
      return Flame.images.fromCache(emitterSheetPath);
    } catch (_) {
      return null;
    }
  }

  /// Synchronously retrieves the 6-frame Yin-Yang vortex spritesheet, or null if unloaded.
  static ui.Image? get vortexSheet {
    try {
      return Flame.images.fromCache(vortexSheetPath);
    } catch (_) {
      return null;
    }
  }

  /// Synchronously retrieves the 8-frame tsukubai ripple spritesheet, or null if unloaded.
  static ui.Image? get cupSheet {
    try {
      return Flame.images.fromCache(cupSheetPath);
    } catch (_) {
      return null;
    }
  }

  /// Synchronously retrieves the 6-frame Torii prism glow spritesheet, or null if unloaded.
  static ui.Image? get filterSheet {
    try {
      return Flame.images.fromCache(filterSheetPath);
    } catch (_) {
      return null;
    }
  }

  /// Synchronously retrieves the Zen Pixel logo banner, or null if unloaded.
  static ui.Image? get zenLogo {
    try {
      return Flame.images.fromCache(zenLogoPath);
    } catch (_) {
      return null;
    }
  }

  /// Clears cached state (primarily for testing).
  static void clear() {
    _isLoaded = false;
  }
}
