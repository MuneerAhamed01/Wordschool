import 'package:go_router/go_router.dart';
import 'package:wordshool/core/remote_config/story_mode_config.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/shared/domains/usercases/get_current_user_usecase.dart';

/// Redirects story routes when Remote Config disables story mode for this user.
Future<String?> redirectStoryModeFeatureGate(GoRouterState state) async {
  if (!getIt.isRegistered<StoryModeConfig>()) {
    return null;
  }

  final user = getIt.isRegistered<GetCurrentUserUseCase>()
      ? await getIt<GetCurrentUserUseCase>()()
      : null;

  if (!getIt<StoryModeConfig>().isEnabledForUser(user?.id)) {
    return DashboardPage.routeName;
  }
  return null;
}
