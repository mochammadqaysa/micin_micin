import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Generates calibrated 16-bit 44.1kHz PCM WAV audio assets for Micin Micin.
///
/// Produces:
/// - `particle_ping.wav`: Warm, crystalline kalimba ping with natural exponential decay.
/// - `filter_pass.wav`: Resonant crystal bowl shimmer with gentle harmonic beating.
/// - `chimes_loop.wav`: Ambient pentatonic chime texture for vertical adaptive layering.
void main() {
  final outputDir = Directory('assets/audio');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  stdout.writeln('Generating Zen relaxation audio assets...');

  // 1. Particle Ping (280ms, 523.25 Hz - C5, kalimba harmonic pluck)
  _generateWav(
    filename: 'assets/audio/particle_ping.wav',
    durationSeconds: 0.28,
    sampleRate: 44100,
    synthesizer: (t, total) {
      final env = math.exp(-t * 16.0); // Natural fast exponential decay
      // Fundamental C5 (523.25 Hz) + soft 2nd & 3rd harmonics
      final f = 523.25;
      final wave = 0.70 * math.sin(2 * math.pi * f * t) +
          0.20 * math.sin(2 * math.pi * f * 2.0 * t) +
          0.10 * math.sin(2 * math.pi * f * 3.0 * t);
      return wave * env * 0.75;
    },
  );

  // 2. Filter Pass (450ms, resonant crystal bowl shimmer)
  _generateWav(
    filename: 'assets/audio/filter_pass.wav',
    durationSeconds: 0.45,
    sampleRate: 44100,
    synthesizer: (t, total) {
      final attack = (t / 0.05).clamp(0.0, 1.0);
      final decay = math.exp(-t * 6.5);
      final env = attack * decay;
      // Dual detuned sines creating pleasant acoustic chorusing / shimmer
      final f1 = 659.25; // E5
      final f2 = 661.50; // Detuned beat
      final f3 = 1318.5; // E6 sparkle
      final wave = 0.55 * math.sin(2 * math.pi * f1 * t) +
          0.30 * math.sin(2 * math.pi * f2 * t) +
          0.15 * math.sin(2 * math.pi * f3 * t);
      return wave * env * 0.70;
    },
  );

  // 3. Chimes Loop (4.0s, gentle pentatonic chimes over warm drone bed)
  _generateWav(
    filename: 'assets/audio/chimes_loop.wav',
    durationSeconds: 4.0,
    sampleRate: 44100,
    synthesizer: (t, total) {
      double sample = 0.0;
      // Pentatonic notes timed across 4 seconds: C5, E5, G5, A5, C6
      final notes = [
        {'time': 0.2, 'freq': 523.25}, // C5
        {'time': 1.1, 'freq': 659.25}, // E5
        {'time': 1.9, 'freq': 783.99}, // G5
        {'time': 2.7, 'freq': 880.00}, // A5
        {'time': 3.4, 'freq': 1046.50}, // C6
      ];

      for (final note in notes) {
        final startTime = note['time']!;
        final freq = note['freq']!;
        if (t >= startTime) {
          final dt = t - startTime;
          final env = math.exp(-dt * 4.5) * (dt < 0.01 ? dt / 0.01 : 1.0);
          sample += 0.22 * math.sin(2 * math.pi * freq * dt) * env;
        }
      }

      // Smooth loop crossfade envelope at edges
      final edgeFade = math.sin(math.pi * (t / total)).clamp(0.0, 1.0);
      return sample * edgeFade * 0.70;
    },
  );

  // 4. Button Click (40ms, tactile bamboo woodblock click)
  _generateWav(
    filename: 'assets/audio/click.wav',
    durationSeconds: 0.040,
    sampleRate: 44100,
    synthesizer: (t, total) {
      final env = math.exp(-t * 110.0); // Fast organic decay
      final f = 880.0; // A5 fundamental
      final wave = 0.65 * math.sin(2 * math.pi * f * t) +
          0.25 * math.sin(2 * math.pi * 2200.0 * t);
      return wave * env * 0.70;
    },
  );

  // 5. Gravity Invert (500ms, singing bell pitch swell)
  _generateWav(
    filename: 'assets/audio/gravity_invert.wav',
    durationSeconds: 0.500,
    sampleRate: 44100,
    synthesizer: (t, total) {
      final env = math.pow(math.sin(math.pi * (t / total)), 1.5).toDouble();
      final freq = 220.0 + (440.0 - 220.0) * math.pow(t / total, 1.2);
      final wave = 0.60 * math.sin(2 * math.pi * freq * t) +
          0.25 * math.sin(4 * math.pi * freq * t) +
          0.15 * math.sin(math.pi * freq * t);
      return wave * env * 0.75;
    },
  );

  // 6. Level Reset (280ms, soft water ripple / sand rake sweep)
  _generateWav(
    filename: 'assets/audio/level_reset.wav',
    durationSeconds: 0.280,
    sampleRate: 44100,
    synthesizer: (t, total) {
      final env = math.exp(-t * 12.0) * math.sin(math.pi * (t / 0.04).clamp(0.0, 1.0));
      final fWater1 = 440.0 * (1.0 + 0.5 * math.sin(2 * math.pi * 12.0 * t));
      final fWater2 = 880.0 * math.exp(-t * 8.0);
      final wave = 0.55 * math.sin(2 * math.pi * fWater1 * t) +
          0.35 * math.sin(2 * math.pi * fWater2 * t);
      return wave * env * 0.65;
    },
  );

  // 7. Level Complete (2.2s, celestial meditation chime chord progression)
  _generateWav(
    filename: 'assets/audio/level_complete.wav',
    durationSeconds: 2.20,
    sampleRate: 44100,
    synthesizer: (t, total) {
      double sample = 0.0;
      // Warm root drone (C3 + G3)
      final envDrone = math.exp(-t * 1.8) * (t / 0.05).clamp(0.0, 1.0);
      sample += (0.25 * math.sin(2 * math.pi * 130.81 * t) +
          0.20 * math.sin(2 * math.pi * 196.00 * t)) * envDrone;

      // Arpeggiated celestial resolution chimes: C5, E5, G5, B5, D6, C6
      final chords = [
        {'time': 0.00, 'freq': 523.25, 'amp': 0.35}, // C5
        {'time': 0.12, 'freq': 659.25, 'amp': 0.35}, // E5
        {'time': 0.24, 'freq': 783.99, 'amp': 0.40}, // G5
        {'time': 0.36, 'freq': 987.77, 'amp': 0.35}, // B5
        {'time': 0.48, 'freq': 1174.66, 'amp': 0.45},// D6
        {'time': 0.60, 'freq': 1046.50, 'amp': 0.40},// C6
      ];

      for (final chord in chords) {
        final startTime = chord['time']!;
        final freq = chord['freq']!;
        final amp = chord['amp']!;
        if (t >= startTime) {
          final dt = t - startTime;
          final env = math.exp(-dt * 2.2) * (dt < 0.008 ? dt / 0.008 : 1.0);
          final chime = (0.70 * math.sin(2 * math.pi * freq * dt) +
              0.20 * math.sin(2 * math.pi * freq * 2.0 * dt) +
              0.10 * math.sin(2 * math.pi * freq * 3.0 * dt)) * env * amp;
          sample += chime;
        }
      }
      return sample * 0.85;
    },
  );

  stdout.writeln('Zen audio assets generated successfully in assets/audio/.');
}

