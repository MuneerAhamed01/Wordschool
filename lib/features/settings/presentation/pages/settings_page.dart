import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wordshool/features/auth/presentation/pages/auth_page.dart';
import 'package:wordshool/shared/presentations/popup/general_pop_up.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/features/settings/presentation/bloc/settings_bloc.dart';
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
            if (context.mounted) {
              context.go(AuthPage.routeName);
            }
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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: false,
        ),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Terms & Conditions'),
              onTap: () => context.push(termsRouteName),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              onTap: () =>
                  _launchUrl('https://sites.google.com/view/wordschool/home'),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Log out',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () => _confirmAndLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndLogout(BuildContext context) async {
    await SlidingDialog.show(
      context,
      title: 'Are you sure you want to log out?',
      onPressContinue: () async {
        // Close dialog before navigating
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        context.read<SettingsBloc>().add(const SettingsEvent.logoutRequested());
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final myurl = Uri.parse(url);
    if (!await launchUrl(myurl)) {
      throw Exception('Could not launch $myurl');
    }
  }
}
