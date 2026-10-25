/// What changed after a player action, so other open tabs can refresh
/// without a Firestore listener.
enum CrosswordChange {
  /// Stats, mistakes and ranks changed (`submitCrossword`).
  puzzleSubmitted,

  /// A "My mistakes" item was marked as learned or not.
  revisionChanged,
}
