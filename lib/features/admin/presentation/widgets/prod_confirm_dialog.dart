import 'package:flutter/material.dart';
import 'package:wordshool/features/admin/data/admin_environment_store.dart';

Future<bool> confirmProdAction(
  BuildContext context, {
  required String actionLabel,
}) async {
  final controller = TextEditingController();
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm production action'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You are about to $actionLabel in PRODUCTION.'),
          const SizedBox(height: 12),
          const Text('Type PROD to confirm:'),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'PROD',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, controller.text.trim() == 'PROD'),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result ?? false;
}

Future<bool> confirmIfProd(
  BuildContext context,
  AdminTargetEnvironment environment, {
  required String actionLabel,
}) async {
  if (!environment.isProd) return true;
  return confirmProdAction(context, actionLabel: actionLabel);
}
