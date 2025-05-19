// lib/features/mentor_features/tips_mentor/models/tip_enums.dart

// API'deki TipAvatar enum'ına karşılık gelir
enum ApiTipAvatar {
  cow, // 0
  tiger, // 1
  dog, // 2
  bird, // 3
  rabbit, // 4
}

// UI'da kullanılacak avatar asset yolları ile eşleşen bir yapı veya enum da oluşturulabilir.
// TipsPage'deki _animalIconPaths listesi ile senkronize olmalı.
// Örneğin:
/*
enum UiTipAvatar {
  cow, tiger, dog, bird, rabbit
}

String getUiTipAvatarAssetPath(UiTipAvatar avatar) {
  switch (avatar) {
    case UiTipAvatar.cow: return 'assets/images/cow.png';
    // ... diğerleri
    default: return 'assets/images/dog_tip.png'; // Varsayılan
  }
}

UiTipAvatar apiTipAvatarToUi(ApiTipAvatar apiAvatar) {
  // Eşleştirme
}
ApiTipAvatar uiTipAvatarToApi(UiTipAvatar uiAvatar) {
 // Eşleştirme
}
*/
// Şimdilik TipsPage'deki _animalIconPaths listesini ve index'lerini kullanacağız.
