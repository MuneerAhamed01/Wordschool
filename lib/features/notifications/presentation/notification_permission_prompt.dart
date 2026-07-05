import 'package:flutter/material.dart';
import 'package:wordshool/di.dart';
import 'package:wordshool/features/notifications/notification_service.dart';
import 'package:wordshool/shared/data/data_source/session_handler.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';

class NotificationPermissionPrompt extends StatefulWidget {
  const NotificationPermissionPrompt({super.key});

  @override
  State<NotificationPermissionPrompt> createState() =>
      _NotificationPermissionPromptState();
}

class _NotificationPermissionPromptState
    extends State<NotificationPermissionPrompt> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowPrompt());
  }

  Future<void> _maybeShowPrompt() async {
    if (_checked || !mounted) return;
    _checked = true;

    final service = getIt<NotificationService>();
    final prefs = service.preferences;

    if (prefs.permissionPromptShown) return;
    if (await service.hasPermission()) {
      await service.markPermissionPromptShown();
      final userId = getIt<SessionHandler>().currentUser?.id;
      if (userId != null) {
        await service.bindUser(userId);
      }
      return;
    }

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Never miss today\'s case'),
          content: const Text(
            'Get daily puzzle reminders, detective case alerts, and streak '
            'warnings so you keep your momentum.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await service.markPermissionPromptShown();
              },
              child: const Text('Not now'),
            ),
            AppButton(
              label: 'Enable',
              expand: false,
              onTap: () async {
                Navigator.of(dialogContext).pop();
                await service.requestPermission();
                await service.markPermissionPromptShown();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
