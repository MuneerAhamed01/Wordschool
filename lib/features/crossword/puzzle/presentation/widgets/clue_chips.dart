import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// `1A 4A 5A … 1D 2D` chips: default, filled (green) or active (gold).
/// Scrolls sideways when they don't fit.
class ClueChips extends StatelessWidget {
  const ClueChips({
    super.key,
    required this.wordIds,
    required this.activeId,
    required this.filledIds,
    required this.onSelected,
  });

  final List<String> wordIds;
  final String? activeId;
  final Set<String> filledIds;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: wordIds.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final id = wordIds[i];
          final active = id == activeId;
          final filled = filledIds.contains(id);
          final (bg, fg, border) = active
              ? (MyColors.hint, MyColors.gameBackground, MyColors.hint)
              : filled
                  ? (
                      MyColors.successBg,
                      MyColors.successText,
                      MyColors.successBg
                    )
                  : (
                      MyColors.gameSurface,
                      MyColors.textSecondary,
                      MyColors.gameBorder
                    );
          return Semantics(
            button: true,
            selected: active,
            label: 'Clue $id${filled ? ', filled' : ''}',
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(id),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 30,
                  constraints: const BoxConstraints(minWidth: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Text(
                    id,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
