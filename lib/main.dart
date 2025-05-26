// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/navigation/app_routes.dart';
import 'core/navigation/route_generator.dart';
import 'state_management/auth_provider.dart';
import 'features/user_features/library/state_management/library_provider.dart';
import 'features/mentor_features/tips_mentor/state_management/tip_provider.dart';
import 'features/course/state_management/course_provider.dart';
import 'features/user_features/reading_session/state_management/reading_provider.dart';
import 'features/user_features/dashboard/state_management/dashboard_provider.dart';
import 'features/user_features/vocabulary_practice/state_management/vocabulary_provider.dart'; // Bu yolun doğru olduğundan emin olun

// YENİ IMPORT (ChatProvider)
import 'state_management/chat_provider.dart'; // ChatProvider için import

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, LibraryProvider>(
          create:
              (context) => LibraryProvider(
                Provider.of<AuthProvider>(context, listen: false),
              ),
          update: (context, auth, previous) => LibraryProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TipProvider>(
          create:
              (context) => TipProvider(
                Provider.of<AuthProvider>(context, listen: false),
              ),
          update: (context, auth, previous) => TipProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CourseProvider>(
          create:
              (context) => CourseProvider(
                Provider.of<AuthProvider>(context, listen: false),
              ),
          update: (context, auth, previous) => CourseProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ReadingProvider>(
          create:
              (context) => ReadingProvider(
                Provider.of<AuthProvider>(context, listen: false),
              ),
          update: (context, auth, previous) => ReadingProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create:
              (context) => DashboardProvider(
                Provider.of<AuthProvider>(context, listen: false),
              ),
          update: (context, auth, previous) => DashboardProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, VocabularyProvider>(
          create:
              (context) => VocabularyProvider(
                Provider.of<AuthProvider>(context, listen: false),
              ),
          update: (context, auth, previousVocabularyProvider) {
            return VocabularyProvider(auth);
          },
        ),
        // --- YENİ ChatProvider EKLEMESİ ---
        // ChatProvider AuthProvider'a doğrudan bağımlı olmadığı için
        // ChangeNotifierProvider olarak eklenir.
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        // --- BİTİŞ: ChatProvider EKLEMESİ ---
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFFF8128);
    const Color appBarBg = Color.fromARGB(255, 241, 247, 255);
    const Color appBarFg = Color(0xFF1F2937);
    const Color scaffoldBg = Colors.white;
    const Color surfaceColor = Colors.white;
    const Color onSurfaceColor = Colors.black87;

    return MaterialApp(
      title: 'Legito - Hızlı Okuma & Odaklanma',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
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
      initialRoute:
          AppRoutes
              .splash, // Eğer splash screen kullanmıyorsanız AppRoutes.login veya uygun bir başlangıç rotası yapın
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
