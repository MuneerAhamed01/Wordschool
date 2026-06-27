class SaveClueGuessParam {
  const SaveClueGuessParam({
    required this.userId,
    required this.caseId,
    required this.clueIndex,
    required this.guess,
  });

  final String userId;
  final String caseId;
  final int clueIndex;
  final String guess;
}
