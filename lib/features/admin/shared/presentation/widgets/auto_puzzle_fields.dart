import 'package:flutter/material.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/utils/grid_validator.dart';

/// Grid size, number of words and difficulty for "Auto-create puzzle"
/// (CW-038), on the Questions dialog and the builder's Options dialog.
class AutoPuzzleFields extends StatelessWidget {
  const AutoPuzzleFields({
    super.key,
    required this.size,
    required this.words,
    required this.difficulty,
    required this.onSize,
    required this.onWords,
    required this.onDifficulty,
  });

  static const minWords = 2;
  static const maxWords = 20;

  final int size;
  final int words;

  /// Null = any difficulty.
  final Difficulty? difficulty;
  final ValueChanged<int> onSize;
  final ValueChanged<int> onWords;
  final ValueChanged<Difficulty?> onDifficulty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: size,
                decoration: const InputDecoration(
                    labelText: 'Grid size', helperText: 'Fitted to the words'),
                items: [
                  for (var s = minGridSize; s <= maxGridSize; s++)
                    DropdownMenuItem(value: s, child: Text('$s × $s')),
                ],
                onChanged: (v) => v == null ? null : onSize(v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: words,
                decoration: const InputDecoration(
                    labelText: 'Words', helperText: 'At most'),
                items: [
                  for (var w = minWords; w <= maxWords; w++)
                    DropdownMenuItem(value: w, child: Text('$w')),
                ],
                onChanged: (v) => v == null ? null : onWords(v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<Difficulty?>(
          value: difficulty,
          decoration: const InputDecoration(labelText: 'Question difficulty'),
          items: [
            const DropdownMenuItem<Difficulty?>(value: null, child: Text('Any')),
            for (final d in Difficulty.values)
              DropdownMenuItem<Difficulty?>(value: d, child: Text(d.label)),
          ],
          onChanged: onDifficulty,
        ),
      ],
    );
  }
}
