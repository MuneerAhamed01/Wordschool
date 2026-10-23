import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/admin/domain/models/admin_enums.dart';

/// Small coloured pill with a label.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.tooltip,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
    return tooltip == null ? pill : Tooltip(message: tooltip!, child: pill);
  }
}

class PuzzleStatusChip extends StatelessWidget {
  const PuzzleStatusChip({super.key, required this.status});

  final PuzzleStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (status) {
      PuzzleStatus.draft => (
          MyColors.gameSurfaceElevated,
          MyColors.textSecondary,
          Icons.edit_outlined
        ),
      PuzzleStatus.inReview => (
          MyColors.infoBg,
          MyColors.infoText,
          Icons.visibility_outlined
        ),
      PuzzleStatus.scheduled => (
          MyColors.warnBg,
          MyColors.warnText,
          Icons.schedule
        ),
      PuzzleStatus.published => (
          MyColors.successBg,
          MyColors.successText,
          Icons.public
        ),
      PuzzleStatus.archived => (
          MyColors.gameSurfaceElevated,
          MyColors.navInactive,
          Icons.inventory_2_outlined
        ),
    };
    return Pill(
      label: status.label,
      background: background,
      foreground: foreground,
      icon: icon,
      tooltip: status.help,
    );
  }
}

class QuestionStatusChip extends StatelessWidget {
  const QuestionStatusChip({super.key, required this.status});

  final QuestionStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (status) {
      QuestionStatus.draft => (
          MyColors.warnBg,
          MyColors.warnText,
          Icons.hourglass_empty
        ),
      QuestionStatus.verified => (
          MyColors.successBg,
          MyColors.successText,
          Icons.verified_outlined
        ),
      QuestionStatus.retired => (
          MyColors.gameSurfaceElevated,
          MyColors.navInactive,
          Icons.block
        ),
    };
    return Pill(
        label: status.label,
        background: background,
        foreground: foreground,
        icon: icon);
  }
}

class DifficultyChip extends StatelessWidget {
  const DifficultyChip({super.key, required this.difficulty});

  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    return Pill(
      label: difficulty.label,
      background: MyColors.gameSurfaceElevated,
      foreground: MyColors.textSecondary,
    );
  }
}
