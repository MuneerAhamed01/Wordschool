import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/word.dart';

/// "2 DOWN · 6 LETTERS" + clue, with previous/next chevrons. Long press
/// (or the ⋯ button) opens the word menu ("Report a wrong answer").
class ClueBar extends StatelessWidget {
  const ClueBar({
    super.key,
    required this.word,
    required this.onPrevious,
    required this.onNext,
    this.onMenu,
  });

  final CrosswordWordEntity? word;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onLongPress: onMenu,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        decoration: BoxDecoration(
          color: MyColors.clueBarBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MyColors.clueBarBorder),
        ),
        child: Row(
          children: [
            _Chevron(
              icon: Icons.chevron_left_rounded,
              label: 'Previous clue',
              onTap: onPrevious,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      word?.label ?? '',
                      style: textTheme.labelSmall?.copyWith(
                        color: MyColors.clueBarLabel,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      word?.clue.en ?? '',
                      style: textTheme.bodyMedium?.copyWith(
                        color: MyColors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (onMenu != null)
              IconButton(
                tooltip: 'More',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 44),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_horiz_rounded,
                    color: MyColors.navInactive, size: 20),
                onPressed: onMenu,
              ),
            _Chevron(
              icon: Icons.chevron_right_rounded,
              label: 'Next clue',
              onTap: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: 40,
          height: 44,
          child: Icon(icon, color: MyColors.clueBarLabel),
        ),
      ),
    );
  }
}
