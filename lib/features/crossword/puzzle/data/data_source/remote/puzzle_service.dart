import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_guard.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/puzzle/data/data_source/puzzle_service.dart';
import 'package:wordshool/features/crossword/shared/data/models/progress.dart';
import 'package:wordshool/features/crossword/shared/data/models/puzzle.dart';
import 'package:wordshool/features/crossword/shared/data/models/result.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';

class PuzzleDataSourceImpl extends PuzzleDataSource {
  PuzzleDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
  })  : _firestore = firestore,
        _functions = functions;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  @override
  Future<DataState<CrosswordPuzzleModel>> getPuzzle(String puzzleId) {
    return guardData('Puzzle.getPuzzle', () async {
      final snap = await _firestore
          .collection(FirebaseCollections.crosswordPuzzles)
          .doc(puzzleId)
          .get();
      final data = snap.data();
      if (data == null) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: "This puzzle isn't available.",
        );
      }
      return CrosswordPuzzleModel.fromJson(data, documentId: snap.id);
    });
  }

  @override
  Future<DataState<CrosswordSubmitOutcomeModel>> submit({
    required CrosswordProgressEntity progress,
    required List<String> revealedWordIds,
  }) {
    return guardData('Puzzle.submit', () async {
      final result = await _functions.httpsCallable('submitCrossword').call({
        'puzzleId': progress.puzzleId,
        'letters': progress.letters,
        'elapsedSec': progress.elapsedSec,
        'hintsUsed': HintCountModel.toJsonOf(progress.hintsUsed),
        'revealedWordIds': revealedWordIds,
      });
      return CrosswordSubmitOutcomeModel.fromJson(
          Map<String, dynamic>.from(result.data as Map));
    });
  }
}
