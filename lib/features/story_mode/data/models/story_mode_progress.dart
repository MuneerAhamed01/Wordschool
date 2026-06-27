import 'package:wordshool/core/firebase/dt_converter.dart';
import 'package:wordshool/features/story_mode/domain/entities/case_outcome.dart';
import 'package:wordshool/features/story_mode/domain/entities/story_mode_progress.dart';

class StoryModeProgressModel extends StoryModeProgressEntity {
  static const int clueCount = 3;

  const StoryModeProgressModel({
    required super.userId,
    required super.caseId,
    required super.currentClueIndex,
    required super.clueAttempts,
    required super.clueGuesses,
    required super.clueSolved,
    required super.totalScore,
    super.outcome,
    super.completedAt,
  });

  factory StoryModeProgressModel.empty({
    required String userId,
    required String caseId,
  }) {
    return StoryModeProgressModel(
      userId: userId,
      caseId: caseId,
      currentClueIndex: 0,
      clueAttempts: const [0, 0, 0],
      clueGuesses: const [[], [], []],
      clueSolved: const [false, false, false],
      totalScore: 0,
    );
  }

  factory StoryModeProgressModel.fromJson(
    Map<String, dynamic> json, {
    required String userId,
    required String caseId,
  }) {
    final outcomeValue = json['outcome'];
    final completedAtValue = json['completedAt'];

    return StoryModeProgressModel(
      userId: userId,
      caseId: caseId,
      currentClueIndex: json['currentClueIndex'] as int,
      clueAttempts: (json['clueAttempts'] as List<dynamic>)
          .map((value) => value as int)
          .toList(),
      clueGuesses: clueGuessesFromFirestore(json['clueGuesses']),
      clueSolved: (json['clueSolved'] as List<dynamic>)
          .map((value) => value as bool)
          .toList(),
      totalScore: json['totalScore'] as int,
      outcome: outcomeValue == null
          ? null
          : CaseOutcomeFirestore.fromFirestoreString(outcomeValue as String),
      completedAt: completedAtValue == null
          ? null
          : FirebaseDTConverter.fromTimestamp(completedAtValue),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentClueIndex': currentClueIndex,
      'clueAttempts': clueAttempts,
      'clueGuesses': clueGuessesToFirestore(clueGuesses),
      'clueSolved': clueSolved,
      'totalScore': totalScore,
      'outcome': outcome?.toFirestoreString(),
      'completedAt':
          completedAt == null ? null : FirebaseDTConverter.toTimestamp(completedAt!),
    };
  }

  /// Firestore rejects nested arrays. Persist guesses as a map of clue index →
  /// string array, e.g. `{ "0": ["STUDY"], "1": [], "2": [] }`.
  static Map<String, List<String>> clueGuessesToFirestore(
    List<List<String>> guesses,
  ) {
    return {
      for (var index = 0; index < guesses.length; index++)
        '$index': List<String>.from(guesses[index]),
    };
  }

  static List<List<String>> clueGuessesFromFirestore(dynamic value) {
    if (value is Map) {
      return List<List<String>>.generate(
        clueCount,
        (index) {
          final guesses = value['$index'];
          if (guesses is! List) {
            return const [];
          }
          return guesses.map((guess) => guess as String).toList();
        },
      );
    }

    if (value is List) {
      return value
          .map(
            (clueGuesses) => (clueGuesses as List<dynamic>)
                .map((guess) => guess as String)
                .toList(),
          )
          .toList();
    }

    return List<List<String>>.generate(clueCount, (_) => const []);
  }
}
