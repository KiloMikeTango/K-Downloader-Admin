// lib/home_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/daily_stats_card.dart';
import 'package:video_downloader_admin/pages/notifications_page.dart';
import 'package:video_downloader_admin/pages/settings_page.dart';
import 'package:video_downloader_admin/pages/tutorial_steps_page.dart';
import 'package:video_downloader_admin/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color kAdminBg = Color(0xFF05060A);
const Color kAdminAccent = Color(0xFF4F46E5);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPage = 0;
  final AuthService _authService = AuthService();

  double _scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width / 1280).clamp(0.8, 1.4);
  }

  Widget _buildSidebar(BuildContext context) {
    final s = _scale(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(18 * s),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 230 * s,
          margin: EdgeInsets.all(16 * s),
          padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 20 * s),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.white.withOpacity(0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18 * s),
            border: Border.all(color: Colors.white.withOpacity(0.28), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30 * s,
                    height: 30 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          kAdminAccent.withOpacity(0.9),
                          Colors.cyanAccent.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * s),
                  Text(
                    'K-Downloader Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14 * s,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24 * s),
              Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 12 * s,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: 10 * s),
              _SidebarItem(
                icon: Icons.notifications_active_outlined,
                label: 'Send Notification',
                selected: selectedPage == 0,
                onTap: () => setState(() => selectedPage = 0),
              ),
              _SidebarItem(
                icon: Icons.article_outlined,
                label: 'Tutorial Steps',
                selected: selectedPage == 1,
                onTap: () => setState(() => selectedPage = 1),
              ),
              _SidebarItem(
                icon: Icons.settings_outlined,
                label: 'App Settings',
                selected: selectedPage == 2,
                onTap: () => setState(() => selectedPage = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final s = _scale(context);
    String title;
    switch (selectedPage) {
      case 0:
        title = 'Broadcast Notification';
        break;
      case 1:
        title = 'Tutorial Steps';
        break;
      case 2:
        title = 'App Settings';
        break;
      default:
        title = 'Dashboard';
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 16 * s),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22 * s,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 10 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 4 * s),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 0.8,
              ),
            ),
            child: Text(
              'K Downloader',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11 * s,
              ),
            ),
          ),
          const Spacer(),
          // User info and logout
          StreamBuilder<User?>(
            stream: _authService.authStateChanges,
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user == null) return const SizedBox.shrink();

              return Row(
                children: [
                  // User email
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * s,
                      vertical: 6 * s,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8 * s),
                      color: Colors.white.withOpacity(0.08),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16 * s,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        SizedBox(width: 6 * s),
                        Text(
                          user.email ?? 'Admin',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12 * s,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10 * s),
                  // Logout button
                  InkWell(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1F2937),
                          title: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18 * s,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to logout?',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14 * s,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red[300],
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _authService.signOut();
                      }
                    },
                    borderRadius: BorderRadius.circular(8 * s),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * s,
                        vertical: 6 * s,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8 * s),
                        color: Colors.red.withOpacity(0.15),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            size: 16 * s,
                            color: Colors.red[300],
                          ),
                          SizedBox(width: 6 * s),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red[300],
                              fontSize: 12 * s,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageBody(BuildContext context) {
    final s = _scale(context);
    Widget child;
    switch (selectedPage) {
      case 0:
        child = const NotificationsPage();
        break;
      case 1:
        child = const TutorialStepsPage();
        break;
      case 2:
        child = const SettingsPage();
        break;
      default:
        child = const SizedBox();
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * s),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DailyStatsCard(),
              SizedBox(height: 20 * s),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: kAdminBg,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF05060A), Color(0xFF111827)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                if (isWide) _buildSidebar(context),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      Expanded(child: _buildPageBody(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final s = (width / 1280).clamp(0.8, 1.4);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * s),
      child: InkWell(
        borderRadius: BorderRadius.circular(10 * s),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 8 * s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10 * s),
            color: selected
                ? Colors.white.withOpacity(0.12)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? Colors.white.withOpacity(0.45)
                  : Colors.white.withOpacity(0.10),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18 * s, color: Colors.white.withOpacity(0.9)),
              SizedBox(width: 8 * s),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13 * s,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
