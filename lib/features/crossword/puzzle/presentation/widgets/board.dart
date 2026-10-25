import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/puzzle/domain/utils/grid.dart';

/// How a square is drawn (`design/screens/psc-crossword.md` → Cell states).
enum CrosswordCellState { block, normal, word, cursor, correct, wrong }

CrosswordCellState cellStateOf(CrosswordGrid grid, int index) {
  if (grid.cells[index].isBlock) return CrosswordCellState.block;
  if (index == grid.cursor) return CrosswordCellState.cursor;
  final checked = grid.checkedAt(index);
  if (checked == true) return CrosswordCellState.correct;
  if (checked == false) return CrosswordCellState.wrong;
  if (grid.activeCells.contains(index)) return CrosswordCellState.word;
  return CrosswordCellState.normal;
}

/// The playable grid: square, gap 2, cell radius 4. Rebuilds from [grid];
/// pass the grid's `revision` as [revision] so it repaints after a change.
class CrosswordBoard extends StatelessWidget {
  const CrosswordBoard({
    super.key,
    required this.grid,
    required this.revision,
    this.onCellTap,
  });

  final CrosswordGrid grid;
  final int revision;
  final ValueChanged<int>? onCellTap;

  static const gap = 2.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxSide = min(
          constraints.maxWidth,
          constraints.hasBoundedHeight
              ? constraints.maxHeight
              : double.infinity);
      final cell =
          (maxSide - gap * (grid.cols - 1)) / max(grid.cols, grid.rows);
      final width = cell * grid.cols + gap * (grid.cols - 1);
      final height = cell * grid.rows + gap * (grid.rows - 1);
      return Center(
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              for (final c in grid.cells)
                Positioned(
                  left: c.col * (cell + gap),
                  top: c.row * (cell + gap),
                  width: cell,
                  height: cell,
                  child: CrosswordCellView(
                    key: ValueKey('cell-${c.index}'),
                    state: cellStateOf(grid, c.index),
                    letter: grid.letterAt(c.index),
                    number: c.number,
                    revealed: grid.isRevealed(c.index),
                    semanticsLabel: _label(c),
                    onTap: c.isBlock || onCellTap == null
                        ? null
                        : () => onCellTap!(c.index),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  String _label(GridCell c) {
    if (c.isBlock) return '';
    final letter = grid.letterAt(c.index);
    final checked = grid.checkedAt(c.index);
    return [
      'Row ${c.row + 1}, column ${c.col + 1}',
      if (c.number != null) 'clue ${c.number}',
      letter.isEmpty ? 'empty' : 'letter $letter',
      if (checked == false) 'not right',
      if (checked == true) 'right',
      if (grid.isRevealed(c.index)) 'revealed',
    ].join(', ');
  }
}

/// One square of the grid.
class CrosswordCellView extends StatelessWidget {
  const CrosswordCellView({
    super.key,
    required this.state,
    this.letter = '',
    this.number,
    this.revealed = false,
    this.semanticsLabel = '',
    this.onTap,
  });

  final CrosswordCellState state;
  final String letter;
  final int? number;
  final bool revealed;
  final String semanticsLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (state == CrosswordCellState.block) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: MyColors.gridBlock,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }
    final (fill, border) = switch (state) {
      CrosswordCellState.cursor => (
          MyColors.gridActiveBg,
          MyColors.gridActiveBorder
        ),
      CrosswordCellState.correct => (
          MyColors.gridCorrectBg,
          MyColors.gridCorrectBg
        ),
      CrosswordCellState.wrong => (
          MyColors.gridWrongBg,
          MyColors.gridWrongBorder
        ),
      CrosswordCellState.word => (MyColors.gridWordBg, MyColors.gridWordBorder),
      _ => (MyColors.gridCell, MyColors.gridCellBorder),
    };
    final textColor = revealed
        ? MyColors.gridRevealedText
        : state == CrosswordCellState.cursor
            ? MyColors.gridActiveText
            : MyColors.white;

    return Semantics(
      label: semanticsLabel,
      button: onTap != null,
      selected: state == CrosswordCellState.cursor,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(builder: (context, size) {
          final side = size.maxWidth;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: border,
                width: state == CrosswordCellState.cursor ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                if (number != null)
                  Positioned(
                    left: 3,
                    top: 1,
                    child: Text(
                      '$number',
                      style: TextStyle(
                        fontSize: max(8, side * 0.24),
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        color: state == CrosswordCellState.cursor
                            ? MyColors.gridActiveText
                            : MyColors.gridNumber,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: side * 0.5,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
