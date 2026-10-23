import 'package:equatable/equatable.dart';
import 'package:wordshool/features/admin/domain/models/admin_enums.dart';
import 'package:wordshool/features/admin/domain/models/json_read.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

/// One word of a puzzle as the admin edits it: the plain answer, not encoded.
class AdminPuzzleWord extends Equatable {
  const AdminPuzzleWord({
    required this.id,
    required this.number,
    required this.direction,
    required this.row,
    required this.col,
    required this.answer,
    required this.clue,
    this.extraClue,
    this.fact,
    required this.questionId,
  });

  /// `{number}{A|D}`, e.g. `2D`.
  final String id;
  final int number;
  final WordDirection direction;
  final int row;
  final int col;
  final String answer;
  final LocalizedText clue;
  final LocalizedText? extraClue;
  final LocalizedText? fact;
  final String questionId;

  int get length => answer.length;

  factory AdminPuzzleWord.fromJson(Map<String, dynamic> json) {
    final extra = json['extraClue'];
    final fact = json['fact'];
    return AdminPuzzleWord(
      id: json['id'] as String? ?? '',
      number: readInt(json['number']),
      direction: WordDirection.fromValue(json['direction']),
      row: readInt(json['row']),
      col: readInt(json['col']),
      answer: (json['answer'] as String? ?? '').toUpperCase(),
      clue: LocalizedText.fromJson(json['clue']),
      extraClue: extra == null ? null : LocalizedText.fromJson(extra),
      fact: fact == null ? null : LocalizedText.fromJson(fact),
      questionId: json['questionId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'direction': direction.value,
        'row': row,
        'col': col,
        'length': length,
        'answer': answer,
        'clue': clue.toJson(),
        if (extraClue != null && !extraClue!.isEmpty)
          'extraClue': extraClue!.toJson(),
        if (fact != null && !fact!.isEmpty) 'fact': fact!.toJson(),
        'questionId': questionId,
      };

  @override
  List<Object?> get props => [
        id,
        number,
        direction,
        row,
        col,
        answer,
        clue,
        extraClue,
        fact,
        questionId
      ];
}

/// A puzzle list row (`adminListPuzzles` leaves out the grid).
class AdminPuzzleSummary extends Equatable {
  const AdminPuzzleSummary({
    required this.id,
    required this.categoryId,
    required this.number,
    required this.title,
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.wordCount,
    required this.xpReward,
    required this.estimatedMinutes,
    required this.status,
    this.publishAt,
    this.publishedAt,
    this.updatedAt,
  });

  final String id;
  final String categoryId;
  final int number;
  final LocalizedText title;
  final Difficulty difficulty;
  final int rows;
  final int cols;
  final int wordCount;
  final int xpReward;
  final int estimatedMinutes;
  final PuzzleStatus status;
  final DateTime? publishAt;
  final DateTime? publishedAt;
  final DateTime? updatedAt;

  factory AdminPuzzleSummary.fromJson(Map<String, dynamic> json,
      {String? documentId}) {
    return AdminPuzzleSummary(
      id: documentId ?? json['id'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      number: readInt(json['number']),
      title: LocalizedText.fromJson(json['title']),
      difficulty: Difficulty.fromValue(json['difficulty']),
      rows: readInt(json['rows']),
      cols: readInt(json['cols']),
      wordCount: readInt(json['wordCount']),
      xpReward: readInt(json['xpReward']),
      estimatedMinutes: readInt(json['estimatedMinutes']),
      status: PuzzleStatus.fromValue(json['status']),
      publishAt: readDate(json['publishAt']),
      publishedAt: readDate(json['publishedAt']),
      updatedAt: readDate(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        number,
        title,
        difficulty,
        rows,
        cols,
        wordCount,
        xpReward,
        estimatedMinutes,
        status,
        publishAt,
        publishedAt,
        updatedAt,
      ];
}

/// A full puzzle with plain answers (`adminGetPuzzle`), or one being built.
class AdminPuzzle extends Equatable {
  const AdminPuzzle({
    this.id,
    required this.categoryId,
    this.number = 0,
    required this.title,
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.layout,
    required this.words,
    required this.xpReward,
    required this.estimatedMinutes,
    this.status = PuzzleStatus.draft,
    this.publishAt,
    this.publishedAt,
  });

  /// Null for a new puzzle; the server assigns `{categoryId}-{0000}`.
  final String? id;
  final String categoryId;
  final int number;
  final LocalizedText title;
  final Difficulty difficulty;
  final int rows;
  final int cols;

  /// `rows × cols` characters: `.` letter cell, `#` block.
  final String layout;
  final List<AdminPuzzleWord> words;
  final int xpReward;
  final int estimatedMinutes;
  final PuzzleStatus status;
  final DateTime? publishAt;
  final DateTime? publishedAt;

  factory AdminPuzzle.fromJson(Map<String, dynamic> json,
      {String? documentId}) {
    return AdminPuzzle(
      id: documentId ?? json['id'] as String?,
      categoryId: json['categoryId'] as String? ?? '',
      number: readInt(json['number']),
      title: LocalizedText.fromJson(json['title']),
      difficulty: Difficulty.fromValue(json['difficulty']),
      rows: readInt(json['rows']),
      cols: readInt(json['cols']),
      layout: json['layout'] as String? ?? '',
      words: readMaps(json['words']).map(AdminPuzzleWord.fromJson).toList(),
      xpReward: readInt(json['xpReward'], 50),
      estimatedMinutes: readInt(json['estimatedMinutes'], 5),
      status: PuzzleStatus.fromValue(json['status']),
      publishAt: readDate(json['publishAt']),
      publishedAt: readDate(json['publishedAt']),
    );
  }

  /// The `adminSaveCrosswordPuzzle` payload.
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'categoryId': categoryId,
        'title': title.toJson(),
        'difficulty': difficulty.value,
        'rows': rows,
        'cols': cols,
        'layout': layout,
        'xpReward': xpReward,
        'estimatedMinutes': estimatedMinutes,
        'words': words.map((w) => w.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        id,
        categoryId,
        number,
        title,
        difficulty,
        rows,
        cols,
        layout,
        words,
        xpReward,
        estimatedMinutes,
        status,
        publishAt,
        publishedAt,
      ];
}
