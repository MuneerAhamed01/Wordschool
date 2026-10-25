// Choices offered in the category editor, and slug helpers.

/// Category colours (`#RRGGBB`, stored on the category doc).
const categoryColors = [
  '#538D4E', // green
  '#B59F3B', // gold
  '#3B82C4', // blue
  '#C4573B', // brick
  '#8A5CC4', // violet
  '#2E9C8F', // teal
  '#C43B7A', // pink
  '#6B7280', // grey
];

/// Icon names stored on the category doc (`^[a-z0-9_-]+$`).
const categoryIconNames = [
  'history_edu',
  'account_balance',
  'public',
  'map',
  'science',
  'menu_book',
  'gavel',
  'eco',
  'sports_cricket',
  'palette',
  'calculate',
  'translate',
];

final _nonSlug = RegExp(r'[^a-z0-9]+');
final _edgeDashes = RegExp(r'^-+|-+$');
final slugPattern = RegExp(r'^[a-z0-9-]+$');

/// `"Kerala History & Culture"` → `kerala-history-culture`.
String slugify(String text, {int maxLength = 60}) {
  final slug =
      text.toLowerCase().replaceAll(_nonSlug, '-').replaceAll(_edgeDashes, '');
  return slug.length <= maxLength
      ? slug
      : slug.substring(0, maxLength).replaceAll(_edgeDashes, '');
}

/// New `order` values after moving the item at [oldIndex] to [newIndex]
/// (Flutter's ReorderableListView indices). Orders become 10, 20, 30…
List<int> reorderedOrders(int count, int oldIndex, int newIndex) {
  final indices = List<int>.generate(count, (i) => i);
  final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
  final moved = indices.removeAt(oldIndex);
  indices.insert(target, moved);
  final orders = List<int>.filled(count, 0);
  for (var position = 0; position < indices.length; position++) {
    orders[indices[position]] = (position + 1) * 10;
  }
  return orders;
}
