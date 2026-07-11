import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/data/admin_api_service.dart';
import 'package:wordshool/features/admin/data/admin_environment_store.dart';
import 'package:wordshool/features/admin/domain/models/admin_case_summary.dart';
import 'package:wordshool/features/admin/presentation/widgets/prod_confirm_dialog.dart';

class AdminCasesPage extends StatefulWidget {
  const AdminCasesPage({super.key});

  @override
  State<AdminCasesPage> createState() => _AdminCasesPageState();
}

class _AdminCasesPageState extends State<AdminCasesPage> {
  List<AdminCaseSummary> _cases = [];
  bool _loading = false;
  String? _error;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().toUtc();
    _rangeEnd = DateTime.utc(now.year, now.month, now.day);
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
      final cases = await adminGetIt<AdminApiService>().listCases(
        startDateId: _dateId(_rangeStart),
        endDateId: _dateId(_rangeEnd),
      );
      if (!mounted) return;
      setState(() {
        _cases = cases;
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

  Future<void> _seedCase({
    required String dateId,
    required String source,
    bool force = false,
  }) async {
    final env = adminGetIt<AdminEnvironmentStore>().current;
    final confirmed = await confirmIfProd(
      context,
      env,
      actionLabel: 'seed detective case ($source)',
    );
    if (!confirmed || !mounted) return;

    try {
      await adminGetIt<AdminApiService>().seedDetectiveCase(
        dateId: dateId,
        source: source,
        force: force,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seeded case for $dateId ($source)')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _bulkSeed() async {
    final env = adminGetIt<AdminEnvironmentStore>().current;
    final confirmed = await confirmIfProd(
      context,
      env,
      actionLabel: 'bulk seed planned cases',
    );
    if (!confirmed || !mounted) return;

    try {
      final result = await adminGetIt<AdminApiService>().bulkSeedPlannedCases(
        startDateId: _dateId(_rangeStart),
        endDateId: _dateId(_rangeEnd),
      );
      if (!mounted) return;
      final count = (result['results'] as List<dynamic>? ?? []).length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processed $count planned cases')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _preview(String dateId) async {
    try {
      final preview = await adminGetIt<AdminApiService>().getCasePreview(dateId);
      if (!mounted) return;
      final caseData = preview['case'] as Map<String, dynamic>?;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Case $dateId'),
          content: SingleChildScrollView(
            child: caseData == null
                ? Text(
                    preview['hasPlannedCatalog'] == true
                        ? 'Planned in catalog but not seeded yet.'
                        : 'No case found.',
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(caseData['title']?.toString() ?? ''),
                      const SizedBox(height: 8),
                      Text(caseData['introduction']?.toString() ?? ''),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
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
              Text('Detective Cases', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              FilledButton.tonal(
                onPressed: _loading ? null : _bulkSeed,
                child: const Text('Bulk seed planned'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading
                    ? null
                    : () => _seedCase(
                          dateId: _dateId(DateTime.now().toUtc()),
                          source: 'planned',
                        ),
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
                      itemCount: _cases.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _cases[index];
                        return ListTile(
                          leading: Icon(
                            item.exists ? Icons.check_circle : Icons.cancel,
                            color: item.exists ? Colors.green : Colors.red,
                          ),
                          title: Text(item.dateId),
                          subtitle: Text(
                            item.exists
                                ? (item.title ?? 'Seeded')
                                : item.hasPlanned
                                    ? 'Planned — not seeded'
                                    : 'Missing',
                          ),
                          onTap: () => _preview(item.dateId),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) {
                              switch (action) {
                                case 'planned':
                                  _seedCase(
                                    dateId: item.dateId,
                                    source: 'planned',
                                    force: item.exists,
                                  );
                                case 'example':
                                  _seedCase(
                                    dateId: item.dateId,
                                    source: 'example',
                                    force: item.exists,
                                  );
                                case 'ai':
                                  _seedCase(
                                    dateId: item.dateId,
                                    source: 'ai',
                                    force: item.exists,
                                  );
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'planned',
                                child: Text('Seed from catalog'),
                              ),
                              PopupMenuItem(
                                value: 'example',
                                child: Text('Seed example'),
                              ),
                              PopupMenuItem(
                                value: 'ai',
                                child: Text('Generate with AI'),
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
