// Wire values of the crossword enums (functions/crossword/types.py) with
// plain-language labels for the admin panel.

enum PuzzleStatus {
  draft('draft', 'Draft', 'Being built — only admins can see it.'),
  inReview('in_review', 'In review', 'Ready for a second person to check.'),
  scheduled('scheduled', 'Scheduled', 'Goes live automatically on its date.'),
  published('published', 'Live', 'Players can see and play it.'),
  archived('archived', 'Archived', 'Hidden from players. Can\'t be changed.');

  const PuzzleStatus(this.value, this.label, this.help);

  final String value;
  final String label;
  final String help;

  /// Only drafts and puzzles in review can be edited (server: CW-017).
  bool get isEditable => this == draft || this == inReview;

  static PuzzleStatus fromValue(Object? value) =>
      values.firstWhere((s) => s.value == value, orElse: () => draft);
}

enum QuestionStatus {
  draft('draft', 'Needs checking'),
  verified('verified', 'Checked'),
  retired('retired', 'Retired');

  const QuestionStatus(this.value, this.label);

  final String value;
  final String label;

  static QuestionStatus fromValue(Object? value) =>
      values.firstWhere((s) => s.value == value, orElse: () => draft);
}

enum Difficulty {
  easy('easy', 'Easy'),
  medium('medium', 'Medium'),
  hard('hard', 'Hard');

  const Difficulty(this.value, this.label);

  final String value;
  final String label;

  static Difficulty fromValue(Object? value) =>
      values.firstWhere((d) => d.value == value, orElse: () => medium);

  static Difficulty? tryValue(Object? value) {
    for (final d in values) {
      if (d.value == value) return d;
    }
    return null;
  }
}

enum SourceType {
  pyq('pyq', 'Previous PSC question paper'),
  book('book', 'Book'),
  website('website', 'Website'),
  other('other', 'Other');

  const SourceType(this.value, this.label);

  final String value;
  final String label;

  static SourceType fromValue(Object? value) =>
      values.firstWhere((s) => s.value == value, orElse: () => other);

  static SourceType? tryValue(Object? value) {
    for (final s in values) {
      if (s.value == value) return s;
    }
    return null;
  }
}

enum ReportStatus {
  open('open', 'Open'),
  fixed('fixed', 'Fixed'),
  rejected('rejected', 'Rejected');

  const ReportStatus(this.value, this.label);

  final String value;
  final String label;

  static ReportStatus fromValue(Object? value) =>
      values.firstWhere((s) => s.value == value, orElse: () => open);
}

enum ReportReason {
  wrongAnswer('wrong_answer', 'Wrong answer'),
  typo('typo', 'Typo'),
  other('other', 'Other');

  const ReportReason(this.value, this.label);

  final String value;
  final String label;

  static ReportReason fromValue(Object? value) =>
      values.firstWhere((r) => r.value == value, orElse: () => other);
}

enum WordDirection {
  across('across', 'Across', 'A'),
  down('down', 'Down', 'D');

  const WordDirection(this.value, this.label, this.letter);

  final String value;
  final String label;
  final String letter;

  int get dRow => this == down ? 1 : 0;
  int get dCol => this == across ? 1 : 0;

  static WordDirection fromValue(Object? value) =>
      value == 'down' ? down : across;
}
