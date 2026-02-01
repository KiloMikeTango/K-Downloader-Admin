// lib/services/settings_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsService {
  final _doc = FirebaseFirestore.instance.collection('admin').doc('config');

  Stream<Map<String, dynamic>?> watch() {
    return _doc.snapshots().map((snap) => snap.data());
  }

  Future<void> saveLastTestChatId(String chatId) async {
    await _doc.set({'lastTestChatId': chatId}, SetOptions(merge: true));
  }
}
