import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/enums/word_tile_type.dart';
import 'package:wordshool/shared/presentations/widgets/shake_widget.dart';

part 'tile_mixin.dart';

class WordTile extends StatefulWidget {
  const WordTile({
    super.key,
    this.tileType = WordTileType.none,
    required this.value,
    required this.shakeCallBack,
    this.revealDelay = Duration.zero,
    this.instantReveal = false,
    this.fontSize = 28,
  });

  final WordTileType tileType;
  final String value;
  final Function(Function shake) shakeCallBack;
  final Duration revealDelay;
  final bool instantReveal;
  final double fontSize;

  @override
  State<WordTile> createState() => _WordTileState();
}

class _WordTileState extends State<WordTile>
    with WordTileStateMixin, TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _popController;
  late Animation<double> _flipAnimation;
  late Animation<double> _popAnimation;

  @override
  WordTileType get type => _tileType;

  @override
  void initState() {
    _tileType = widget.tileType;
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _popAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeOutBack),
    );

    if (widget.instantReveal && widget.value.isNotEmpty) {
      _flipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant WordTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.instantReveal && widget.value.isNotEmpty) {
      _flipController.value = 1.0;
      return;
    }

    if (oldWidget.tileType != widget.tileType &&
        widget.tileType != WordTileType.none) {
      Future.delayed(widget.revealDelay, () {
        if (mounted) _flipController.forward(from: 0);
      });
    }

    if (oldWidget.value != widget.value && widget.value.isNotEmpty) {
      _popController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShakeWidget(
      child: Builder(
        builder: (context) {
          if (ShakeWidget.of(context)?.shake != null) {
            widget.shakeCallBack(ShakeWidget.of(context)!.shake);
          }

          return AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              const halfTurn = 3.1415926535;
              final angle = _flipAnimation.value * halfTurn;
              final showBack = angle >= halfTurn / 2;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(angle),
                child: showBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateX(halfTurn),
                        child: _buildFace(useEvaluated: true),
                      )
                    : _buildFace(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFace({bool useEvaluated = false}) {
    final faceType = useEvaluated ? widget.tileType : WordTileType.none;
    final bgColor = _colorForType(faceType, evaluated: useEvaluated);
    final borderColor = useEvaluated && faceType != WordTileType.none
        ? bgColor
        : (widget.value.isEmpty ? MyColors.gameBorder : MyColors.textMuted);

    return ScaleTransition(
      scale: _popAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: Text(
            widget.value.toUpperCase(),
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w700,
              color: MyColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForType(WordTileType tileType, {bool evaluated = false}) {
    switch (tileType) {
      case WordTileType.green:
        return MyColors.tileCorrect;
      case WordTileType.orange:
        return MyColors.tilePresent;
      case WordTileType.error:
        return MyColors.tileAbsent;
      case WordTileType.none:
        if (widget.value.isEmpty) return MyColors.tileEmpty;
        return evaluated ? MyColors.tileAbsent : MyColors.tileFilled;
    }
  }
}
