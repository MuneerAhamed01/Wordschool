enum ClueType {
  location,
  weapon,
  suspect,
}

extension ClueTypeFirestore on ClueType {
  String toFirestoreString() => name;

  static ClueType fromFirestoreString(String value) {
    return ClueType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => throw ArgumentError('Unknown clue type: $value'),
    );
  }
}
