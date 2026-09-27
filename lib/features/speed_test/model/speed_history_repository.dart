import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'speed_test_result.dart';

/// Keeps past speed test results in a JSON file in the app's support
/// directory, newest first.
class SpeedHistoryRepository {
  SpeedHistoryRepository({this.maxEntries = 50});

  final int maxEntries;
  File? _file;

  Future<File> _historyFile() async => _file ??= File(
    '${(await getApplicationSupportDirectory()).path}/speed_history.json',
  );

  /// Returns an empty list if nothing is saved yet or the file is unreadable.
  Future<List<SpeedTestResult>> load() async {
    try {
      final file = await _historyFile();
      if (!await file.exists()) return [];
      final entries = jsonDecode(await file.readAsString()) as List<Object?>;
      return [
        for (final entry in entries)
          SpeedTestResult.fromJson(entry as Map<String, Object?>),
      ];
    } on Object {
      return [];
    }
  }

  Future<void> save(List<SpeedTestResult> history) async {
    final file = await _historyFile();
    await file.parent.create(recursive: true);
    final kept = history.take(maxEntries).map((r) => r.toJson()).toList();
    await file.writeAsString(jsonEncode(kept), flush: true);
  }

  Future<void> clear() async {
    final file = await _historyFile();
    if (await file.exists()) await file.delete();
  }
}
