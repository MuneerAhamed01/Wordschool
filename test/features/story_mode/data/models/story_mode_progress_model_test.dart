import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/story_mode/data/models/story_mode_progress.dart';
import 'package:wordshool/features/story_mode/domain/entities/case_outcome.dart';

void main() {
  group('StoryModeProgressModel', () {
    test('empty factory creates default progress shape', () {
      final progress = StoryModeProgressModel.empty(
        userId: 'user-123',
        caseId: '2026-06-18',
      );

      expect(progress.userId, 'user-123');
      expect(progress.caseId, '2026-06-18');
      expect(progress.currentClueIndex, 0);
      expect(progress.clueAttempts, [0, 0, 0]);
      expect(progress.clueGuesses, [[], [], []]);
      expect(progress.clueSolved, [false, false, false]);
      expect(progress.totalScore, 0);
      expect(progress.outcome, isNull);
      expect(progress.completedAt, isNull);
    });

    test('round-trips JSON with nested guesses and outcome', () {
      final completedAt = DateTime.utc(2026, 6, 18, 15, 30);
      final model = StoryModeProgressModel(
        userId: 'user-123',
        caseId: '2026-06-18',
        currentClueIndex: 2,
        clueAttempts: const [2, 3, 1],
        clueGuesses: const [
          ['CRANE', 'STUDY'],
          ['BLADE', 'KNIFE', 'SWORD'],
          ['HEIRS'],
        ],
        clueSolved: const [true, true, true],
        totalScore: 240,
        outcome: CaseOutcome.caseClosed,
        completedAt: completedAt,
      );

      final json = model.toJson();
      final restored = StoryModeProgressModel.fromJson(
        json,
        userId: 'user-123',
        caseId: '2026-06-18',
      );

      expect(restored.userId, model.userId);
      expect(restored.caseId, model.caseId);
      expect(restored.currentClueIndex, model.currentClueIndex);
      expect(restored.clueAttempts, model.clueAttempts);
      expect(restored.clueGuesses, model.clueGuesses);
      expect(restored.clueSolved, model.clueSolved);
      expect(restored.totalScore, model.totalScore);
      expect(restored.outcome, CaseOutcome.caseClosed);
      expect(restored.completedAt?.millisecondsSinceEpoch,
          completedAt.millisecondsSinceEpoch);
      expect(json['outcome'], 'case_closed');
      expect(json['completedAt'], isA<Timestamp>());
    });

    test('omits userId and caseId from Firestore payload', () {
      final model = StoryModeProgressModel.empty(
        userId: 'user-123',
        caseId: '2026-06-18',
      );

      final json = model.toJson();

      expect(json.containsKey('userId'), isFalse);
      expect(json.containsKey('caseId'), isFalse);
    });

    test('restores null outcome and completedAt', () {
      final json = StoryModeProgressModel.empty(
        userId: 'user-123',
        caseId: '2026-06-18',
      ).toJson();

      final restored = StoryModeProgressModel.fromJson(
        json,
        userId: 'user-123',
        caseId: '2026-06-18',
      );

      expect(restored.outcome, isNull);
      expect(restored.completedAt, isNull);
    });
  });
}
