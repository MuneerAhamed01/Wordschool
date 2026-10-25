import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/shared/domain/models/category.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/puzzle.dart';
import 'package:wordshool/features/admin/shared/domain/models/question.dart';
import 'package:wordshool/features/admin/shared/domain/models/results.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

const examplePuzzlePath =
    '.claude/skills/crossword-content/examples/kerala-history-0012.puzzle.json';

void main() {
  group('LocalizedText', () {
    test('leaves out an empty ml and trims', () {
      expect(const LocalizedText(en: ' Vaikom ', ml: ' ').toJson(),
          {'en': 'Vaikom'});
      expect(const LocalizedText(en: 'Vaikom', ml: 'വൈക്കം').toJson(),
          {'en': 'Vaikom', 'ml': 'വൈക്കം'});
      expect(LocalizedText.fromJson(null), LocalizedText.empty);
    });
  });

  group('AdminCategory', () {
    final json = {
      'id': 'kerala-history',
      'name': {'en': 'Kerala History'},
      'icon': 'history_edu',
      'color': '#538D4E',
      'order': 10.0,
      'isActive': true,
      'publishedPuzzleCount': 3,
      'lastPuzzleNumber': 5,
      'createdAt': '2026-10-23T10:00:00+00:00',
    };

    test('fromJson reads numbers sent as doubles', () {
      final category = AdminCategory.fromJson(json);
      expect(category.order, 10);
      expect(category.publishedPuzzleCount, 3);
      expect(category.subject, 'kerala_history');
    });

    test('toJson is the adminSaveCategory payload without counters', () {
      expect(AdminCategory.fromJson(json).toJson(), {
        'id': 'kerala-history',
        'name': {'en': 'Kerala History'},
        'icon': 'history_edu',
        'color': '#538D4E',
        'order': 10,
        'isActive': true,
      });
    });
  });

  group('AdminQuestion', () {
    final json = {
      'id': 'q1',
      'answer': 'VAIKOM',
      'answerDisplay': {'en': 'Vaikom', 'ml': 'വൈക്കം'},
      'clues': [
        {'en': 'Hard clue', 'level': 'hard'},
        {'en': 'Easy clue', 'level': 'easy'},
      ],
      'fact': {'en': 'Fact.'},
      'subject': 'kerala_history',
      'topic': 'renaissance',
      'examTags': ['ldc'],
      'difficulty': 'medium',
      'source': {'type': 'book', 'ref': 'TODO: page'},
      'status': 'verified',
      'usedInPuzzles': ['kerala-history-0001'],
      'updatedAt': '2026-10-23T10:00:00+00:00',
    };

    test('fromJson reads every field', () {
      final question = AdminQuestion.fromJson(json);
      expect(question.status, QuestionStatus.verified);
      expect(question.firstClue?.en, 'Easy clue');
      expect(question.source.isPlaceholder, isTrue);
      expect(question.updatedAt, DateTime.utc(2026, 10, 23, 10));
    });

    test('toJson leaves out server fields and an empty topic', () {
      final payload = AdminQuestion.fromJson({...json, 'topic': ''}).toJson();
      expect(payload.containsKey('status'), isFalse);
      expect(payload.containsKey('usedInPuzzles'), isFalse);
      expect(payload.containsKey('topic'), isFalse);
      expect(payload['id'], 'q1');
      expect(payload['clues'], [
        {'en': 'Hard clue', 'level': 'hard'},
        {'en': 'Easy clue', 'level': 'easy'},
      ]);
    });
  });

  group('AdminPuzzle', () {
    test('the example puzzle round-trips into the save payload', () {
      final json = jsonDecode(File(examplePuzzlePath).readAsStringSync())
          as Map<String, dynamic>;
      final puzzle = AdminPuzzle.fromJson(json);
      expect(puzzle.words, hasLength(7));
      expect(puzzle.words.first.direction, WordDirection.across);

      final payload = puzzle.toJson();
      expect(payload['id'], 'kerala-history-0012');
      expect(payload.containsKey('number'), isFalse);
      expect(payload.containsKey('status'), isFalse);
      final word = (payload['words'] as List).first as Map<String, dynamic>;
      expect(word['length'], 7);
      expect(word['answer'], 'MUZIRIS');
      expect(word['direction'], 'across');
    });

    test('summary reads status and publishAt', () {
      final summary = AdminPuzzleSummary.fromJson({
        'id': 'kerala-history-0001',
        'status': 'scheduled',
        'publishAt': '2026-11-01T00:00:00+05:30',
        'title': {'en': 'T'},
      });
      expect(summary.status, PuzzleStatus.scheduled);
      expect(summary.publishAt, DateTime.utc(2026, 10, 31, 18, 30));
    });
  });

  test('SaveResult.fromJson', () {
    final result = SaveResult.fromJson(
        {'id': 'kerala-history-0001', 'number': 1, 'created': true});
    expect(result.number, 1);
    expect(result.created, isTrue);
    expect(result.createdCategoryId, isNull);

    final question = SaveResult.fromJson({
      'id': 'q1',
      'created': true,
      'createdCategoryId': 'general-knowledge'
    });
    expect(question.createdCategoryId, 'general-knowledge');
  });

  test('enum wire values match functions/crossword/types.py', () {
    expect(PuzzleStatus.values.map((s) => s.value),
        ['draft', 'in_review', 'scheduled', 'published', 'archived']);
    expect(QuestionStatus.values.map((s) => s.value),
        ['draft', 'verified', 'retired']);
    expect(SourceType.values.map((s) => s.value),
        ['pyq', 'book', 'website', 'other']);
    expect(ReportReason.values.map((s) => s.value),
        ['wrong_answer', 'typo', 'other']);
  });
}
