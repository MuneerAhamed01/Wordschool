import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/shared/presentations/widgets/pressable_scale.dart';

part 'helper.dart';

class CustomKeyboard extends StatefulWidget {
  final Function(String) onKeyPressed;
  final Function() onEnterPressed;
  final Function() onBackspacePressed;
  final List<String> orangedList;
  final List<String> greenedList;
  final List<String> disabledList;
  final double keyHeight;
  final double keyFontSize;

  const CustomKeyboard({
    super.key,
    required this.onKeyPressed,
    required this.onEnterPressed,
    required this.onBackspacePressed,
    this.orangedList = const [],
    this.greenedList = const [],
    this.disabledList = const [],
    this.keyHeight = 52,
    this.keyFontSize = 14,
  });

  @override
  State<CustomKeyboard> createState() => _CustomKeyboardState();
}

class _CustomKeyboardState extends State<CustomKeyboard>
    with CustomKeyboardHelper {
  Widget _buildKey(String key) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: PressableScale(
          onTap: () => widget.onKeyPressed(key),
          scale: 0.92,
          child: Container(
            height: widget.keyHeight,
            decoration: BoxDecoration(
              color: keyBackground(key),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  fontSize: widget.keyFontSize,
                  fontWeight: FontWeight.w700,
                  color: keyTextColor(key),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey({
    required String label,
    required VoidCallback onPressed,
    required int flex,
    IconData? icon,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: PressableScale(
          onTap: onPressed,
          scale: 0.92,
          child: Container(
            height: widget.keyHeight,
            decoration: BoxDecoration(
              color: MyColors.keyAction,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: widget.keyFontSize + 4,
                    color: MyColors.white,
                  ),
                  if (label.isNotEmpty) const SizedBox(width: 4),
                ],
                if (label.isNotEmpty)
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: widget.keyFontSize - 1,
                      fontWeight: FontWeight.w700,
                      color: MyColors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          ...keyboardLayout.map(
            (row) => Row(
              children: row.map(_buildKey).toList(),
            ),
          ),
          Row(
            children: [
              _buildActionKey(
                label: 'ENTER',
                onPressed: widget.onEnterPressed,
                flex: 3,
              ),
              _buildActionKey(
                label: '',
                onPressed: widget.onBackspacePressed,
                flex: 2,
                icon: Icons.backspace_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
