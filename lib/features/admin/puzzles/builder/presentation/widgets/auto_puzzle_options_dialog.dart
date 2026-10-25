import 'package:flutter/material.dart';
import 'package:wordshool/features/admin/puzzles/domain/utils/auto_puzzle.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/auto_puzzle_fields.dart';

/// "Options" on the auto-create card: size, words, difficulty, prefer unused.
class AutoPuzzleOptionsDialog extends StatefulWidget {
  const AutoPuzzleOptionsDialog({super.key, required this.options});

  final AutoPuzzleOptions options;

  /// The new options, or null when cancelled.
  static Future<AutoPuzzleOptions?> show(
          BuildContext context, AutoPuzzleOptions options) =>
      showDialog<AutoPuzzleOptions>(
        context: context,
        builder: (_) => AutoPuzzleOptionsDialog(options: options),
      );

  @override
  State<AutoPuzzleOptionsDialog> createState() =>
      _AutoPuzzleOptionsDialogState();
}

class _AutoPuzzleOptionsDialogState extends State<AutoPuzzleOptionsDialog> {
  late var _options = widget.options;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Auto-create options'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AutoPuzzleFields(
              size: _options.size,
              words: _options.targetWords,
              difficulty: _options.difficulty,
              onSize: (v) => setState(() => _options = _options.copyWith(size: v)),
              onWords: (v) =>
                  setState(() => _options = _options.copyWith(targetWords: v)),
              onDifficulty: (v) => setState(() => _options =
                  _options.copyWith(difficulty: v, clearDifficulty: v == null)),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _options.preferUnused,
              onChanged: (v) =>
                  setState(() => _options = _options.copyWith(preferUnused: v)),
              title: const Text('Prefer questions not in a puzzle yet'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(context, _options),
            child: const Text('Build again')),
      ],
    );
  }
}
