import 'package:flutter/material.dart';

class AppSnackBar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, const Color(0xFF16A34A));
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, const Color(0xFFDC2626));
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, const Color(0xFF1D4ED8));
  }

  static void _show(BuildContext context, String message, Color tone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: tone,
      ),
    );
  }
}
