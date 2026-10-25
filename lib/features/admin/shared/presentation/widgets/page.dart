import 'package:flutter/material.dart';
import 'package:wordshool/features/admin/shared/presentation/widgets/help_card.dart';
import 'package:wordshool/config/themes/colors.dart';

/// Standard admin page: title, one-line explanation, optional help box,
/// actions on the right, and a centred body at most 1200 px wide.
class AdminPage extends StatelessWidget {
  const AdminPage({
    super.key,
    required this.title,
    this.subtitle,
    this.help,
    this.actions = const [],
    this.leading,
    required this.child,
    this.scrollable = true,
  });

  final String title;
  final String? subtitle;
  final String? help;
  final List<Widget> actions;
  final Widget? leading;
  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 700;
    final padding = EdgeInsets.symmetric(
      horizontal: narrow ? 16 : 32,
      vertical: narrow ? 16 : 28,
    );
    final textTheme = Theme.of(context).textTheme;

    final header = Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: MyColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (actions.isNotEmpty)
          Wrap(spacing: 8, runSpacing: 8, children: actions),
      ],
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        if (help != null) ...[
          const SizedBox(height: 16),
          HelpCard(text: help!),
        ],
        const SizedBox(height: 20),
        if (scrollable) child else Expanded(child: child),
      ],
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: scrollable
            ? SingleChildScrollView(padding: padding, child: content)
            : Padding(padding: padding, child: content),
      ),
    );
  }
}
