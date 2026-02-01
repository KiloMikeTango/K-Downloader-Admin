import 'package:flutter/material.dart';
import 'package:video_downloader_admin/models/tutorial_step.dart';
import 'package:video_downloader_admin/services/tutorial_steps_service.dart';

class TutorialStepsAdminScreen extends StatelessWidget {
  final _service = TutorialStepsService();
   TutorialStepsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TutorialStep>>(
      stream: _service.watchSteps(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final steps = snapshot.data!;
        return Column(
          children: [
            _headerBar(context),
            Expanded(child: _stepsTable(context, steps)),
          ],
        );
      },
    );
  }

  Widget _headerBar(BuildContext context) {
    return Row(
      children: [
        Text('Tutorial Steps' /* glassy title style */),
        const Spacer(),
        ElevatedButton(
          onPressed: () => _openStepForm(context),
          child: const Text('Add Step'),
        ),
      ],
    );
  }

  Widget _stepsTable(BuildContext context, List<TutorialStep> steps) {
    return ListView.builder(
      itemCount: steps.length,
      itemBuilder: (context, i) {
        final s = steps[i];
        return ListTile(
          leading: Text(s.order.toString()),
          title: Text(s.text, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(s.buttonText ?? 'No button'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _openStepForm(context, step: s),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteStep(context, s),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openStepForm(BuildContext context, {TutorialStep? step}) {
    // showDialog or showModalBottomSheet with form fields bound to step
  }

  void _deleteStep(BuildContext context, TutorialStep step) {
    // confirm dialog then _service.deleteStep(step.id)
  }
}
