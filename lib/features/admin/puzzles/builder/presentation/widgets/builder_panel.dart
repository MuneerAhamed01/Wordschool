import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// A titled card on the builder page.
class BuilderPanel extends StatelessWidget {
  const BuilderPanel(
      {super.key,
      required this.title,
      required this.child,
      this.trailing,
      this.highlight = false});

  final String title;
  final Widget child;
  final Widget? trailing;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: highlight
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: MyColors.gridWordBorder),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
