import 'package:flutter/material.dart';

/// Describes optional chrome around the game board when computing layout.
class GameLayoutFlags {
  const GameLayoutFlags({
    this.hasBanner = false,
    this.hasHero = false,
    this.hasFooter = false,
    this.hasKeyboard = false,
    this.hasGuessCounter = false,
    this.heroShowsAnswerTiles = false,
    this.footerHasTwoButtons = false,
  });

  final bool hasBanner;
  final bool hasHero;
  final bool hasFooter;
  final bool hasKeyboard;
  final bool hasGuessCounter;
  final bool heroShowsAnswerTiles;
  final bool footerHasTwoButtons;
}

/// Responsive sizing for the game board, keyboard, and result chrome.
class GameLayoutMetrics {
  const GameLayoutMetrics({
    required this.tileSize,
    required this.tileSpacing,
    required this.keyHeight,
    required this.tileFontSize,
    required this.keyFontSize,
    required this.scale,
    required this.isCompact,
  });

  final double tileSize;
  final double tileSpacing;
  final double keyHeight;
  final double tileFontSize;
  final double keyFontSize;
  final double scale;
  final bool isCompact;

  double get boardSide => tileSize * 5 + tileSpacing * 4;

  static const double _horizontalPadding = 40;
  static const double _defaultSpacing = 6;
  static const double _defaultKeyHeight = 52;
  static const double _defaultTileFontSize = 28;
  static const double _minTileSize = 40;
  static const double _minKeyHeight = 36;

  static GameLayoutMetrics compute({
    required double maxWidth,
    required double maxHeight,
    required GameLayoutFlags flags,
  }) {
    final widthTile =
        (maxWidth - _horizontalPadding - 4 * _defaultSpacing) / 5;

    var overhead = _estimateOverhead(flags);
    var gridHeight = maxHeight - overhead;
    var heightTile = (gridHeight - 4 * _defaultSpacing) / 5;

    var tileSize = widthTile < heightTile
        ? widthTile
        : heightTile.clamp(_minTileSize, widthTile);
    var scale = tileSize / widthTile;

    if (flags.hasKeyboard) {
      final scaledKeyHeight = (_defaultKeyHeight * scale)
          .clamp(_minKeyHeight, _defaultKeyHeight)
          .toDouble();
      final keyboardDelta =
          4 * scaledKeyHeight + 6 - (4 * _defaultKeyHeight + 6);
      overhead += keyboardDelta;
      gridHeight = maxHeight - overhead;
      heightTile = (gridHeight - 4 * _defaultSpacing) / 5;
      tileSize = widthTile < heightTile
          ? widthTile
          : heightTile.clamp(_minTileSize, widthTile);
      scale = tileSize / widthTile;
    }

    final tileSpacing =
        (_defaultSpacing * scale).clamp(4.0, _defaultSpacing).toDouble();
    final keyHeight = (_defaultKeyHeight * scale)
        .clamp(_minKeyHeight, _defaultKeyHeight)
        .toDouble();
    final tileFontSize = (_defaultTileFontSize * scale)
        .clamp(18.0, _defaultTileFontSize)
        .toDouble();
    final keyFontSize = (14 * scale).clamp(11.0, 14.0).toDouble();
    final isCompact = scale < 0.92;

    return GameLayoutMetrics(
      tileSize: tileSize,
      tileSpacing: tileSpacing,
      keyHeight: keyHeight,
      tileFontSize: tileFontSize,
      keyFontSize: keyFontSize,
      scale: scale,
      isCompact: isCompact,
    );
  }

  static double _estimateOverhead(GameLayoutFlags flags) {
    double overhead = 8;

    if (flags.hasBanner) overhead += 48;
    if (flags.hasHero) {
      overhead += flags.heroShowsAnswerTiles ? 196 : 148;
    }
    if (flags.hasFooter) {
      overhead += flags.footerHasTwoButtons ? 168 : 100;
    }
    if (flags.hasGuessCounter) overhead += 32;
    if (flags.hasKeyboard) {
      overhead += 4 * _defaultKeyHeight + 6;
    }

    return overhead;
  }

  static GameLayoutMetrics of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_GameLayoutScope>();
    return scope?.metrics ?? _fallback(context);
  }

  static GameLayoutMetrics _fallback(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return compute(
      maxWidth: size.width,
      maxHeight: size.height,
      flags: const GameLayoutFlags(),
    );
  }
}

/// Provides [GameLayoutMetrics] to game UI descendants.
class GameLayoutScope extends InheritedWidget {
  const GameLayoutScope({
    super.key,
    required this.metrics,
    required super.child,
  });

  final GameLayoutMetrics metrics;

  @override
  bool updateShouldNotify(GameLayoutScope oldWidget) =>
      metrics != oldWidget.metrics;
}

// Alias so metrics can reference the scope type without a circular import.
typedef _GameLayoutScope = GameLayoutScope;
