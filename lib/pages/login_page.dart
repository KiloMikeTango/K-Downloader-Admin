// lib/pages/login_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_downloader_admin/services/auth_service.dart';
import 'package:video_downloader_admin/widgets/glass_card.dart';

const Color kAdminBg = Color(0xFF05060A);
const Color kAdminAccent = Color(0xFF4F46E5);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  double _scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width / 1280).clamp(0.8, 1.4);
  }

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
              ? cleanError.substring(0, 60) + '...'
              : cleanError;
        } else {
          final cleanError = errorStr.contains('Exception: ')
              ? errorStr.split('Exception: ')[1]
              : errorStr;
          _errorMessage = cleanError.length > 80
              ? cleanError.substring(0, 80) + '...'
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
    final s = _scale(context);
    final isWide = MediaQuery.of(context).size.width >= 600;

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
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24 * s),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 500 : double.infinity,
                  ),
                  child: GlassCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and Title
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 70 * s,
                                height: 70 * s,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 2,
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      kAdminAccent.withOpacity(0.9),
                                      Colors.cyanAccent.withOpacity(0.6),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                  size: 35 * s,
                                ),
                              ),
                              SizedBox(height: 24 * s),
                              Text(
                                'Admin Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32 * s,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10 * s),
                              Text(
                                'K-Downloader Admin Panel',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14 * s,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 50 * s),

                        // Error Message
                        if (_errorMessage != null)
                          Container(
                            padding: EdgeInsets.all(14 * s),
                            margin: EdgeInsets.only(bottom: 24 * s),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12 * s),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[300],
                                  size: 22 * s,
                                ),
                                SizedBox(width: 10 * s),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red[300],
                                      fontSize: 13 * s,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Google Sign In Button
                        _buildGmailButton(
                          context: context,
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGmailButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    final s = _scale(context);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: EdgeInsets.symmetric(vertical: 18 * s),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * s),
        ),
        elevation: 2,
      ),
      child: isLoading
          ? SizedBox(
              height: 24 * s,
              width: 24 * s,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[700]!),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 22 * s,
                  height: 22 * s,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.g_mobiledata,
                    color: Colors.red,
                    size: 20 * s,
                  ),
                ),
                SizedBox(width: 14 * s),
                Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 16 * s,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
    );
  }
}
