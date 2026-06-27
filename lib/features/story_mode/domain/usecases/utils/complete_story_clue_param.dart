class CompleteStoryClueParam {
  const CompleteStoryClueParam({
    required this.userId,
    required this.caseId,
    required this.clueIndex,
    required this.solved,
  });

  final String userId;
  final String caseId;
  final int clueIndex;
  final bool solved;
}
