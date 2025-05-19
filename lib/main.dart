// lib/main.dart
import 'package:flutter/foundation.dart'; // kDebugMode için
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // HttpOverrides için
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/navigation/app_routes.dart';
import 'core/navigation/route_generator.dart';
import 'state_management/auth_provider.dart';
// LibraryProvider için import
import 'features/user_features/library/state_management/library_provider.dart';

// SADECE GELİŞTİRME AŞAMASINDA KULLANILMALIDIR!
// Lokal HTTPS sertifikalarına (localhost gibi) güvenmek için.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // SADECE GELİŞTİRME AŞAMASINDA!
  // Production'a geçerken bu satır kaldırılmalı veya uygun sertifika yönetimi yapılmalı.
  // Bu, Flutter'ın localhost gibi kendinden imzalı SSL sertifikalarına güvenmesini sağlar.
  if (kDebugMode) {
    // Sadece debug modunda çalışsın
    HttpOverrides.global = MyHttpOverrides();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // AuthProvider'a bağımlı LibraryProvider'ı ekliyoruz
        ChangeNotifierProxyProvider<AuthProvider, LibraryProvider>(
          // create metodu, LibraryProvider ilk oluşturulduğunda çağrılır.
          // Burada AuthProvider'ın bir örneğini alır.
          create:
              (context) => LibraryProvider(
                Provider.of<AuthProvider>(context, listen: false),
              ),
          // update metodu, AuthProvider'da bir değişiklik olduğunda (notifyListeners çağrıldığında)
          // veya bu ProxyProvider yeniden build edildiğinde çağrılır.
          // LibraryProvider'ı yeni AuthProvider örneği ile günceller.
          // previousLibraryProvider, önceki LibraryProvider örneğidir, state'i korumak için kullanılabilir.
          update: (context, auth, previousLibraryProvider) {
            // Eğer auth (AuthProvider) null ise (teorik olarak olmamalı ama bir güvenlik önlemi)
            // veya previousLibraryProvider null ise (ilk oluşturma) yeni bir tane oluştur.
            if (auth == null || previousLibraryProvider == null) {
              return LibraryProvider(
                auth ?? Provider.of<AuthProvider>(context, listen: false),
              ); // auth null ise tekrar context'ten al
            }
            // AuthProvider değiştiyse, LibraryProvider'a yeni AuthProvider'ı ver.
            // LibraryProvider'ın constructor'ında auth state'ine göre işlem yapılıyorsa
            // bu yeni bir instance oluşturmak anlamına gelebilir veya mevcut instance'ı güncelleyebilir.
            // Mevcut LibraryProvider constructor'ı AuthProvider'ı doğrudan kullanıyor.
            // Dolayısıyla her AuthProvider güncellemesinde LibraryProvider'ın da güncellenmesi mantıklı.
            // Veya, LibraryProvider'ın içinde AuthProvider'ı güncelleyen bir metot olabilirdi.
            // Şimdilik, basitçe yeni bir AuthProvider ile yeni bir LibraryProvider oluşturuyoruz.
            // Eğer LibraryProvider'ın kendi state'ini koruması gerekiyorsa (auth dışında),
            // o zaman previousLibraryProvider.updateAuth(auth) gibi bir yapı daha iyi olabilirdi.
            return LibraryProvider(auth);
          },
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Temel renkler
    const Color primaryOrange = Color(0xFFFF8128);
    const Color appBarBg = Color.fromARGB(255, 241, 247, 255);
    const Color appBarFg = Color(0xFF1F2937);
    const Color scaffoldBg = Colors.white;
    const Color surfaceColor = Colors.white;
    const Color onSurfaceColor = Colors.black87;

    return MaterialApp(
      title: 'Legito - Hızlı Okuma & Odaklanma',
      debugShowCheckedModeBanner: false,
      // Lokalizasyon ayarları
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      // locale: const Locale('tr', 'TR'), // Varsayılan dil (isteğe bağlı)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryOrange,
          onPrimary: Colors.white,
          secondary: primaryOrange.withOpacity(0.7),
          onSecondary: Colors.white,
          error: Colors.red.shade700,
          onError: Colors.white,
          background: scaffoldBg,
          onBackground: onSurfaceColor,
          surface: surfaceColor,
          onSurface: onSurfaceColor,
        ),
        scaffoldBackgroundColor: scaffoldBg,
        appBarTheme: AppBarTheme(
          backgroundColor: appBarBg,
          foregroundColor: appBarFg,
          elevation: 0.5,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: appBarFg,
          ),
          iconTheme: IconThemeData(color: appBarFg),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: primaryOrange, width: 1.5),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          titleTextStyle: TextStyle(
            color: onSurfaceColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
            color: onSurfaceColor.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primaryOrange),
        ),
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
