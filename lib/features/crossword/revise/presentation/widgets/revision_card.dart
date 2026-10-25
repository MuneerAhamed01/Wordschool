import 'package:flutter/material.dart';
import 'package:wordshool/features/crossword/revise/domain/entities/revision_item.dart';
import 'package:wordshool/features/crossword/shared/presentation/widgets/mistake_card.dart';
import 'package:wordshool/features/crossword/shared/presentation/widgets/tag_chip.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';

/// One mistake with its subject and "Mark as learned".
class RevisionCard extends StatelessWidget {
  const RevisionCard({
    super.key,
    required this.item,
    required this.saving,
    required this.onLearned,
  });

  final RevisionItemEntity item;
  final bool saving;
  final VoidCallback onLearned;

  @override
  Widget build(BuildContext context) {
    return MistakeCard(
      answer: item.answer,
      clue: item.clue.en,
      fact: item.fact.en,
      kind: MistakeKind.revise,
      reference: item.wrongCount > 1 ? 'Missed ${item.wrongCount} times' : null,
      trailing: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          if (item.subjectLabel.isNotEmpty) TagChip(label: item.subjectLabel),
          AppButton(
            label: 'Mark as learned',
            height: 44,
            expand: false,
            variant: ButtonVariant.ghost,
            isLoading: saving,
            onTap: onLearned,
          ),
        ],
      ),
    );
  }
}
