import 'dart:async';

import 'package:flutter/material.dart';

/// Reveals text character-by-character. Respects reduced motion and is skippable.
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

class _TypewriterTextState extends State<TypewriterText> {
  int _visibleCount = 0;
  bool _skipped = false;
  bool _dependenciesReady = false;
  Timer? _revealTimer;

  @override
  void dispose() {
    _revealTimer?.cancel();
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

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations || widget.text.isEmpty) {
      if (_visibleCount != widget.text.length) {
        setState(() => _visibleCount = widget.text.length);
      }
      widget.onComplete?.call();
      return;
    }

    _revealTimer = Timer.periodic(widget.durationPerChar, (timer) {
      if (!mounted || _skipped) {
        timer.cancel();
        return;
      }
      if (_visibleCount >= widget.text.length) {
        timer.cancel();
        widget.onComplete?.call();
        return;
      }
      setState(() => _visibleCount++);
    });
  }

  void _skip() {
    if (_skipped) return;
    _revealTimer?.cancel();
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

    return GestureDetector(
      onTap: _skip,
      behavior: HitTestBehavior.translucent,
      child: Text(
        visible,
        style: widget.style,
        textAlign: widget.textAlign,
      ),
    );
  }
}
