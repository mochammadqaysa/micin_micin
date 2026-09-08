import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    stderr.writeln('coverage/lcov.info does not exist.');
    return;
  }

  final lines = file.readAsLinesSync();
  String currentFile = '';
  int engineFound = 0;
  int engineHit = 0;
  int modelsFound = 0;
  int modelsHit = 0;
  int totalFound = 0;
  int totalHit = 0;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).replaceAll(r'\', '/');
    } else if (line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      final hit = int.parse(parts[1]);

      totalFound++;
      if (hit > 0) totalHit++;

      if (currentFile.contains('lib/engine/')) {
        engineFound++;
        if (hit > 0) engineHit++;
      } else if (currentFile.contains('lib/models/')) {
        modelsFound++;
        if (hit > 0) modelsHit++;
      }
    }
  }

  final enginePct = engineFound > 0 ? (engineHit / engineFound * 100).toStringAsFixed(1) : '0';
  final modelsPct = modelsFound > 0 ? (modelsHit / modelsFound * 100).toStringAsFixed(1) : '0';
  final totalPct = totalFound > 0 ? (totalHit / totalFound * 100).toStringAsFixed(1) : '0';

  stdout.writeln('Engine Coverage: $enginePct% ($engineHit/$engineFound)');
  stdout.writeln('Models Coverage: $modelsPct% ($modelsHit/$modelsFound)');
  stdout.writeln('Total Repository Coverage: $totalPct% ($totalHit/$totalFound)');
}
