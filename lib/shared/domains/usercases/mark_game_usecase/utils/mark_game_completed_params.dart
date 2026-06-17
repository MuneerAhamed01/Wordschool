class MarkGameCompletedParam {
  final String gameId;
  final bool isCorrect;
  final bool isArchiveMode;

  MarkGameCompletedParam({
    required this.gameId,
    required this.isCorrect,
    this.isArchiveMode = false,
  });
}
