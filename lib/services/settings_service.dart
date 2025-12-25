// lib/services/settings_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsService {
  final _doc = FirebaseFirestore.instance
      .collection('app_config')
      .doc('token');

  Stream<Map<String, dynamic>?> watch() {
    return _doc.snapshots().map((snap) => snap.data());
  }

  Future<void> saveToken(String token) async {
    await _doc.set(
      {'botToken': token},
      SetOptions(merge: true),
    );
  }

  Future<void> saveLastTestChatId(String chatId) async {
    await _doc.set(
      {'lastTestChatId': chatId},
      SetOptions(merge: true),
    );
  }
}
