import 'package:wordshool/core/utils/json_read.dart';
import 'package:wordshool/features/crossword/shared/data/models/result.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

/// `hintsUsed` map ⇄ [HintCount] (a plain value, so it compares equal).
abstract final class HintCountModel {
  static HintCount fromJson(Object? json) {
    final map = asMap(json);
    return HintCount(
      letter: asInt(map['letter']),
      word: asInt(map['word']),
      clue: asInt(map['clue']),
    );
  }

  /// All three keys, as the rules and `submitCrossword` require.
  static Map<String, dynamic> toJsonOf(HintCount hints) =>
      {'letter': hints.letter, 'word': hints.word, 'clue': hints.clue};
}

class CrosswordProgressModel extends CrosswordProgressEntity {
  const CrosswordProgressModel({
    required super.puzzleId,
    super.status,
    required super.letters,
    super.elapsedSec,
    super.hintsUsed,
    super.checksUsed,
    super.result,
  });

  /// [documentId] is the puzzle id.
  factory CrosswordProgressModel.fromJson(
    Map<String, dynamic> json, {
    String? documentId,
  }) {
    return CrosswordProgressModel(
      puzzleId: documentId ?? asString(json['puzzleId']),
      status: CrosswordProgressStatus.fromWire(json['status']),
      letters: asString(json['letters']),
      elapsedSec: asInt(json['elapsedSec']),
      hintsUsed: HintCountModel.fromJson(json['hintsUsed']),
      checksUsed: asInt(json['checksUsed']),
      result: json['result'] is Map
          ? CrosswordResultModel.fromJson(asMap(json['result']))
          : null,
    );
  }

  /// The player-writable fields (timestamps are added by the data source).
  static Map<String, dynamic> toJsonOf(CrosswordProgressEntity progress) => {
        'status': CrosswordProgressStatus.inProgress.wire,
        'letters': progress.letters,
        'elapsedSec': progress.elapsedSec,
        'hintsUsed': HintCountModel.toJsonOf(progress.hintsUsed),
        'checksUsed': progress.checksUsed,
      };
}
