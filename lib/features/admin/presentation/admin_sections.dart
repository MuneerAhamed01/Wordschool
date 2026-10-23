import 'package:flutter/material.dart';

/// The admin panel's sections, in menu order, with plain-language help.
enum AdminSection {
  home(
    path: '/',
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    summary: 'Start here — what to do next.',
  ),
  categories(
    path: '/categories',
    label: 'Categories',
    icon: Icons.folder_outlined,
    selectedIcon: Icons.folder,
    summary: 'Topics players pick from, like "Kerala History".',
  ),
  questions(
    path: '/questions',
    label: 'Questions',
    icon: Icons.quiz_outlined,
    selectedIcon: Icons.quiz,
    summary:
        'The fact bank. Every crossword word comes from a checked question.',
  ),
  puzzles(
    path: '/puzzles',
    label: 'Puzzles',
    icon: Icons.grid_on_outlined,
    selectedIcon: Icons.grid_on,
    summary:
        'Build crosswords from checked questions, review and publish them.',
  ),
  schedule(
    path: '/schedule',
    label: 'Daily schedule',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month,
    summary: 'Pick the "Puzzle of the day" for each date.',
  ),
  reports(
    path: '/reports',
    label: 'Reports',
    icon: Icons.flag_outlined,
    selectedIcon: Icons.flag,
    summary: 'Problems players reported, like a wrong answer or a typo.',
  ),
  bulkUpload(
    path: '/bulk-upload',
    label: 'Bulk upload',
    icon: Icons.upload_file_outlined,
    selectedIcon: Icons.upload_file,
    summary: 'Add many questions (spreadsheet or JSON) or puzzles at once.',
  );

  const AdminSection({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.summary,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String summary;

  /// The section a location belongs to (`/puzzles/abc` → [puzzles]).
  static AdminSection forLocation(String location) {
    for (final section in values.skip(1)) {
      if (location == section.path || location.startsWith('${section.path}/')) {
        return section;
      }
    }
    return home;
  }
}
