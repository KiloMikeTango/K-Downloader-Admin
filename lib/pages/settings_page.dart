// lib/pages/settings_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_downloader_admin/pages/home_page.dart';
import 'package:video_downloader_admin/widgets/glass_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool? isMaintenance;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceFlag();
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

  @override
  Widget build(BuildContext context) {
    final s = _scale(context);
    return GlassCard(
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
                'If enabled, client app can show a maintenance screen or block downloads.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12 * s,
                ),
              ),
              value: isMaintenance!,
              onChanged: _updateMaintenanceFlag,
              activeColor: kAdminAccent,
            ),
        ],
      ),
    );
  }
}
