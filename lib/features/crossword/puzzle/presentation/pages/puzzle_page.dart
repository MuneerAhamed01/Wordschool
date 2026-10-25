import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/core/remote_config/app_remote_config.dart';
import 'package:wordshool/core/routes/app_routes.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/entities/content_report.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/bloc/puzzle_bloc.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/widgets/clue_bar.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/widgets/clue_chips.dart';
import 'package:wordshool/features/crossword/puzzle/domain/utils/result_args_of.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/widgets/back_row.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/widgets/board.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/widgets/fill_status.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/widgets/finish_dialog.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/widgets/puzzle_header.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/widgets/keyboard.dart';
import 'package:wordshool/features/crossword/puzzle/hints/presentation/widgets/hints_sheet.dart';
import 'package:wordshool/features/crossword/puzzle/report/presentation/widgets/report_sheet.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/app_sheet.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/snackbar.dart';
import 'package:wordshool/shared/presentations/widgets/state_message.dart';

/// Puzzle screen (`design/screens/psc-crossword.md#2-puzzle`, CW-046).
class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key, required this.puzzleId, required this.config});

  static const routeName = AppRoutes.puzzle;

  final String puzzleId;
  final AppRemoteConfig config;

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> with WidgetsBindingObserver {
  final _focus = FocusNode();
  bool _leaving = false;
  bool _canPop = false;

  PuzzleBloc get _bloc => context.read<PuzzleBloc>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Timer pauses and progress saves when the app goes to the background.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _bloc.add(const PuzzleLifecycleChanged(active: false));
    } else if (state == AppLifecycleState.resumed) {
      _bloc.add(const PuzzleLifecycleChanged(active: true));
    }
  }

  /// Saves without waiting for the network (Firestore queues the write and
  /// the bloc finishes it after the route closes), then lets the route pop.
  void _leave() {
    if (_leaving) return;
    _leaving = true;
    unawaited(_bloc.saveNow());
    setState(() => _canPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace) {
      _bloc.add(const PuzzleBackspacePressed());
    } else if (key == LogicalKeyboardKey.enter) {
      _bloc.add(const PuzzleCheckPressed());
    } else if (key == LogicalKeyboardKey.tab) {
      _bloc.add(PuzzleWordStepped(
          forward: !HardwareKeyboard.instance.isShiftPressed));
    } else {
      final ch = event.character?.toUpperCase();
      if (ch == null || !RegExp(r'^[A-Z]$').hasMatch(ch)) {
        return KeyEventResult.ignored;
      }
      _bloc.add(PuzzleLetterTyped(ch));
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: BlocConsumer<PuzzleBloc, PuzzleState>(
        listenWhen: (a, b) =>
            b is PuzzleReady &&
            (a is! PuzzleReady ||
                a.notice != b.notice ||
                a.outcome != b.outcome),
        listener: (context, state) {
          final ready = state as PuzzleReady;
          final outcome = ready.outcome;
          if (outcome != null) {
            context.pushReplacement(
              AppRoutes.resultOf(ready.puzzle.id),
              extra: resultArgsOf(ready.puzzle, ready.grid, outcome),
            );
            return;
          }
          final notice = ready.notice;
          if (notice != null) {
            CustomSnackBar.show(
              context,
              message: notice.message,
              type: notice.isError ? SnackBarType.error : SnackBarType.info,
            );
          }
        },
        builder: (context, state) => GameScaffold(
          body: switch (state) {
            PuzzleLoading() => const Center(child: CircularProgressIndicator()),
            PuzzleLoadFailed(:final message) => Column(
                children: [
                  BackRow(onBack: () => context.pop()),
                  Expanded(
                    child: StateMessage.error(
                      message: message,
                      onAction: () => _bloc.add(PuzzleOpened(widget.puzzleId)),
                    ),
                  ),
                ],
              ),
            PuzzleReady() => Focus(
                focusNode: _focus,
                autofocus: true,
                onKeyEvent: _onKey,
                child: _buildPlaying(context, state),
              ),
          },
        ),
      ),
    );
  }

  Widget _buildPlaying(BuildContext context, PuzzleReady s) {
    final word = s.activeWord;
    final grid = s.grid;
    final filledIds = {
      for (final w in grid.words)
        if (grid.isWordFilled(w.id)) w.id,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        children: [
          PuzzleHeader(
            state: s,
            onBack: _leave,
            onHints: () => _openHints(context, s),
            onMenu: (action) => _onMenu(context, s, action),
          ),
          FillStatus(grid: grid, lastCheck: s.lastCheck),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: CrosswordBoard(
                grid: grid,
                revision: s.revision,
                onCellTap: (i) => _bloc.add(PuzzleCellTapped(i)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          ClueBar(
            word: word,
            onPrevious: () =>
                _bloc.add(const PuzzleWordStepped(forward: false)),
            onNext: () => _bloc.add(const PuzzleWordStepped(forward: true)),
            onMenu: word == null ? null : () => _report(context, s),
          ),
          ClueChips(
            wordIds: [for (final w in grid.words) w.id],
            activeId: grid.activeWord?.id,
            filledIds: filledIds,
            onSelected: (id) => _bloc.add(PuzzleWordSelected(id)),
          ),
          if (grid.isComplete)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: AppButton(
                key: const ValueKey('submit-banner'),
                height: 46,
                isLoading: s.submitting,
                label: grid.isSolved
                    ? 'Solved! View results'
                    : 'All squares filled · Submit',
                onTap: () => _bloc.add(const PuzzleSubmitted()),
              ),
            ),
          CrosswordKeyboard(
            onLetter: (ch) => _bloc.add(PuzzleLetterTyped(ch)),
            onBackspace: () => _bloc.add(const PuzzleBackspacePressed()),
            onCheck: () => _bloc.add(const PuzzleCheckPressed()),
          ),
        ],
      ),
    );
  }

  Future<void> _openHints(BuildContext context, PuzzleReady s) async {
    final word = s.activeWord;
    if (word == null) return;
    final penalties = widget.config.crosswordHintPenalties;
    final grid = s.grid;
    final choice = await showAppSheet<HintChoice>(
      context,
      builder: (_) => HintsSheet(
        word: word,
        revealsLeft: s.revealsLeft,
        letterPenalty: penalties.letter,
        wordPenalty: penalties.word,
        clueShown: s.cluesShown.contains(word.id),
        onShowClue: () => _bloc.add(const PuzzleClueShown()),
        canRevealLetter: !grid.isRevealed(grid.cursor),
        canRevealWord: !grid.revealedWordIds.contains(word.id),
      ),
    );
    if (choice == null) return;
    _bloc.add(PuzzleRevealRequested(word: choice == HintChoice.word));
  }

  Future<void> _report(BuildContext context, PuzzleReady s) async {
    final word = s.activeWord;
    if (word == null) return;
    final picked = await showAppSheet<(ReportReason, String)>(
      context,
      builder: (_) => ReportSheet(word: word),
    );
    if (picked == null) return;
    _bloc.add(PuzzleReported(reason: picked.$1, message: picked.$2));
  }

  Future<void> _onMenu(
      BuildContext context, PuzzleReady s, PuzzleMenuAction action) async {
    switch (action) {
      case PuzzleMenuAction.report:
        await _report(context, s);
      case PuzzleMenuAction.finish:
        final ok = await showFinishDialog(context,
            emptySquares: s.grid.letterCount - s.grid.filledCount);
        if (ok == true) _bloc.add(const PuzzleSubmitted());
    }
  }
}
