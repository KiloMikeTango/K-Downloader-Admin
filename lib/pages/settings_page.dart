// lib/pages/settings_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import '../widgets/glass_card.dart';
import '../services/settings_service.dart';
import 'package:dio/dio.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool? isMaintenance;
  final _tokenController = TextEditingController();
  final _chatIdController = TextEditingController();
  final _settingsService = SettingsService();
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceFlag();
    _listenBotSettings();
  }

  Future<void> _loadMaintenanceFlag() async {
    final doc = await FirebaseFirestore.instance
        .collection('app_config')
        .doc('is_maintenance')
        .get();
    final data = doc.data();
    setState(() {
      isMaintenance = (data?['enabled'] ?? false) as bool;
    });
  }

  void _listenBotSettings() {
    _settingsService.watch().listen((data) {
      if (!mounted) return;
      final token = (data?['botToken'] ?? '') as String;
      final lastChatId = (data?['lastTestChatId'] ?? '') as String;
      setState(() {
        _tokenController.text = token;
        _chatIdController.text = lastChatId;
      });
    });
  }

  Future<void> _updateMaintenanceFlag(bool value) async {
    setState(() => isMaintenance = value);
    await FirebaseFirestore.instance
        .collection('app_config')
        .doc('is_maintenance')
        .set({'enabled': value}, SetOptions(merge: true));
  }

  double _scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width / 1280).clamp(0.8, 1.4);
  }

  Future<void> _saveToken() async {
    final token = _tokenController.text.trim();
    await _settingsService.saveToken(token);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bot token saved.')));
  }

  Future<void> _testBot() async {
    final token = _tokenController.text.trim();
    final chatId = _chatIdController.text.trim();

    if (token.isEmpty || chatId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter both token and chat id.')),
      );
      return;
    }

    setState(() => _testing = true);
    try {
      final dio = Dio();
      final url =
          'https://api.telegram.org/bot$token/sendMessage'; // Telegram Bot API
      final res = await dio.post(
        url,
        data: {
          'chat_id': chatId,
          'text': '✅ K Downloader bot test message from admin panel.',
        },
      );

      if (res.statusCode == 200 && res.data['ok'] == true) {
        await _settingsService.saveLastTestChatId(chatId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test message sent successfully.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Telegram API error: ${res.statusCode} - ${res.data}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send test message: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _chatIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _scale(context);
    return GlassCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * s,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16 * s),

            // Maintenance
            if (isMaintenance == null)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            else
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Maintenance mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'If enabled, client app shows maintenance screen.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 12 * s,
                  ),
                ),
                value: isMaintenance!,
                onChanged: _updateMaintenanceFlag,
                activeColor: kAdminAccent,
              ),
            SizedBox(height: 20 * s),

            // Bot token
            Text(
              'Telegram Bot Token',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * s,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8 * s),
            TextField(
              controller: _tokenController,
              style: TextStyle(color: Colors.white, fontSize: 13 * s),
              decoration: InputDecoration(
                hintText: '123456789:ABC-DEF1234...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13 * s,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * s),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * s),
                  borderSide: BorderSide(color: kAdminAccent, width: 1.4),
                ),
              ),
            ),
            SizedBox(height: 10 * s),
            SizedBox(
              height: 40 * s,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAdminAccent.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10 * s),
                  ),
                ),
                onPressed: _saveToken,
                child: Text(
                  'Save Bot Token',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13 * s,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24 * s),

            // Test bot
            Text(
              'Test Bot (send message)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14 * s,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8 * s),
            TextField(
              controller: _chatIdController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white, fontSize: 13 * s),
              decoration: InputDecoration(
                labelText: 'Chat ID',
                labelStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12 * s,
                ),
                hintText: 'e.g. 123456789',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13 * s,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * s),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * s),
                  borderSide: BorderSide(color: kAdminAccent, width: 1.4),
                ),
              ),
            ),
            SizedBox(height: 10 * s),
            SizedBox(
              height: 40 * s,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _testing
                      ? Colors.white.withOpacity(0.2)
                      : kAdminAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10 * s),
                  ),
                ),
                onPressed: _testing ? null : _testBot,
                child: _testing
                    ? SizedBox(
                        width: 18 * s,
                        height: 18 * s,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Send Test Message',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
