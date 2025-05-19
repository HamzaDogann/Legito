// lib/features/user_features/library/models/resource_enums.dart

// API'deki ResourceType enum'ına karşılık gelir
enum ApiResourceType {
  book, // 0
  journal, // 1
  article, // 2
  blog, // 3
  encyclopedia, // 4
  other, // 5
}

// API'deki SourceStatus enum'ına karşılık gelir
enum ApiSourceStatus {
  complete, // 0
  continues, // 1
  waiting, // 2
}

// UI'da kullanılan ResourceTypeEnum (Mevcut kodunuzdaki)
// Bu enum'ı API enum'ı ile eşleştireceğiz.
enum UiResourceType { book, journal, article, blog, encyclopedia, other }

// UI'da kullanılan Status String'leri (Mevcut kodunuzdaki)
// Bunları da API enum'ı ile eşleştireceğiz.
const String statusCurrentlyReading = "Şuan Okunanlar"; // API'de Continues (1)
const String statusCompleted = "Tamamlananlar"; // API'de Complete (0)
const String statusToBeRead = "Okunacaklar";         // API'de Waiting (2)