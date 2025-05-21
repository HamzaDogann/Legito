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

  //! Course (Teknik Dersler)
  static const String getCourseIndexEndpoint =
      "/Course/Index"; // GET (Kullanıcı için popüler ve son eklenenler)
  static const String getCourseDetailEndpoint =
      "/Course/Course"; // GET (Kullanıcı için, /{courseId} eklenecek)
  static const String getUserCoursesEndpoint =
      "/Course/GetUser"; // GET (Mentor için kendi dersleri)
  static const String searchCoursesEndpoint =
      "/Course/Search"; // GET (Kullanıcı için, ?query=... eklenecek)
  static const String createCourseEndpoint =
      "/Course/Create"; // POST (Mentor için)
  static const String updateCourseEndpoint =
      "/Course/Update"; // PUT (Mentor için, /{courseId} eklenecek)
  static const String deleteCourseEndpoint =
      "/Course/Delete"; // DELETE (Mentor için, /{courseId} eklenecek)

  //! Reading Session
  static const String uploadReadingImageEndpoint = "/Reading/Image"; // POST
  static const String uploadReadingPdfEndpoint = "/Reading/Pdf"; // POST
  static const String createReadingSessionEndpoint = "/Reading/Create"; // POST

  //! Word (Kelime Alıştırması)
  static const String getRandomWordsEndpoint = "/Word/Random";

  //! Dashboard
  static const String getUserDashboardEndpoint = "/Dashboard/GetUser";
}
