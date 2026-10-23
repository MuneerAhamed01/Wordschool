import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/admin/domain/utils/grid_validator.dart';

/// Draws a crossword grid. In [editing] mode unused squares look like an
/// empty canvas (they become black squares when saved) and every square is
/// tappable; otherwise unused squares are drawn black, as players see them.
class CrosswordGrid extends StatelessWidget {
  const CrosswordGrid({
    super.key,
    required this.rows,
    required this.cols,
    required this.letters,
    required this.numbers,
    this.highlighted = const {},
    this.problemCells = const {},
    this.showLetters = true,
    this.editing = false,
    this.onCellTap,
    this.maxCellSize = 44,
  });

  final int rows;
  final int cols;
  final Map<Cell, String> letters;
  final Map<Cell, int> numbers;
  final Set<Cell> highlighted;
  final Set<Cell> problemCells;
  final bool showLetters;
  final bool editing;
  final ValueChanged<Cell>? onCellTap;
  final double maxCellSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 2.0;
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : maxCellSize * cols;
        final size = min(maxCellSize, (available - gap * (cols + 1)) / cols)
            .floorToDouble();
        final width = size * cols + gap * (cols + 1);
        final height = size * rows + gap * (rows + 1);
        return Center(
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(gap),
            decoration: BoxDecoration(
              color: MyColors.gridBlock,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                for (var r = 0; r < rows; r++)
                  Padding(
                    padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : gap),
                    child: Row(
                      children: [
                        for (var c = 0; c < cols; c++)
                          Padding(
                            padding:
                                EdgeInsets.only(right: c == cols - 1 ? 0 : gap),
                            child: _GridCell(
                              size: size,
                              letter: letters[(r, c)],
                              number: numbers[(r, c)],
                              highlighted: highlighted.contains((r, c)),
                              problem: problemCells.contains((r, c)),
                              showLetter: showLetters,
                              editing: editing,
                              onTap: onCellTap == null
                                  ? null
                                  : () => onCellTap!((r, c)),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.size,
    required this.letter,
    required this.number,
    required this.highlighted,
    required this.problem,
    required this.showLetter,
    required this.editing,
    required this.onTap,
  });

  final double size;
  final String? letter;
  final int? number;
  final bool highlighted;
  final bool problem;
  final bool showLetter;
  final bool editing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLetter = letter != null;
    final Color background;
    Color? border;
    if (problem) {
      background = MyColors.gridWrongBg;
      border = MyColors.gridWrongBorder;
    } else if (highlighted) {
      background = MyColors.gridWordBg;
      border = MyColors.gridWordBorder;
    } else if (isLetter) {
      background = MyColors.gridCell;
    } else {
      background = editing ? MyColors.gameSurface : MyColors.gridBlock;
      if (editing) border = MyColors.gameBorderSubtle;
    }

    final cell = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size > 24 ? 4 : 2),
        border: border == null ? null : Border.all(color: border, width: 1.5),
      ),
      child: Stack(
        children: [
          if (number != null && size >= 22)
            Positioned(
              left: 3,
              top: 1,
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: max(8, size * 0.24),
                  color: MyColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (isLetter && showLetter)
            Center(
              child: Text(
                letter!,
                style: TextStyle(
                  fontSize: size * 0.48,
                  fontWeight: FontWeight.w800,
                  color: problem ? MyColors.errorText : MyColors.white,
                ),
              ),
            ),
        ],
      ),
    );
    if (onTap == null) return cell;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: cell),
    );
  }
}
