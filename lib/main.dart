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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "K Downloader Admin Panel",
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
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
