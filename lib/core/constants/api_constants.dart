// lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = "https://10.0.2.2:7046/api";

  // Endpoints

  //! Auth
  static const String signInEmailEndpoint = "/Auth/SignInEmail";
  static const String signUpEndpoint = "/Auth/SignUp";
  static const String signOutEndpoint = "/Auth/SignOut";

  //! User
  static const String userInfoEndpoint = "/User/Info";
  static const String updateUserEndpoint = "/User/Info";
  static const String updateUserPhotoEndpoint = "/User/Photo";
  static const String updateUserPasswordEndpoint = "/User/Password";

  //! Resource (Kitaplık)
  static const String getResourcesEndpoint = "/Resource/Resources";
  static const String createResourceEndpoint = "/Resource/Create";
  static const String updateResourceEndpoint = "/Resource/Update";
  static const String deleteResourceEndpoint = "/Resource/Delete";

  //! Tip (İpucu)
  static const String getRandomTipEndpoint = "/Tip/Random";
  static const String getUserTipsEndpoint = "/Tip/GetUser";
  static const String createTipEndpoint = "/Tip/Create";
  static const String updateTipEndpoint = "/Tip/Update";
  static const String deleteTipEndpoint = "/Tip/Delete";
}
