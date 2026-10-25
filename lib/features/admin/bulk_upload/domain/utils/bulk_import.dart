import 'dart:convert';

import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/puzzle.dart';
import 'package:wordshool/features/admin/shared/domain/models/question.dart';
import 'package:wordshool/features/admin/bulk_upload/domain/utils/csv.dart';
import 'package:wordshool/features/admin/shared/domain/utils/grid_validator.dart';
import 'package:wordshool/features/admin/shared/domain/utils/question_text.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

/// Bulk upload (CW-036): read a questions file (CSV or JSON) or a puzzle file
/// (JSON, shapes in `.claude/skills/crossword-content/examples/`), check each
/// item like the server does, and decide whether it is new, an update or
/// unchanged. Pure — the page makes the calls.

enum ImportKind { questions, puzzles }

enum ImportAction {
  create('New'),
  update('Update'),
  unchanged('No change'),
  skip('Error');

  const ImportAction(this.label);

  final String label;
}

class ImportFileError implements Exception {
  const ImportFileError(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One item of an uploaded file.
class ImportRow<T> {
  ImportRow({required this.label, this.item, List<String>? problems})
      : problems = problems ?? [];

  /// Where it is in the file, e.g. `Row 3 · VAIKOM`.
  final String label;
  T? item;
  final List<String> problems;
  ImportAction action = ImportAction.create;

  /// Id of the document an update writes to.
  String? existingId;

  /// Extra explanation shown in the preview.
  String? note;

  bool get ok => problems.isEmpty;
}

ImportKind detectKind(String fileName, String text) {
  final name = fileName.toLowerCase();
  if (name.endsWith('.csv') || name.endsWith('.tsv') || name.endsWith('.txt')) {
    return ImportKind.questions;
  }
  final trimmed = text.trimLeft();
  if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
    return ImportKind.questions;
  }
  final Object? json;
  try {
    json = jsonDecode(trimmed);
  } on FormatException catch (e) {
    throw ImportFileError('This is not valid JSON: ${e.message}');
  }
  if (json is Map && json.containsKey('questions')) return ImportKind.questions;
  if (json is Map &&
      (json.containsKey('words') || json.containsKey('puzzles'))) {
    return ImportKind.puzzles;
  }
  if (json is List &&
      json.isNotEmpty &&
      json.first is Map &&
      (json.first as Map).containsKey('words')) {
    return ImportKind.puzzles;
  }
  throw const ImportFileError(
    'Could not tell what this file contains. A questions file has "questions"; '
    'a puzzle file has "words".',
  );
}

// ---------------------------------------------------------------- questions

/// Columns of the questions spreadsheet, in template order.
const questionCsvColumns = [
  'answer',
  'answer_display_en',
  'answer_display_ml',
  'clue_easy',
  'clue_medium',
  'clue_hard',
  'fact_en',
  'fact_ml',
  'subject',
  'topic',
  'exam_tags',
  'difficulty',
  'source_type',
  'source_ref',
];

const _requiredCsvColumns = [
  'answer',
  'fact_en',
  'subject',
  'difficulty',
  'source_type',
  'source_ref'
];

/// The spreadsheet template, with one example row (UTF-8 with BOM so Excel
/// shows Malayalam correctly).
String questionCsvTemplate() => '\uFEFF${[
      toCsvLine(questionCsvColumns),
      toCsvLine([
        'Vaikom',
        'Vaikom',
        'വൈക്കം',
        'Satyagraha town in Kottayam district visited by Gandhiji in 1925',
        '1924–25 satyagraha for the right to use temple roads',
        '',
        'The Vaikom Satyagraha (1924–25) protested the ban on oppressed castes using the roads around the Vaikom temple.',
        '',
        'kerala_history',
        'renaissance',
        'ldc, lgs',
        'medium',
        'book',
        'Kerala Charithram, p. 112',
      ]),
    ].join('\r\n')}\r\n';

