import 'package:wordshool/features/admin/domain/models/admin_enums.dart';

/// Allowed moves, as in functions/crossword/status_logic.py `TRANSITIONS`.
const puzzleTransitions = <PuzzleStatus, List<PuzzleStatus>>{
  PuzzleStatus.draft: [PuzzleStatus.inReview],
  PuzzleStatus.inReview: [
    PuzzleStatus.draft,
    PuzzleStatus.scheduled,
    PuzzleStatus.published
  ],
  PuzzleStatus.scheduled: [PuzzleStatus.scheduled, PuzzleStatus.published],
  PuzzleStatus.published: [PuzzleStatus.archived],
  PuzzleStatus.archived: [],
};

/// A button on the puzzle page that moves it to [target].
class StatusAction {
  const StatusAction({
    required this.target,
    required this.label,
    required this.description,
    this.needsDate = false,
    this.confirm,
    this.primary = false,
    this.destructive = false,
  });

  final PuzzleStatus target;
  final String label;
  final String description;

  /// Asks for a go-live date and time (scheduled).
  final bool needsDate;

  /// Confirmation text; null = no confirmation.
  final String? confirm;
  final bool primary;
  final bool destructive;
}

/// What the admin can do with a puzzle in [status], best action first.
List<StatusAction> statusActions(PuzzleStatus status) {
  final actions = <StatusAction>[];
  for (final target in puzzleTransitions[status]!) {
    actions.add(switch ((status, target)) {
      (_, PuzzleStatus.inReview) => const StatusAction(
          target: PuzzleStatus.inReview,
          label: 'Send for review',
          description:
              'Ask a second person to check the puzzle before it goes live.',
          primary: true,
        ),
      (_, PuzzleStatus.draft) => const StatusAction(
          target: PuzzleStatus.draft,
          label: 'Back to draft',
          description: 'Something needs changing — move it back to Draft.',
        ),
      (PuzzleStatus.scheduled, PuzzleStatus.scheduled) => const StatusAction(
          target: PuzzleStatus.scheduled,
          label: 'Change date',
          description: 'Pick a different go-live date and time.',
          needsDate: true,
        ),
      (_, PuzzleStatus.scheduled) => const StatusAction(
          target: PuzzleStatus.scheduled,
          label: 'Schedule',
          description: 'Pick a date; it goes live by itself at that time.',
          needsDate: true,
          primary: true,
        ),
      (_, PuzzleStatus.published) => const StatusAction(
          target: PuzzleStatus.published,
          label: 'Publish now',
          description: 'Players can play it straight away.',
          confirm:
              'Players will be able to see and play this puzzle straight away. '
              'After this it can no longer be edited.',
        ),
      (_, PuzzleStatus.archived) => const StatusAction(
          target: PuzzleStatus.archived,
          label: 'Archive',
          description: 'Hide it from players. This can\'t be undone.',
          confirm: 'Players will no longer see this puzzle. Archived puzzles '
              'can\'t be published or edited again.',
          destructive: true,
        ),
    });
  }
  return actions;
}

/// Puzzles that may be the puzzle of the day on a date (server: CW-018):
/// published ones, or scheduled ones going live by 00:00 IST that day.
bool canBeDaily({
  required PuzzleStatus status,
  required DateTime? publishAt,
  required DateTime dayStart,
}) {
  if (status == PuzzleStatus.published) return true;
  return status == PuzzleStatus.scheduled &&
      publishAt != null &&
      !publishAt.isAfter(dayStart);
}
