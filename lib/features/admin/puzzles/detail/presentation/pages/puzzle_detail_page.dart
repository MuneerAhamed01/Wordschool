import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/empty_state.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/loading_block.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/shared/data/data_source/categories_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/puzzles_service.dart';
import 'package:wordshool/features/admin/shared/data/data_source/schedule_service.dart';
import 'package:wordshool/features/admin/shared/domain/models/category.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/domain/models/puzzle.dart';
import 'package:wordshool/core/utils/ist_date.dart';
import 'package:wordshool/features/admin/puzzles/domain/utils/puzzle_draft.dart';
import 'package:wordshool/features/admin/shared/domain/utils/status_flow.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/feedback.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/page.dart';
import 'package:wordshool/features/admin/puzzles/presentation/widgets/crossword_grid.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/schedule_dialogs.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/status_chip.dart';

/// One puzzle: preview as players see it, and buttons to move it along
/// Draft → In review → Scheduled / Live → Archived.
class AdminPuzzleDetailPage extends StatefulWidget {
  const AdminPuzzleDetailPage(
      {super.key, required this.puzzleId, this.highlightWordId});

  final String puzzleId;

  /// Word to highlight, e.g. from a player report.
  final String? highlightWordId;

  @override
  State<AdminPuzzleDetailPage> createState() => _AdminPuzzleDetailPageState();
}

