/// Small helpers for reading callable JSON (numbers may arrive as doubles).
int readInt(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;

DateTime? readDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

List<String> readStrings(Object? value) =>
    value is List ? value.whereType<String>().toList() : const [];

Map<String, dynamic> readMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

List<Map<String, dynamic>> readMaps(Object? value) =>
    value is List ? value.map(readMap).toList() : const [];
