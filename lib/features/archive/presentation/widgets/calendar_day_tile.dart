import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/shared/presentations/widgets/pressable_scale.dart';

enum CalendarDayStatus {
  notPlayed,
  won,
  lost,
  today,
  future,
}

class CalendarDayTile extends StatelessWidget {
  const CalendarDayTile({
    super.key,
    required this.dayNumber,
    required this.status,
    required this.onTap,
  });

  final int dayNumber;
  final CalendarDayStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = status == CalendarDayStatus.future;

    return PressableScale(
      enabled: !disabled,
      onTap: onTap,
      scale: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _backgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _borderColor(),
            width: status == CalendarDayStatus.today ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '$dayNumber',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: disabled ? MyColors.gameBorder : MyColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Color _backgroundColor() {
    switch (status) {
      case CalendarDayStatus.won:
        return MyColors.tileCorrect;
      case CalendarDayStatus.lost:
        return MyColors.tilePresent;
      case CalendarDayStatus.today:
        return MyColors.gameSurfaceElevated;
      case CalendarDayStatus.future:
        return MyColors.gameSurface.withValues(alpha: 0.4);
      case CalendarDayStatus.notPlayed:
        return MyColors.gameSurface;
    }
  }

  Color _borderColor() {
    switch (status) {
      case CalendarDayStatus.today:
        return MyColors.accentGlow;
      case CalendarDayStatus.won:
        return MyColors.tileCorrect;
      case CalendarDayStatus.lost:
        return MyColors.tilePresent;
      default:
        return MyColors.gameBorder;
    }
  }
}
