import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/data/admin_api_service.dart';
import 'package:wordshool/features/admin/domain/models/admin_category.dart';
import 'package:wordshool/features/admin/domain/models/admin_enums.dart';
import 'package:wordshool/features/admin/domain/models/admin_puzzle.dart';
import 'package:wordshool/features/admin/domain/utils/ist_date.dart';
import 'package:wordshool/features/admin/presentation/widgets/admin_feedback.dart';
import 'package:wordshool/features/admin/presentation/widgets/admin_page.dart';
import 'package:wordshool/features/admin/presentation/widgets/category_visuals.dart';
import 'package:wordshool/features/admin/presentation/widgets/filter_chips.dart';
import 'package:wordshool/features/admin/presentation/widgets/status_chip.dart';

class AdminPuzzlesPage extends StatefulWidget {
  const AdminPuzzlesPage({super.key, this.initialCategoryId});

  static const routeName = '/puzzles';

  /// `/puzzles?category=kerala-history`.
  static String location({String? categoryId}) =>
      categoryId == null ? routeName : '$routeName?category=$categoryId';

  /// `/puzzles/new?category=…`.
  static String newLocation(String? categoryId) => categoryId == null
      ? '$routeName/new'
      : '$routeName/new?category=$categoryId';

  static String editLocation(String puzzleId) => '$routeName/$puzzleId/edit';

  static String detailLocation(String puzzleId) => '$routeName/$puzzleId';

  final String? initialCategoryId;

  @override
  State<AdminPuzzlesPage> createState() => _AdminPuzzlesPageState();
}

class _AdminPuzzlesPageState extends State<AdminPuzzlesPage> {
  final _api = adminGetIt<AdminApiService>();

