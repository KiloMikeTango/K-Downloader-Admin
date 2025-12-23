// lib/services/tutorial_steps_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_downloader_admin/models/tutorial_step.dart';

class TutorialStepsService {
  final _col = FirebaseFirestore.instance.collection('tutorialSteps');

  Stream<List<TutorialStep>> watchSteps() {
    return _col.orderBy('order').snapshots().map(
          (snap) => snap.docs.map((d) => TutorialStep.fromDoc(d)).toList(),
        );
  }

  Future<void> createStep(TutorialStep step) {
    return _col.add(step.toMap());
  }

  Future<void> updateStep(TutorialStep step) {
    return _col.doc(step.id).update(step.toMap());
  }

  Future<void> deleteStep(String id) {
    return _col.doc(id).delete();
  }
}
