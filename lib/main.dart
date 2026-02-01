import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:video_downloader_admin/firebase_options.dart';
import 'package:video_downloader_admin/pages/home_page.dart';
import 'package:video_downloader_admin/pages/login_page.dart';
import 'package:video_downloader_admin/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E3A8A);
    const secondaryColor = Color(0xFF0F766E);
    const surfaceColor = Color(0xFFF8FAFC);
    const scaffoldColor = Color(0xFFF1F5F9);
    const errorColor = Color(0xFFB91C1C);
    const borderColor = Color(0xFFE2E8F0);
    const textColor = Color(0xFF0F172A);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "K Downloader Admin Panel",
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: scaffoldColor,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: primaryColor,
          onPrimary: Colors.white,
          secondary: secondaryColor,
          onSecondary: Colors.white,
          error: errorColor,
          onError: Colors.white,
          surface: surfaceColor,
          onSurface: textColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: textColor,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme:  CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),

            side: const BorderSide(color: borderColor),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: borderColor,
          thickness: 1,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: textColor,
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: errorColor, width: 1.5),
          ),
          labelStyle: const TextStyle(color: Color(0xFF475569)),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: const BorderSide(color: borderColor),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textColor,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: Color(0xFF475569),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is authenticated and is admin, show HomePage
        if (snapshot.hasData) {
          return FutureBuilder<bool>(
            future: authService.isAdmin(),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (adminSnapshot.hasData && adminSnapshot.data == true) {
                return const HomePage();
              } else {
                // User is authenticated but not admin
                return const LoginPage();
              }
            },
          );
        }

        // User is not authenticated, show LoginPage
        return const LoginPage();
      },
    );
  }
}
