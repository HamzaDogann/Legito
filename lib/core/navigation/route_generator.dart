// lib/core/navigation/route_generator.dart
import 'package:flutter/material.dart';
import 'app_routes.dart';

// Argüman Sınıfları
import '../../features/user_features/support_user/models/mentor_account_args.dart';
import '../../features/user_features/techniques_user/models/lesson_detail_args.dart';
import '../../features/user_features/support_user/models/chat_args.dart';
import '../../features/mentor_features/interactions_mentor/models/user_account_args.dart';
import '../../features/mentor_features/home/models/mentor_home_args.dart';

// EKRAN IMPORTLARI
// Auth & Common Screens
import '../../features/auth/screens/SplashScreen.dart';
import '../../features/auth/screens/LoginPage.dart';
import '../../features/auth/screens/RegisterPage.dart';
import '../../features/auth/screens/MembershipAgreementPage.dart';
import '../../features/home/screens/PublicHomePage.dart';
import '../../features/common_screens/screens/AccountPage.dart';
import '../../features/common_screens/screens/AccountSettingPage.dart';
import '../../features/common_screens/screens/UpdatePasswordPage.dart';
import '../../features/common_screens/screens/UpdateUserPage.dart';
import '../../features/common_screens/screens/AboutUsPage.dart';
import '../../features/common_screens/screens/AssistanceCenterPage.dart';

// User Feature Screens
import '../../features/user_features/dashboard/screens/UserDashboard.dart';
import '../../features/user_features/library/screens/LibraryPage.dart';
import '../../features/user_features/techniques_user/screens/TechniquesPage.dart';
import '../../features/user_features/techniques_user/screens/LessonDetailPage.dart';
import '../../features/user_features/reading_session/screens/StartReadPage.dart';
import '../../features/user_features/support_user/screens/SupportPage.dart';
import '../../features/user_features/support_user/screens/SearchMentorPage.dart';
import '../../features/user_features/support_user/screens/ChatPage.dart'
    as user_chat;
import '../../features/user_features/support_user/screens/MentorAccountPage.dart';

// Mentor Feature Screens
import '../../features/mentor_features/home/screens/MentorHomePage.dart';
import '../../features/mentor_features/dashboard/screens/MentorDashboardPage.dart';
import '../../features/mentor_features/techniques_mentor/screens/TechniquesLessonPage.dart';
import '../../features/mentor_features/tips_mentor/screens/TipsPage.dart';
import '../../features/mentor_features/interactions_mentor/screens/UserAccountPage.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    print("RouteGenerator: Rota isteniyor -> ${settings.name}");

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case AppRoutes.membershipAgreement:
        return MaterialPageRoute(
          builder: (_) => const MembershipAgreementPage(),
        );
      case AppRoutes.publicHome:
        return MaterialPageRoute(builder: (_) => const PublicHomeScreen());
      case AppRoutes.account:
        return MaterialPageRoute(builder: (_) => const AccountPage());
      case AppRoutes.accountSettings:
        return MaterialPageRoute(builder: (_) => const AccountSettingPage());
      case AppRoutes.updatePassword:
        return MaterialPageRoute(builder: (_) => const UpdatePasswordPage());
      case AppRoutes.updateUser:
        return MaterialPageRoute(builder: (_) => const UpdateUserPage());
      case AppRoutes.aboutUs:
        return MaterialPageRoute(builder: (_) => const AboutUsPage());
      case AppRoutes.assistanceCenter:
        return MaterialPageRoute(builder: (_) => const AssistanceCenterPage());

      // User Features
      case AppRoutes.userDashboard:
        return MaterialPageRoute(builder: (_) => const UserDashboard());
      case AppRoutes.library:
        return MaterialPageRoute(builder: (_) => const LibraryPage());
      case AppRoutes.techniquesUser:
        return MaterialPageRoute(builder: (_) => const TechniquesPage());
      case AppRoutes.lessonDetailUser:
        if (args is LessonDetailArgs) {
          return MaterialPageRoute(
            builder: (_) => LessonDetailPage(args: args),
          );
        }
        return _errorRoute(
          message: 'Ders detay argümanları eksik veya geçersiz.',
        );
      case AppRoutes.startReadPage: // <<< YENİ CASE
        // final startReadArgs = args as StartReadArgs?; // Eğer argüman alacaksa
        return MaterialPageRoute(
          builder: (_) => const StartReadPage(/*args: startReadArgs*/),
        );
      case AppRoutes.supportUser:
        return MaterialPageRoute(builder: (_) => const SupportPage());
      case AppRoutes.searchMentor:
        return MaterialPageRoute(builder: (_) => const SearchMentorPage());
      case AppRoutes.chatWithMentor:
        if (args is ChatArgs) {
          return MaterialPageRoute(
            builder: (_) => user_chat.ChatPage(args: args),
          );
        }
        return _errorRoute(message: 'Chat argümanları eksik veya geçersiz.');
      case AppRoutes.mentorAccountViewByUser:
        if (args is MentorAccountArgs) {
          return MaterialPageRoute(
            builder: (_) => MentorAccountPage(args: args),
          );
        }
        return _errorRoute(
          message: 'Mentor profil argümanları eksik veya geçersiz.',
        );

      // Mentor Features
      case AppRoutes.mentorHome:
        if (args is MentorHomeArgs) {
          return MaterialPageRoute(builder: (_) => MentorHomePage(args: args));
        }
        return _errorRoute(
          message: 'Mentor ana sayfa argümanları eksik veya geçersiz.',
        );
      case AppRoutes.mentorDashboard:
        return MaterialPageRoute(builder: (_) => const MentorDashboardPage());
      case AppRoutes.techniquesLessonMentor:
        return MaterialPageRoute(builder: (_) => const TechniquesLessonPage());
      case AppRoutes.tipsMentor:
        return MaterialPageRoute(builder: (_) => const TipsPage());
      case AppRoutes.userAccountViewByMentor:
        if (args is UserAccountArgs) {
          return MaterialPageRoute(builder: (_) => UserAccountPage(args: args));
        }
        return _errorRoute(
          message: 'Kullanıcı profil argümanları eksik veya geçersiz.',
        );

      default:
        print("RouteGenerator: Tanımlanmayan rota -> ${settings.name}");
        return _errorRoute(message: "Rota bulunamadı: ${settings.name}");
    }
  }

  static Route<dynamic> _errorRoute({String message = 'Sayfa bulunamadı!'}) {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Hata')),
          body: Center(child: Text(message)),
        );
      },
    );
  }
}