String _rowLabel(int line, String answer) =>
    answer.isEmpty ? 'Row $line' : 'Row $line · $answer';

/// Reads a questions spreadsheet (CSV, or TSV pasted from Google Sheets).
///
/// Throws [ImportFileError] when the header is missing required columns.
List<ImportRow<AdminQuestion>> parseQuestionsCsv(String text) {
  final rows = parseCsv(text);
  if (rows.isEmpty) throw const ImportFileError('The file is empty.');
  final header = [for (final cell in rows.first) toSnake(cell)];
  final missing =
      _requiredCsvColumns.where((c) => !header.contains(c)).toList();
  if (missing.isNotEmpty) {
    throw ImportFileError(
      'The first row must name the columns. Missing: ${missing.join(', ')}. '
      'Download the template to see the expected columns.',
    );
  }
  final result = <ImportRow<AdminQuestion>>[];
  for (var r = 1; r < rows.length; r++) {
    final cells = rows[r];
    String cell(String column) {
      final index = header.indexOf(column);
      return index < 0 || index >= cells.length ? '' : cells[index].trim();
    }

    if (cells.every((c) => c.trim().isEmpty)) continue;
    final line = r + 1;
    final problems = <String>[];
    final rawAnswer = cell('answer');
    final answer = normalizeAnswer(rawAnswer);
    final answerIssue = answerProblem(rawAnswer);
    if (answerIssue != null) problems.add('answer: $answerIssue');

    final clues = [
      for (final level in Difficulty.values)
        if (cell('clue_${level.value}').isNotEmpty)
          QuestionClue(en: cell('clue_${level.value}'), level: level),
    ];
    if (clues.isEmpty) {
      problems
          .add('Add at least one clue (clue_easy, clue_medium or clue_hard).');
    }

    final question = _questionFrom(
      problems: problems,
      answer: answer,
      displayEn: cell('answer_display_en').isEmpty
          ? rawAnswer
          : cell('answer_display_en'),
      displayMl: cell('answer_display_ml'),
      clues: clues,
      factEn: cell('fact_en'),
      factMl: cell('fact_ml'),
      subject: cell('subject'),
      topic: cell('topic'),
      tags: parseTags(cell('exam_tags')),
      difficulty: cell('difficulty'),
      sourceType: cell('source_type'),
      sourceRef: cell('source_ref'),
    );
    result.add(ImportRow(
        label: _rowLabel(line, answer), item: question, problems: problems));
  }
  if (result.isEmpty) {
    throw const ImportFileError('The file has a header row but no questions.');
  }
  return result;
}

