part of 'keyboard.dart';

mixin CustomKeyboardHelper on State<CustomKeyboard> {
  final List<List<String>> keyboardLayout = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  Color backgroundColor(String key) {
    if (widget.greenedList.contains(key)) {
      return MyColors.green5;
    }

    if (widget.orangedList.contains(key)) {
      return MyColors.orange4;
    }

    if (widget.disabledList.contains(key)) {
      return MyColors.gray5;
    }
    return Colors.white;
  }

  Color textColor(String key) {
    final isAvailable = widget.orangedList.contains(key) ||
        widget.greenedList.contains(key) ||
        widget.disabledList.contains(key);

    if (isAvailable) return Colors.white;

    return Colors.black;
  }
}
