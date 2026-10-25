class LoadHomeProgressParam {
  const LoadHomeProgressParam({
    this.dailyPuzzleId,
    required this.categoryIds,
  });

  final String? dailyPuzzleId;
  final List<String> categoryIds;
}
