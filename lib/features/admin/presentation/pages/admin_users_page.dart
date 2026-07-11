import 'package:flutter/material.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/data/admin_api_service.dart';
import 'package:wordshool/features/admin/data/admin_environment_store.dart';
import 'package:wordshool/features/admin/domain/models/admin_user_summary.dart';
import 'package:wordshool/features/admin/presentation/widgets/prod_confirm_dialog.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _queryController = TextEditingController();
  AdminUserSummary? _user;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _user = null;
    });

    try {
      final user = await adminGetIt<AdminApiService>().searchUsers(query);
      if (!mounted) return;
      setState(() {
        _user = user;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _blockUser(AdminUserSummary user) async {
    final env = adminGetIt<AdminEnvironmentStore>().current;
    final confirmed = await confirmIfProd(
      context,
      env,
      actionLabel: 'block user ${user.uid}',
    );
    if (!confirmed || !mounted) return;

    final reasonController = TextEditingController();
    final disableAuth = ValueNotifier(false);

    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block user'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: disableAuth,
              builder: (context, value, _) => CheckboxListTile(
                value: value,
                onChanged: (v) => disableAuth.value = v ?? false,
                title: const Text('Also disable Firebase Auth'),
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
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (proceed != true || !mounted) {
      reasonController.dispose();
      return;
    }

    try {
      await adminGetIt<AdminApiService>().blockUser(
        uid: user.uid,
        reason: reasonController.text.trim(),
        disableAuth: disableAuth.value,
      );
      reasonController.dispose();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User blocked')),
      );
      await _search();
    } catch (e) {
      reasonController.dispose();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _unblockUser(AdminUserSummary user) async {
    final env = adminGetIt<AdminEnvironmentStore>().current;
    final confirmed = await confirmIfProd(
      context,
      env,
      actionLabel: 'unblock user ${user.uid}',
    );
    if (!confirmed || !mounted) return;

    try {
      await adminGetIt<AdminApiService>().unblockUser(uid: user.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unblocked')),
      );
      await _search();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Users', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    labelText: 'UID or email',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading ? null : _search,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Search'),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          if (user != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName ?? 'Unknown', style: Theme.of(context).textTheme.titleMedium),
                    Text(user.email ?? user.uid),
                    const SizedBox(height: 8),
                    Text('Streak: ${user.streak}'),
                    Text('Completed games: ${user.completedGames}'),
                    Text('Detective points: ${user.detectivePoints}'),
                    if (user.authDisabled)
                      const Text('Auth: disabled', style: TextStyle(color: Colors.red)),
                    if (user.isBlocked) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Blocked: ${user.blockedReason ?? "No reason"}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      if (user.blockedBy != null)
                        Text('Blocked by: ${user.blockedBy}'),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (!user.isBlocked)
                          FilledButton(
                            onPressed: () => _blockUser(user),
                            child: const Text('Block user'),
                          ),
                        if (user.isBlocked) ...[
                          FilledButton.tonal(
                            onPressed: () => _unblockUser(user),
                            child: const Text('Unblock user'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
