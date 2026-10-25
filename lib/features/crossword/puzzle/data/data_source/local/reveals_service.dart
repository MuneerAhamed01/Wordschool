import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordshool/core/resorces/data_guard.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/core/utils/json_read.dart';
import 'package:wordshool/features/crossword/puzzle/data/data_source/reveals_service.dart';

class RevealsDataSourceImpl extends RevealsDataSource {
  RevealsDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  static String _key(String puzzleId) => 'crossword.reveals.$puzzleId';

  @override
  Future<DataState<({List<int> cells, List<String> wordIds})>> getReveals(
      String puzzleId) {
    return guardData('Reveals.getReveals', () async {
      final raw = _prefs.getString(_key(puzzleId));
      if (raw == null) return (cells: <int>[], wordIds: <String>[]);
      final json = asMap(jsonDecode(raw));
      final cells = json['cells'] is List ? json['cells'] as List : const [];
      return (
        cells: cells.whereType<int>().toList(),
        wordIds: asStringList(json['wordIds']),
      );
    });
  }

  @override
  Future<DataState<void>> saveReveals(
    String puzzleId, {
    required List<int> cells,
    required List<String> wordIds,
  }) {
    return guardData('Reveals.saveReveals', () async {
      if (cells.isEmpty && wordIds.isEmpty) return;
      await _prefs.setString(
          _key(puzzleId), jsonEncode({'cells': cells, 'wordIds': wordIds}));
    });
  }

  @override
  Future<DataState<void>> clearReveals(String puzzleId) {
    return guardData('Reveals.clearReveals', () async {
      await _prefs.remove(_key(puzzleId));
    });
  }
}
