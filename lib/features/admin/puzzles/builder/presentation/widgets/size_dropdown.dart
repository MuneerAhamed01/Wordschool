import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// Rows / columns picker.
class SizeDropdown extends StatelessWidget {
  const SizeDropdown(
      {super.key,
      required this.label,
      required this.value,
      required this.options,
      required this.onChanged});

  final String label;
  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ', style: const TextStyle(color: MyColors.textSecondary)),
        DropdownButton<int>(
          value: value,
          underline: const SizedBox.shrink(),
          items: [
            for (final o in options)
              DropdownMenuItem(value: o, child: Text('$o'))
          ],
          onChanged: (v) => v == null ? null : onChanged(v),
        ),
      ],
    );
  }
}
