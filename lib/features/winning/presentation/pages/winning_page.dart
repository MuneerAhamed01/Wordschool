import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/enums/word_tile_type.dart';
import 'package:wordshool/core/utils/date_helper.dart';
import 'package:wordshool/features/archive/presentation/pages/archive_page.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/features/winning/presentation/widgets/animated_checkmark.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/streak_chip.dart';
import 'package:wordshool/shared/presentations/widgets/wordle_tile/tile.dart';

class WinningPage extends StatefulWidget {
  static const String routeName = '/winning';

  const WinningPage({
    super.key,
    required this.word,
    this.isLost = false,
    this.isArchiveMode = false,
    required this.gameDateId,
    this.updatedStreak,
  });

  final String word;
  final bool isLost;
  final bool isArchiveMode;
  final String gameDateId;
  final int? updatedStreak;

  @override
  State<WinningPage> createState() => _WinningPageState();
}

class _WinningPageState extends State<WinningPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      body: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeSlideIn(
                child: widget.isLost
                    ? Icon(
                        Icons.auto_awesome_rounded,
                        size: 72,
                        color: MyColors.streakAccent.withValues(alpha: 0.9),
                      )
                    : const AnimatedCheckmarkAvatar(
                        backgroundColor: MyColors.tileCorrect,
                      ),
              ),
              const SizedBox(height: 28),
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  _headline(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              FadeSlideIn(
                delay: const Duration(milliseconds: 140),
                child: Text(
                  _subtitle(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MyColors.textMuted,
                        height: 1.4,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.isLost) ...[
                const SizedBox(height: 16),
                Text(
                  'The word was',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: MyColors.textMuted,
                      ),
                ),
              ],
              const SizedBox(height: 20),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: _buildWordRow(),
              ),
              if (!widget.isLost &&
                  !widget.isArchiveMode &&
                  widget.updatedStreak != null) ...[
                const SizedBox(height: 20),
                StreakChip(streak: widget.updatedStreak!),
              ],
              const SizedBox(height: 32),
              FadeSlideIn(
                delay: const Duration(milliseconds: 320),
                child: AppButton(
                  label: 'Back to Home',
                  icon: Icons.home_outlined,
                  variant: ButtonVariant.primary,
                  onTap: () => context.go(DashboardPage.routeName),
                ),
              ),
              if (widget.isLost && !widget.isArchiveMode) ...[
                const SizedBox(height: 10),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 380),
                  child: AppButton(
                    label: 'Sharpen skills in Archive',
                    icon: Icons.history_rounded,
                    variant: ButtonVariant.secondary,
                    onTap: () => context.push(ArchivePage.routeName),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _headline() {
    if (widget.isLost) {
      return widget.isArchiveMode ? 'Not this time' : 'So close!';
    }
    if (widget.isArchiveMode) {
      return 'Puzzle cracked!';
    }
    return 'You nailed it!';
  }

  String _subtitle() {
    if (widget.isLost) {
      return widget.isArchiveMode
          ? 'Every attempt builds your word sense. Pick another date and try again.'
          : 'The streak resets, but your skill doesn\'t. Tomorrow is a fresh start.';
    }
    if (widget.isArchiveMode) {
      return 'You solved ${_formatDate(widget.gameDateId)} — nice work.';
    }
    if (widget.updatedStreak != null && widget.updatedStreak! > 1) {
      return '${widget.updatedStreak} days in a row — you\'re on fire.';
    }
    return 'Come back tomorrow to keep the momentum going.';
  }

  Widget _buildWordRow() {
    final letters = widget.word.toUpperCase().split('');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: SizedBox(
            width: 52,
            height: 52,
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

  String _formatDate(String dateId) {
    final date = DateHelper.parseDateId(dateId);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
