import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/utils/game_layout_metrics.dart';
import 'package:wordshool/core/enums/word_tile_type.dart';
import 'package:wordshool/features/game/presentation/utils/constants.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';
import 'package:wordshool/shared/presentations/widgets/streak_chip.dart';
import 'package:wordshool/shared/presentations/widgets/wordle_tile/tile.dart';

class GameResultHero extends StatelessWidget {
  const GameResultHero({
    super.key,
    required this.isWin,
    required this.answerWord,
    required this.guessCount,
    this.streak,
    this.isArchiveMode = false,
  });

  final bool isWin;
  final String answerWord;
  final int guessCount;
  final int? streak;
  final bool isArchiveMode;

  @override
  Widget build(BuildContext context) {
    final metrics = GameLayoutMetrics.of(context);
    final accent = isWin ? MyColors.tileCorrect : MyColors.streakAccent;
    final compact = metrics.isCompact;

    return FadeSlideIn(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(16, compact ? 4 : 8, 16, 0),
        padding: EdgeInsets.fromLTRB(
          compact ? 14 : 18,
          compact ? 12 : 18,
          compact ? 14 : 18,
          compact ? 12 : 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.22),
              MyColors.gameSurfaceElevated,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.45)),
        ),
        child: Column(
          children: [
            Icon(
              isWin ? Icons.emoji_events_rounded : Icons.psychology_alt_rounded,
              size: compact ? 32 : 40,
              color: accent,
            ),
            SizedBox(height: compact ? 6 : 10),
            Text(
              _headline(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: MyColors.white,
                    fontSize: compact ? 20 : null,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: compact ? 4 : 6),
            Text(
              _subtitle(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MyColors.white.withValues(alpha: 0.75),
                    height: 1.35,
                    fontSize: compact ? 13 : null,
                  ),
              textAlign: TextAlign.center,
            ),
            if (!isWin) ...[
              SizedBox(height: compact ? 10 : 14),
              Text(
                'The word was',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: MyColors.textMuted,
                      fontSize: compact ? 12 : null,
                    ),
              ),
              SizedBox(height: compact ? 6 : 8),
              _AnswerTiles(word: answerWord, metrics: metrics),
            ],
            if (isWin && !isArchiveMode && streak != null && streak! > 0) ...[
              SizedBox(height: compact ? 10 : 14),
              StreakChip(streak: streak!),
            ],
          ],
        ),
      ),
    );
  }

  String _headline() {
    if (isWin) {
      if (guessCount == 1) return 'Genius!';
      if (guessCount <= 3) return 'Brilliant!';
      return 'You got it!';
    }
    return 'Almost had it';
  }

  String _subtitle() {
    if (isWin) {
      final guesses = 'in $guessCount of ${GameConstants.maxWords}';
      if (isArchiveMode) return 'You solved this archive puzzle $guesses.';
      return 'Solved $guesses — keep your streak alive tomorrow.';
    }
    if (isArchiveMode) {
      return 'Every puzzle makes you sharper. Replay others in the archive.';
    }
    return 'Don\'t stop now — tomorrow\'s word is waiting for you.';
  }
}

class _AnswerTiles extends StatelessWidget {
  const _AnswerTiles({required this.word, required this.metrics});

  final String word;
  final GameLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final letters = word.toUpperCase().split('');
    final tileSide = metrics.isCompact ? 38.0 : 44.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(GameConstants.maxLetters, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: SizedBox(
            width: tileSide,
            height: tileSide,
            child: WordTile(
              value: letters.elementAtOrNull(index) ?? '',
              tileType: WordTileType.green,
              instantReveal: true,
              fontSize: metrics.tileFontSize,
              shakeCallBack: (_) {},
            ),
          ),
        );
      }),
    );
  }
}
