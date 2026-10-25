import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/core/routes/admin_router.dart';
import 'package:wordshool/features/admin/data/admin_auth_service.dart';

void main() {
  group('adminRedirect', () {
    test('signed-out and non-admin users are sent to /login', () {
      for (final status in [
        AdminAuthStatus.signedOut,
        AdminAuthStatus.notAdmin
      ]) {
        expect(adminRedirect(location: '/puzzles', status: status), '/login');
        expect(adminRedirect(location: '/login', status: status), isNull);
      }
    });

    test('admins skip /login and stay where they are', () {
      expect(adminRedirect(location: '/login', status: AdminAuthStatus.admin),
          '/');
      expect(adminRedirect(location: '/reports', status: AdminAuthStatus.admin),
          isNull);
    });

    test('no redirect before the session is known', () {
      expect(
          adminRedirect(
              location: '/questions', status: AdminAuthStatus.unknown),
          isNull);
    });
  });
}
