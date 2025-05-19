//  # API base URL, genel renkler, boyutlar
// lib/core/constants/api_constants.dart
class ApiConstants {
  // WEB/DESKTOP için HTTPS ve localhost kullanıyorsanız:
  static const String baseUrl = "https://10.0.2.2:7046/api";

  // ANDROID EMULATOR için (API'niz HTTPS ve 7046 portunda çalışıyorsa):
  // static const String baseUrl = "https://10.0.2.2:7046/api";

  // FİZİKSEL CİHAZ veya IOS EMULATOR için (Bilgisayarınızın yerel IP'si ve API portu):
  // static const String baseUrl = "https://192.168.1.X:7046/api"; // X yerine kendi IP'nizi yazın

  // Endpoints

  //! Auth
  static const String signInEmailEndpoint = "/Auth/SignInEmail";
  static const String signUpEndpoint = "/Auth/SignUp";
  static const String signOutEndpoint = "/Auth/SignOut";

  //! User
  static const String userInfoEndpoint = "/User/Info";

  //! Resource (Kitaplık)
  static const String getResourcesEndpoint = "/Resource/Resources"; // GET
  static const String createResourceEndpoint = "/Resource/Create"; // POST
  static const String updateResourceEndpoint =
      "/Resource/Update"; // PUT (/{resourceId} eklenecek)
  static const String deleteResourceEndpoint =
      "/Resource/Delete"; // DELETE (/{resourceId}
}
  // static const String registerEndpoint = "/Auth/SignUpEmail"; // Gelecekteki kayıt için
  // Diğer endpoint'ler buraya eklenebilir
