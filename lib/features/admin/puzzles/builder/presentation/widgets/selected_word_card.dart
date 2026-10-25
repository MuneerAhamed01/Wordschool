import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/admin/shared/domain/models/question.dart';
import 'package:wordshool/features/admin/puzzles/domain/utils/puzzle_draft.dart';
import 'package:wordshool/shared/domains/entities/localized_text.dart';
import 'package:wordshool/features/admin/puzzles/builder/presentation/widgets/builder_panel.dart';

/// Edits the selected word: clue choice, direction, remove.
class SelectedWordCard extends StatefulWidget {
  const SelectedWordCard({
    super.key,
    required this.placement,
    required this.number,
    required this.question,
    required this.onChanged,
    required this.onRemove,
    required this.onClose,
  });

  final Placement placement;
  final int? number;
  final AdminQuestion? question;
  final ValueChanged<Placement> onChanged;
  final VoidCallback onRemove;
  final VoidCallback onClose;

  @override
  State<SelectedWordCard> createState() => _SelectedWordCardState();
}

class _SelectedWordCardState extends State<SelectedWordCard> {
  late final _clueEn = TextEditingController(text: widget.placement.clue.en);
  late final _clueMl = TextEditingController(text: widget.placement.clue.ml);
  late final _extraEn =
      TextEditingController(text: widget.placement.extraClue?.en);

  @override
  void dispose() {
    _clueEn.dispose();
    _clueMl.dispose();
    _extraEn.dispose();
    super.dispose();
  }

  void _emit() {
    final extra = _extraEn.text.trim();
    widget.onChanged(widget.placement.copyWith(
      clue: LocalizedText(en: _clueEn.text, ml: _clueMl.text),
      extraClue: extra.isEmpty ? null : LocalizedText(en: extra),
      clearExtraClue: extra.isEmpty,
    ));
  }

  void _useClue(QuestionClue clue) {
    _clueEn.text = clue.en;
    _clueMl.text = clue.ml ?? '';
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.placement;
    final clues = widget.question?.clues ?? const <QuestionClue>[];
    return BuilderPanel(
      title: '${widget.number ?? '–'} ${p.direction.label}: ${p.answer}',
      highlight: true,
      trailing: IconButton(
          tooltip: 'Close',
          onPressed: widget.onClose,
          icon: const Icon(Icons.close)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _clueEn,
            maxLength: 300,
            onChanged: (_) => _emit(),
            decoration: const InputDecoration(
                labelText: 'Clue players see (English) *'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _clueMl,
            maxLength: 300,
            onChanged: (_) => _emit(),
            decoration: const InputDecoration(labelText: 'Clue (Malayalam)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _extraEn,
            maxLength: 300,
            onChanged: (_) => _emit(),
            decoration: const InputDecoration(
              labelText: 'Extra hint (optional)',
              helperText: 'Shown when a player asks for help with this word',
            ),
          ),
          if (clues.length > 1) ...[
            const SizedBox(height: 8),
            Text('Use a clue from the question:',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final clue in clues)
                  ActionChip(
                    label: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: Text('${clue.level.label}: ${clue.en}',
                          overflow: TextOverflow.ellipsis),
                    ),
                    onPressed: () => _useClue(clue),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: widget.onRemove,
              style:
                  OutlinedButton.styleFrom(foregroundColor: MyColors.errorText),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove from grid'),
            ),
          ),
        ],
      ),
    );
  }
}
