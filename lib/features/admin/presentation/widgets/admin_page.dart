import 'package:flutter/material.dart';
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

/// A soft blue box that explains a page in plain words.
class HelpCard extends StatelessWidget {
  const HelpCard(
      {super.key, required this.text, this.icon = Icons.lightbulb_outline});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MyColors.infoBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MyColors.infoText, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: MyColors.infoText, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Friendly empty / loading-failed state with an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          Icon(icon, size: 48, color: MyColors.navInactive),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style:
                  textTheme.bodyMedium?.copyWith(color: MyColors.textSecondary),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// Centred spinner for a page that is loading.
class LoadingBlock extends StatelessWidget {
  const LoadingBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
