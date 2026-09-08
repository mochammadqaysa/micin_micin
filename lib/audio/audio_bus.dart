import 'dart:math' as math;

/// Available audio bus channels within the Micin Micin mixer hierarchy.
enum AudioBusType {
  master,
  music,
  ambience,
  sfx,
  interaction,
}

/// A node in the hierarchical audio mixing graph.
///
/// Controls gain in logarithmic decibels (dB), ducking attenuation, and mute states.
/// Computes effective linear volume (`0.0` to `1.0`) for underlying [AudioPlayer]s.
class AudioBus {
  final AudioBusType type;
  final String name;
  final AudioBus? parent;

  double _gainDb;
  double _duckingOffsetDb = 0.0;

  /// Whether this specific bus is muted.
  bool isMuted;

  AudioBus({
    required this.type,
    required this.name,
    this.parent,
    double gainDb = 0.0,
    this.isMuted = false,
  }) : _gainDb = gainDb.clamp(-80.0, 6.0);

  /// Base gain configured for this bus in decibels (typically -80.0 dB to +6.0 dB).
  double get gainDb => _gainDb;
  set gainDb(double value) {
    _gainDb = value.clamp(-80.0, 6.0);
  }

  /// Transient attenuation applied via sidechain ducking in dB (typically negative or 0.0).
  double get duckingOffsetDb => _duckingOffsetDb;
  set duckingOffsetDb(double value) {
    _duckingOffsetDb = value.clamp(-80.0, 0.0);
  }

  /// Cumulative effective gain in dB, taking parent hierarchy and ducking into account.
  ///
  /// Returns `-80.0` (effective silence) if this bus or any parent ancestor is muted.
  double get effectiveGainDb {
    if (isMuted || (parent != null && parent!.isMuted)) {
      return -80.0;
    }
    final parentContribution = parent?.effectiveGainDb ?? 0.0;
    return (_gainDb + _duckingOffsetDb + parentContribution).clamp(-80.0, 6.0);
  }

  /// Effective linear volume in `[0.0, 1.0]` ready for `AudioPlayer.setVolume()`.
  double get effectiveLinearVolume => dbToLinear(effectiveGainDb);

  /// Converts a decibel gain value to linear amplitude `[0.0, 1.0]`.
  ///
  /// Assumes `-80.0 dB` or below corresponds to complete silence (`0.0`).
  static double dbToLinear(double db) {
    if (db <= -79.9) return 0.0;
    final linear = math.pow(10.0, db / 20.0).toDouble();
    return linear.clamp(0.0, 1.0);
  }

  /// Converts a linear amplitude `[0.0, 1.0]` to decibels (dB).
  ///
  /// Values $\le 0.0001$ map to `-80.0 dB`.
  static double linearToDb(double linear) {
    if (linear <= 0.0001) return -80.0;
    final db = 20.0 * (math.log(linear.clamp(0.0001, 1.0)) / math.ln10);
    return db.clamp(-80.0, 6.0);
  }
}
