part of 'tile.dart';

mixin WordTileStateMixin on State<WordTile> {
  WordTileType get type;

  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  WordTileType _tileType = WordTileType.none;

  // late AnimationController animationController;
  // late Animation<double> animation;

  List<Color> get myGradientColors {
    return [
      if (type == WordTileType.green) ...[
        MyColors.green4,
        MyColors.green5,
      ] else if (type == WordTileType.none) ...[
        MyColors.gray5,
        MyColors.gray6,
      ] else if (type == WordTileType.error) ...[
        Colors.red,
        Colors.red.withOpacity(0.6),
      ] else ...[
        MyColors.orange4,
        MyColors.orange5,
      ]
    ];
  }

  Color get strokeColor {
    if (type == WordTileType.green) return MyColors.green4;

    if (type == WordTileType.none) return MyColors.gray5;

    return MyColors.orange4;
  }

  Color get textColor {
    if (type == WordTileType.orange) return MyColors.gray5;

    return Colors.white;
  }

  @override
  void didUpdateWidget(covariant WordTile oldWidget) {
    if (oldWidget.tileType != widget.tileType) {
      _tileType = widget.tileType;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _tileType = widget.tileType;
    super.initState();
  }
}
