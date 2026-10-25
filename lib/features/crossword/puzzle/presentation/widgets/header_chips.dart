import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/shared/presentation/utils/format.dart';

/// `mm:ss` timer; dimmed while paused.
class TimerChip extends StatelessWidget {
  const TimerChip({super.key, required this.seconds, this.paused = false});

  final int seconds;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Time ${formatClock(seconds)}${paused ? ', paused' : ''}',
      excludeSemantics: true,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: MyColors.gameSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MyColors.gameBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              paused ? Icons.pause_rounded : Icons.timer_outlined,
              size: 15,
              color: MyColors.navInactive,
            ),
            const SizedBox(width: 4),
            Text(
              formatClock(seconds),
              style: TextStyle(
                color: paused ? MyColors.navInactive : MyColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lightbulb button with the reveals-left badge.
class HintButton extends StatelessWidget {
  const HintButton({super.key, required this.remaining, required this.onTap});

  final int remaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Hints, $remaining reveals left',
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: MyColors.hint, size: 24),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: remaining > 0
                        ? MyColors.tilePresent
                        : MyColors.gameBorder,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$remaining',
                    style: const TextStyle(
                      color: MyColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
