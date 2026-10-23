import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/domain/utils/answer_encoding.dart';

void main() {
  // Same fixtures as functions/crossword/answer_encoding_test.py.
  final fixtures = jsonDecode(
    File('test/fixtures/answer_encoding.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final cases = (fixtures['cases'] as List).cast<Map<String, dynamic>>();

  test('matches the design doc fixture', () {
    expect(encodeAnswer('VAIKOM', 'kerala-history-0012', '2D'), 'PSQ7KiMs');
  });

  for (final c in cases) {
    final answer = c['answer'] as String;
    final puzzleId = c['puzzleId'] as String;
    final wordId = c['wordId'] as String;
    final answerEnc = c['answerEnc'] as String;

    test('encodes and decodes $answer like the server', () {
      expect(encodeAnswer(answer, puzzleId, wordId), answerEnc);
      expect(decodeAnswer(answerEnc, puzzleId, wordId), answer);
    });
  }
}
