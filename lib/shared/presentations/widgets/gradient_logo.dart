import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wordshool/config/themes/colors.dart';

enum WordTileType { green, none, orange }

class AnimatedGradientSquares extends StatefulWidget {
  final int squareCount;
  final double squareSize;
  final Duration animationDuration;

  const AnimatedGradientSquares({
    super.key,
    this.squareCount = 5,
    this.squareSize = 50,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  AnimatedGradientSquaresState createState() => AnimatedGradientSquaresState();
}

class AnimatedGradientSquaresState extends State<AnimatedGradientSquares>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  int _currentColorIndex = 0;

  List<List<Color>> get allGradientColors {
    return [
      [MyColors.green4, MyColors.green5],
      [MyColors.gray5, MyColors.gray6],
      [MyColors.orange4, MyColors.orange5],
    ];
  }

  List<String> words = ["Apple", "House", "Smile", "Truck", "Beach"];

  String shownWord = "Apple";

  final Random _random = Random();
  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.squareCount,
      (index) => AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _startAnimationSequence();
  }

  void _startAnimationSequence() {
    for (int i = 0; i < widget.squareCount; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        final randomDigit = _random.nextInt(words.length);
        shownWord = words[randomDigit];
        _controllers[i].forward().then((_) {
          _controllers[i].reverse();
          if (i == widget.squareCount - 1) {
            _currentColorIndex =
                (_currentColorIndex + 1) % allGradientColors.length;
            setState(() {});
            _startAnimationSequence();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.squareCount, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -10 * _animations[index].value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInCirc,
                width: widget.squareSize,
                height: widget.squareSize,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: allGradientColors[_currentColorIndex],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    shownWord[index].toUpperCase(),
                    style: GoogleFonts.crimsonText(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
