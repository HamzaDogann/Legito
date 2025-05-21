// lib/features/user_features/vocabulary_practice/models/word_item_dto.dart
class WordItemDto {
  final String id;
  final String name; // Kelimenin kendisi
  final int type; // ApiWordType enum'ının index'i

  WordItemDto({required this.id, required this.name, required this.type});

  factory WordItemDto.fromJson(Map<String, dynamic> json) {
    return WordItemDto(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as int,
    );
  }
}
