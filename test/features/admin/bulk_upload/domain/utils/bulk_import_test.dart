import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/puzzle.dart';
import 'package:wordshool/features/admin/shared/domain/models/question.dart';
import 'package:wordshool/features/admin/bulk_upload/domain/utils/bulk_import.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

const examples = '.claude/skills/crossword-content/examples';
String questionsExample() =>
    File('$examples/kerala-history.questions.json').readAsStringSync();
String puzzleExample() =>
    File('$examples/kerala-history-0012.puzzle.json').readAsStringSync();

AdminQuestion verified(String id, String answer,
        {String subject = 'kerala_history'}) =>
    AdminQuestion(
      id: id,
      answer: answer,
      answerDisplay: LocalizedText(en: answer),
      clues: const [QuestionClue(en: 'clue', level: Difficulty.easy)],
      fact: const LocalizedText(en: 'fact'),
      subject: subject,
      difficulty: Difficulty.easy,
      source: const QuestionSource(type: SourceType.book, ref: 'p. 1'),
      status: QuestionStatus.verified,
    );

AdminPuzzleSummary summary(String id, String title, PuzzleStatus status) =>
    AdminPuzzleSummary(
      id: id,
      categoryId: 'kerala-history',
      number: int.parse(id.split('-').last),
      title: LocalizedText(en: title),
      difficulty: Difficulty.medium,
      rows: 8,
      cols: 8,
      wordCount: 7,
      xpReward: 50,
      estimatedMinutes: 6,
      status: status,
    );

