import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';

/// A lone back button (load error).
class BackRow extends StatelessWidget {
  const BackRow({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        tooltip: 'Back',
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        icon: const Icon(Icons.arrow_back_rounded, color: MyColors.white),
        onPressed: onBack,
      ),
    );
  }
}
