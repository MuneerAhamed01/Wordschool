import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/feedback.dart';

/// Everything the grid validator found, or "All good".
class ProblemsCard extends StatelessWidget {
  const ProblemsCard({super.key, required this.problems});

  final List<String> problems;

  @override
  Widget build(BuildContext context) {
    if (problems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: MyColors.successBg, borderRadius: BorderRadius.circular(12)),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: MyColors.successText),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Everything looks good — ready to save.',
                style: TextStyle(
                    color: MyColors.successText, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: MyColors.errorBg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${problems.length} thing${problems.length == 1 ? '' : 's'} to fix before saving',
            style: const TextStyle(
                color: MyColors.errorText, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ProblemList(problems: problems, maxItems: 8),
        ],
      ),
    );
  }
}
