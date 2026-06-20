import 'package:equatable/equatable.dart';
import 'package:wordshool/features/story_mode/domain/entities/case_outcome.dart';

class StoryModeProgressEntity extends Equatable {
  final String userId;
  final String caseId;
  final int currentClueIndex;
  final List<int> clueAttempts;
  final List<List<String>> clueGuesses;
  final List<bool> clueSolved;
  final int totalScore;
  final CaseOutcome? outcome;
  final DateTime? completedAt;

  const StoryModeProgressEntity({
    required this.userId,
    required this.caseId,
    required this.currentClueIndex,
    required this.clueAttempts,
    required this.clueGuesses,
    required this.clueSolved,
    required this.totalScore,
    this.outcome,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        caseId,
        currentClueIndex,
        clueAttempts,
        clueGuesses,
        clueSolved,
        totalScore,
        outcome,
        completedAt,
      ];
}
