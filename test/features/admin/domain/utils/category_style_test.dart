import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/domain/utils/category_style.dart';

void main() {
  test('slugify makes a server-valid id', () {
    expect(slugify('Kerala History & Culture'), 'kerala-history-culture');
    expect(slugify('  Indian  Constitution! '), 'indian-constitution');
    expect(slugify('ചരിത്രം'), '');
    expect(slugify('a' * 70).length, 60);
  });

  test('stored icons and colours match the server patterns', () {
    final icon = RegExp(r'^[a-z0-9_-]+$');
    final color = RegExp(r'^#[0-9A-F]{6}$');
    expect(categoryIconNames.every(icon.hasMatch), isTrue);
    expect(categoryColors.every(color.hasMatch), isTrue);
  });

  group('reorderedOrders', () {
    test('moving the first item to the end', () {
      // ReorderableListView reports newIndex = length when dropping at the end.
      expect(reorderedOrders(3, 0, 3), [30, 10, 20]);
    });

    test('moving the last item to the top', () {
      expect(reorderedOrders(3, 2, 0), [20, 30, 10]);
    });

    test('dropping in place keeps the order', () {
      expect(reorderedOrders(3, 1, 1), [10, 20, 30]);
    });
  });
}
