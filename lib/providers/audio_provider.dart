import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/audio_manager.dart';

/// Global provider exposing the single [AudioManager] instance.
final audioManagerProvider = Provider<AudioManager>((ref) {
  final manager = AudioManager();
  ref.onDispose(() => manager.dispose());
  return manager;
});

/// Reactive provider for master bus gain in decibels.
final masterGainDbProvider = StateProvider<double>((ref) {
  final manager = ref.watch(audioManagerProvider);
  return manager.masterBus.gainDb;
});

/// Reactive provider for music bus gain in decibels.
final musicGainDbProvider = StateProvider<double>((ref) {
  final manager = ref.watch(audioManagerProvider);
  return manager.musicBus.gainDb;
});

/// Reactive provider for SFX bus gain in decibels.
final sfxGainDbProvider = StateProvider<double>((ref) {
  final manager = ref.watch(audioManagerProvider);
  return manager.sfxBus.gainDb;
});

/// Reactive provider for interaction bus gain in decibels.
final interactionGainDbProvider = StateProvider<double>((ref) {
  final manager = ref.watch(audioManagerProvider);
  return manager.interactionBus.gainDb;
});