/// Reads `{subject, questions: [...]}` (content/questions/*.json). `draftNotes`
/// is dropped.
List<ImportRow<AdminQuestion>> parseQuestionsJson(String text) {
  final Object? json;
  try {
    json = jsonDecode(text);
  } on FormatException catch (e) {
    throw ImportFileError('This is not valid JSON: ${e.message}');
  }
  if (json is! Map || json['questions'] is! List) {
    throw const ImportFileError('Expected {"subject": …, "questions": [ … ]}.');
  }
  final fileSubject =
      json['subject'] is String ? json['subject'] as String : '';
  final items = json['questions'] as List;
  if (items.isEmpty) throw const ImportFileError('The file has no questions.');
  final result = <ImportRow<AdminQuestion>>[];
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    final problems = <String>[];
    if (item is! Map) {
      result.add(ImportRow(
          label: 'Question ${i + 1}', problems: ['must be an object']));
      continue;
    }
    String text(Object? value) => value is String ? value.trim() : '';
    final rawAnswer = text(item['answer']);
    final answer = normalizeAnswer(rawAnswer);
    final answerIssue = answerProblem(rawAnswer);
    if (answerIssue != null) problems.add('answer: $answerIssue');

    final clues = <QuestionClue>[];
    final rawClues = item['clues'];
    if (rawClues is! List || rawClues.isEmpty || rawClues.length > 5) {
      problems.add('clues: add 1 to 5 clues.');
    } else {
      for (var c = 0; c < rawClues.length; c++) {
        final clue = rawClues[c];
        final level = clue is Map ? Difficulty.tryValue(clue['level']) : null;
        final en = clue is Map ? text(clue['en']) : '';
        if (en.isEmpty || level == null) {
          problems.add(
              'clues[$c]: needs "en" text and a level (easy, medium or hard).');
        } else {
          clues.add(QuestionClue(
              en: en, ml: text((clue as Map)['ml']), level: level));
        }
      }
    }
    final display =
        item['answerDisplay'] is Map ? item['answerDisplay'] as Map : const {};
    final fact = item['fact'] is Map ? item['fact'] as Map : const {};
    final source = item['source'] is Map ? item['source'] as Map : const {};
    final tags = item['examTags'] is List
        ? (item['examTags'] as List).whereType<String>().map(toSnake).toList()
        : <String>[];
    final question = _questionFrom(
      problems: problems,
      answer: answer,
      displayEn: text(display['en']),
      displayMl: text(display['ml']),
      clues: clues,
      factEn: text(fact['en']),
      factMl: text(fact['ml']),
      subject:
          text(item['subject']).isEmpty ? fileSubject : text(item['subject']),
      topic: text(item['topic']),
      tags: tags.where((t) => t.isNotEmpty).toList(),
      difficulty: text(item['difficulty']),
      sourceType: text(source['type']),
      sourceRef: text(source['ref']),
    );
    result.add(ImportRow(
        label: 'Question ${i + 1} · $answer',
        item: question,
        problems: problems));
  }
  return result;
}

AdminQuestion _questionFrom({
  required List<String> problems,
  required String answer,
  required String displayEn,
  required String displayMl,
  required List<QuestionClue> clues,
  required String factEn,
  required String factMl,
  required String subject,
  required String topic,
  required List<String> tags,
  required String difficulty,
  required String sourceType,
  required String sourceRef,
}) {
  if (displayEn.isEmpty) problems.add('answer display (English) is missing.');
  if (factEn.isEmpty) problems.add('fact (English) is missing.');
  final subjectSnake = toSnake(subject);
  if (subjectSnake.isEmpty) {
    problems.add('subject is missing, e.g. kerala_history.');
  }
  final level = Difficulty.tryValue(difficulty.toLowerCase());
  if (level == null) {
    problems
        .add('difficulty must be easy, medium or hard (got "$difficulty").');
  }
  final type = SourceType.tryValue(sourceType.toLowerCase());
  if (type == null) {
    problems.add(
        'source type must be pyq, book, website or other (got "$sourceType").');
  }
  if (sourceRef.isEmpty) {
    problems.add('source reference is missing — where was the fact checked?');
  }
  return AdminQuestion(
    answer: answer,
    answerDisplay: LocalizedText(en: displayEn, ml: displayMl),
    clues: clues,
    fact: LocalizedText(en: factEn, ml: factMl),
    subject: subjectSnake,
    topic: toSnake(topic),
    examTags: tags,
    difficulty: level ?? Difficulty.medium,
    source: QuestionSource(type: type ?? SourceType.other, ref: sourceRef),
  );
}

String _questionKey(AdminQuestion q) => '${q.subject}|${q.answer}';

