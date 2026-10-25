import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/empty_state.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/loading_block.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/schedule/data/data_source/daily_entries_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/categories_service.dart';
import 'package:wordshool/features/admin/shared/domain/models/category.dart';
import 'package:wordshool/features/admin/schedule/domain/models/daily_entry.dart';
import 'package:wordshool/core/utils/ist_date.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/feedback.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/page.dart';
import 'package:wordshool/shared/presentations/widgets/category_visuals.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/schedule_dialogs.dart';

/// The puzzle of the day for the next 30 days (India time); empty days are
/// flagged so nobody opens the app to nothing.
class AdminSchedulePage extends StatefulWidget {
  const AdminSchedulePage({super.key});

  static const routeName = AdminRoutes.schedule;
  static const days = 30;

  @override
  State<AdminSchedulePage> createState() => _AdminSchedulePageState();
}

class _AdminSchedulePageState extends State<AdminSchedulePage> {
  final _categoryService = adminGetIt<AdminCategoriesService>();
  final _dailyEntryService = adminGetIt<DailyEntriesService>();
  late List<String> _dates;
  Map<String, CrosswordDailyEntry>? _entries;
  List<AdminCategory> _categories = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _dates = nextIstDateIds(AdminSchedulePage.days);
    setState(() => _error = null);
    final results = await Future.wait([
      _dailyEntryService.getDailyEntries(_dates),
      _categoryService.listCategories()
    ]);
    if (!mounted) return;
    setState(() {
      if (results[0] is DataSuccess) {
        _entries = results[0].data as Map<String, CrosswordDailyEntry>;
      } else {
        _error = results[0].error?.message;
      }
      if (results[1] is DataSuccess) {
        _categories = results[1].data as List<AdminCategory>;
      }
    });
  }

  Future<void> _choose(String dateId) async {
    final saved = await choosePuzzleForDay(
      context,
      dateId: dateId,
      categories: _categories,
      currentPuzzleId: _entries?[dateId]?.puzzleId,
    );
    if (!saved || !mounted) return;
    showSuccess(context, 'Puzzle of the day set for ${friendlyDate(dateId)}');
    final refreshed = await _dailyEntryService.getDailyEntries([dateId]);
    if (!mounted || refreshed is! DataSuccess) return;
    setState(() {
      _entries = {..._entries!, ...refreshed.data!};
    });
  }

  AdminCategory? _category(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Daily schedule',
      subtitle:
          'The "Puzzle of the day" for the next ${AdminSchedulePage.days} days.',
      help:
          'At midnight (India time) the app shows that day\'s puzzle. Choose a Live '
          'puzzle — or a Scheduled one that goes live by midnight — for every day. '
          'Empty days are shown in yellow.',
      actions: [
        OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh')),
      ],
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load the schedule',
        message: _error,
        action:
            OutlinedButton(onPressed: _load, child: const Text('Try again')),
      );
    }
    final entries = _entries;
    if (entries == null) return const LoadingBlock();
    final filled = _dates.where(entries.containsKey).length;
    final emptySoon =
        _dates.take(7).where((d) => !entries.containsKey(d)).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Summary(filled: filled, total: _dates.length, emptySoon: emptySoon),
        const SizedBox(height: 16),
        for (var i = 0; i < _dates.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DayRow(
              dateId: _dates[i],
              label: i == 0
                  ? 'Today'
                  : i == 1
                      ? 'Tomorrow'
                      : null,
              entry: entries[_dates[i]],
              category: entries[_dates[i]] == null
                  ? null
                  : _category(entries[_dates[i]]!.categoryId),
              onChoose: () => _choose(_dates[i]),
            ),
          ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary(
      {required this.filled, required this.total, required this.emptySoon});

  final int filled;
  final int total;
  final int emptySoon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$filled of $total days have a puzzle',
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : filled / total,
                minHeight: 10,
                backgroundColor: MyColors.warnBg,
                color: MyColors.tileCorrect,
              ),
            ),
            if (emptySoon > 0) ...[
              const SizedBox(height: 10),
              Text(
                '$emptySoon of the next 7 days ${emptySoon == 1 ? 'has' : 'have'} no puzzle yet.',
                style: const TextStyle(
                    color: MyColors.warnText, fontWeight: FontWeight.w700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.dateId,
    required this.label,
    required this.entry,
    required this.category,
    required this.onChoose,
  });

  final String dateId;
  final String? label;
  final CrosswordDailyEntry? entry;
  final AdminCategory? category;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final empty = entry == null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: empty ? MyColors.warnBg : MyColors.gameSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: empty ? MyColors.gridWordBorder : MyColors.gameBorderSubtle),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Text(label!,
                      style: const TextStyle(
                          color: MyColors.successText,
                          fontWeight: FontWeight.w800)),
                Text(friendlyDate(dateId),
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 520),
            child: empty
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: MyColors.warnText, size: 20),
                      SizedBox(width: 8),
                      Text('No puzzle yet',
                          style: TextStyle(
                              color: MyColors.warnText,
                              fontWeight: FontWeight.w700)),
                    ],
                  )
                : InkWell(
                    onTap: () =>
                        context.go(AdminRoutes.puzzleDetail(entry!.puzzleId)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (category != null) ...[
                          CategoryBadge(
                              icon: category!.icon,
                              color: category!.color,
                              size: 32),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry!.title.en,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                              Text(
                                '${category?.name.en ?? entry!.categoryId} · ${entry!.wordCount} words · '
                                '${entry!.difficulty.label}',
                                style: textTheme.bodySmall
                                    ?.copyWith(color: MyColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          empty
              ? FilledButton.icon(
                  onPressed: onChoose,
                  icon: const Icon(Icons.add),
                  label: const Text('Choose puzzle'))
              : OutlinedButton(
                  onPressed: onChoose, child: const Text('Change')),
        ],
      ),
    );
  }
}
