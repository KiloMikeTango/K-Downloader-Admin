// lib/pages/notifications_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:video_downloader_admin/widgets/app_snackbar.dart';
import 'package:video_downloader_admin/widgets/form_section.dart';
import 'package:video_downloader_admin/widgets/info_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final titleController = TextEditingController();
  final messageController = TextEditingController();
  bool sending = false;

  Future<void> _sendNotification() async {
    if (titleController.text.isEmpty || messageController.text.isEmpty) {
      AppSnackBar.showError(context, 'Please enter both title and message.');
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

      final client = await auth.clientViaServiceAccount(serviceAccount, scopes);

      const projectId = 'video-downloader-admin';

      final messagePayload = {
        'message': {
          'topic': 'all_users',
          'notification': {
            'title': titleController.text.trim(),
            'body': messageController.text.trim(),
          },
          'android': {'priority': 'HIGH'},
          'data': {'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
        },
      };
      try {
        final response = await client.post(
          Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
          ),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(messagePayload),
        );

        if (!mounted) return;
        if (response.statusCode == 200) {
          AppSnackBar.showSuccess(context, 'Notification sent successfully.');
          titleController.clear();
          messageController.clear();
        } else {
          AppSnackBar.showError(
            context,
            'Failed: ${response.statusCode} - ${response.body}',
          );
        }
      } finally {
        client.close();
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Error: $e');
    }

    if (!mounted) return;
    setState(() => sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormSection(
              title: 'Compose Notification',
              subtitle: 'Send a message to all active users',
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Notification title',
                    ),
                  ),
                  SizedBox(height: isCompact ? 12 : 16),
                  TextField(
                    controller: messageController,
                    maxLines: isCompact ? 4 : 6,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Write the message content',
                    ),
                  ),
                  SizedBox(height: isCompact ? 16 : 20),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: sending ? null : _sendNotification,
                      icon: sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        sending ? 'Sending...' : 'Send Notification',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isCompact ? 16 : 20),
            FormSection(
              title: 'Delivery Details',
              subtitle: 'Current broadcast configuration',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  InfoCard(
                    label: 'Target',
                    value: 'all_users',
                    icon: Icons.campaign_rounded,
                    tone: Color(0xFF2563EB),
                  ),
                  InfoCard(
                    label: 'Priority',
                    value: 'High',
                    icon: Icons.bolt_rounded,
                    tone: Color(0xFFEA580C),
                  ),
                  InfoCard(
                    label: 'Transport',
                    value: 'FCM v1',
                    icon: Icons.cloud_rounded,
                    tone: Color(0xFF0F766E),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Make sure the message is concise and action-focused.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}
