// lib/features/user_features/dashboard/screens/UserDashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // AuthProvider için
import '../../../../core/enums/user_role.dart'; // UserRole enum'u için
import '../../../../core/navigation/app_routes.dart'; // AppRoutes için
import '../../../../state_management/auth_provider.dart'; // AuthProvider için

import '../../../../shared_widgets/user_stats_card_widget.dart';

class UserDashboard extends StatefulWidget {
  // Bu renkler artık main.dart'taki temadan geleceği için burada tanımlamaya gerek yok,
  // ama eğer bu sayfaya özel kalacaklarsa burada kalabilirler.
  // Şimdilik yoruma alıyorum, çünkü AppBar'ın temadan gelmesini istiyoruz.
  // static const Color appBarBackground = Color(0xFFF4F6F9);
  // static const Color textDark = Color(0xFF1F2937);

  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated ||
          authProvider.userRole != UserRole.user) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isAuthenticated ||
        authProvider.userRole != UserRole.user) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Temadan gelen renkleri kullanmak için Theme.of(context)
    final appBarTheme = Theme.of(context).appBarTheme;
    final Color currentAppBarBackgroundColor =
        appBarTheme.backgroundColor ??
        const Color(0xFFF4F6F9); // Temadan al, yoksa varsayılan
    final Color currentAppBarForegroundColor =
        appBarTheme.foregroundColor ??
        const Color(0xFF1F2937); // Temadan al, yoksa varsayılan

    return Scaffold(
      // backgroundColor: UserDashboard.appBarBackground, // Artık temadan veya Scaffold'un kendi varsayılanından
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Genel scaffold arka planını kullanır
      // Veya bu sayfaya özel bir arka plan rengi:
      backgroundColor:
          currentAppBarBackgroundColor, // AppBar ile aynı olması isteniyorsa

      appBar: AppBar(
        // backgroundColor: UserDashboard.appBarBackground, // KALDIRILDI - Temadan gelecek
        // elevation: 0, // Bu sayfaya özel kalabilir veya temadan alınabilir
        // Temadan gelen elevation'ı kullanmak için bu satırı silebilir veya
        // appBarTheme.elevation ?? 0 şeklinde kullanabilirsiniz.
        // Şimdilik sayfaya özel olarak 0 bırakıyorum.
        elevation: 0,

        leading: IconButton(
          // icon: const Icon(Icons.arrow_back, color: UserDashboard.textDark), // KALDIRILDI
          icon: Icon(
            Icons.arrow_back,
            color: currentAppBarForegroundColor,
          ), // Temadan gelen rengi kullan
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
            }
          },
        ),
        title: Text(
          'İlerlemem',
          // style: TextStyle( // KALDIRILDI - Temadan gelecek
          //   color: UserDashboard.textDark,
          //   fontWeight: FontWeight.bold,
          //   fontSize: 20,
          // ),
          // Temadan gelen titleTextStyle'ı kullanır. Gerekirse üzerine yazılabilir.
          // Örneğin sadece fontSize'ı değiştirmek isterseniz:
          // style: appBarTheme.titleTextStyle?.copyWith(fontSize: 20),
        ),
        centerTitle: false, // Bu sayfaya özel
        titleSpacing: 0, // Bu sayfaya özel
        // foregroundColor: currentAppBarForegroundColor, // AppBar içindeki tüm ikon ve metinler için genel renk.
        // titleTextStyle ve iconTheme bunu ezer.
        // main.dart'taki appBarTheme'de zaten ayarlı.
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatsGrid(
                    labelMaxWidth:
                        (constraints.maxWidth / 2) -
                        40, // Biraz daha boşluk bırakalım
                  ),
                  const SizedBox(height: 30),
                  const ChartsSection(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
