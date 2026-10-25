import 'package:get_it/get_it.dart';
import 'package:wordshool/features/crossword/category/di.dart';
import 'package:wordshool/features/crossword/home/di.dart';
import 'package:wordshool/features/crossword/leaderboard/di.dart';
import 'package:wordshool/features/crossword/puzzle/di.dart';
import 'package:wordshool/features/crossword/revise/di.dart';
import 'package:wordshool/features/crossword/shared/di.dart';

/// PSC Crossword: shared pieces first, then one call per module.
void initCrossword(GetIt getIt) {
  initCrosswordShared(getIt);
  initCrosswordHome(getIt);
  initCrosswordCategory(getIt);
  initCrosswordPuzzle(getIt);
  initCrosswordRevise(getIt);
  initCrosswordLeaderboard(getIt);
}
