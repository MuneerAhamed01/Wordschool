import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/puzzle/domain/utils/grid.dart';

/// "12 of 40 letters filled" and the last Check's result.
class FillStatus extends StatelessWidget {
  const FillStatus({super.key, required this.grid, this.lastCheck});

  final CrosswordGrid grid;
  final CheckSummary? lastCheck;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${grid.filledCount} of ${grid.letterCount} letters filled',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: MyColors.navInactive, fontSize: 12),
            ),
          ),
          if (lastCheck != null)
            Text(
              lastCheck!.wrong == 0
                  ? 'All correct so far'
                  : '${lastCheck!.wrong} to fix',
              key: const ValueKey('check-status'),
              style: TextStyle(
                color: lastCheck!.wrong == 0
                    ? MyColors.successText
                    : MyColors.errorText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