void _generateWav({
  required String filename,
  required double durationSeconds,
  required int sampleRate,
  required double Function(double t, double totalDuration) synthesizer,
}) {
  final numSamples = (durationSeconds * sampleRate).toInt();
  final byteData = ByteData(44 + numSamples * 2);

  // RIFF Header
  byteData.setUint8(0, 0x52); // 'R'
  byteData.setUint8(1, 0x49); // 'I'
  byteData.setUint8(2, 0x46); // 'F'
  byteData.setUint8(3, 0x46); // 'F'
  byteData.setUint32(4, 36 + numSamples * 2, Endian.little);
  byteData.setUint8(8, 0x57);  // 'W'
  byteData.setUint8(9, 0x41);  // 'A'
  byteData.setUint8(10, 0x56); // 'V'
  byteData.setUint8(11, 0x45); // 'E'

  // Format chunk ('fmt ')
  byteData.setUint8(12, 0x66); // 'f'
  byteData.setUint8(13, 0x6D); // 'm'
  byteData.setUint8(14, 0x74); // 't'
  byteData.setUint8(15, 0x20); // ' '
  byteData.setUint32(16, 16, Endian.little); // Subchunk1Size
  byteData.setUint16(20, 1, Endian.little);  // PCM format
  byteData.setUint16(22, 1, Endian.little);  // Mono channel
  byteData.setUint32(24, sampleRate, Endian.little);
  byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate (16-bit mono)
  byteData.setUint16(32, 2, Endian.little);  // BlockAlign
  byteData.setUint16(34, 16, Endian.little); // BitsPerSample

  // Data chunk ('data')
  byteData.setUint8(36, 0x64); // 'd'
  byteData.setUint8(37, 0x61); // 'a'
  byteData.setUint8(38, 0x74); // 't'
  byteData.setUint8(39, 0x61); // 'a'
  byteData.setUint32(40, numSamples * 2, Endian.little);

  // PCM Sample Data
  int offset = 44;
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final val = synthesizer(t, durationSeconds).clamp(-1.0, 1.0);
    final pcmSample = (val * 32767.0).toInt().clamp(-32768, 32767);
    byteData.setInt16(offset, pcmSample, Endian.little);
    offset += 2;
  }

  final file = File(filename);
  file.writeAsBytesSync(byteData.buffer.asUint8List());
  stdout.writeln('-> Wrote $filename (${file.lengthSync()} bytes)');
}
