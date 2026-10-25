import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/features/crossword/shared/presentation/widgets/tag_chip.dart';

/// One puzzle in the category list with its New / In progress / Done mark.
class PuzzleRow extends StatelessWidget {
  const PuzzleRow({
    super.key,
    required this.puzzle,
    required this.progress,
    required this.onTap,
  });

  final CrosswordPuzzleEntity puzzle;
  final CrosswordProgressEntity? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final (icon, color, status) = p == null
        ? (Icons.fiber_new_rounded, MyColors.accentGlow, 'New')
        : p.isCompleted
            ? (
                Icons.check_circle_rounded,
                MyColors.successText,
                p.result == null ? 'Done' : 'Done · ${p.result!.score}%'
              )
            : (Icons.timelapse_rounded, MyColors.hint, 'In progress');
    return Semantics(
      button: true,
      label: 'Puzzle ${puzzle.number}, ${puzzle.title.en}, '
          '${puzzle.difficulty.label}, $status',
      excludeSemantics: true,
      child: Material(
        color: MyColors.gameSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: MyColors.gameSurfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${puzzle.number}',
                    style: const TextStyle(
                        color: MyColors.white,
                        fontWeight: FontWeight.w800,
                        fontFeatures: [FontFeature.tabularFigures()]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        puzzle.title.en,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: MyColors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          TagChip(label: puzzle.difficulty.label),
                          const SizedBox(width: 6),
                          Text('${puzzle.wordCount} clues',
                              style: const TextStyle(
                                  color: MyColors.navInactive, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: color, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
