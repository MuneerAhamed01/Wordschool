import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/story_mode/data/data_source/story_progress_service.dart';
import 'package:wordshool/features/story_mode/data/models/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/entities/case_outcome.dart';
import 'package:wordshool/features/story_mode/domain/utils/case_outcome_resolver.dart';
import 'package:wordshool/features/story_mode/domain/utils/detective_score_calculator.dart';

class InMemoryStoryProgressDataSource extends StoryProgressDataSource {
  final Map<String, StoryModeProgressModel> _docs = {};

  String _key(String userId, String caseId) => '$userId:$caseId';

  @override
  Future<DataState<StoryModeProgressModel>> ensureProgressDoc({
    required String userId,
    required String caseId,
  }) async {
    final key = _key(userId, caseId);
    final existing = _docs[key];
    if (existing != null) {
      return DataSuccess(data: existing);
    }

    final empty = StoryModeProgressModel.empty(userId: userId, caseId: caseId);
    _docs[key] = empty;
    return DataSuccess(data: empty);
  }

  @override
  Future<DataState<StoryModeProgressModel>> saveClueGuess({
    required String userId,
    required String caseId,
    required int clueIndex,
    required String guess,
  }) async {
    final ensureResult = await ensureProgressDoc(userId: userId, caseId: caseId);
    if (ensureResult is! DataSuccess<StoryModeProgressModel>) {
      return ensureResult;
    }

    final progress = ensureResult.data!;
    if (progress.completedAt != null) {
      return DataSuccess(data: progress);
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
    _docs[_key(userId, caseId)] = updated;
    return DataSuccess(data: updated);
  }

  @override
  Future<DataState<StoryModeProgressModel>> completeClue({
    required String userId,
    required String caseId,
    required int clueIndex,
    required bool solved,
  }) async {
    final ensureResult = await ensureProgressDoc(userId: userId, caseId: caseId);
    if (ensureResult is! DataSuccess<StoryModeProgressModel>) {
      return ensureResult;
    }

    final progress = ensureResult.data!;
    if (progress.completedAt != null) {
      return DataSuccess(data: progress);
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
    _docs[_key(userId, caseId)] = updated;
    return DataSuccess(data: updated);
  }

  @override
  Future<DataState<StoryModeProgressModel>> completeStoryCase({
    required String userId,
    required String caseId,
  }) async {
    final ensureResult = await ensureProgressDoc(userId: userId, caseId: caseId);
    if (ensureResult is! DataSuccess<StoryModeProgressModel>) {
      return ensureResult;
    }

    final progress = ensureResult.data!;
    if (progress.completedAt != null) {
      return DataSuccess(data: progress);
    }

    if (progress.currentClueIndex < 3) {
      return DataError<StoryModeProgressModel>(
        error: AppError(error: 'Case is not finished', code: '400'),
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
      completedAt: DateTime.utc(2026, 6, 27),
    );
    _docs[_key(userId, caseId)] = updated;
    return DataSuccess(data: updated);
  }
}

void main() {
  group('StoryProgressDataSource', () {
    late InMemoryStoryProgressDataSource dataSource;

    setUp(() {
      dataSource = InMemoryStoryProgressDataSource();
    });

    test('saveClueGuess appends guess and increments attempts', () async {
      final saveResult = await dataSource.saveClueGuess(
        userId: 'user-1',
        caseId: '2026-06-18',
        clueIndex: 0,
        guess: 'study',
      );

      expect(saveResult, isA<DataSuccess<StoryModeProgressModel>>());
      final progress = (saveResult as DataSuccess<StoryModeProgressModel>).data!;
      expect(progress.clueGuesses[0], ['STUDY']);
      expect(progress.clueAttempts[0], 1);
    });

    test('completeClue marks solved, advances index, and scores clue', () async {
      await dataSource.saveClueGuess(
        userId: 'user-1',
        caseId: '2026-06-18',
        clueIndex: 0,
        guess: 'study',
      );

      final completeResult = await dataSource.completeClue(
        userId: 'user-1',
        caseId: '2026-06-18',
        clueIndex: 0,
        solved: true,
      );

      expect(completeResult, isA<DataSuccess<StoryModeProgressModel>>());
      final progress =
          (completeResult as DataSuccess<StoryModeProgressModel>).data!;
      expect(progress.clueSolved[0], isTrue);
      expect(progress.currentClueIndex, 1);
      expect(progress.totalScore, 100);
    });

    test('completeClue on failed clue advances without points', () async {
      for (var i = 0; i < 5; i++) {
        await dataSource.saveClueGuess(
          userId: 'user-1',
          caseId: '2026-06-18',
          clueIndex: 0,
          guess: 'wrong',
        );
      }

      final completeResult = await dataSource.completeClue(
        userId: 'user-1',
        caseId: '2026-06-18',
        clueIndex: 0,
        solved: false,
      );

      final progress =
          (completeResult as DataSuccess<StoryModeProgressModel>).data!;
      expect(progress.clueSolved[0], isFalse);
      expect(progress.currentClueIndex, 1);
      expect(progress.clueAttempts[0], 5);
      expect(progress.totalScore, 0);
    });

    test('completeStoryCase sets outcome and completedAt', () async {
      for (var clueIndex = 0; clueIndex < 3; clueIndex++) {
        await dataSource.saveClueGuess(
          userId: 'user-1',
          caseId: '2026-06-18',
          clueIndex: clueIndex,
          guess: 'study',
        );
        await dataSource.completeClue(
          userId: 'user-1',
          caseId: '2026-06-18',
          clueIndex: clueIndex,
          solved: true,
        );
      }

      final result = await dataSource.completeStoryCase(
        userId: 'user-1',
        caseId: '2026-06-18',
      );

      final progress = (result as DataSuccess<StoryModeProgressModel>).data!;
      expect(progress.totalScore, 300);
      expect(progress.outcome, CaseOutcome.caseClosed);
      expect(progress.completedAt, isNotNull);
    });

    test('completeStoryCase cold case when one clue failed', () async {
      for (var i = 0; i < 5; i++) {
        await dataSource.saveClueGuess(
          userId: 'user-1',
          caseId: '2026-06-18',
          clueIndex: 0,
          guess: 'wrong',
        );
      }
      await dataSource.completeClue(
        userId: 'user-1',
        caseId: '2026-06-18',
        clueIndex: 0,
        solved: false,
      );

      for (var clueIndex = 1; clueIndex < 3; clueIndex++) {
        await dataSource.saveClueGuess(
          userId: 'user-1',
          caseId: '2026-06-18',
          clueIndex: clueIndex,
          guess: 'study',
        );
        await dataSource.completeClue(
          userId: 'user-1',
          caseId: '2026-06-18',
          clueIndex: clueIndex,
          solved: true,
        );
      }

      final result = await dataSource.completeStoryCase(
        userId: 'user-1',
        caseId: '2026-06-18',
      );

      final progress = (result as DataSuccess<StoryModeProgressModel>).data!;
      expect(progress.totalScore, 200);
      expect(progress.outcome, CaseOutcome.coldCase);
    });
  });
}
