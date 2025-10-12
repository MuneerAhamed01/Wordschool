import 'package:flutter/material.dart';

class GlowingLightbulbButton extends StatefulWidget {
  final double size;
  final Color glowColor;
  final Color iconColor;
  final VoidCallback onTap;

  const GlowingLightbulbButton({
    super.key,
    this.size = 60,
    this.glowColor = Colors.yellow,
    this.iconColor = Colors.yellow,
    required this.onTap,
  });

  @override
  _GlowingLightbulbButtonState createState() => _GlowingLightbulbButtonState();
}

class _GlowingLightbulbButtonState extends State<GlowingLightbulbButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 22,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: GlowPainter(
                  glowColor: widget.glowColor,
                  radius: widget.size / 2,
                  opacity: _animation.value,
                ),
                child: Icon(
                  Icons.lightbulb,
                  size: widget.size,
                  color: widget.iconColor,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class GlowPainter extends CustomPainter {
  final Color glowColor;
  final double radius;
  final double opacity;

  GlowPainter({
    required this.glowColor,
    required this.radius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = glowColor.withValues(alpha: opacity * 0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius / 2);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(GlowPainter oldDelegate) {
    return opacity != oldDelegate.opacity;
  }
}
