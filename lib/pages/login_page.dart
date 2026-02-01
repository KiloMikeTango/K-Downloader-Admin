// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:video_downloader_admin/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        return;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        final errorStr = e.toString();
        if (errorStr.contains('Access denied') || errorStr.contains('Admin')) {
          _errorMessage = 'Access denied.';
        } else if (errorStr.contains('network') ||
            errorStr.contains('Network') ||
            errorStr.contains('SERVICE_DISABLED') ||
            errorStr.contains('People API')) {
          _errorMessage = 'Network error.';
        } else if (errorStr.contains('popup_closed') ||
            errorStr.contains('popup_blocked')) {
          _errorMessage = 'Sign-in canceled.';
        } else if (errorStr.contains('Invalid account') ||
            errorStr.contains('Authentication failed') ||
            errorStr.contains('Verification failed') ||
            errorStr.contains('Invalid credential') ||
            errorStr.contains('No tokens') ||
            errorStr.contains('No user returned') ||
            errorStr.contains('No ID token') ||
            errorStr.contains('Auth error')) {
          final cleanError = errorStr.contains('Exception: ')
              ? errorStr.split('Exception: ')[1].split('.')[0]
              : 'Authentication failed.';
          _errorMessage = cleanError.length > 60
              ? '${cleanError.substring(0, 60)}...'
              : cleanError;
        } else {
          final cleanError = errorStr.contains('Exception: ')
              ? errorStr.split('Exception: ')[1]
              : errorStr;
          _errorMessage = cleanError.length > 80
              ? '${cleanError.substring(0, 80)}...'
              : cleanError;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    final isCompact = MediaQuery.of(context).size.width < 420;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16 : 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 440 : double.infinity,
              ),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 20 : 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.primary.withAlpha(18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'K Downloader Admin',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Sign in with your admin account',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isCompact ? 20 : 24),
                      Text(
                        'Admin Login',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: isCompact ? 20 : 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isCompact ? 16 : 20),
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withAlpha(15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.error.withAlpha(70),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.g_mobiledata),
                        label: Text(
                          _isLoading ? 'Signing in...' : 'Continue with Google',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Only approved admin emails can access the dashboard.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
