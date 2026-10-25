import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/presentation/admin_sections.dart';

void main() {
  test('forLocation matches a section and its sub-pages', () {
    expect(AdminSection.forLocation('/'), AdminSection.home);
    expect(AdminSection.forLocation('/puzzles'), AdminSection.puzzles);
    expect(AdminSection.forLocation('/puzzles/kerala-history-0001'),
        AdminSection.puzzles);
    expect(AdminSection.forLocation('/bulk-upload'), AdminSection.bulkUpload);
    expect(AdminSection.forLocation('/unknown'), AdminSection.home);
  });
}
