import 'package:wordshool/core/utils/json_read.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result.dart';

class CrosswordResultModel extends CrosswordResultEntity {
  const CrosswordResultModel({
    required super.score,
    required super.correctWords,
    required super.totalWords,
    required super.xpEarned,
    required super.timeSec,
    super.wrongWordIds,
    super.revealedWordIds,
  });

  factory CrosswordResultModel.fromJson(Map<String, dynamic> json) {
    return CrosswordResultModel(
      score: asInt(json['score']),
      correctWords: asInt(json['correctWords']),
      totalWords: asInt(json['totalWords']),
      xpEarned: asInt(json['xpEarned']),
      timeSec: asInt(json['timeSec']),
      wrongWordIds: asStringList(json['wrongWordIds']),
      revealedWordIds: asStringList(json['revealedWordIds']),
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'correctWords': correctWords,
        'totalWords': totalWords,
        'xpEarned': xpEarned,
        'timeSec': timeSec,
        'wrongWordIds': wrongWordIds,
        'revealedWordIds': revealedWordIds,
      };
}

class CrosswordSubmitOutcomeModel extends CrosswordSubmitOutcome {
  const CrosswordSubmitOutcomeModel({
    required super.result,
    required super.xp,
    required super.currentStreak,
    super.alreadySubmitted,
  });

  /// The `submitCrossword` response.
  factory CrosswordSubmitOutcomeModel.fromJson(Map<String, dynamic> json) {
    return CrosswordSubmitOutcomeModel(
      result: CrosswordResultModel.fromJson(asMap(json['result'])),
      xp: asInt(json['xp']),
      currentStreak: asInt(json['currentStreak']),
      alreadySubmitted: asBool(json['alreadySubmitted']),
    );
  }
}
