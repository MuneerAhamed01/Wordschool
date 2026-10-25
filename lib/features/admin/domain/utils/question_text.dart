// Text rules shared by the question form and bulk upload; they mirror
// functions/crossword/question_logic.py so problems show before saving.

final _strippedFromAnswers = RegExp(r'[\s.\-]');
final _answerPattern = RegExp(r'^[A-Z]{2,}$');
final _nonSnake = RegExp(r'[^a-z0-9]+');
final _edgeUnderscores = RegExp(r'^_+|_+$');
final snakePattern = RegExp(r'^[a-z0-9_]+$');

/// Uppercase and drop spaces, hyphens and dots: `Vasco da-Gama.` → `VASCODAGAMA`.
String normalizeAnswer(String raw) =>
    raw.replaceAll(_strippedFromAnswers, '').toUpperCase();

/// True when [answer] (already normalised) is 2+ letters A–Z.
bool isValidAnswer(String answer) => _answerPattern.hasMatch(answer);

/// Problem with a typed answer, or null when it is fine.
String? answerProblem(String raw) {
  final answer = normalizeAnswer(raw);
  if (answer.isEmpty) return 'Enter the answer';
  if (!isValidAnswer(answer)) {
    return 'Use English letters A–Z only (at least 2). '
        'Spaces, dots and dashes are removed automatically.';
  }
  if (answer.length > 15) return 'Too long for the grid (15 letters at most)';
  return null;
}

/// `"Kerala History"` → `kerala_history` (subjects, topics, exam tags).
String toSnake(String text) => text
    .trim()
    .toLowerCase()
    .replaceAll(_nonSnake, '_')
    .replaceAll(_edgeUnderscores, '');

/// `"LDC, LGS; degree level"` → `[ldc, lgs, degree_level]` (no duplicates).
List<String> parseTags(String text) => text
    .split(RegExp(r'[,;|]'))
    .map(toSnake)
    .where((t) => t.isNotEmpty)
    .toSet()
    .toList();

/// `kerala_history` → `Kerala history`.
String humanize(String snake) {
  final words = snake.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  return words.isEmpty ? words : words[0].toUpperCase() + words.substring(1);
}
