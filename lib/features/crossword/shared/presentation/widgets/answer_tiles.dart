import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// The answer as green letter tiles (26 × 30).
class AnswerTiles extends StatelessWidget {
  const AnswerTiles({super.key, required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Answer: $answer',
      excludeSemantics: true,
      child: Wrap(
        spacing: 3,
        runSpacing: 3,
        children: [
          for (final ch in answer.split(''))
            Container(
              width: 26,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: MyColors.tileCorrect,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(ch,
                  style: const TextStyle(
                      color: MyColors.white, fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }
}
