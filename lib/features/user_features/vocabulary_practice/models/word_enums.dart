// lib/features/user_features/vocabulary_practice/models/word_enums.dart

enum ApiWordType {
  adjective, // 0 - Sıfat
  conjunction, // 1 - Bağlaç
  verb, // 2 - Fiil
  pronoun, // 3 - Zamir
  preposition, // 4 - Edat
  noun, // 5 - İsim
  adverb, // 6 - Zarf
  additionalVerb, // 7 - Ek eylem
}

String getApiWordTypeDisplayName(ApiWordType type) {
  switch (type) {
    case ApiWordType.adjective:
      return "Sıfat";
    case ApiWordType.conjunction:
      return "Bağlaç";
    case ApiWordType.verb:
      return "Fiil";
    case ApiWordType.pronoun:
      return "Zamir";
    case ApiWordType.preposition:
      return "Edat";
    case ApiWordType.noun:
      return "İsim";
    case ApiWordType.adverb:
      return "Zarf";
    case ApiWordType.additionalVerb:
      return "Ek Eylem";
  }
}
