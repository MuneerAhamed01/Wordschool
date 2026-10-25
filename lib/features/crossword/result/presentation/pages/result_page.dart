import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/remote_config/app_remote_config.dart';
import 'package:wordshool/core/routes/app_routes.dart';
import 'package:wordshool/features/crossword/result/domain/utils/xp_level.dart';
import 'package:wordshool/features/crossword/result/presentation/widgets/level_card.dart';
import 'package:wordshool/features/crossword/result/presentation/widgets/result_hero.dart';
import 'package:wordshool/features/crossword/result/presentation/widgets/result_stats.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result_args.dart';
import 'package:wordshool/features/crossword/shared/presentation/utils/format.dart';
import 'package:wordshool/features/crossword/shared/presentation/widgets/mistake_card.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/snackbar.dart';
import 'package:wordshool/shared/presentations/widgets/state_message.dart';

/// Results (`design/screens/psc-crossword.md#4-results`, CW-049).
class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.args, required this.config});

  static const routeName = AppRoutes.result;

  /// Null when opened without the puzzle screen (deep link / restart).
  final ResultArgs? args;
  final AppRemoteConfig config;

  @override
  Widget build(BuildContext context) {
    final a = args;
    if (a == null) return _buildUnavailable(context);
    final formula = config.xpLevelFormula;
    final level =
        levelFor(a.outcome.xp, base: formula.base, growth: formula.growth);

    return GameScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _buildTopBar(context, a),
          ResultHero(args: a),
          const SizedBox(height: 18),
          ResultStats(outcome: a.outcome),
          const SizedBox(height: 16),
          LevelCard(level: level),
          const SizedBox(height: 20),
          ..._buildMistakes(context, a),
          const SizedBox(height: 8),
          ..._buildActions(context, a),
        ],
      ),
    );
  }

  Widget _buildUnavailable(BuildContext context) {
    return GameScaffold(
      body: StateMessage(
        icon: Icons.grid_view_rounded,
        title: 'Result not available',
        message: 'Open the puzzle again from its category to see it.',
        actionLabel: 'Go to Home',
        onAction: () => context.go(AppRoutes.home),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ResultArgs a) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Close',
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          icon: const Icon(Icons.close_rounded, color: MyColors.white),
          onPressed: () => context.go(AppRoutes.home),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Copy result',
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          icon: const Icon(Icons.ios_share_rounded, color: MyColors.white),
          onPressed: () => _copy(context, a),
        ),
      ],
    );
  }

  List<Widget> _buildMistakes(BuildContext context, ResultArgs a) {
    return [
      Text(
        a.mistakes.isEmpty ? 'No mistakes — great work!' : 'Mistakes to revise',
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: MyColors.white, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      for (final m in a.mistakes) ...[
        MistakeCard(
          answer: m.answer,
          clue: m.clue,
          fact: m.fact,
          kind: m.revealed ? MistakeKind.revealed : MistakeKind.typed,
          typed: m.typed,
          reference: m.reference,
        ),
        const SizedBox(height: 10),
      ],
    ];
  }

  List<Widget> _buildActions(BuildContext context, ResultArgs a) {
    return [
      if (a.mistakes.isNotEmpty) ...[
        AppButton(
          key: const ValueKey('revise-mistakes'),
          label: 'Revise ${plural(a.mistakes.length, 'mistake')}',
          height: 50,
          onTap: () => context.go(AppRoutes.revise),
        ),
        const SizedBox(height: 10),
      ],
      AppButton(
        key: const ValueKey('next-puzzle'),
        label: 'Next puzzle',
        height: 50,
        variant:
            a.mistakes.isEmpty ? ButtonVariant.primary : ButtonVariant.ghost,
        onTap: () =>
            context.pushReplacement(AppRoutes.categoryOf(a.puzzle.categoryId)),
      ),
    ];
  }

  Future<void> _copy(BuildContext context, ResultArgs a) async {
    final r = a.outcome.result;
    await Clipboard.setData(ClipboardData(
      text: 'PSC Crossword · ${a.puzzle.title.en} (Puzzle ${a.puzzle.number})\n'
          '${r.score}% · ${r.correctWords}/${r.totalWords} words · '
          '${formatClock(r.timeSec)} · +${r.xpEarned} XP',
    ));
    if (context.mounted) {
      CustomSnackBar.show(context,
          message: 'Result copied — paste it anywhere.');
    }
  }
}
