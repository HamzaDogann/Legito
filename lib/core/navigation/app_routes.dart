// lib/core/navigation/app_routes.dart

class AppRoutes {
  // Auth & Common Initial Routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String membershipAgreement = '/membership-agreement';

  // Common Screens (Accessible after login, potentially by multiple roles)
  static const String publicHome =
      '/home'; // Ana yönlendirme, BottomNav içerebilir
  static const String account = '/account'; // Hesap ana sayfası
  static const String accountSettings = '/account-settings';
  static const String updatePassword = '/update-password';
  static const String updateUser = '/update-user';
  static const String aboutUs = '/about-us';
  static const String assistanceCenter = '/assistance-center';

  // User Features
  static const String userDashboard = '/user/dashboard';
  static const String library = '/user/library';
  static const String techniquesUser = '/user/techniques'; // Teknikler listesi
  static const String lessonDetailUser =
      '/user/lesson-detail'; // Seçilen teknik/ders detayı (arg: LessonDetailArgs)
  static const String supportUser = '/user/support';
  static const String searchMentor = '/user/search-mentor';
  static const String chatWithMentor =
      '/user/chat'; // Argüman alabilir (chat_args.dart -> ChatArgs)
  static const String mentorAccountViewByUser =
      '/user/view-mentor-account'; // Argüman alabilir (mentor_account_args.dart -> MentorAccountArgs)

  // Mentor Features
  static const String mentorHome = '/mentor/home';
  static const String mentorDashboard =
      '/mentor/dashboard'; // <<< Mentor İstatistik Sayfası EKLENDİ
  static const String techniquesLessonMentor =
      '/mentor/techniques-lesson'; // Mentorun teknik/ders CRUD sayfası
  static const String tipsMentor =
      '/mentor/tips'; // Mentorun ipucu CRUD sayfası
  static const String userAccountViewByMentor =
      '/mentor/view-user-account'; // Argüman alabilir (user_account_args.dart -> UserAccountArgs)

  // Admin Features (Şimdilik placeholder, implemente edilince eklenecek)
  // static const String adminDashboard = '/admin/dashboard';
  // static const String adminMentorManagement = '/admin/mentor-management';
}
