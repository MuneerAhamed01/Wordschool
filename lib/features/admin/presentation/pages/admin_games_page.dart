import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/data/admin_api_service.dart';
import 'package:wordshool/features/admin/data/admin_environment_store.dart';
import 'package:wordshool/features/admin/domain/models/admin_game_summary.dart';
import 'package:wordshool/features/admin/presentation/widgets/prod_confirm_dialog.dart';

class AdminGamesPage extends StatefulWidget {
  const AdminGamesPage({super.key});

  @override
  State<AdminGamesPage> createState() => _AdminGamesPageState();
}

class _AdminGamesPageState extends State<AdminGamesPage> {
  List<AdminGameSummary> _games = [];
  bool _loading = false;
  String? _error;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _rangeEnd = DateTime(now.year, now.month, now.day);
    _rangeStart = _rangeEnd.subtract(const Duration(days: 13));
    _load();
  }

  String _dateId(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final games = await adminGetIt<AdminApiService>().listGames(
        startDateId: _dateId(_rangeStart),
        endDateId: _dateId(_rangeEnd),
      );
      if (!mounted) return;
      setState(() {
        _games = games;
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

  Future<void> _seedGame({String? dateId, String? word, bool force = false}) async {
    final env = adminGetIt<AdminEnvironmentStore>().current;
    final confirmed = await confirmIfProd(
      context,
      env,
      actionLabel: 'seed a daily puzzle',
    );
    if (!confirmed || !mounted) return;

    final targetDate = dateId ?? _dateId(DateTime.now());
    final wordController = TextEditingController(text: word);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Seed puzzle for $targetDate'),
        content: TextField(
          controller: wordController,
          decoration: const InputDecoration(
            labelText: 'Word (optional — uses hash if empty)',
            border: OutlineInputBorder(),
          ),
          maxLength: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Seed'),
          ),
        ],
      ),
    );

    if (result != true || !mounted) {
      wordController.dispose();
      return;
    }

    try {
      await adminGetIt<AdminApiService>().seedDailyGame(
        dateId: targetDate,
        todayWord: wordController.text.trim().isEmpty
            ? null
            : wordController.text.trim(),
        force: force,
      );
      wordController.dispose();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seeded puzzle for $targetDate')),
      );
      await _load();
    } catch (e) {
      wordController.dispose();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _seedMissing() async {
    final env = adminGetIt<AdminEnvironmentStore>().current;
    final confirmed = await confirmIfProd(
      context,
      env,
      actionLabel: 'seed missing puzzles',
    );
    if (!confirmed || !mounted) return;

    try {
      final result = await adminGetIt<AdminApiService>().seedMissingGames(
        startDateId: _dateId(_rangeStart),
        endDateId: _dateId(_rangeEnd),
      );
      if (!mounted) return;
      final created = (result['created'] as List<dynamic>? ?? []).length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created $created puzzles')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _deleteGame(String dateId) async {
    final env = adminGetIt<AdminEnvironmentStore>().current;
    final confirmed = await confirmIfProd(
      context,
      env,
      actionLabel: 'delete puzzle $dateId',
    );
    if (!confirmed || !mounted) return;

    try {
      await adminGetIt<AdminApiService>().deleteGame(dateId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted $dateId')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Daily Puzzles', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              FilledButton.tonal(
                onPressed: _loading ? null : _seedMissing,
                child: const Text('Seed missing'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading ? null : () => _seedGame(),
                child: const Text('Seed today'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      itemCount: _games.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final game = _games[index];
                        return ListTile(
                          leading: Icon(
                            game.exists ? Icons.check_circle : Icons.cancel,
                            color: game.exists ? Colors.green : Colors.red,
                          ),
                          title: Text(game.dateId),
                          subtitle: Text(
                            game.exists ? game.todayWord.toUpperCase() : 'Not seeded',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) {
                              switch (action) {
                                case 'seed':
                                  _seedGame(dateId: game.dateId, force: game.exists);
                                case 'override':
                                  _seedGame(dateId: game.dateId, force: true);
                                case 'delete':
                                  if (game.exists) _deleteGame(game.dateId);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'seed', child: Text('Seed')),
                              if (game.exists)
                                const PopupMenuItem(
                                  value: 'override',
                                  child: Text('Override'),
                                ),
                              if (game.exists)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
