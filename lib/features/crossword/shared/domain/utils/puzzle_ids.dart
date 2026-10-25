/// Puzzle ids are `{categoryId}-{0000}` (`kerala-history-0012`).
final _puzzleId = RegExp(r'^(.+)-(\d{4})$');

/// `kerala-history` for `kerala-history-0012`; the id itself if it isn't
/// in that shape.
String categoryOfPuzzle(String puzzleId) =>
    _puzzleId.firstMatch(puzzleId)?.group(1) ?? puzzleId;
