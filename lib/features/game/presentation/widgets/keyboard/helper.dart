part of 'keyboard.dart';

mixin CustomKeyboardHelper on State<CustomKeyboard> {
  final List<List<String>> keyboardLayout = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  Color keyBackground(String key) {
    if (widget.greenedList.contains(key)) return MyColors.tileCorrect;
    if (widget.orangedList.contains(key)) return MyColors.tilePresent;
    if (widget.disabledList.contains(key)) return MyColors.tileAbsent;
    return MyColors.keyDefault;
  }

  Color keyTextColor(String key) {
    return MyColors.white;
  }
}
