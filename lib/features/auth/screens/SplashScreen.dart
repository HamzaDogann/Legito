// lib/features/auth/screens/SplashScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../state_management/auth_provider.dart';
import '../../../core/enums/user_role.dart';
import '../../mentor_features/home/models/mentor_home_args.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ), // Animasyon süresi biraz ayarlandı
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5), // Daha yumuşak bir başlangıç
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    ); // Curve değiştirildi

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Önce animasyonu başlat, sonra auth kontrolünü yap
    _animationController.forward().whenComplete(() {
      // Animasyon bittikten sonra auth kontrolünü ve yönlendirmeyi yap
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthStatus();

    // Animasyon zaten bittiği için ek bir gecikmeye gerek yok,
    // ama istenirse eklenebilir:
    // await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      switch (authProvider.userRole) {
        case UserRole.user:
          Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
          break;
        case UserRole.mentor:
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.mentorHome,
            arguments: MentorHomeArgs(
              mentorId: authProvider.userId ?? 'unknown_mentor_id',
              mentorName: authProvider.displayName ?? 'Mentor',
            ),
          );
          break;
        case UserRole.admin:
          print(
            "Admin girişi algılandı, ancak admin paneli rotası tanımlanmadı. Login'e yönlendiriliyor.",
          );
          Navigator.pushReplacementNamed(context, AppRoutes.login);
          break;
        default:
          print(
            "Kimlik doğrulandı ama rol tanımsız veya misafir. Login'e yönlendiriliyor.",
          );
          Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Veya temanıza uygun bir renk
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Image.asset(
              'assets/images/Legito.png', // Bu path'in projenizde doğru olduğundan emin olun
              width: 250, // Boyut isteğe bağlı ayarlanabilir
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