/// Matches rows to [existing] questions on answer + subject: an identical one
/// is left alone (so checked questions stay checked), a different one is
/// updated, the rest are new. A repeat inside the file is an error.
void planQuestionImport(
    List<ImportRow<AdminQuestion>> rows, List<AdminQuestion> existing) {
  final byKey = {for (final q in existing) _questionKey(q): q};
  final seen = <String>{};
  for (final row in rows) {
    final question = row.item;
    if (question == null || !row.ok) {
      row.action = ImportAction.skip;
      continue;
    }
    final key = _questionKey(question);
    if (!seen.add(key)) {
      row.problems.add(
          '${question.answer} appears more than once for ${question.subject} in this file.');
      row.action = ImportAction.skip;
      continue;
    }
    final match = byKey[key];
    if (match == null) {
      row.action = ImportAction.create;
      row.note = 'Will be added as "Needs checking".';
    } else if (match.status == QuestionStatus.retired) {
      row.problems.add('${question.answer} is retired and can\'t be changed.');
      row.action = ImportAction.skip;
    } else if (_sameContent(match, question)) {
      row.action = ImportAction.unchanged;
      row.existingId = match.id;
      row.note = 'Already in the bank — nothing to do.';
    } else {
      row.action = ImportAction.update;
      row.existingId = match.id;
      row.item = question.copyWith(id: match.id);
      row.note = match.isVerified
          ? 'Will be updated and need checking again.'
          : 'Will be updated.';
    }
  }
}

bool _sameContent(AdminQuestion a, AdminQuestion b) {
  final left = a.copyWith(id: '-').toJson();
  final right = b.copyWith(id: '-').toJson();
  return jsonEncode(left) == jsonEncode(right);
}

// ---------------------------------------------------------------- puzzles

/// Reads one puzzle, a list of puzzles, or `{puzzles: [...]}`
/// (content/puzzles/*.json, plain answers).
List<ImportRow<AdminPuzzle>> parsePuzzlesJson(String text) {
  final Object? json;
  try {
    json = jsonDecode(text);
  } on FormatException catch (e) {
    throw ImportFileError('This is not valid JSON: ${e.message}');
  }
  final List<Object?> items = switch (json) {
    {'puzzles': final List<Object?> list} => list,
    final List<Object?> list => list,
    final Map<String, dynamic> map => [map],
    _ => throw const ImportFileError('Expected a puzzle object with "words".'),
  };
  final result = <ImportRow<AdminPuzzle>>[];
  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    if (item is! Map) {
      result.add(
          ImportRow(label: 'Puzzle ${i + 1}', problems: ['must be an object']));
      continue;
    }
    result.add(_parsePuzzle(Map<String, dynamic>.from(item), i));
  }
  return result;
}

ImportRow<AdminPuzzle> _parsePuzzle(Map<String, dynamic> json, int index) {
  final problems = <String>[];
  final title = json['title'] is Map ? (json['title'] as Map)['en'] : null;
  final label =
      'Puzzle ${index + 1}${title is String && title.isNotEmpty ? ' · $title' : ''}';
  if (title is! String || title.trim().isEmpty) {
    problems.add('title.en is missing.');
  }
  if (json['categoryId'] is! String || (json['categoryId'] as String).isEmpty) {
    problems.add('categoryId is missing, e.g. kerala-history.');
  }
  if (Difficulty.tryValue(json['difficulty']) == null) {
    problems.add('difficulty must be easy, medium or hard.');
  }
  for (final field in ['rows', 'cols']) {
    if (json[field] is! num) problems.add('$field must be a number.');
  }
  if (json['layout'] is! String) problems.add('layout is missing.');
  final xp = json['xpReward'];
  if (xp is! num || xp < 1 || xp > 1000) {
    problems.add('xpReward must be 1 to 1000.');
  }
  final minutes = json['estimatedMinutes'];
  if (minutes is! num || minutes < 1 || minutes > 120) {
    problems.add('estimatedMinutes must be 1 to 120.');
  }
  final rawWords = json['words'];
  if (rawWords is! List || rawWords.length < 2) {
    problems.add('words: a puzzle needs at least 2 words.');
    return ImportRow(label: label, problems: problems);
  }
  final words = <AdminPuzzleWord>[];
  for (var w = 0; w < rawWords.length; w++) {
    final raw = rawWords[w];
    if (raw is! Map) {
      problems.add('words[$w] must be an object.');
      continue;
    }
    final map = Map<String, dynamic>.from(raw);
    final answer =
        normalizeAnswer(map['answer'] is String ? map['answer'] as String : '');
    final word = AdminPuzzleWord.fromJson({...map, 'answer': answer});
    if (map['length'] is num &&
        (map['length'] as num).toInt() != answer.length) {
      problems.add(
          '${word.id}: length ${map['length']} doesn\'t match ${answer.length}-letter answer $answer.');
    }
    if (word.clue.isEmpty) problems.add('${word.id}: clue.en is missing.');
    words.add(word);
  }
  final puzzle =
      AdminPuzzle.fromJson({...json, 'words': const []}).copyWithWords(words);
  if (problems.isEmpty) {
    problems.addAll(
      gridProblems(
              rows: puzzle.rows,
              cols: puzzle.cols,
              layout: puzzle.layout,
              words: puzzle.words)
          .map((p) => p.message),
    );
  }
  return ImportRow(label: label, item: puzzle, problems: problems);
}

