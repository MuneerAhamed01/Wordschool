import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wordshool/features/story_mode/presentation/theme/story_theme.dart';

/// Reveals text character-by-character with a blinking cursor. Skippable.
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.durationPerChar = const Duration(milliseconds: 28),
    this.onComplete,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Duration durationPerChar;
  final VoidCallback? onComplete;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  int _visibleCount = 0;
  bool _skipped = false;
  bool _dependenciesReady = false;
  Timer? _revealTimer;
  late final AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    );
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dependenciesReady) {
      _dependenciesReady = true;
      _startReveal();
    }
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _visibleCount = 0;
      _skipped = false;
      _startReveal();
    }
  }

  void _startReveal() {
    if (!_dependenciesReady) {
      return;
    }

    _revealTimer?.cancel();
    _cursorController.stop();

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations || widget.text.isEmpty) {
      if (_visibleCount != widget.text.length) {
        setState(() => _visibleCount = widget.text.length);
      }
      widget.onComplete?.call();
      return;
    }

    _cursorController.repeat(reverse: true);

    _revealTimer = Timer.periodic(widget.durationPerChar, (timer) {
      if (!mounted || _skipped) {
        timer.cancel();
        return;
      }
      if (_visibleCount >= widget.text.length) {
        timer.cancel();
        _cursorController.stop();
        widget.onComplete?.call();
        return;
      }
      setState(() => _visibleCount++);
    });
  }

  void _skip() {
    if (_skipped) return;
    _revealTimer?.cancel();
    _cursorController.stop();
    setState(() {
      _skipped = true;
      _visibleCount = widget.text.length;
    });
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.text.substring(
      0,
      _visibleCount.clamp(0, widget.text.length),
    );
    final isComplete = _visibleCount >= widget.text.length;
    final baseStyle = widget.style ??
        Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55);

    return GestureDetector(
      onTap: _skip,
      behavior: HitTestBehavior.translucent,
      child: AnimatedBuilder(
        animation: _cursorController,
        builder: (context, _) {
          final showCursor = !isComplete && !_skipped;
          final cursorVisible = showCursor && _cursorController.value > 0.45;
          final cursor = cursorVisible ? '▌' : '';

          return Text(
            '$visible$cursor',
            style: baseStyle?.copyWith(
              shadows: cursorVisible
                  ? [
                      Shadow(
                        color: StoryTheme.accent.withValues(alpha: 0.25),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            textAlign: widget.textAlign,
          );
        },
      ),
    );
  }
}
