import 'dart:math';

import 'package:equatable/equatable.dart';

/// Where a player's total XP sits in the level curve.
class LevelProgress extends Equatable {
  const LevelProgress({
    required this.level,
    required this.xpIntoLevel,
    required this.xpForLevel,
  });

  final int level;

  /// XP earned since this level started.
  final int xpIntoLevel;

  /// XP this level takes to finish.
  final int xpForLevel;

  double get fraction => xpForLevel == 0 ? 0 : xpIntoLevel / xpForLevel;

  @override
  List<Object?> get props => [level, xpIntoLevel, xpForLevel];
}

/// Level for [xp] with Remote Config `xp_level_formula`: finishing level n
/// takes `base × growth^(n−1)` XP (rounded). Level 1 starts at 0 XP.
LevelProgress levelFor(int xp, {required int base, required double growth}) {
  var level = 1;
  var remaining = max(0, xp);
  var need = base;
  // 500 levels is far beyond any real total; guards bad config.
  while (remaining >= need && level < 500) {
    remaining -= need;
    level++;
    need = (base * pow(growth, level - 1)).round();
  }
  return LevelProgress(level: level, xpIntoLevel: remaining, xpForLevel: need);
}
