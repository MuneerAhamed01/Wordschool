enum GameMode {
  daily,
  archive,
  story,
}

extension GameModeAnalytics on GameMode {
  String get analyticsName => name;
}
