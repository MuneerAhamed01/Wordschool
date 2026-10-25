class SetRevisionMasteredParam {
  const SetRevisionMasteredParam({
    required this.questionId,
    this.mastered = true,
  });

  final String questionId;
  final bool mastered;
}
