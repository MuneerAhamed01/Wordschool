class MarkGameCompletedResult {
  const MarkGameCompletedResult({
    required this.wasAlreadyCompleted,
    this.updatedStreak,
  });

  final bool wasAlreadyCompleted;
  final int? updatedStreak;
}
