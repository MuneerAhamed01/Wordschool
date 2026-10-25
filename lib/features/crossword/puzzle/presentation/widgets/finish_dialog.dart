import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// "Finish this puzzle?" — true when the player confirms.
Future<bool?> showFinishDialog(
  BuildContext context, {
  required int emptySquares,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: MyColors.sheetBackground,
      title: const Text('Finish this puzzle?',
          style: TextStyle(color: MyColors.white)),
      content: Text(
        emptySquares == 0
            ? 'Your answers will be scored now.'
            : '$emptySquares squares are still empty. Words that aren\'t '
                'complete count as mistakes.',
        style: const TextStyle(color: MyColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Keep playing'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Finish'),
        ),
      ],
    ),
  );
}