void main() {
  group('detectKind', () {
    test('by file type and content', () {
      expect(detectKind('q.csv', 'answer,fact_en'), ImportKind.questions);
      expect(detectKind('paste', 'answer\tfact_en'), ImportKind.questions);
      expect(detectKind('q.json', questionsExample()), ImportKind.questions);
      expect(detectKind('p.json', puzzleExample()), ImportKind.puzzles);
      expect(() => detectKind('x.json', '{"foo": 1}'),
          throwsA(isA<ImportFileError>()));
      expect(
          () => detectKind('x.json', '{oops'), throwsA(isA<ImportFileError>()));
    });
  });

  group('questions spreadsheet', () {
    test('the template parses into one valid question', () {
      final rows = parseQuestionsCsv(questionCsvTemplate());
      expect(rows, hasLength(1));
      expect(rows.single.problems, isEmpty);
      final q = rows.single.item!;
      expect(q.answer, 'VAIKOM');
      expect(q.answerDisplay.ml, 'വൈക്കം');
      expect(q.clues.map((c) => c.level), [Difficulty.easy, Difficulty.medium]);
      expect(q.examTags, ['ldc', 'lgs']);
      expect(q.source.type, SourceType.book);
      expect(q.toJson().containsKey('id'), isFalse);
    });

    test('missing columns are a file error', () {
      expect(() => parseQuestionsCsv('answer,clue_easy\nVaikom,x'),
          throwsA(isA<ImportFileError>()));
    });

    test('row problems are listed in plain words', () {
      const csv =
          'Answer,Clue Easy,Fact EN,Subject,Difficulty,Source Type,Source Ref\n'
          'വൈക്കം,,,Kerala History,very hard,magazine,\n';
      final row = parseQuestionsCsv(csv).single;
      expect(row.label, 'Row 2 · വൈക്കം');
      expect(
          row.problems.join('\n'),
          allOf(
            contains('A–Z'),
            contains('at least one clue'),
            contains('fact (English)'),
            contains('difficulty must be'),
            contains('source type must be'),
            contains('source reference'),
          ));
      expect(row.item!.subject, 'kerala_history');
    });
  });

  group('questions JSON', () {
    test('the example file imports cleanly; draftNotes is dropped', () {
      final rows = parseQuestionsJson(questionsExample());
      expect(rows.map((r) => r.item!.answer), ['VAIKOM', 'ASAN']);
      expect(rows.every((r) => r.ok), isTrue,
          reason: '${rows.map((r) => r.problems)}');
      final json = rows.first.item!.toJson();
      expect(json.containsKey('draftNotes'), isFalse);
      expect(json['topic'], 'renaissance');
      expect(json['answerDisplay'], {'en': 'Vaikom', 'ml': 'വൈക്കം'});
    });
  });

  group('planQuestionImport', () {
    test('new, unchanged, update, duplicate and retired', () {
      final rows = parseQuestionsJson(questionsExample());
      final same =
          rows[1].item!.copyWith(id: 'q-asan', status: QuestionStatus.verified);
      planQuestionImport(rows, [same]);
      expect(rows[0].action, ImportAction.create);
      expect(rows[1].action, ImportAction.unchanged);
      expect(rows[1].existingId, 'q-asan');

      // Re-importing an edited file updates instead of duplicating.
      final again = parseQuestionsJson(
          questionsExample().replaceFirst('Veena Poovu', 'Veena Poovu (1907)'));
      planQuestionImport(again, [same]);
      expect(again[1].action, ImportAction.update);
      expect(again[1].item!.id, 'q-asan');
      expect(again[1].note, contains('checking again'));

      final retired =
          rows[1].item!.copyWith(id: 'q-old', status: QuestionStatus.retired);
      final third = parseQuestionsJson(questionsExample());
      planQuestionImport(third, [retired]);
      expect(third[1].action, ImportAction.skip);

      final dupes = parseQuestionsJson(questionsExample()
          .replaceFirst('"answer": "ASAN"', '"answer": "VAIKOM"'));
      planQuestionImport(dupes, []);
      expect(dupes[1].action, ImportAction.skip);
      expect(dupes[1].problems.single, contains('more than once'));
    });
  });

  group('puzzles', () {
    test('the example puzzle parses with no grid problems', () {
      final row = parsePuzzlesJson(puzzleExample()).single;
      expect(row.problems, isEmpty);
      expect(row.item!.words, hasLength(7));
      expect(row.item!.id, 'kerala-history-0012');
    });

    test('a wrong length or a clashing letter is reported', () {
      final badLength = parsePuzzlesJson(puzzleExample().replaceFirst(
          '"length": 7,\n      "answer": "MUZIRIS"',
          '"length": 6,\n      "answer": "MUZIRIS"'));
      expect(badLength.single.problems.join(), contains('length 6'));
      final clash = parsePuzzlesJson(
          puzzleExample().replaceFirst('"VAIKOM"', '"VAIXOM"'));
      expect(clash.single.problems.join(), contains('2 Down (VAIXOM) needs'));
    });

    test('TODO question ids are linked by answer; missing ones are problems',
        () {
      final row = parsePuzzlesJson(puzzleExample()).single;
      final bank = {
        for (final (i, answer) in [
          'MUZIRIS',
          'MALABAR',
          'VAIKOM',
          'GAMA',
          'ASAN',
          'KAPPAD'
        ].indexed)
          'q$i': verified('q$i', answer),
        'other': verified('other', 'VAIKOM', subject: 'geography'),
      };
      linkPuzzleQuestions(row, bank, subject: 'kerala_history');
      final ids = {for (final w in row.item!.words) w.answer: w.questionId};
      expect(ids['VAIKOM'], 'q2');
      expect(ids['MUZIRIS'], 'q0');
      expect(row.problems.single, contains('EMS'));
    });

    group('planPuzzleImport', () {
      ImportRow<AdminPuzzle> row() => parsePuzzlesJson(puzzleExample()).single;

      test('matching id that is still a draft → update', () {
        final r = row();
        planPuzzleImport(r, [
          summary('kerala-history-0012', 'Old title', PuzzleStatus.inReview)
        ]);
        expect(r.action, ImportAction.update);
        expect(r.item!.id, 'kerala-history-0012');
      });

      test('a live puzzle is not replaced', () {
        final r = row();
        planPuzzleImport(
            r, [summary('kerala-history-0012', 'x', PuzzleStatus.published)]);
        expect(r.action, ImportAction.skip);
        expect(r.problems.single, contains('live'));
      });

      test('no id match → match on title (re-import after a first create)', () {
        final r = row();
        planPuzzleImport(r, [
          summary('kerala-history-0001', 'Kerala Renaissance and Trade',
              PuzzleStatus.draft)
        ]);
        expect(r.action, ImportAction.update);
        expect(r.item!.id, 'kerala-history-0001');
      });

      test('nothing matches → created without the file id', () {
        final r = row();
        planPuzzleImport(r, []);
        expect(r.action, ImportAction.create);
        expect(r.item!.id, isNull);
        expect(r.item!.toJson().containsKey('id'), isFalse);
      });
    });
  });
}
