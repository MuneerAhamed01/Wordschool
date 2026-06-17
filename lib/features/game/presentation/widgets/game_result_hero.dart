import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
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
    final accent = isWin ? MyColors.tileCorrect : MyColors.streakAccent;

    return FadeSlideIn(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
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
              size: 40,
              color: accent,
            ),
            const SizedBox(height: 10),
            Text(
              _headline(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: MyColors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _subtitle(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MyColors.white.withValues(alpha: 0.75),
                    height: 1.35,
                  ),
              textAlign: TextAlign.center,
            ),
            if (!isWin) ...[
              const SizedBox(height: 14),
              Text(
                'The word was',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: MyColors.textMuted,
                    ),
              ),
              const SizedBox(height: 8),
              _AnswerTiles(word: answerWord),
            ],
            if (isWin && !isArchiveMode && streak != null && streak! > 0) ...[
              const SizedBox(height: 14),
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
  const _AnswerTiles({required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    final letters = word.toUpperCase().split('');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(GameConstants.maxLetters, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: SizedBox(
            width: 44,
            height: 44,
            child: WordTile(
              value: letters.elementAtOrNull(index) ?? '',
              tileType: WordTileType.green,
              instantReveal: true,
              shakeCallBack: (_) {},
            ),
          ),
        );
      }),
    );
  }
}
