import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wordshool/core/firebase/collections.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_progress_service.dart';
import 'package:wordshool/features/story_mode/data/models/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/utils/case_outcome_resolver.dart';
import 'package:wordshool/features/story_mode/domain/utils/detective_score_calculator.dart';

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
      if (progress.completedAt != null) {
        return DataSuccess<StoryModeProgressModel>(data: progress);
      }

      final clueGuesses = progress.clueGuesses
          .map((guesses) => List<String>.from(guesses))
          .toList();
      final clueAttempts = List<int>.from(progress.clueAttempts);

      clueGuesses[clueIndex] = [...clueGuesses[clueIndex], guess.toUpperCase()];
      clueAttempts[clueIndex] = clueAttempts[clueIndex] + 1;

      final updated = StoryModeProgressModel(
        userId: userId,
        caseId: caseId,
        currentClueIndex: progress.currentClueIndex,
        clueAttempts: clueAttempts,
        clueGuesses: clueGuesses,
        clueSolved: List<bool>.from(progress.clueSolved),
        totalScore: progress.totalScore,
        outcome: progress.outcome,
        completedAt: progress.completedAt,
      );
      final payload = updated.toJson();

      await _progressDoc(userId, caseId).update({
        'clueGuesses': payload['clueGuesses'],
        'clueAttempts': payload['clueAttempts'],
      });

      return DataSuccess<StoryModeProgressModel>(data: updated);
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
      if (progress.completedAt != null) {
        return DataSuccess<StoryModeProgressModel>(data: progress);
      }

      final clueSolved = List<bool>.from(progress.clueSolved);
      clueSolved[clueIndex] = solved;

      final nextClueIndex = clueIndex + 1;
      final currentClueIndex = nextClueIndex > progress.currentClueIndex
          ? nextClueIndex
          : progress.currentClueIndex;

      final cluePoints = DetectiveScoreCalculator.pointsForClue(
        solved: solved,
        attempts: progress.clueAttempts[clueIndex],
      );

      final updated = StoryModeProgressModel(
        userId: userId,
        caseId: caseId,
        currentClueIndex: currentClueIndex,
        clueAttempts: List<int>.from(progress.clueAttempts),
        clueGuesses: progress.clueGuesses
            .map((guesses) => List<String>.from(guesses))
            .toList(),
        clueSolved: clueSolved,
        totalScore: progress.totalScore + cluePoints,
        outcome: progress.outcome,
        completedAt: progress.completedAt,
      );
      final payload = updated.toJson();

      await _progressDoc(userId, caseId).update({
        'clueSolved': payload['clueSolved'],
        'currentClueIndex': payload['currentClueIndex'],
        'clueGuesses': payload['clueGuesses'],
        'totalScore': payload['totalScore'],
      });

      return DataSuccess<StoryModeProgressModel>(data: updated);
    } catch (error, stackTrace) {
      return DataError<StoryModeProgressModel>(
        error: AppError.fromException(error),
        stackTrace: stackTrace,
        context: 'StoryProgressDataSource.completeClue',
      );
    }
  }

  @override
  Future<DataState<StoryModeProgressModel>> completeStoryCase({
    required String userId,
    required String caseId,
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
      if (progress.completedAt != null) {
        return DataSuccess<StoryModeProgressModel>(data: progress);
      }

      if (progress.currentClueIndex < 3) {
        return DataError<StoryModeProgressModel>(
          error: AppError(
            error: 'Case is not finished',
            message: 'Complete all clues before closing the case',
            code: '400',
          ),
        );
      }

      final expectedScore = DetectiveScoreCalculator.totalScore(
        clueSolved: progress.clueSolved,
        clueAttempts: progress.clueAttempts,
        currentClueIndex: progress.currentClueIndex,
      );

      final updated = StoryModeProgressModel(
        userId: userId,
        caseId: caseId,
        currentClueIndex: progress.currentClueIndex,
        clueAttempts: List<int>.from(progress.clueAttempts),
        clueGuesses: progress.clueGuesses
            .map((guesses) => List<String>.from(guesses))
            .toList(),
        clueSolved: List<bool>.from(progress.clueSolved),
        totalScore: expectedScore,
        outcome: CaseOutcomeResolver.resolve(progress.clueSolved),
        completedAt: DateTime.now(),
      );
      final payload = updated.toJson();

      await _progressDoc(userId, caseId).update({
        'totalScore': payload['totalScore'],
        'outcome': payload['outcome'],
        'completedAt': payload['completedAt'],
      });

      return DataSuccess<StoryModeProgressModel>(data: updated);
    } catch (error, stackTrace) {
      return DataError<StoryModeProgressModel>(
        error: AppError.fromException(error),
        stackTrace: stackTrace,
        context: 'StoryProgressDataSource.completeStoryCase',
      );
    }
  }
}
