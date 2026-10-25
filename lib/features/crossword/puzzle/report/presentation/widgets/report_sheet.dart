import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/entities/content_report.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/word.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/app_sheet.dart';

/// "Report a wrong answer" (CW-052): reason + optional message. Pops with
/// `(reason, message)` or null.
class ReportSheet extends StatefulWidget {
  const ReportSheet({super.key, required this.word});

  final CrosswordWordEntity word;

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  ReportReason _reason = ReportReason.wrongAnswer;
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetHeader(
          overline: widget.word.label,
          title: 'Report a problem',
          subtitle: widget.word.clue.en,
        ),
        const SizedBox(height: 12),
        for (final reason in ReportReason.values)
          RadioListTile<ReportReason>(
            key: ValueKey('reason-${reason.wire}'),
            value: reason,
            groupValue: _reason,
            onChanged: (r) => setState(() => _reason = r ?? _reason),
            activeColor: MyColors.accentGlow,
            contentPadding: EdgeInsets.zero,
            title: Text(reason.label,
                style: const TextStyle(color: MyColors.white)),
          ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey('report-message'),
          controller: _message,
          maxLength: ContentReportEntity.maxMessageLength,
          maxLines: 3,
          style: const TextStyle(color: MyColors.white),
          decoration: InputDecoration(
            hintText: 'What should it be? (optional)',
            hintStyle: const TextStyle(color: MyColors.navInactive),
            filled: true,
            fillColor: MyColors.gameSurface,
            counterStyle: const TextStyle(color: MyColors.navInactive),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AppButton(
          key: const ValueKey('report-send'),
          label: 'Send report',
          height: 48,
          onTap: () => Navigator.of(context).pop((_reason, _message.text)),
        ),
      ],
    );
  }
}
