import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/admin/shared/domain/utils/server_problems.dart';
import 'package:wordshool/shared/presentations/widgets/snackbar.dart';

void showSuccess(BuildContext context, String message) {
  CustomSnackBar.show(context, message: message, type: SnackBarType.success);
}

/// Shows the server's message. When it lists several problems the snackbar
/// gets a "See all" button that opens them as a list.
void showAdminError(BuildContext context, AppError? error) {
  final message = error?.message ?? 'Something went wrong.';
  final problems = splitProblems(message);
  if (problems.length <= 1) {
    CustomSnackBar.show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: const Duration(seconds: 6),
    );
    return;
  }
  CustomSnackBar.show(
    context,
    message: '${problems.length} things need fixing: ${problems.first}',
    type: SnackBarType.error,
    duration: const Duration(seconds: 8),
    actionLabel: 'See all',
    onAction: () => showProblemsDialog(context, problems),
  );
}

Future<void> showProblemsDialog(
  BuildContext context,
  List<String> problems, {
  String title = 'Please fix these',
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(child: ProblemList(problems: problems)),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Red bullet list of problems.
class ProblemList extends StatelessWidget {
  const ProblemList({super.key, required this.problems, this.maxItems});

  final List<String> problems;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final shown =
        maxItems == null ? problems : problems.take(maxItems!).toList();
    final hidden = problems.length - shown.length;
    final style = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: MyColors.errorText, height: 1.35);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final problem in shown)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.error_outline,
                      size: 16, color: MyColors.errorText),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(problem, style: style)),
              ],
            ),
          ),
        if (hidden > 0) Text('…and $hidden more', style: style),
      ],
    );
  }
}

/// Yes/no dialog. Returns true when the user confirms.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SizedBox(width: 440, child: Text(message)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: MyColors.gridWrongBg)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
