import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:video_downloader_admin/screens/home_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Admin Notification Panel",
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
