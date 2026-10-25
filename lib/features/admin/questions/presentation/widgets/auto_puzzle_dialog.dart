import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/features/admin/shared/domain/models/category.dart';
import 'package:wordshool/features/admin/shared/domain/models/enums.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/auto_puzzle_fields.dart';

/// "Auto-create puzzle" on the Questions page: pick a category and the grid
/// options; returns the builder path to open (CW-038).
class AutoPuzzleDialog extends StatefulWidget {
  const AutoPuzzleDialog({
    super.key,
    required this.categories,
    this.initialSubject,
    this.checkedCount,
  });

  final List<AdminCategory> categories;

  /// Preselects the category with this subject (the page's subject filter).
  final String? initialSubject;

  /// Checked questions in a category, when the page has all of them loaded.
  final int? Function(AdminCategory category)? checkedCount;

  /// The path to go to, or null when cancelled.
  static Future<String?> show(
    BuildContext context, {
    required List<AdminCategory> categories,
    String? initialSubject,
    int? Function(AdminCategory category)? checkedCount,
  }) =>
      showDialog<String>(
        context: context,
        builder: (_) => AutoPuzzleDialog(
          categories: categories,
          initialSubject: initialSubject,
          checkedCount: checkedCount,
        ),
      );

  @override
  State<AutoPuzzleDialog> createState() => _AutoPuzzleDialogState();
}

class _AutoPuzzleDialogState extends State<AutoPuzzleDialog> {
  late AdminCategory? _category = _initialCategory;
  int _size = 9;
  int _words = 8;
  Difficulty? _difficulty;

  AdminCategory? get _initialCategory {
    for (final c in widget.categories) {
      if (c.subject == widget.initialSubject) return c;
    }
    return widget.categories.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final category = _category;
    final count = category == null ? null : widget.checkedCount?.call(category);
    return AlertDialog(
      title: const Text('Auto-create puzzle'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Builds a grid from the category\'s checked questions and opens '
              'it in the puzzle builder. Nothing is saved until you press Save.',
              style: TextStyle(color: MyColors.textSecondary),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AdminCategory>(
              value: category,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Category',
                helperText: count == null
                    ? null
                    : '$count checked question${count == 1 ? '' : 's'} in this category',
              ),
              items: [
                for (final c in widget.categories)
                  DropdownMenuItem(value: c, child: Text(c.name.en)),
              ],
              onChanged: (c) => setState(() => _category = c),
            ),
            const SizedBox(height: 12),
            AutoPuzzleFields(
              size: _size,
              words: _words,
              difficulty: _difficulty,
              onSize: (v) => setState(() => _size = v),
              onWords: (v) => setState(() => _words = v),
              onDifficulty: (v) => setState(() => _difficulty = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: category == null
              ? null
              : () => Navigator.pop(
                    context,
                    AdminRoutes.autoPuzzle(category.id,
                        size: _size,
                        words: _words,
                        difficulty: _difficulty?.value),
                  ),
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: const Text('Build puzzle'),
        ),
      ],
    );
  }
}
