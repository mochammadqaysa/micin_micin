import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:micin_micin/audio/audio_bus.dart';
import 'package:micin_micin/audio/audio_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(ReleaseMode.loop);
    registerFallbackValue(AssetSource('audio/sugar_song.mp3'));
    registerFallbackValue(AssetSource('audio/ok_sound.mp3'));
  });

  late MockAudioPlayer mockBgmPlayer;
  late MockAudioPlayer mockChimesPlayer;
  late MockAudioPlayer mockSfxPlayer;
  late MockAudioPlayer mockInteractionPlayer;

  setUp(() {
    mockBgmPlayer = MockAudioPlayer();
    mockChimesPlayer = MockAudioPlayer();
    mockSfxPlayer = MockAudioPlayer();
    mockInteractionPlayer = MockAudioPlayer();

    for (final player in [mockBgmPlayer, mockChimesPlayer, mockSfxPlayer, mockInteractionPlayer]) {
      when(() => player.setReleaseMode(any())).thenAnswer((_) async {});
      when(() => player.play(any())).thenAnswer((_) async {});
      when(() => player.stop()).thenAnswer((_) async {});
      when(() => player.dispose()).thenAnswer((_) async {});
      when(() => player.setVolume(any())).thenAnswer((_) async {});
      when(() => player.setPlaybackRate(any())).thenAnswer((_) async {});
    }
  });

  group('AudioBus Unit Tests', () {
    test('computes effective gain in dB hierarchically from parent', () {
      final master = AudioBus(type: AudioBusType.master, name: 'Master', gainDb: -3.0);
      final music = AudioBus(type: AudioBusType.music, name: 'Music', parent: master, gainDb: -4.0);

      expect(master.effectiveGainDb, equals(-3.0));
      expect(music.effectiveGainDb, equals(-7.0));
    });

    test('mute on parent propagates effective silence (-80 dB) to children', () {
      final master = AudioBus(type: AudioBusType.master, name: 'Master', gainDb: -3.0);
      final sfx = AudioBus(type: AudioBusType.sfx, name: 'SFX', parent: master, gainDb: -2.0);

      expect(sfx.effectiveGainDb, equals(-5.0));
      expect(sfx.effectiveLinearVolume, closeTo(0.562, 0.01));

      master.isMuted = true;
      expect(sfx.effectiveGainDb, equals(-80.0));
      expect(sfx.effectiveLinearVolume, equals(0.0));
    });

    test('ducking offset attenuates effective gain without altering base gainDb', () {
      final master = AudioBus(type: AudioBusType.master, name: 'Master', gainDb: 0.0);
      final music = AudioBus(type: AudioBusType.music, name: 'Music', parent: master, gainDb: 0.0);

      music.duckingOffsetDb = -10.0;
      expect(music.gainDb, equals(0.0));
      expect(music.effectiveGainDb, equals(-10.0));
      expect(music.effectiveLinearVolume, closeTo(0.316, 0.01));

      music.duckingOffsetDb = 0.0;
      expect(music.effectiveGainDb, equals(0.0));
      expect(music.effectiveLinearVolume, equals(1.0));
    });

    test('dbToLinear and linearToDb accurate bidirectional math conversion', () {
      expect(AudioBus.dbToLinear(0.0), closeTo(1.0, 0.001));
      expect(AudioBus.dbToLinear(-6.0), closeTo(0.501, 0.01));
      expect(AudioBus.dbToLinear(-20.0), closeTo(0.1, 0.001));
      expect(AudioBus.dbToLinear(-80.0), equals(0.0));

      expect(AudioBus.linearToDb(1.0), closeTo(0.0, 0.001));
      expect(AudioBus.linearToDb(0.5), closeTo(-6.02, 0.05));
      expect(AudioBus.linearToDb(0.0), equals(-80.0));
    });
  });

  group('AudioManager Architecture Tests', () {
    test('initializes with default mixer bus configuration and headroom', () {
      final manager = AudioManager(
        bgmPlayer: mockBgmPlayer,
        chimesPlayer: mockChimesPlayer,
        sfxPlayer: mockSfxPlayer,
        interactionPlayers: [mockInteractionPlayer],
      );

      expect(manager.isMusicEnabled, isTrue);
      expect(manager.isSoundEnabled, isTrue);
      expect(manager.isInitialized, isFalse);

      expect(manager.masterBus.gainDb, equals(-3.0));
      expect(manager.musicBus.gainDb, equals(-4.0));
      expect(manager.sfxBus.gainDb, equals(-2.0));
      expect(manager.interactionBus.gainDb, equals(-4.0));
    });

    test('init() sets initialized status and configures looping on bgm player', () async {
      final manager = AudioManager(
        bgmPlayer: mockBgmPlayer,
        chimesPlayer: mockChimesPlayer,
        sfxPlayer: mockSfxPlayer,
        interactionPlayers: [mockInteractionPlayer],
      );
      await manager.init();

      expect(manager.isInitialized, isTrue);
      verify(() => mockBgmPlayer.setReleaseMode(ReleaseMode.loop)).called(1);
    });

    test('playBgm() plays authentic sugar_song.mp3 in loop', () async {
      final manager = AudioManager(
        bgmPlayer: mockBgmPlayer,
        chimesPlayer: mockChimesPlayer,
        sfxPlayer: mockSfxPlayer,
        interactionPlayers: [mockInteractionPlayer],
      );
      await manager.init();

      await manager.playBgm();
      verify(() => mockBgmPlayer.play(any(
        that: isA<AssetSource>().having((s) => s.path, 'path', 'audio/sugar_song.mp3'),
      ))).called(1);
    });

    test('toggleMusic() flips music state and mutes music bus', () {
      final manager = AudioManager(
        bgmPlayer: mockBgmPlayer,
        chimesPlayer: mockChimesPlayer,
        sfxPlayer: mockSfxPlayer,
        interactionPlayers: [mockInteractionPlayer],
      );
      expect(manager.isMusicEnabled, isTrue);

      manager.toggleMusic();
      expect(manager.isMusicEnabled, isFalse);
      expect(manager.musicBus.isMuted, isTrue);
      verify(() => mockBgmPlayer.stop()).called(1);

      manager.toggleMusic();
      expect(manager.isMusicEnabled, isTrue);
      expect(manager.musicBus.isMuted, isFalse);
      verify(() => mockBgmPlayer.play(any())).called(1);
    });

    test('toggleSound() flips sound state and mutes sfx and interaction buses', () {
      final manager = AudioManager(
        bgmPlayer: mockBgmPlayer,
        chimesPlayer: mockChimesPlayer,
        sfxPlayer: mockSfxPlayer,
        interactionPlayers: [mockInteractionPlayer],
      );
      expect(manager.isSoundEnabled, isTrue);

      manager.toggleSound();
      expect(manager.isSoundEnabled, isFalse);
      expect(manager.sfxBus.isMuted, isTrue);
      expect(manager.interactionBus.isMuted, isTrue);

      manager.toggleSound();
      expect(manager.isSoundEnabled, isTrue);
      expect(manager.sfxBus.isMuted, isFalse);
      expect(manager.interactionBus.isMuted, isFalse);
    });

    test('updateProgress() updates progress ratio clamp in Option A', () async {
      final manager = AudioManager(
        bgmPlayer: mockBgmPlayer,
        chimesPlayer: mockChimesPlayer,
        sfxPlayer: mockSfxPlayer,
        interactionPlayers: [mockInteractionPlayer],
      );
      await manager.init();

      await manager.updateProgress(0.0);
      expect(manager.currentProgressRatio, equals(0.0));

      await manager.updateProgress(0.65);
      expect(manager.currentProgressRatio, equals(0.65));

      await manager.updateProgress(1.5);
      expect(manager.currentProgressRatio, equals(1.0));
    });

    test('playSfx(SoundType.levelComplete) plays ok_sound.mp3 with ducking', () async {
      final manager = AudioManager(
        bgmPlayer: mockBgmPlayer,
        chimesPlayer: mockChimesPlayer,
        sfxPlayer: mockSfxPlayer,
        interactionPlayers: [mockInteractionPlayer],
      );
      await manager.init();

      await manager.playSfx(SoundType.levelComplete);
      verify(() => mockSfxPlayer.play(any(
        that: isA<AssetSource>().having((s) => s.path, 'path', 'audio/ok_sound.mp3'),
      ))).called(1);
    });

    test('playParticleCapture() triggers pentatonic pitch scaling', () async {
      final manager = AudioManager(
        bgmPlayer: mockBgmPlayer,
        chimesPlayer: mockChimesPlayer,
        sfxPlayer: mockSfxPlayer,
        interactionPlayers: [mockInteractionPlayer],
      );
      await manager.init();

      await manager.playParticleCapture(fillPercentage: 0.2);
      verify(() => mockInteractionPlayer.setPlaybackRate(any())).called(1);
      verify(() => mockInteractionPlayer.play(any())).called(1);
    });

    test('playFilterResonance() plays resonant frequency keyed to filter color', () async {
      final manager = AudioManager(
        bgmPlayer: mockBgmPlayer,
        chimesPlayer: mockChimesPlayer,
        sfxPlayer: mockSfxPlayer,
        interactionPlayers: [mockInteractionPlayer],
      );
      await manager.init();

      await manager.playFilterResonance(filterColor: const Color(0xFF70C1B3));
      verify(() => mockInteractionPlayer.setPlaybackRate(any())).called(1);
      verify(() => mockInteractionPlayer.play(any())).called(1);
    });

    test('sidechain ducking applies and releases volume attenuation', () {
      final manager = AudioManager(
        bgmPlayer: mockBgmPlayer,
        chimesPlayer: mockChimesPlayer,
        sfxPlayer: mockSfxPlayer,
        interactionPlayers: [mockInteractionPlayer],
      );

      manager.duckMusic(active: true, duckDb: -10.0);
      expect(manager.musicBus.duckingOffsetDb, equals(-10.0));

      manager.duckMusic(active: false);
      expect(manager.musicBus.duckingOffsetDb, equals(0.0));
    });

    test('playSfx executes safely for all SoundType values', () async {
      final manager = AudioManager(
        bgmPlayer: mockBgmPlayer,
        chimesPlayer: mockChimesPlayer,
        sfxPlayer: mockSfxPlayer,
        interactionPlayers: [mockInteractionPlayer],
      );
      await manager.init();

      for (final type in SoundType.values) {
        await manager.playSfx(type);
      }

      verify(() => mockSfxPlayer.play(any())).called(SoundType.values.length);
    });

    test('dispose cleans up all audio players cleanly', () {
      final manager = AudioManager(
        bgmPlayer: mockBgmPlayer,
        chimesPlayer: mockChimesPlayer,
        sfxPlayer: mockSfxPlayer,
        interactionPlayers: [mockInteractionPlayer],
      );

      manager.dispose();
      verify(() => mockBgmPlayer.dispose()).called(1);
      verify(() => mockChimesPlayer.dispose()).called(1);
      verify(() => mockSfxPlayer.dispose()).called(1);
      verify(() => mockInteractionPlayer.dispose()).called(1);
    });
  });
}
