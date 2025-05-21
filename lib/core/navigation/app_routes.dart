// lib/core/navigation/app_routes.dart

class AppRoutes {
  // Auth & Common Initial Routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String membershipAgreement = '/membership-agreement';

  // Common Screens
  static const String publicHome = '/home';
  static const String account = '/account';
  static const String accountSettings = '/account-settings';
  static const String updatePassword = '/update-password';
  static const String updateUser = '/update-user';
  static const String aboutUs = '/about-us';
  static const String assistanceCenter = '/assistance-center';

  // User Features
  static const String userDashboard = '/user/dashboard';
  static const String library = '/user/library';
  static const String techniquesUser = '/user/techniques';
  static const String lessonDetailUser = '/user/lesson-detail';
  static const String startReadPage = '/user/start-read';
  static const String vocabularyPractice = '/user/vocabulary-practice';
  static const String supportUser = '/user/support';
  static const String searchMentor = '/user/search-mentor';
  static const String chatWithMentor = '/user/chat';
  static const String mentorAccountViewByUser = '/user/view-mentor-account';

  // Mentor Features
  static const String mentorHome = '/mentor/home';
  static const String mentorDashboard = '/mentor/dashboard';
  static const String techniquesLessonMentor = '/mentor/techniques-lesson';
  static const String tipsMentor = '/mentor/tips';
  static const String userAccountViewByMentor = '/mentor/view-user-account';

  // Admin Features
  // static const String adminDashboard = '/admin/dashboard';
}
