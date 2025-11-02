import 'package:flutter/material.dart';

class AnimatedCheckmarkAvatar extends StatefulWidget {
  final double size;
  final Color checkmarkColor;
  final Color backgroundColor;
  final Duration checkmarkDuration;
  final Duration zoomDuration;

  const AnimatedCheckmarkAvatar({
    super.key,
    this.size = 100.0,
    this.checkmarkColor = Colors.white,
    this.backgroundColor = Colors.purple,
    this.checkmarkDuration = const Duration(milliseconds: 1000),
    this.zoomDuration = const Duration(milliseconds: 500),
  });

  @override
  _AnimatedCheckmarkAvatarState createState() =>
      _AnimatedCheckmarkAvatarState();
}

class _AnimatedCheckmarkAvatarState extends State<AnimatedCheckmarkAvatar>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _zoomController;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _checkmarkController =
        AnimationController(vsync: this, duration: widget.checkmarkDuration);
    _zoomController =
        AnimationController(vsync: this, duration: widget.zoomDuration);

    _checkmarkAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.easeInOut,
    ));

    _zoomAnimation = Tween<double>(begin: 1, end: 1.2).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInOut,
    ));

    _checkmarkController.forward().then((_) {
      _zoomController.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_checkmarkAnimation, _zoomAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _zoomAnimation.value,
          child: CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: widget.backgroundColor,
            child: CustomPaint(
              size: Size(widget.size / 1.2, widget.size / 1.2),
              painter: CheckmarkPainter(
                progress: _checkmarkAnimation.value,
                color: widget.checkmarkColor,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _zoomController.dispose();
    super.dispose();
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 10
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.45, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.3);

    final pathMetric = path.computeMetrics().first;
    final extractPath = pathMetric.extractPath(0, pathMetric.length * progress);

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
