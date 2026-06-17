part of 'tile.dart';

mixin WordTileStateMixin on State<WordTile> {
  WordTileType get type;

  WordTileType _tileType = WordTileType.none;

  Color get tileBackgroundColor {
    switch (type) {
      case WordTileType.green:
        return MyColors.tileCorrect;
      case WordTileType.orange:
        return MyColors.tilePresent;
      case WordTileType.error:
        return MyColors.tileAbsent;
      case WordTileType.none:
        return widget.value.isEmpty
            ? MyColors.tileEmpty
            : MyColors.tileFilled;
    }
  }

  Color get tileBorderColor {
    if (type != WordTileType.none) return tileBackgroundColor;
    return widget.value.isEmpty ? MyColors.gameBorder : MyColors.textMuted;
  }

  Color get textColor => MyColors.white;

  @override
  void didUpdateWidget(covariant WordTile oldWidget) {
    if (oldWidget.tileType != widget.tileType) {
      _tileType = widget.tileType;
    }
    super.didUpdateWidget(oldWidget);
  }
}
