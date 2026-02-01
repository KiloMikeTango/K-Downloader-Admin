// lib/pages/settings_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
      final url = 'https://api.telegram.org/bot$token/sendMessage';
      final res = await dio.post(
        url,
        data: {'chat_id': chatId, 'text': 'K Downloader bot test message.'},
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
    return GlassCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            if (isMaintenance == null)
              const Center(child: CircularProgressIndicator())
            else
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Maintenance mode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Enable maintenance mode.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                value: isMaintenance!,
                onChanged: _updateMaintenanceFlag,
                activeColor: Colors.blue.shade700,
              ),
            const SizedBox(height: 32),

            const Text(
              'Telegram Bot Token',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tokenController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: '123456789:ABC-DEF1234...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveToken,
                child: const Text(
                  'Save Bot Token',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Test Bot (send message)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _chatIdController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Chat ID',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                hintText: 'e.g. 123456789',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _testing
                      ? Colors.grey.shade300
                      : Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _testing ? null : _testBot,
                child: _testing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Send Test Message',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
