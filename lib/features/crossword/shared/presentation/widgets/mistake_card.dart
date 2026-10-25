import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/shared/presentation/widgets/answer_tiles.dart';

enum MistakeKind { typed, revealed, revise }

/// A word to revise: answer tiles, tag, clue, fact (Results and Revise).
class MistakeCard extends StatelessWidget {
  const MistakeCard({
    super.key,
    required this.answer,
    required this.clue,
    required this.fact,
    required this.kind,
    this.typed,
    this.reference,
    this.trailing,
  });

  final String answer;
  final String clue;
  final String fact;
  final MistakeKind kind;

  /// What the player typed (`VAI·AM`) for [MistakeKind.typed].
  final String? typed;

  /// "2 Down" or a subject label.
  final String? reference;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tag = switch (kind) {
      MistakeKind.typed => (
          typed == null || typed!.replaceAll('·', '').isEmpty
              ? 'Left empty'
              : 'You typed $typed',
          MyColors.errorBg,
          MyColors.errorText
        ),
      MistakeKind.revealed => ('Revealed', MyColors.warnBg, MyColors.warnText),
      MistakeKind.revise => (null, null, null),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MyColors.gameSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColors.gameBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnswerTiles(answer: answer),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (tag.$1 != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tag.$2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(tag.$1!,
                      style: TextStyle(
                          color: tag.$3,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              if (reference != null && reference!.isNotEmpty)
                Text(reference!,
                    style: const TextStyle(
                        color: MyColors.navInactive, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(clue,
              style: const TextStyle(
                  color: MyColors.white, fontWeight: FontWeight.w600)),
          if (fact.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(fact,
                style: const TextStyle(
                    color: MyColors.textSecondary, height: 1.35)),
          ],
          if (trailing != null) ...[const SizedBox(height: 10), trailing!],
        ],
      ),
    );
  }
}
