class WinningPageParam {
  final String word;
  final bool isLost;
  final bool isArchiveMode;
  final String gameDateId;
  final int? updatedStreak;

  WinningPageParam({
    required this.word,
    required this.isLost,
    this.isArchiveMode = false,
    required this.gameDateId,
    this.updatedStreak,
  });
}
