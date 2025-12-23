// lib/pages/notifications_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:video_downloader_admin/pages/home_page.dart';
import 'package:video_downloader_admin/widgets/glass_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  bool sending = false;

  double _scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width / 1280).clamp(0.8, 1.4);
  }

  TextStyle _labelStyle(BuildContext context) {
    final s = _scale(context);
    return TextStyle(
      fontSize: 13 * s,
      color: Colors.white.withOpacity(0.75),
      fontWeight: FontWeight.w500,
    );
  }

  InputDecoration _glassInputDecoration(
    BuildContext context, {
    required String label,
  }) {
    final s = _scale(context);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 13 * s,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * s),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.18),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * s),
        borderSide: BorderSide(
          color: kAdminAccent.withOpacity(0.9),
          width: 1.4,
        ),
      ),
    );
  }

  Future<void> _sendNotification() async {
    if (titleController.text.isEmpty || messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both title and message.')),
      );
      return;
    }

    setState(() => sending = true);

    try {
      final jsonString = await rootBundle.loadString(
        'video-downloader-admin-b4c12c0fe07e.json',
      );
      final serviceAccount = auth.ServiceAccountCredentials.fromJson(
        jsonDecode(jsonString),
      );

      final scopes = <String>[
        'https://www.googleapis.com/auth/firebase.messaging',
      ];

      final client =
          await auth.clientViaServiceAccount(serviceAccount, scopes);

      const projectId = 'video-downloader-admin';

      final messagePayload = {
        'message': {
          'topic': 'all_users',
          'notification': {
            'title': titleController.text.trim(),
            'body': messageController.text.trim(),
          },
        },
      };

      final response = await client.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        ),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(messagePayload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent successfully!')),
        );
        titleController.clear();
        messageController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed: ${response.statusCode} - ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      client.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = _scale(context);
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send to topic: all_users',
            style: TextStyle(
              fontSize: 13 * s,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 20 * s),
          Text('Title', style: _labelStyle(context)),
          SizedBox(height: 6 * s),
          TextField(
            controller: titleController,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14 * s,
            ),
            decoration: _glassInputDecoration(
              context,
              label: 'Notification Title',
            ),
          ),
          SizedBox(height: 18 * s),
          Text('Message', style: _labelStyle(context)),
          SizedBox(height: 6 * s),
          TextField(
            controller: messageController,
            maxLines: 5,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14 * s,
            ),
            decoration: _glassInputDecoration(
              context,
              label: 'Notification Message',
            ),
          ),
          SizedBox(height: 26 * s),
          SizedBox(
            height: 48 * s,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAdminAccent.withOpacity(0.92),
                disabledBackgroundColor: kAdminAccent.withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14 * s),
                ),
                elevation: 0,
              ),
              onPressed: sending ? null : _sendNotification,
              child: sending
                  ? SizedBox(
                      width: 22 * s,
                      height: 22 * s,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.send_rounded,
                          size: 18 * s,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8 * s),
                        Text(
                          'Send Notification',
                          style: TextStyle(
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
