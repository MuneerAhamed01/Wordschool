import 'package:flutter/material.dart';

class InheritedShakeWidget extends InheritedWidget {
  final ShakeWidgetState shakeWidgetState;

  const InheritedShakeWidget({
    super.key,
    required this.shakeWidgetState,
    required super.child,
  });

  static InheritedShakeWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedShakeWidget>();
  }

  @override
  bool updateShouldNotify(InheritedShakeWidget oldWidget) {
    return shakeWidgetState != oldWidget.shakeWidgetState;
  }
}

class ShakeWidget extends StatefulWidget {
  final Duration duration;
  final double deltaX;
  final Widget child;
  final Curve curve;

  const ShakeWidget({
    super.key,
    this.duration = const Duration(milliseconds: 500),
    this.deltaX = 20,
    this.curve = Curves.bounceOut,
    required this.child,
  });

  @override
  ShakeWidgetState createState() => ShakeWidgetState();

  static ShakeWidgetState? of(BuildContext context) {
    return InheritedShakeWidget.of(context)?.shakeWidgetState;
  }
}

class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: widget.curve),
    );

    // _animationController.forward().then((e) {
    //   _animationController.reverse();
    // });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void shake() {
    _animationController.forward(from: 0.0);
  }

  /// convert 0-1 to 0-1-0
  double _shake(double animation) =>
      6 * (0.5 - (0.5 - widget.curve.transform(animation)).abs());

  @override
  Widget build(BuildContext context) {
    return InheritedShakeWidget(
      shakeWidgetState: this,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(widget.deltaX * _shake(_animation.value), 0),
            // angle: _animation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
