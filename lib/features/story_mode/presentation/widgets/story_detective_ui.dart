import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wordshool/features/story_mode/presentation/theme/story_theme.dart';

/// Noir detective scaffold with animated atmosphere and glass-ready layout.
class DetectiveScaffold extends StatelessWidget {
  const DetectiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.showMagnifier = true,
    this.onBack,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool showMagnifier;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      extendBodyBehindAppBar: appBar != null,
      backgroundColor: StoryTheme.background,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DetectiveAtmosphere(),
          if (showMagnifier)
            const Positioned(
              top: 72,
              right: -18,
              child: MagnifyingGlassDecoration(size: 110),
            ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                top: appBar != null ? kToolbarHeight : 0,
              ),
              child: body,
            ),
          ),
        ],
      ),
    );

    if (onBack != null) {
      child = PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            onBack!();
          }
        },
        child: child,
      );
    }

    return child;
  }
}

/// Animated noir background: vignette, spotlight pulse, drifting particles.
class DetectiveAtmosphere extends StatefulWidget {
  const DetectiveAtmosphere({super.key});

  @override
  State<DetectiveAtmosphere> createState() => _DetectiveAtmosphereState();
}

class _DetectiveAtmosphereState extends State<DetectiveAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  void _syncAnimation() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      if (_controller.value != 0) {
        _controller.value = 0;
      }
      return;
    }
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      return CustomPaint(
        painter: _NoirBackgroundPainter(progress: 0),
        child: const SizedBox.expand(),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _NoirBackgroundPainter(progress: _controller.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _NoirBackgroundPainter extends CustomPainter {
  _NoirBackgroundPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final baseGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          StoryTheme.background,
          const Color(0xFF12101A),
          const Color(0xFF0E0C14),
          StoryTheme.background,
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, baseGradient);

    final spotlightCenter = Offset(
      size.width * (0.5 + 0.08 * math.sin(progress * math.pi * 2)),
      size.height * 0.12,
    );
    final spotlight = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (spotlightCenter.dx / size.width) * 2 - 1,
          (spotlightCenter.dy / size.height) * 2 - 1,
        ),
        radius: 0.85,
        colors: [
          StoryTheme.accent.withValues(alpha: 0.14),
          StoryTheme.accent.withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, spotlight);

    final crimeGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.75, 0.9),
        radius: 0.55,
        colors: [
          StoryTheme.crimeRed.withValues(alpha: 0.07),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, crimeGlow);

    final particlePaint = Paint()..style = PaintingStyle.fill;
    const particleCount = 22;
    for (var i = 0; i < particleCount; i++) {
      final seed = i / particleCount;
      final x = size.width * ((seed * 0.91 + progress * 0.04 + i * 0.037) % 1);
      final y = size.height * ((0.15 + seed * 0.75 + progress * 0.06) % 1);
      final alpha = 0.08 + 0.12 * math.sin((progress + seed) * math.pi * 2);
      particlePaint.color = StoryTheme.accent.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), 1.2 + seed * 1.8, particlePaint);
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.05,
        colors: [
          Colors.transparent,
          StoryTheme.background.withValues(alpha: 0.55),
          StoryTheme.background.withValues(alpha: 0.92),
        ],
        stops: const [0.45, 0.82, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);

    final scanLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.018)
      ..strokeWidth = 1;
    final scanY = size.height * progress;
    canvas.drawLine(
      Offset(0, scanY),
      Offset(size.width, scanY),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NoirBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Frosted glass evidence panel with gold trim.
class GlassEvidencePanel extends StatelessWidget {
  const GlassEvidencePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.accentLabel,
    this.animate = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final String? accentLabel;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    Widget panel = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: StoryTheme.glassBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: StoryTheme.accent.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  StoryTheme.glassFill.withValues(alpha: 0.22),
                  StoryTheme.glassFill.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          StoryTheme.accent.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: padding,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (accentLabel != null) {
      panel = Stack(
        clipBehavior: Clip.none,
        children: [
          panel,
          Positioned(
            top: -10,
            left: 20,
            child: DetectiveLabelChip(label: accentLabel!),
          ),
        ],
      );
    }

    if (!animate || MediaQuery.disableAnimationsOf(context)) {
      return panel;
    }

    return panel
        .animate()
        .fadeIn(duration: 450.ms, curve: Curves.easeOut)
        .slideY(begin: 0.06, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}

class DetectiveLabelChip extends StatelessWidget {
  const DetectiveLabelChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: StoryTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: StoryTheme.accent.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: StoryTheme.accent.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: StoryTheme.accent,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// Decorative magnifying glass with slow float and lens shimmer.
class MagnifyingGlassDecoration extends StatelessWidget {
  const MagnifyingGlassDecoration({
    super.key,
    this.size = 96,
    this.opacity = 0.55,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Opacity(
        opacity: opacity * 0.7,
        child: _MagnifyingGlassIcon(size: size),
      );
    }

    return Opacity(
      opacity: opacity,
      child: _MagnifyingGlassIcon(size: size)
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: -6, end: 6, duration: 3.2.seconds, curve: Curves.easeInOut)
          .rotate(begin: -0.04, end: 0.04, duration: 4.seconds),
    );
  }
}

class _MagnifyingGlassIcon extends StatelessWidget {
  const _MagnifyingGlassIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final lensSize = size * 0.62;
    final handleWidth = size * 0.1;
    final handleLength = size * 0.38;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: size * 0.06,
            top: size * 0.04,
            child: Container(
              width: lensSize,
              height: lensSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    StoryTheme.glassFill.withValues(alpha: 0.35),
                    StoryTheme.glassFill.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: StoryTheme.accent.withValues(alpha: 0.75),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: StoryTheme.accent.withValues(alpha: 0.25),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Align(
                alignment: const Alignment(-0.35, -0.35),
                child: Container(
                  width: lensSize * 0.28,
                  height: lensSize * 0.18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: lensSize * 0.72,
            top: lensSize * 0.68,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: handleWidth,
                height: handleLength,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(handleWidth),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      StoryTheme.accent,
                      StoryTheme.accent.withValues(alpha: 0.55),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: StoryTheme.accent.withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetectiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetectiveAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: onBack == null
          ? null
          : IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: StoryTheme.narrativeText.withValues(alpha: 0.9),
                size: 20,
              ),
              onPressed: onBack,
            ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fingerprint_rounded,
            size: 18,
            color: StoryTheme.accent.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Crime-scene tape style divider.
class CrimeSceneTape extends StatelessWidget {
  const CrimeSceneTape({super.key, this.label = 'EVIDENCE'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 28,
          width: constraints.maxWidth,
          child: CustomPaint(
            painter: _TapePainter(label: label),
          ),
        );
      },
    );
  }
}

class _TapePainter extends CustomPainter {
  _TapePainter({required this.label});

  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width, size.height * 0.65)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height * 0.7)
      ..close();

    final tapePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          StoryTheme.crimeTape.withValues(alpha: 0.85),
          StoryTheme.crimeTape.withValues(alpha: 0.65),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, tapePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$label   ' * 8,
        style: TextStyle(
          color: StoryTheme.background.withValues(alpha: 0.75),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);

    canvas.save();
    canvas.clipPath(path);
    canvas.translate(0, size.height * 0.38);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TapePainter oldDelegate) =>
      oldDelegate.label != label;
}

