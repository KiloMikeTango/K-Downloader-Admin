// lib/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/daily_stats_card.dart';
import 'package:video_downloader_admin/pages/notifications_page.dart';
import 'package:video_downloader_admin/pages/settings_page.dart';
import 'package:video_downloader_admin/pages/tutorial_steps_page.dart';
import 'package:video_downloader_admin/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_downloader_admin/widgets/page_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedPage = 0;
  final AuthService _authService = AuthService();
  final List<_NavItemData> _navItems = const [
    _NavItemData(
      label: 'Notifications',
      subtitle: 'Broadcast to all users',
      icon: Icons.notifications_active_outlined,
    ),
    _NavItemData(
      label: 'Tutorial Steps',
      subtitle: 'Manage onboarding content',
      icon: Icons.article_outlined,
    ),
    _NavItemData(
      label: 'Settings',
      subtitle: 'Admin controls and rules',
      icon: Icons.settings_outlined,
    ),
  ];

  Widget _buildSidebar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth >= 1200 ? 280.0 : 260.0;

    return Container(
      width: sidebarWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'K-Downloader Admin',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                for (var i = 0; i < _navItems.length; i++)
                  _SidebarItem(
                    icon: _navItems[i].icon,
                    label: _navItems[i].label,
                    selected: selectedPage == i,
                    onTap: () => setState(() => selectedPage = i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isCompact) {
    final current = _navItems[selectedPage];
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 24,
        vertical: isCompact ? 12 : 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: PageHeader(
        title: current.label,
        subtitle: current.subtitle,
        trailing: _buildUserActions(context, isCompact),
      ),
    );
  }

  Widget _buildUserActions(BuildContext context, bool isCompact) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) return const SizedBox.shrink();
        final theme = Theme.of(context);
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(16),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(40),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isCompact ? 120 : 180,
                    ),
                    child: Text(
                      user.email ?? 'Admin',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
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
              icon: Icon(
                Icons.logout,
                size: 16,
                color: theme.colorScheme.error,
              ),
              label: Text(
                'Logout',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.error.withAlpha(80)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageBody(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxContentWidth = screenWidth >= 1400 ? 1200.0 : 980.0;
    final isWide = screenWidth >= 900;
    final pages = const [
      NotificationsPage(),
      TutorialStepsPage(),
      SettingsPage(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 24 : 16,
                vertical: isWide ? 24 : 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const DailyStatsCard(),
                    const SizedBox(height: 20),
                    IndexedStack(index: selectedPage, children: pages),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isCompact = screenWidth < 720;

    return Scaffold(
      drawer: isDesktop ? null : Drawer(child: _buildSidebar(context)),
      appBar: isDesktop
          ? null
          : AppBar(title: Text(_navItems[selectedPage].label)),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop) _buildSidebar(context),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) _buildHeader(context, isCompact),
                  Expanded(child: _buildPageBody(context)),
                ],
              ),
            ),
          ],
        ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withAlpha(18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha(60),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade700,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final String subtitle;
  final IconData icon;

  const _NavItemData({
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}
