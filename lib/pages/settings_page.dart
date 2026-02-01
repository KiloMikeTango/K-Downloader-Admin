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
  bool _rulesChecking = false;
  String? _rulesCheckMessage;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceFlag();
    _listenBotSettings();
  }

  Future<void> _loadMaintenanceFlag() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admin')
          .doc('maintenance')
          .get();
      final data = doc.data();
      if (!mounted) return;
      setState(() {
        isMaintenance = (data?['enabled'] ?? false) as bool;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isMaintenance = false;
      });
    }
  }

  void _listenBotSettings() {
    _settingsService.watch().listen((data) {
      if (!mounted) return;
      final lastChatId = (data?['lastTestChatId'] ?? '') as String;
      setState(() {
        _chatIdController.text = lastChatId;
      });
    });
  }

  Future<void> _updateMaintenanceFlag(bool value) async {
    setState(() => isMaintenance = value);
    await FirebaseFirestore.instance.collection('admin').doc('maintenance').set(
      {'enabled': value},
      SetOptions(merge: true),
    );
  }

  Future<void> _saveToken() async {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bot token kept locally.')));
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

  Future<void> _setRulesCheckResult(String message) async {
    if (!mounted) return;
    setState(() {
      _rulesChecking = false;
      _rulesCheckMessage = message;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _runRulesCheck(
    String label,
    Future<void> Function() action,
  ) async {
    if (_rulesChecking) return;
    setState(() {
      _rulesChecking = true;
      _rulesCheckMessage = null;
    });
    try {
      await action();
      await _setRulesCheckResult('$label: success');
    } catch (e) {
      await _setRulesCheckResult('$label: $e');
    }
  }

  Future<void> _testPublicRead() async {
    await FirebaseFirestore.instance
        .collection('publicConfig')
        .doc('rules_check')
        .get();
  }

  Future<void> _testTutorialRead() async {
    await FirebaseFirestore.instance
        .collection('tutorialSteps')
        .doc('rules_check')
        .get();
  }

  Future<void> _testAdminRead() async {
    await FirebaseFirestore.instance.collection('admin').doc('config').get();
  }

  Future<void> _testAdminWrite() async {
    await FirebaseFirestore.instance.collection('admin').doc('rules_check').set(
      {'checkedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Future<void> _testStatsRead() async {
    await FirebaseFirestore.instance
        .collection('stats')
        .doc('daily_downloads')
        .get();
  }

  Future<void> _testStatsWriteDenied() async {
    if (_rulesChecking) return;
    setState(() {
      _rulesChecking = true;
      _rulesCheckMessage = null;
    });
    final doc = FirebaseFirestore.instance
        .collection('stats')
        .doc('rules_check');
    try {
      await doc.set({
        'probe': true,
        'checkedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      try {
        await doc.delete();
      } catch (_) {}
      await _setRulesCheckResult('Stats write: unexpectedly succeeded');
    } catch (_) {
      await _setRulesCheckResult('Stats write: blocked (expected)');
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;
        return GlassCard(
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
              SizedBox(height: isCompact ? 16 : 20),
              if (isMaintenance == null)
                const Center(child: CircularProgressIndicator())
              else
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: isCompact,
                  title: const Text(
                    'Maintenance mode',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  value: isMaintenance!,
                  onChanged: _updateMaintenanceFlag,
                  activeThumbColor: Colors.blue.shade700,
                ),
              SizedBox(height: isCompact ? 20 : 24),
              TextField(
                controller: _tokenController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Bot Token',
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
                    borderSide: BorderSide(
                      color: Colors.blue.shade700,
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 12 : 16),
              SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _saveToken,
                  child: const Text(
                    'Save Token',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 20 : 24),
              TextField(
                controller: _chatIdController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Test Chat ID',
                  hintText: '123456789',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.blue.shade700,
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 12 : 16),
              SizedBox(
                height: 44,
                width: double.infinity,
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
                          'Send Test',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: isCompact ? 20 : 24),
              const Text(
                'Rules Check',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _rulesChecking
                        ? null
                        : () => _runRulesCheck('Public read', _testPublicRead),
                    child: const Text('Public read'),
                  ),
                  OutlinedButton(
                    onPressed: _rulesChecking
                        ? null
                        : () => _runRulesCheck(
                            'Tutorial read',
                            _testTutorialRead,
                          ),
                    child: const Text('Tutorial read'),
                  ),
                  OutlinedButton(
                    onPressed: _rulesChecking
                        ? null
                        : () => _runRulesCheck('Admin read', _testAdminRead),
                    child: const Text('Admin read'),
                  ),
                  OutlinedButton(
                    onPressed: _rulesChecking
                        ? null
                        : () => _runRulesCheck('Admin write', _testAdminWrite),
                    child: const Text('Admin write'),
                  ),
                  OutlinedButton(
                    onPressed: _rulesChecking
                        ? null
                        : () => _runRulesCheck('Stats read', _testStatsRead),
                    child: const Text('Stats read'),
                  ),
                  OutlinedButton(
                    onPressed: _rulesChecking ? null : _testStatsWriteDenied,
                    child: const Text('Stats write'),
                  ),
                ],
              ),
              if (_rulesCheckMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Text(
                    _rulesCheckMessage!,
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
