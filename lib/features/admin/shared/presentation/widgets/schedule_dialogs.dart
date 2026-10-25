import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/shared/data/data_source/puzzles_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/schedule_service.dart';
import 'package:wordshool/features/admin/shared/domain/models/category.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/puzzle.dart';
import 'package:wordshool/core/utils/ist_date.dart';
import 'package:wordshool/features/admin/shared/domain/utils/status_flow.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/status_chip.dart';

DateTime _istToday() => istDate(DateTime.now());

DateTime _dateOf(String id) {
  final parts = id.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

/// Asks for a go-live date and time (India time). Returns the instant in UTC.
Future<DateTime?> pickGoLive(BuildContext context, {DateTime? current}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => _GoLiveDialog(current: current),
  );
}

class _GoLiveDialog extends StatefulWidget {
  const _GoLiveDialog({this.current});

  final DateTime? current;

  @override
  State<_GoLiveDialog> createState() => _GoLiveDialogState();
}

class _GoLiveDialogState extends State<_GoLiveDialog> {
  late DateTime _day;
  TimeOfDay _time = const TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    super.initState();
    final current = widget.current;
    if (current != null) {
      final ist = current.toUtc().add(istOffset);
      _day = DateTime.utc(ist.year, ist.month, ist.day);
      _time = TimeOfDay(hour: ist.hour, minute: ist.minute);
    } else {
      _day = _istToday().add(const Duration(days: 1));
    }
  }

  DateTime get _instant => istDateTime(_day, _time.hour, _time.minute);

  Future<void> _pickDay() async {
    final today = _istToday();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_day.year, _day.month, _day.day),
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 1, today.month, today.day),
    );
    if (picked != null) {
      setState(
          () => _day = DateTime.utc(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final inFuture = _instant.isAfter(DateTime.now().toUtc());
    return AlertDialog(
      title: const Text('When should it go live?'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Times are India time (IST).'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDay,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(friendlyDate(dateId(_day))),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule, size: 18),
                  label: Text(_time.format(context)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              inFuture
                  ? 'Goes live ${friendlyIstDateTime(_instant)}.'
                  : 'That time has already passed — pick a later one.',
              style: TextStyle(
                color: inFuture ? MyColors.successText : MyColors.errorText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tip: keep 12:00 AM if you also want it as the puzzle of the day on that date.',
              style: TextStyle(color: MyColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed:
              inFuture ? () => Navigator.of(context).pop(_instant) : null,
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}

/// Asks for a date (today or later, India time) as `YYYY-MM-DD`.
Future<String?> pickDailyDate(BuildContext context, {String? initial}) async {
  final today = _istToday();
  final first = DateTime(today.year, today.month, today.day);
  final picked = await showDatePicker(
    context: context,
    helpText: 'Puzzle of the day for…',
    initialDate: initial == null ? first : _dateOf(initial),
    firstDate: first,
    lastDate: DateTime(today.year + 1, today.month, today.day),
  );
  return picked == null
      ? null
      : dateId(DateTime.utc(picked.year, picked.month, picked.day));
}

/// Lets the admin pick a published / scheduled puzzle for [dateId] and saves
/// it with `adminScheduleDaily`. Returns true when saved.
Future<bool> choosePuzzleForDay(
  BuildContext context, {
  required String dateId,
  required List<AdminCategory> categories,
  String? currentPuzzleId,
}) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) => _ChoosePuzzleDialog(
      dateId: dateId,
      categories: categories,
      currentPuzzleId: currentPuzzleId,
    ),
  );
  return saved ?? false;
}

class _ChoosePuzzleDialog extends StatefulWidget {
  const _ChoosePuzzleDialog({
    required this.dateId,
    required this.categories,
    this.currentPuzzleId,
  });

  final String dateId;
  final List<AdminCategory> categories;
  final String? currentPuzzleId;

  @override
  State<_ChoosePuzzleDialog> createState() => _ChoosePuzzleDialogState();
}

class _ChoosePuzzleDialogState extends State<_ChoosePuzzleDialog> {
  final _puzzleService = adminGetIt<AdminPuzzlesService>();
  final _scheduleService = adminGetIt<AdminScheduleService>();
  late String? _categoryId =
      widget.categories.isEmpty ? null : widget.categories.first.id;
  List<AdminPuzzleSummary>? _puzzles;
  String? _error;
  String? _saving;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final categoryId = _categoryId;
    if (categoryId == null) return;
    setState(() {
      _puzzles = null;
      _error = null;
    });
    final result =
        await _puzzleService.listPuzzles(categoryId: categoryId, limit: 100);
    if (!mounted || categoryId != _categoryId) return;
    setState(() {
      if (result is DataSuccess) {
        _puzzles = result.data!.items
            .where((p) =>
                p.status == PuzzleStatus.published ||
                p.status == PuzzleStatus.scheduled)
            .toList();
      } else {
        _error = result.error?.message;
      }
    });
  }

  Future<void> _choose(AdminPuzzleSummary puzzle) async {
    setState(() {
      _saving = puzzle.id;
      _error = null;
    });
    final result = await _scheduleService.scheduleDaily(
        dateId: widget.dateId, puzzleId: puzzle.id);
    if (!mounted) return;
    if (result is DataSuccess) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = null;
        _error = result.error?.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayStart = startOfIstDay(widget.dateId);
    final puzzles = _puzzles;
    return AlertDialog(
      title: Text('Puzzle of the day · ${friendlyDate(widget.dateId)}'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Only Live puzzles, or Scheduled ones that go live by midnight of this day, can be chosen.',
              style: TextStyle(color: MyColors.textSecondary),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final c in widget.categories)
                  DropdownMenuItem(value: c.id, child: Text(c.name.en)),
              ],
              onChanged: (id) {
                setState(() => _categoryId = id);
                _load();
              },
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!,
                    style: const TextStyle(color: MyColors.errorText)),
              ),
            if (widget.categories.isEmpty)
              const Text('There are no categories yet.')
            else if (puzzles == null && _error == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (puzzles != null && puzzles.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No Live or Scheduled puzzles in this category. Publish or schedule one first.',
                  style: TextStyle(color: MyColors.warnText),
                ),
              )
            else if (puzzles != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final p in puzzles) _buildRow(p, dayStart),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel')),
      ],
    );
  }

  Widget _buildRow(AdminPuzzleSummary puzzle, DateTime dayStart) {
    final allowed = canBeDaily(
        status: puzzle.status, publishAt: puzzle.publishAt, dayStart: dayStart);
    final current = puzzle.id == widget.currentPuzzleId;
    return ListTile(
      enabled: allowed && _saving == null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text('#${puzzle.number} ${puzzle.title.en}'),
      subtitle: Text(
        allowed
            ? '${puzzle.wordCount} words · ${puzzle.difficulty.label}'
            : 'Goes live too late (${friendlyIstDateTime(puzzle.publishAt!)})',
      ),
      leading: PuzzleStatusChip(status: puzzle.status),
      trailing: _saving == puzzle.id
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
          : current
              ? const Icon(Icons.check, color: MyColors.successText)
              : null,
      onTap: allowed && _saving == null ? () => _choose(puzzle) : null,
    );
  }
}
