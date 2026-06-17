import 'package:wordshool/core/enums/game_mode.dart';
import 'package:wordshool/core/utils/date_helper.dart';

class GameLoadConfig {
  GameLoadConfig({
    String? gameDateId,
    this.gameMode = GameMode.daily,
  }) : gameDateId = gameDateId ?? DateHelper.todayDateId();

  final String gameDateId;
  final GameMode gameMode;
}
