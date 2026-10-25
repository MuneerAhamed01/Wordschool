/// The server joins every problem with "; " (functions/crossword/errors.py).
List<String> splitProblems(String message) => message
    .split('; ')
    .map((p) => p.trim())
    .where((p) => p.isNotEmpty)
    .toList();
