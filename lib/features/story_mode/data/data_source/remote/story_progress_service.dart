import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_progress_service.dart';
import 'package:wordshool/features/story_mode/data/models/story_mode_progress.dart';

class StoryProgressDataSourceImpl extends StoryProgressDataSource {
  StoryProgressDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _progressDoc(
    String userId,
    String caseId,
  ) {
    return _firestore
        .collection(FirebaseCollections.userStoryProgress)
        .doc(userId)
        .collection(FirebaseCollections.storyCases)
        .doc(caseId);
  }

  @override
  Future<DataState<StoryModeProgressModel>> ensureProgressDoc({
    required String userId,
    required String caseId,
  }) async {
    try {
      final docRef = _progressDoc(userId, caseId);
      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        return DataSuccess<StoryModeProgressModel>(
          data: StoryModeProgressModel.fromJson(
            snapshot.data()!,
            userId: userId,
            caseId: caseId,
          ),
        );
      }

      final empty = StoryModeProgressModel.empty(
        userId: userId,
        caseId: caseId,
      );
      await docRef.set(empty.toJson());
      return DataSuccess<StoryModeProgressModel>(data: empty);
    } catch (error, stackTrace) {
      return DataError<StoryModeProgressModel>(
        error: AppError.fromException(error),
        stackTrace: stackTrace,
        context: 'StoryProgressDataSource.ensureProgressDoc',
      );
    }
  }

  @override
  Future<DataState<StoryModeProgressModel>> saveClueGuess({
    required String userId,
    required String caseId,
    required int clueIndex,
    required String guess,
  }) async {
    try {
      final ensureResult = await ensureProgressDoc(
        userId: userId,
        caseId: caseId,
      );
      if (ensureResult is! DataSuccess<StoryModeProgressModel>) {
        return ensureResult;
      }

      final progress = ensureResult.data!;
      final clueGuesses = progress.clueGuesses
          .map((guesses) => List<String>.from(guesses))
          .toList();
      final clueAttempts = List<int>.from(progress.clueAttempts);

      clueGuesses[clueIndex] = [...clueGuesses[clueIndex], guess.toUpperCase()];
      clueAttempts[clueIndex] = clueAttempts[clueIndex] + 1;

      await _progressDoc(userId, caseId).update({
        'clueGuesses': clueGuesses,
        'clueAttempts': clueAttempts,
      });

      return DataSuccess<StoryModeProgressModel>(
        data: StoryModeProgressModel(
          userId: userId,
          caseId: caseId,
          currentClueIndex: progress.currentClueIndex,
          clueAttempts: clueAttempts,
          clueGuesses: clueGuesses,
          clueSolved: List<bool>.from(progress.clueSolved),
          totalScore: progress.totalScore,
          outcome: progress.outcome,
          completedAt: progress.completedAt,
        ),
      );
    } catch (error, stackTrace) {
      return DataError<StoryModeProgressModel>(
        error: AppError.fromException(error),
        stackTrace: stackTrace,
        context: 'StoryProgressDataSource.saveClueGuess',
      );
    }
  }

  @override
  Future<DataState<StoryModeProgressModel>> completeClue({
    required String userId,
    required String caseId,
    required int clueIndex,
    required bool solved,
  }) async {
    try {
      final ensureResult = await ensureProgressDoc(
        userId: userId,
        caseId: caseId,
      );
      if (ensureResult is! DataSuccess<StoryModeProgressModel>) {
        return ensureResult;
      }

      final progress = ensureResult.data!;
      final clueSolved = List<bool>.from(progress.clueSolved);
      clueSolved[clueIndex] = solved;

      final nextClueIndex = clueIndex + 1;
      final currentClueIndex = nextClueIndex > progress.currentClueIndex
          ? nextClueIndex
          : progress.currentClueIndex;

      await _progressDoc(userId, caseId).update({
        'clueSolved': clueSolved,
        'currentClueIndex': currentClueIndex,
      });

      return DataSuccess<StoryModeProgressModel>(
        data: StoryModeProgressModel(
          userId: userId,
          caseId: caseId,
          currentClueIndex: currentClueIndex,
          clueAttempts: List<int>.from(progress.clueAttempts),
          clueGuesses: progress.clueGuesses
              .map((guesses) => List<String>.from(guesses))
              .toList(),
          clueSolved: clueSolved,
          totalScore: progress.totalScore,
          outcome: progress.outcome,
          completedAt: progress.completedAt,
        ),
      );
    } catch (error, stackTrace) {
      return DataError<StoryModeProgressModel>(
        error: AppError.fromException(error),
        stackTrace: stackTrace,
        context: 'StoryProgressDataSource.completeClue',
      );
    }
  }
}
