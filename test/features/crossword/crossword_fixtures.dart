import 'dart:convert';
import 'dart:io';

import 'package:wordshool/features/crossword/shared/data/models/puzzle.dart';

/// Real-shaped docs in `test/fixtures/crossword/` (the example puzzle
/// `kerala-history-0012`, answers encoded by the server's encoder).
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/crossword/$name.json').readAsStringSync())
        as Map<String, dynamic>;

/// `{id, data}` fixture → `(data, id)`.
(Map<String, dynamic>, String) fixtureDoc(String name) {
  final json = fixture(name);
  return (json['data'] as Map<String, dynamic>, json['id'] as String);
}

CrosswordPuzzleModel examplePuzzle() {
  final (data, id) = fixtureDoc('puzzle');
  return CrosswordPuzzleModel.fromJson(data, documentId: id);
}

/// `solved`, `inProgress`, `completedWithTypo` letters strings.
final Map<String, String> exampleLetters =
    fixture('letters').map((k, v) => MapEntry(k, v as String));
