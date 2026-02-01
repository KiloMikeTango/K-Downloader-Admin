// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:video_downloader_admin/services/auth_service.dart';
import 'package:video_downloader_admin/widgets/glass_card.dart';

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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16 : 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 440 : double.infinity,
              ),
              child: GlassCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: isCompact ? 4 : 8),
                    Icon(
                      Icons.admin_panel_settings,
                      size: isCompact ? 40 : 48,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(height: isCompact ? 16 : 20),
                    Text(
                      'Admin Login',
                      style: TextStyle(
                        fontSize: isCompact ? 22 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isCompact ? 24 : 32),

                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(
                          vertical: isCompact ? 14 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.grey,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: isCompact ? 18 : 20,
                                  height: isCompact ? 18 : 20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.white,
                                  ),
                                  child: const Icon(
                                    Icons.g_mobiledata,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    fontSize: isCompact ? 14 : 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
