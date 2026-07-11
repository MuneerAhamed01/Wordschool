import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BlockedUserPage extends StatelessWidget {
  const BlockedUserPage({super.key, this.reason});

  static const routeName = '/blocked';

  final String? reason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  'Account blocked',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  reason?.isNotEmpty == true
                      ? reason!
                      : 'Your account has been blocked. Contact support if you believe this is a mistake.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/auth'),
                  child: const Text('Back to sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
