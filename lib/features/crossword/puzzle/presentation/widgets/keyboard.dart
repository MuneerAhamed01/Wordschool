import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wordshool/config/themes/colors.dart';

/// QWERTY keyboard for the puzzle: row 3 is CHECK (1.6×) + Z–M + delete (1.6×).
/// Keys are 52 high.
class CrosswordKeyboard extends StatelessWidget {
  const CrosswordKeyboard({
    super.key,
    required this.onLetter,
    required this.onBackspace,
    required this.onCheck,
  });

  final ValueChanged<String> onLetter;
  final VoidCallback onBackspace;
  final VoidCallback onCheck;

  static const rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];
  static const keyHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow([for (final ch in rows[0].split('')) _buildLetter(ch)]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child:
              _buildRow([for (final ch in rows[1].split('')) _buildLetter(ch)]),
        ),
        _buildRow([
          _KeyCap(
            flex: 16,
            label: 'CHECK',
            semanticsLabel: 'Check answers',
            color: MyColors.crosswordKeyAction,
            onTap: onCheck,
          ),
          for (final ch in rows[2].split('')) _buildLetter(ch),
          _KeyCap(
            flex: 16,
            icon: Icons.backspace_outlined,
            semanticsLabel: 'Delete',
            color: MyColors.crosswordKey,
            onTap: onBackspace,
          ),
        ]),
      ],
    );
  }

  Widget _buildLetter(String ch) => _KeyCap(
        flex: 10,
        label: ch,
        semanticsLabel: ch,
        color: MyColors.crosswordKey,
        onTap: () => onLetter(ch),
      );

  Widget _buildRow(List<Widget> keys) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: keys),
      );
}

class _KeyCap extends StatelessWidget {
  const _KeyCap({
    required this.flex,
    this.label,
    this.icon,
    required this.semanticsLabel,
    required this.color,
    required this.onTap,
  });

  final int flex;
  final String? label;
  final IconData? icon;
  final String semanticsLabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        child: Semantics(
          button: true,
          label: semanticsLabel,
          excludeSemantics: true,
          child: Material(
            color: color,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              key: ValueKey('key-$semanticsLabel'),
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              child: SizedBox(
                height: CrosswordKeyboard.keyHeight,
                child: Center(
                  child: icon != null
                      ? Icon(icon, color: MyColors.white, size: 20)
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label!,
                            style: TextStyle(
                              color: MyColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: label!.length > 1 ? 12 : 17,
                              letterSpacing: label!.length > 1 ? 0.5 : 0,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
