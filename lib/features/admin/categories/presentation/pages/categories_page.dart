import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/empty_state.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/loading_block.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/shared/data/data_source/categories_service.dart';
import 'package:wordshool/features/admin/shared/domain/models/category.dart';
import 'package:wordshool/features/admin/categories/domain/utils/category_style.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/feedback.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/page.dart';
import 'package:wordshool/shared/presentations/widgets/category_visuals.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';

class AdminCategoriesPage extends StatefulWidget {
  const AdminCategoriesPage({super.key});

  static const routeName = AdminRoutes.categories;

  @override
  State<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends State<AdminCategoriesPage> {
  final _categoryService = adminGetIt<AdminCategoriesService>();
  List<AdminCategory>? _categories;
  String? _loadError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loadError = null);
    final result = await _categoryService.listCategories();
    if (!mounted) return;
    setState(() {
      if (result is DataSuccess) {
        _categories = result.data;
      } else {
        _loadError = result.error?.message;
      }
    });
  }

  Future<bool> _save(AdminCategory category, String successMessage) async {
    setState(() => _saving = true);
    final result = await _categoryService.saveCategory(category);
    if (!mounted) return false;
    setState(() => _saving = false);
    if (result is DataSuccess) {
      showSuccess(context, successMessage);
      return true;
    }
    showAdminError(context, result.error);
    return false;
  }

  Future<void> _toggleActive(AdminCategory category, bool isActive) async {
    final updated = category.copyWith(isActive: isActive);
    _replace(updated);
    final ok = await _save(
      updated,
      isActive
          ? '"${category.name.en}" is visible to players'
          : '"${category.name.en}" is hidden from players',
    );
    if (!ok) _replace(category);
  }

  void _replace(AdminCategory category) {
    setState(() {
      _categories = [
        for (final c in _categories!) c.id == category.id ? category : c,
      ];
    });
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    final current = _categories!;
    final orders = reorderedOrders(current.length, oldIndex, newIndex);
    final updated = [
      for (var i = 0; i < current.length; i++)
        current[i].copyWith(order: orders[i]),
    ]..sort((a, b) => a.order.compareTo(b.order));
    setState(() => _categories = updated);

    setState(() => _saving = true);
    for (var i = 0; i < current.length; i++) {
      if (current[i].order == orders[i]) continue;
      final result = await _categoryService
          .saveCategory(current[i].copyWith(order: orders[i]));
      if (result is! DataSuccess) {
        if (!mounted) return;
        setState(() => _saving = false);
        showAdminError(context, result.error);
        await _load();
        return;
      }
    }
    if (!mounted) return;
    setState(() => _saving = false);
    showSuccess(context, 'New order saved');
  }

  Future<void> _openEditor([AdminCategory? existing]) async {
    final nextOrder = (_categories ?? [])
            .fold<int>(0, (max, c) => c.order > max ? c.order : max) +
        10;
    final category = await showDialog<AdminCategory>(
      context: context,
      builder: (context) => _CategoryDialog(
        existing: existing,
        takenIds: {for (final c in _categories ?? <AdminCategory>[]) c.id},
        nextOrder: nextOrder,
      ),
    );
    if (category == null || !mounted) return;
    final ok = await _save(
      category,
      existing == null
          ? 'Category "${category.name.en}" added'
          : 'Changes saved',
    );
    if (ok) await _load();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Categories',
      subtitle: 'Topics players choose from before they play.',
      help: 'Drag the ⠿ handle to change the order players see. Switch a '
          'category off to hide it from players — nothing is deleted.',
      actions: [
        if (_saving)
          const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        FilledButton.icon(
          onPressed: _categories == null ? null : () => _openEditor(),
          icon: const Icon(Icons.add),
          label: const Text('Add category'),
        ),
      ],
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loadError != null) {
      return EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load categories',
        message: _loadError,
        action:
            OutlinedButton(onPressed: _load, child: const Text('Try again')),
      );
    }
    final categories = _categories;
    if (categories == null) return const LoadingBlock();
    if (categories.isEmpty) {
      return EmptyState(
        icon: Icons.folder_open,
        title: 'No categories yet',
        message: 'Add the first topic, for example "Kerala History".',
        action: FilledButton.icon(
          onPressed: () => _openEditor(),
          icon: const Icon(Icons.add),
          label: const Text('Add category'),
        ),
      );
    }
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: categories.length,
      onReorder: _saving ? (_, __) {} : _reorder,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Padding(
          key: ValueKey(category.id),
          padding: const EdgeInsets.only(bottom: 10),
          child: _CategoryRow(
            index: index,
            category: category,
            onEdit: () => _openEditor(category),
            onAutoPuzzle: () =>
                context.go(AdminRoutes.autoPuzzle(category.id)),
            onToggle:
                _saving ? null : (value) => _toggleActive(category, value),
          ),
        );
      },
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.index,
    required this.category,
    required this.onEdit,
    required this.onAutoPuzzle,
    required this.onToggle,
  });

  final int index;
  final AdminCategory category;
  final VoidCallback onEdit;
  final VoidCallback onAutoPuzzle;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < 640;
    final puzzles = category.publishedPuzzleCount;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 12, 12),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child:
                      Icon(Icons.drag_indicator, color: MyColors.navInactive),
                ),
              ),
            ),
            CategoryBadge(icon: category.icon, color: category.color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name.en,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (category.name.ml != null)
                    Text(category.name.ml!, style: textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(
                    '$puzzles live puzzle${puzzles == 1 ? '' : 's'} · ID ${category.id}',
                    style: textTheme.bodySmall
                        ?.copyWith(color: MyColors.navInactive),
                  ),
                ],
              ),
            ),
            if (!narrow)
              Text(
                category.isActive ? 'Visible' : 'Hidden',
                style: textTheme.bodySmall?.copyWith(
                  color: category.isActive
                      ? MyColors.successText
                      : MyColors.navInactive,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Tooltip(
              message:
                  category.isActive ? 'Hide from players' : 'Show to players',
              child: Switch(value: category.isActive, onChanged: onToggle),
            ),
            IconButton(
              tooltip: 'Auto-create puzzle',
              onPressed: onAutoPuzzle,
              icon: const Icon(Icons.auto_awesome),
            ),
            IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({
    this.existing,
    required this.takenIds,
    required this.nextOrder,
  });

  final AdminCategory? existing;
  final Set<String> takenIds;
  final int nextOrder;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameEn = TextEditingController(text: widget.existing?.name.en);
  late final _nameMl = TextEditingController(text: widget.existing?.name.ml);
  late final _descEn =
      TextEditingController(text: widget.existing?.description?.en);
  late final _descMl =
      TextEditingController(text: widget.existing?.description?.ml);
  late final _slug = TextEditingController(text: widget.existing?.id);
  late String _icon = widget.existing?.icon ?? categoryIconNames.first;
  late String _color = widget.existing?.color ?? categoryColors.first;
  bool _slugEdited = false;

  bool get _isNew => widget.existing == null;

  @override
  void dispose() {
    for (final c in [_nameEn, _nameMl, _descEn, _descMl, _slug]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.existing;
    final description = LocalizedText(en: _descEn.text, ml: _descMl.text);
    Navigator.of(context).pop(
      AdminCategory(
        id: existing?.id ?? _slug.text.trim(),
        name: LocalizedText(en: _nameEn.text, ml: _nameMl.text),
        description: description.isEmpty ? null : description,
        icon: _icon,
        color: _color,
        order: existing?.order ?? widget.nextOrder,
        isActive: existing?.isActive ?? true,
        publishedPuzzleCount: existing?.publishedPuzzleCount ?? 0,
        lastPuzzleNumber: existing?.lastPuzzleNumber ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(_isNew ? 'Add category' : 'Edit category'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameEn,
                  autofocus: _isNew,
                  maxLength: 60,
                  decoration: const InputDecoration(
                      labelText: 'Name (English) *',
                      hintText: 'Kerala History'),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Enter a name' : null,
                  onChanged: (value) {
                    if (_isNew && !_slugEdited) _slug.text = slugify(value);
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameMl,
                  maxLength: 60,
                  decoration: const InputDecoration(
                      labelText: 'Name (Malayalam)', hintText: 'കേരള ചരിത്രം'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descEn,
                  maxLength: 200,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Short description (English)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descMl,
                  maxLength: 200,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Short description (Malayalam)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _slug,
                  enabled: _isNew,
                  maxLength: 60,
                  decoration: InputDecoration(
                    labelText: 'ID',
                    helperText: _isNew
                        ? 'Made from the name. Used in puzzle IDs; can\'t be changed later.'
                        : 'The ID can\'t be changed.',
                  ),
                  onChanged: (_) => _slugEdited = true,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (!_isNew) return null;
                    if (value.isEmpty) return 'Enter an ID';
                    if (!slugPattern.hasMatch(value)) {
                      return 'Use only small letters, numbers and dashes';
                    }
                    if (widget.takenIds.contains(value)) {
                      return 'Another category already uses this ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text('Icon', style: textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final name in categoryIconNames)
                      _ChoiceTile(
                        selected: name == _icon,
                        tooltip: name.replaceAll('_', ' '),
                        onTap: () => setState(() => _icon = name),
                        child: Icon(categoryIcon(name),
                            color: categoryColor(_color)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Colour', style: textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final hex in categoryColors)
                      _ChoiceTile(
                        selected: hex == _color,
                        tooltip: hex,
                        onTap: () => setState(() => _color = hex),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                              color: categoryColor(hex),
                              shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: _submit,
            child: Text(_isNew ? 'Add category' : 'Save changes')),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.selected,
    required this.onTap,
    required this.child,
    required this.tooltip,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MyColors.gameSurfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? MyColors.white : MyColors.gameBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
