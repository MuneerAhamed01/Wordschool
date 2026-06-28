import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/config/monetization_config.dart';
import 'package:wordshool/core/monetization/story_entitlements.dart';
import 'package:wordshool/core/monetization/iap_service.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/auth/presentation/pages/auth_page.dart';
import 'package:wordshool/features/settings/presentation/widgets/story_settings_tiles.dart';
import 'package:wordshool/shared/presentations/popup/general_pop_up.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:wordshool/shared/presentations/widgets/action_tile.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/snackbar.dart';

class SettingsPage extends StatelessWidget {
  static const String routeName = '/settings';
  static const String termsRouteName = '/terms';
  static const String privacyRouteName = '/privacy';
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: (context, state) {
        state.whenOrNull(
          success: () {
            if (context.mounted) context.go(AuthPage.routeName);
          },
          error: (message) {
            CustomSnackBar.show(
              context,
              message: message,
              type: SnackBarType.error,
            );
          },
        );
      },
      child: GameScaffold(
        safeAreaBottom: false,
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            FadeSlideIn(
              child: ActionTile(
                title: 'Terms & Conditions',
                subtitle: 'Read our terms of service',
                icon: Icons.description_outlined,
                accentColor: MyColors.lightBlue3,
                onTap: () => context.push(termsRouteName),
              ),
            ),
            const SizedBox(height: 10),
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: ActionTile(
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                icon: Icons.privacy_tip_outlined,
                accentColor: MyColors.tileCorrect,
                onTap: () =>
                    _launchUrl('https://sites.google.com/view/wordschool/home'),
              ),
            ),
            const SizedBox(height: 10),
            FadeSlideIn(
              delay: const Duration(milliseconds: 120),
              child: const StoryAudioSettingTile(),
            ),
            const SizedBox(height: 10),
            if (getIt<MonetizationConfig>().isMonetizationAndPurchasesEnabled) ...[
              FadeSlideIn(
                delay: const Duration(milliseconds: 140),
                child: const DetectiveUpgradeTiles(),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: ActionTile(
                  title: 'Restore purchases',
                  subtitle: 'Detective Pro, hint packs & remove ads',
                  icon: Icons.restore_rounded,
                  accentColor: MyColors.streakAccent,
                  onTap: () async {
                    if (getIt.isRegistered<IapService>()) {
                      await getIt<IapService>().restorePurchases();
                      if (getIt.isRegistered<StoryEntitlementsService>()) {
                        await getIt<StoryEntitlementsService>().refresh();
                      }
                      if (context.mounted) {
                        CustomSnackBar.show(
                          context,
                          message:
                              'Restore requested — check your entitlements',
                          type: SnackBarType.success,
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
            FadeSlideIn(
              delay: const Duration(milliseconds: 240),
              child: ActionTile(
                title: 'Log out',
                subtitle: 'Sign out of your account',
                icon: Icons.logout_rounded,
                accentColor: Colors.redAccent,
                onTap: () => _confirmLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    await SlidingDialog.show(
      context,
      title: 'Are you sure you want to log out?',
      onPressContinue: () {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        context.read<SettingsBloc>().add(const SettingsEvent.logoutRequested());
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