/// Points every word at a checked question with its answer. A word whose
/// `questionId` is a placeholder (e.g. `TODO`) or not a checked question is
/// linked by answer, preferring [subject]; if none exists it's a problem.
void linkPuzzleQuestions(
  ImportRow<AdminPuzzle> row,
  Map<String, AdminQuestion> verifiedById, {
  String? subject,
}) {
  final puzzle = row.item;
  if (puzzle == null) return;
  final byAnswer = <String, List<AdminQuestion>>{};
  for (final q in verifiedById.values) {
    byAnswer.putIfAbsent(q.answer, () => []).add(q);
  }
  final linked = <AdminPuzzleWord>[];
  for (final word in puzzle.words) {
    final current = verifiedById[word.questionId];
    if (current != null && current.answer == word.answer) {
      linked.add(word);
      continue;
    }
    final candidates = byAnswer[word.answer] ?? const <AdminQuestion>[];
    if (candidates.isEmpty) {
      row.problems.add(
        '${word.id} ${word.answer}: no checked question has this answer. '
        'Add it in Questions (or upload a questions file) and mark it as checked first.',
      );
      linked.add(word);
      continue;
    }
    final best = candidates.firstWhere((q) => q.subject == subject,
        orElse: () => candidates.first);
    linked.add(word.withQuestionId(best.id!));
  }
  row.item = puzzle.copyWithWords(linked);
}

/// Matches a puzzle row on `id`, then on title within its category
/// ([existing] = that category's puzzles). Live, scheduled and archived
/// puzzles can't be overwritten.
void planPuzzleImport(
    ImportRow<AdminPuzzle> row, List<AdminPuzzleSummary> existing) {
  final puzzle = row.item;
  if (puzzle == null || !row.ok) {
    row.action = ImportAction.skip;
    return;
  }
  final title = puzzle.title.en.trim().toLowerCase();
  AdminPuzzleSummary? match;
  for (final p in existing) {
    if (p.id == puzzle.id) match = p;
  }
  match ??= existing
      .where((p) => p.title.en.trim().toLowerCase() == title)
      .firstOrNull;
  if (match == null) {
    row.action = ImportAction.create;
    row.item = puzzle.withId(null);
    row.note = puzzle.id == null
        ? 'Will be saved as a new draft.'
        : 'No puzzle ${puzzle.id} yet — will be saved as a new draft with the next number.';
    return;
  }
  if (!match.status.isEditable) {
    row.problems.add(
      '#${match.number} "${match.title.en}" is ${match.status.label.toLowerCase()} and can\'t be '
      'replaced. Archive it and change this puzzle\'s title to upload it as a new one.',
    );
    row.action = ImportAction.skip;
    return;
  }
  row.action = ImportAction.update;
  row.existingId = match.id;
  row.item = puzzle.withId(match.id);
  row.note =
      'Will replace #${match.number} (${match.status.label}) and make it a draft again.';
}
