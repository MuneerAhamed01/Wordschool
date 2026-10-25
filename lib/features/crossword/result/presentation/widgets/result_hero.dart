import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result_args.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';

/// Check mark, puzzle name, "Puzzle solved" and the score.
class ResultHero extends StatelessWidget {
  const ResultHero({super.key, required this.args});

  final ResultArgs args;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final result = args.outcome.result;
    return FadeSlideIn(
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: MyColors.tileCorrect,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.check_rounded,
                color: MyColors.white, size: 48),
          ),
          const SizedBox(height: 14),
          Text(
            '${args.puzzle.title.en} · Puzzle ${args.puzzle.number}',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: MyColors.navInactive),
          ),
          const SizedBox(height: 4),
          Text(
            result.isPerfect ? 'Puzzle solved' : 'Puzzle complete',
            style: textTheme.headlineSmall
                ?.copyWith(color: MyColors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: '${result.score}',
                style: const TextStyle(
                    color: MyColors.successText,
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),
              const TextSpan(
                text: '  points',
                style: TextStyle(color: MyColors.navInactive),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
