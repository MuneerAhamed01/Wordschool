import 'package:equatable/equatable.dart';

/// Visible text in English and (optionally) Malayalam: `{en, ml?}`.
class LocalizedText extends Equatable {
  const LocalizedText({required this.en, this.ml});

  final String en;
  final String? ml;

  static const empty = LocalizedText(en: '');

  bool get isEmpty => en.trim().isEmpty;

  factory LocalizedText.fromJson(Object? json) {
    if (json is Map) {
      final ml = json['ml'] as String?;
      return LocalizedText(
        en: json['en'] as String? ?? '',
        ml: ml == null || ml.isEmpty ? null : ml,
      );
    }
    return empty;
  }

  /// Trimmed; leaves out an empty `ml` (the server rejects empty optional text).
  Map<String, dynamic> toJson() => {
        'en': en.trim(),
        if ((ml ?? '').trim().isNotEmpty) 'ml': ml!.trim(),
      };

  LocalizedText copyWith({String? en, String? ml}) =>
      LocalizedText(en: en ?? this.en, ml: ml ?? this.ml);

  @override
  List<Object?> get props => [en, ml];
}