  List<AdminCategory>? _categories;
  String? _categoryId;
  PuzzleStatus? _status;
  List<AdminPuzzleSummary> _puzzles = [];
  String? _cursor;
  bool _loading = true;
  bool _loadingMore = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final result = await _api.listCategories();
    if (!mounted) return;
    if (result is! DataSuccess) {
      setState(() {
        _loading = false;
        _loadError = result.error?.message;
      });
      return;
    }
    final categories = result.data!;
    setState(() {
      _categories = categories;
      final wanted = widget.initialCategoryId;
      _categoryId = categories.any((c) => c.id == wanted)
          ? wanted
          : (categories.isEmpty ? null : categories.first.id);
    });
    if (_categoryId != null) {
      await _load();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _load({bool more = false}) async {
    final categoryId = _categoryId;
    if (categoryId == null) return;
    setState(() {
      if (more) {
        _loadingMore = true;
      } else {
        _loading = true;
        _loadError = null;
      }
    });
    final result = await _api.listPuzzles(
      categoryId: categoryId,
      status: _status,
      startAfterId: more ? _cursor : null,
    );
    if (!mounted || categoryId != _categoryId) return;
    setState(() {
      _loading = false;
      _loadingMore = false;
      if (result is DataSuccess) {
        _puzzles =
            more ? [..._puzzles, ...result.data!.items] : result.data!.items;
        _cursor = result.data!.nextStartAfterId;
      } else if (more) {
        showAdminError(context, result.error);
      } else {
        _loadError = result.error?.message;
      }
    });
  }

  void _selectCategory(String id) {
    setState(() => _categoryId = id);
    context.go(AdminPuzzlesPage.location(categoryId: id));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Puzzles',
      subtitle:
          'Build crosswords from checked questions, then review and publish them.',
      help:
          'A puzzle moves through: Draft → In review → Scheduled or Live → Archived. '
          'Only Draft and In review puzzles can be edited.',
      actions: [
        FilledButton.icon(
          onPressed: _categoryId == null
              ? null
              : () => context.go(AdminPuzzlesPage.newLocation(_categoryId)),
          icon: const Icon(Icons.add),
          label: const Text('New puzzle'),
        ),
      ],
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    final categories = _categories;
    if (categories == null) {
      if (_loadError != null) {
        return EmptyState(
          icon: Icons.cloud_off,
          title: 'Could not load categories',
          message: _loadError,
          action: OutlinedButton(
              onPressed: _loadCategories, child: const Text('Try again')),
        );
      }
      return const LoadingBlock();
    }
    if (categories.isEmpty) {
      return EmptyState(
        icon: Icons.folder_open,
        title: 'Add a category first',
        message: 'Every puzzle belongs to a category such as "Kerala History".',
        action: FilledButton(
            onPressed: () => context.go('/categories'),
            child: const Text('Go to Categories')),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in categories)
              ChoiceChip(
                avatar: Icon(categoryIcon(category.icon),
                    size: 18, color: categoryColor(category.color)),
                label: Text(category.name.en),
                selected: category.id == _categoryId,
                onSelected: (_) => _selectCategory(category.id),
              ),
          ],
        ),
        const SizedBox(height: 12),
        FilterChips<PuzzleStatus?>(
          options: const [null, ...PuzzleStatus.values],
          selected: _status,
          label: (s) => s?.label ?? 'All statuses',
          onSelected: (s) {
            setState(() => _status = s);
            _load();
          },
        ),
        const SizedBox(height: 16),
        _buildList(),
      ],
    );
  }

  Widget _buildList() {
    if (_loading) return const LoadingBlock();
    if (_loadError != null) {
      return EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load puzzles',
        message: _loadError,
        action:
            OutlinedButton(onPressed: _load, child: const Text('Try again')),
      );
    }
    if (_puzzles.isEmpty) {
      return EmptyState(
        icon: Icons.grid_on,
        title: _status == null
            ? 'No puzzles in this category yet'
            : 'No ${_status!.label.toLowerCase()} puzzles',
        message: _status == null
            ? 'Press "New puzzle" to build the first one.'
            : null,
        action: _status == null
            ? FilledButton.icon(
                onPressed: () =>
                    context.go(AdminPuzzlesPage.newLocation(_categoryId)),
                icon: const Icon(Icons.add),
                label: const Text('New puzzle'),
              )
            : null,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final puzzle in _puzzles)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PuzzleCard(puzzle: puzzle),
          ),
        if (_cursor != null)
          Center(
            child: OutlinedButton.icon(
              onPressed: _loadingMore ? null : () => _load(more: true),
              icon: const Icon(Icons.expand_more),
              label: const Text('Load more'),
            ),
          ),
      ],
    );
  }
}

class _PuzzleCard extends StatelessWidget {
  const _PuzzleCard({required this.puzzle});

  final AdminPuzzleSummary puzzle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final when = switch (puzzle.status) {
      PuzzleStatus.scheduled when puzzle.publishAt != null =>
        'Goes live ${friendlyIstDateTime(puzzle.publishAt!)}',
      PuzzleStatus.published when puzzle.publishedAt != null =>
        'Live since ${friendlyIstDateTime(puzzle.publishedAt!)}',
      _ => puzzle.updatedAt == null
          ? ''
          : 'Last saved ${friendlyIstDateTime(puzzle.updatedAt!)}',
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(AdminPuzzlesPage.detailLocation(puzzle.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MyColors.gameSurfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#${puzzle.number}',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      puzzle.title.en,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        PuzzleStatusChip(status: puzzle.status),
                        DifficultyChip(difficulty: puzzle.difficulty),
                        Pill(
                          label:
                              '${puzzle.wordCount} words · ${puzzle.rows}×${puzzle.cols}',
                          background: MyColors.gameSurfaceElevated,
                          foreground: MyColors.textSecondary,
                        ),
                      ],
                    ),
                    if (when.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(when,
                          style: textTheme.bodySmall
                              ?.copyWith(color: MyColors.navInactive)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: MyColors.navInactive),
            ],
          ),
        ),
      ),
    );
  }
}
