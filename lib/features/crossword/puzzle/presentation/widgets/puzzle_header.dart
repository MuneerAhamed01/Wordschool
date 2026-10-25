import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/bloc/puzzle_bloc.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/widgets/header_chips.dart';

enum PuzzleMenuAction { report, finish }

/// Back, title, timer, hints and the ⋮ menu.
class PuzzleHeader extends StatelessWidget {
  const PuzzleHeader({
    super.key,
    required this.state,
    required this.onBack,
    required this.onHints,
    required this.onMenu,
  });

  final PuzzleReady state;
  final VoidCallback onBack;
  final VoidCallback onHints;
  final ValueChanged<PuzzleMenuAction> onMenu;

  @override
  Widget build(BuildContext context) {
    final p = state.puzzle;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: const Icon(Icons.arrow_back_rounded, color: MyColors.white),
            onPressed: onBack,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  p.title.en,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: MyColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
                Text(
                  'Puzzle ${p.number} · ${p.difficulty.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: MyColors.navInactive, fontSize: 11),
                ),
              ],
            ),
          ),
          TimerChip(seconds: state.elapsedSec, paused: state.paused),
          HintButton(remaining: state.revealsLeft, onTap: onHints),
          PopupMenuButton<PuzzleMenuAction>(
            tooltip: 'More',
            color: MyColors.sheetBackground,
            icon: const Icon(Icons.more_vert_rounded, color: MyColors.white),
            onSelected: onMenu,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: PuzzleMenuAction.report,
                child: Text('Report a wrong answer',
                    style: TextStyle(color: MyColors.white)),
              ),
              PopupMenuItem(
                value: PuzzleMenuAction.finish,
                child: Text('Finish puzzle',
                    style: TextStyle(color: MyColors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
