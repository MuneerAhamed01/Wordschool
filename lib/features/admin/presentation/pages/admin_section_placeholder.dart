import 'package:flutter/material.dart';
import 'package:wordshool/features/admin/presentation/admin_sections.dart';
import 'package:wordshool/features/admin/presentation/widgets/admin_page.dart';

/// Stand-in for a section that is not built yet.
class AdminSectionPlaceholder extends StatelessWidget {
  const AdminSectionPlaceholder({super.key, required this.section});

  final AdminSection section;

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: section.label,
      subtitle: section.summary,
      child: EmptyState(
        icon: section.icon,
        title: 'Coming soon',
        message: 'This section is being built.',
      ),
    );
  }
}
