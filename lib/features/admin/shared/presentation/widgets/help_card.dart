import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// A soft blue box that explains a page in plain words.
class HelpCard extends StatelessWidget {
  const HelpCard(
      {super.key, required this.text, this.icon = Icons.lightbulb_outline});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MyColors.infoBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MyColors.infoText, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: MyColors.infoText, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
