import 'package:wordshool/core/enums/game_mode.dart';
import 'package:wordshool/core/utils/date_helper.dart';
import 'package:wordshool/features/game/presentation/utils/game_load_config.dart';

class GameRouteParser {
  GameRouteParser._();

  static GameLoadConfig parseUri(Uri uri) {
    final dateParam = uri.queryParameters['date'];
    final modeParam = uri.queryParameters['mode'];

    final gameDateId = dateParam != null && DateHelper.isValidDateId(dateParam)
        ? dateParam
        : DateHelper.todayDateId();

    final gameMode = modeParam == 'archive' ? GameMode.archive : GameMode.daily;

    return GameLoadConfig(
      gameDateId: gameDateId,
      gameMode: gameMode,
    );
  }
}
