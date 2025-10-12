import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  });

  final WordTileType tileType;

  final String value;

  final Function(Function shake) shakeCallBack;

  @override
  State<WordTile> createState() => _WordTileState();
}

class _WordTileState extends State<WordTile>
    with WordTileStateMixin, SingleTickerProviderStateMixin {
  @override
  WordTileType get type => _tileType;

  @override
  Widget build(BuildContext context) {
    return ShakeWidget(
      child: Builder(
        builder: (context) {
          if (ShakeWidget.of(context)?.shake != null) {
            widget.shakeCallBack(ShakeWidget.of(context)!.shake);
          }
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: strokeColor,
                width: 6,
              ),
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: myGradientColors,
              ),
            ),
            child: Center(
              child: Text(
                widget.value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
