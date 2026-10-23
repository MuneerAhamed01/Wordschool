import 'package:equatable/equatable.dart';
import 'package:wordshool/features/admin/domain/models/admin_enums.dart';
import 'package:wordshool/features/admin/domain/models/json_read.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

class QuestionClue extends Equatable {
  const QuestionClue({required this.en, this.ml, required this.level});

  final String en;
  final String? ml;
  final Difficulty level;

  factory QuestionClue.fromJson(Map<String, dynamic> json) {
    final ml = json['ml'] as String?;
    return QuestionClue(
      en: json['en'] as String? ?? '',
      ml: ml == null || ml.isEmpty ? null : ml,
      level: Difficulty.fromValue(json['level']),
    );
  }

  Map<String, dynamic> toJson() => {
        'en': en.trim(),
        if ((ml ?? '').trim().isNotEmpty) 'ml': ml!.trim(),
        'level': level.value,
      };

  @override
  List<Object?> get props => [en, ml, level];
}

class QuestionSource extends Equatable {
  const QuestionSource({required this.type, required this.ref});

  final SourceType type;
  final String ref;

  /// The server refuses to verify a question whose reference starts with TODO.
  bool get isPlaceholder => ref.trim().toUpperCase().startsWith('TODO');

  factory QuestionSource.fromJson(Object? json) {
    final map = readMap(json);
    return QuestionSource(
      type: SourceType.fromValue(map['type']),
      ref: map['ref'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'type': type.value, 'ref': ref.trim()};

  @override
  List<Object?> get props => [type, ref];
}

/// `pscQuestions/{id}` — one fact in the private question bank.
class AdminQuestion extends Equatable {
  const AdminQuestion({
    this.id,
    required this.answer,
    required this.answerDisplay,
    required this.clues,
    required this.fact,
    required this.subject,
    this.topic,
    this.examTags = const [],
    required this.difficulty,
    required this.source,
    this.status = QuestionStatus.draft,
    this.usedInPuzzles = const [],
    this.updatedAt,
  });

  /// Null for a question that isn't saved yet.
  final String? id;

  /// Grid answer, A–Z only (the server normalises it).
  final String answer;
  final LocalizedText answerDisplay;
  final List<QuestionClue> clues;
  final LocalizedText fact;
  final String subject;
  final String? topic;
  final List<String> examTags;
  final Difficulty difficulty;
  final QuestionSource source;
  final QuestionStatus status;
  final List<String> usedInPuzzles;
  final DateTime? updatedAt;

  bool get isVerified => status == QuestionStatus.verified;

  /// The easiest clue, used as the default crossword clue.
  QuestionClue? get firstClue {
    for (final level in Difficulty.values) {
      for (final clue in clues) {
        if (clue.level == level) return clue;
      }
    }
    return null;
  }

  factory AdminQuestion.fromJson(Map<String, dynamic> json,
      {String? documentId}) {
    final topic = json['topic'] as String?;
    return AdminQuestion(
      id: documentId ?? json['id'] as String?,
      answer: json['answer'] as String? ?? '',
      answerDisplay: LocalizedText.fromJson(json['answerDisplay']),
      clues: readMaps(json['clues']).map(QuestionClue.fromJson).toList(),
      fact: LocalizedText.fromJson(json['fact']),
      subject: json['subject'] as String? ?? '',
      topic: topic == null || topic.isEmpty ? null : topic,
      examTags: readStrings(json['examTags']),
      difficulty: Difficulty.fromValue(json['difficulty']),
      source: QuestionSource.fromJson(json['source']),
      status: QuestionStatus.fromValue(json['status']),
      usedInPuzzles: readStrings(json['usedInPuzzles']),
      updatedAt: readDate(json['updatedAt']),
    );
  }

  /// The `adminSaveQuestion` payload; empty optional fields are left out.
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'answer': answer.trim(),
        'answerDisplay': answerDisplay.toJson(),
        'clues': clues.map((c) => c.toJson()).toList(),
        'fact': fact.toJson(),
        'subject': subject.trim(),
        if ((topic ?? '').trim().isNotEmpty) 'topic': topic!.trim(),
        'examTags': examTags,
        'difficulty': difficulty.value,
        'source': source.toJson(),
      };

  AdminQuestion copyWith({
    String? id,
    QuestionStatus? status,
    DateTime? updatedAt,
  }) =>
      AdminQuestion(
        id: id ?? this.id,
        answer: answer,
        answerDisplay: answerDisplay,
        clues: clues,
        fact: fact,
        subject: subject,
        topic: topic,
        examTags: examTags,
        difficulty: difficulty,
        source: source,
        status: status ?? this.status,
        usedInPuzzles: usedInPuzzles,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        id,
        answer,
        answerDisplay,
        clues,
        fact,
        subject,
        topic,
        examTags,
        difficulty,
        source,
        status,
        usedInPuzzles,
        updatedAt,
      ];
}