class _AdminPuzzleDetailPageState extends State<AdminPuzzleDetailPage> {
  final _categoryService = adminGetIt<AdminCategoriesService>();
  final _puzzleService = adminGetIt<AdminPuzzlesService>();
  final _scheduleService = adminGetIt<AdminScheduleService>();
  AdminPuzzle? _puzzle;
  List<AdminCategory> _categories = [];
  String? _error;
  bool _busy = false;
  bool _showAnswers = false;
  late String? _selectedWordId = widget.highlightWordId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    final results = await Future.wait([
      _puzzleService.getPuzzle(widget.puzzleId),
      _categoryService.listCategories()
    ]);
    if (!mounted) return;
    setState(() {
      if (results[0] is DataSuccess) {
        _puzzle = results[0].data as AdminPuzzle;
      } else {
        _error = results[0].error?.message;
      }
      if (results[1] is DataSuccess) {
        _categories = results[1].data as List<AdminCategory>;
      }
    });
  }

  String get _categoryName {
    final id = _puzzle?.categoryId;
    for (final c in _categories) {
      if (c.id == id) return c.name.en;
    }
    return id ?? '';
  }

  Future<void> _run(StatusAction action) async {
    final puzzle = _puzzle!;
    DateTime? publishAt;
    if (action.needsDate) {
      publishAt = await pickGoLive(context, current: puzzle.publishAt);
      if (publishAt == null) return;
    } else if (action.confirm != null) {
      final ok = await confirmAction(
        context,
        title: '${action.label}?',
        message: action.confirm!,
        confirmLabel: action.label,
        destructive: action.destructive,
      );
      if (!ok) return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    final result = await _puzzleService.setPuzzleStatus(
        puzzleId: puzzle.id!, status: action.target, publishAt: publishAt);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result is DataSuccess) {
      showSuccess(
          context,
          switch (action.target) {
            PuzzleStatus.scheduled =>
              'Scheduled — goes live ${friendlyIstDateTime(publishAt!)}',
            PuzzleStatus.published => 'The puzzle is live',
            PuzzleStatus.archived => 'The puzzle is archived',
            PuzzleStatus.inReview => 'Sent for review',
            PuzzleStatus.draft => 'Moved back to draft',
          });
      await _load();
    } else {
      showAdminError(context, result.error);
    }
  }

  Future<void> _setAsDaily() async {
    final date = await pickDailyDate(context);
    if (date == null || !mounted) return;
    setState(() => _busy = true);
    final result = await _scheduleService.scheduleDaily(
        dateId: date, puzzleId: widget.puzzleId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result is DataSuccess) {
      showSuccess(context, 'Puzzle of the day for ${friendlyDate(date)}');
    } else {
      showAdminError(context, result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzle;
    final back = IconButton(
      tooltip: 'Back to puzzles',
      onPressed: () =>
          context.go(AdminRoutes.puzzlesOf(categoryId: puzzle?.categoryId)),
      icon: const Icon(Icons.arrow_back),
    );
    if (puzzle == null) {
      return AdminPage(
        title: 'Puzzle',
        leading: back,
        child: _error == null
            ? const LoadingBlock()
            : EmptyState(
                icon: Icons.cloud_off,
                title: 'Could not open the puzzle',
                message: _error,
                action: OutlinedButton(
                    onPressed: _load, child: const Text('Try again')),
              ),
      );
    }

    final wide = MediaQuery.sizeOf(context).width >= 1100;
    final preview = _buildPreview(puzzle);
    final side = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatusCard(puzzle),
        const SizedBox(height: 16),
        _buildInfoCard(puzzle)
      ],
    );
    return AdminPage(
      title: '#${puzzle.number} ${puzzle.title.en}',
      subtitle: _categoryName,
      leading: back,
      actions: [
        if (puzzle.status.isEditable)
          OutlinedButton.icon(
            onPressed: () => context.go(AdminRoutes.editPuzzle(puzzle.id!)),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit puzzle'),
          ),
      ],
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: preview),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: side),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [side, const SizedBox(height: 16), preview],
            ),
    );
  }

  Widget _buildStatusCard(AdminPuzzle puzzle) {
    final actions = statusActions(puzzle.status);
    final textTheme = Theme.of(context).textTheme;
    final canBeDaily = puzzle.status == PuzzleStatus.published ||
        puzzle.status == PuzzleStatus.scheduled;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Status',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(width: 10),
                PuzzleStatusChip(status: puzzle.status),
                const Spacer(),
                if (_busy)
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 8),
            Text(puzzle.status.help,
                style: textTheme.bodyMedium
                    ?.copyWith(color: MyColors.textSecondary)),
            if (puzzle.status == PuzzleStatus.scheduled &&
                puzzle.publishAt != null) ...[
              const SizedBox(height: 6),
              Text(
                'Goes live ${friendlyIstDateTime(puzzle.publishAt!)}',
                style: const TextStyle(
                    color: MyColors.warnText, fontWeight: FontWeight.w700),
              ),
            ],
            if (puzzle.status == PuzzleStatus.published &&
                puzzle.publishedAt != null) ...[
              const SizedBox(height: 6),
              Text(
                'Live since ${friendlyIstDateTime(puzzle.publishedAt!)}',
                style: const TextStyle(
                    color: MyColors.successText, fontWeight: FontWeight.w700),
              ),
            ],
            if (actions.isNotEmpty || canBeDaily) ...[
              const SizedBox(height: 16),
              Text('What next?', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              for (final action in actions)
                _ActionRow(
                    action: action, busy: _busy, onPressed: () => _run(action)),
              if (canBeDaily)
                _ActionRow(
                  action: const StatusAction(
                    target: PuzzleStatus.published,
                    label: 'Make puzzle of the day',
                    description:
                        'Show it to everyone as the daily puzzle on a date.',
                  ),
                  icon: Icons.today,
                  busy: _busy,
                  onPressed: _setAsDaily,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
                width: 130,
                child: Text(label,
                    style: const TextStyle(color: MyColors.textSecondary))),
            Expanded(
                child: Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      );

  Widget _buildInfoCard(AdminPuzzle puzzle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _buildInfoRow('Category', _categoryName),
            if (puzzle.title.ml != null)
              _buildInfoRow('Title (ML)', puzzle.title.ml!),
            _buildInfoRow('Difficulty', puzzle.difficulty.label),
            _buildInfoRow('Words', '${puzzle.words.length}'),
            _buildInfoRow('Grid', '${puzzle.rows} × ${puzzle.cols}'),
            _buildInfoRow('XP reward', '${puzzle.xpReward}'),
            _buildInfoRow(
                'Time to solve', 'About ${puzzle.estimatedMinutes} min'),
            _buildInfoRow('Puzzle ID', puzzle.id ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(AdminPuzzle puzzle) {
    final draft = PuzzleDraft.fromPuzzle(puzzle);
    final selected =
        puzzle.words.where((w) => w.id == _selectedWordId).firstOrNull;
    final highlighted = selected == null
        ? <(int, int)>{}
        : {
            for (var i = 0; i < selected.length; i++)
              (
                selected.row + selected.direction.dRow * i,
                selected.col + selected.direction.dCol * i
              ),
          };
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Preview — as players see it',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const Text('Show answers',
                    style: TextStyle(color: MyColors.textSecondary)),
                Switch(
                    value: _showAnswers,
                    onChanged: (v) => setState(() => _showAnswers = v)),
              ],
            ),
            const SizedBox(height: 12),
            CrosswordGrid(
              rows: puzzle.rows,
              cols: puzzle.cols,
              letters: draft.letters,
              numbers: draft.numbers,
              showLetters: _showAnswers,
              highlighted: highlighted,
              maxCellSize: 48,
              onCellTap: (cell) {
                final index =
                    draft.placementAt(cell, direction: selected?.direction);
                if (index == null) return;
                final p = draft.placements[index];
                setState(() => _selectedWordId = puzzle.words
                    .firstWhere((w) =>
                        w.row == p.row &&
                        w.col == p.col &&
                        w.direction == p.direction)
                    .id);
              },
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final across = _ClueList(
                  title: 'Across',
                  words: puzzle.words
                      .where((w) => w.direction == WordDirection.across)
                      .toList(),
                  showAnswers: _showAnswers,
                  selectedId: _selectedWordId,
                  onTap: (id) => setState(() => _selectedWordId = id),
                );
                final down = _ClueList(
                  title: 'Down',
                  words: puzzle.words
                      .where((w) => w.direction == WordDirection.down)
                      .toList(),
                  showAnswers: _showAnswers,
                  selectedId: _selectedWordId,
                  onTap: (id) => setState(() => _selectedWordId = id),
                );
                if (constraints.maxWidth < 560) {
                  return Column(
                      children: [across, const SizedBox(height: 16), down]);
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: across),
                    const SizedBox(width: 16),
                    Expanded(child: down)
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow(
      {required this.action,
      required this.busy,
      required this.onPressed,
      this.icon});

  final StatusAction action;
  final bool busy;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final iconData = icon ??
        switch (action.target) {
          PuzzleStatus.inReview => Icons.send_outlined,
          PuzzleStatus.draft => Icons.undo,
          PuzzleStatus.scheduled => Icons.schedule,
          PuzzleStatus.published => Icons.public,
          PuzzleStatus.archived => Icons.inventory_2_outlined,
        };
    final button = action.primary
        ? FilledButton.icon(
            onPressed: busy ? null : onPressed,
            icon: Icon(iconData),
            label: Text(action.label))
        : OutlinedButton.icon(
            onPressed: busy ? null : onPressed,
            style: action.destructive
                ? OutlinedButton.styleFrom(foregroundColor: MyColors.errorText)
                : null,
            icon: Icon(iconData),
            label: Text(action.label),
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 210, child: button),
          const SizedBox(width: 12),
          Expanded(
            child: Text(action.description,
                style: const TextStyle(
                    color: MyColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ClueList extends StatelessWidget {
  const _ClueList({
    required this.title,
    required this.words,
    required this.showAnswers,
    required this.selectedId,
    required this.onTap,
  });

  final String title;
  final List<AdminPuzzleWord> words;
  final bool showAnswers;
  final String? selectedId;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: textTheme.labelMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        for (final word in words)
          Material(
            color: word.id == selectedId
                ? MyColors.gridWordBg
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onTap(word.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('${word.number}',
                          style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${word.clue.en} (${word.length})'),
                          if (showAnswers) ...[
                            const SizedBox(height: 2),
                            Text(
                              word.answer,
                              style: const TextStyle(
                                color: MyColors.successText,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            if (word.fact != null && !word.fact!.isEmpty)
                              Text(
                                word.fact!.en,
                                style: const TextStyle(
                                    color: MyColors.textSecondary,
                                    fontSize: 12),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
