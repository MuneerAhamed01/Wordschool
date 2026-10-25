/// Leaderboard name for `users/{uid}.displayName` (CW-055): the Google name,
/// or "Guest 1234" from the uid (stable across devices and sessions).
String playerDisplayName({required String uid, String? name}) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isNotEmpty) {
    // The rules allow up to 40 characters.
    return trimmed.length <= maxDisplayNameLength
        ? trimmed
        : trimmed.substring(0, maxDisplayNameLength).trimRight();
  }
  var hash = 0;
  for (final unit in uid.codeUnits) {
    hash = (hash * 31 + unit) % 10000;
  }
  return 'Guest ${hash.toString().padLeft(4, '0')}';
}

const maxDisplayNameLength = 40;
