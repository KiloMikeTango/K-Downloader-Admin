// lib/models/tutorial_step.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorialStep {
  final String id;
  final int order;
  final String text;
  final String imageUrl;
  final String? buttonText;
  final String? buttonUrl;

  TutorialStep({
    required this.id,
    required this.order,
    required this.text,
    required this.imageUrl,
    this.buttonText,
    this.buttonUrl,
  });

  factory TutorialStep.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TutorialStep(
      id: doc.id,
      order: (data['order'] ?? 0) as int,
      text: (data['text'] ?? '') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      buttonText: data['buttonText'] as String?,
      buttonUrl: data['buttonUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'text': text,
      'imageUrl': imageUrl,
      'buttonText': buttonText,
      'buttonUrl': buttonUrl,
    };
  }
}