/// Animated detective stamp for solved cases.
class DetectiveCaseStamp extends StatelessWidget {
  const DetectiveCaseStamp({
    super.key,
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final stampColor = color ?? StoryTheme.crimeRed;

    Widget stamp = Transform.rotate(
      angle: -0.12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: stampColor.withValues(alpha: 0.85), width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: stampColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
        ),
      ),
    );

    if (MediaQuery.disableAnimationsOf(context)) {
      return stamp;
    }

    return stamp
        .animate()
        .scale(
          begin: const Offset(1.8, 1.8),
          end: const Offset(1, 1),
          duration: 420.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 280.ms);
  }
}

/// Pulsing detective CTA wrapper.
class DetectiveActionButton extends StatelessWidget {
  const DetectiveActionButton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child;
    }

    return child
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .boxShadow(
          begin: BoxShadow(
            color: StoryTheme.accent.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          end: BoxShadow(
            color: StoryTheme.accent.withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          duration: 2.4.seconds,
        );
  }
}

/// Case file header with title and optional stamp.
class DetectiveCaseHeader extends StatelessWidget {
  const DetectiveCaseHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.stamp,
  });

  final String title;
  final String? subtitle;
  final Widget? stamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (stamp != null) ...[
          stamp!,
          const SizedBox(height: 12),
        ],
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            shadows: [
              Shadow(
                color: StoryTheme.accent.withValues(alpha: 0.25),
                blurRadius: 12,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: StoryTheme.narrativeText.withValues(alpha: 0.75),
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.08, end: 0, duration: 450.ms, curve: Curves.easeOut);
  }
}
