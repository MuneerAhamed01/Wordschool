/// Lenient readers for Firestore / callable JSON (numbers may arrive as
/// int or double; missing fields fall back to a default).
int asInt(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;

int? asIntOrNull(Object? value) => value is num ? value.toInt() : null;

String asString(Object? value, [String fallback = '']) =>
    value is String ? value : fallback;

bool asBool(Object? value, [bool fallback = false]) =>
    value is bool ? value : fallback;

List<String> asStringList(Object? value) =>
    value is List ? value.whereType<String>().toList() : const [];

Map<String, dynamic> asMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

List<Map<String, dynamic>> asMapList(Object? value) =>
    value is List ? value.map(asMap).toList() : const [];

/// An ISO string (callable JSON) or a `DateTime`; Firestore timestamps go
/// through `FirebaseDTConverter.tryParse` in the data layer.
DateTime? asDate(Object? value) => switch (value) {
      DateTime d => d,
      String s => DateTime.tryParse(s),
      _ => null,
    };
