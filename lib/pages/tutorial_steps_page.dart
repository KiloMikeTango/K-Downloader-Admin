// lib/pages/tutorial_steps_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_downloader_admin/models/tutorial_step.dart';
import 'package:video_downloader_admin/pages/home_page.dart';
import 'package:video_downloader_admin/services/tutorial_steps_service.dart';
import 'package:video_downloader_admin/widgets/glass_card.dart';

class TutorialStepsPage extends StatelessWidget {
  const TutorialStepsPage({super.key});

  double _scale(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width / 1280).clamp(0.8, 1.4);
  }

  InputDecoration _glassInputDecoration(
    BuildContext context, {
    required String label,
  }) {
    final s = _scale(context);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 13 * s,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * s),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.18),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * s),
        borderSide: BorderSide(
          color: kAdminAccent.withOpacity(0.9),
          width: 1.4,
        ),
      ),
    );
  }

  void _openStepDialog(
    BuildContext context,
    TutorialStepsService service, {
    TutorialStep? existing,
  }) {
    final orderCtrl =
        TextEditingController(text: existing?.order.toString() ?? '');
    final textCtrl = TextEditingController(text: existing?.text ?? '');
    final imageUrlCtrl =
        TextEditingController(text: existing?.imageUrl ?? '');
    final buttonTextCtrl =
        TextEditingController(text: existing?.buttonText ?? '');
    final buttonUrlCtrl =
        TextEditingController(text: existing?.buttonUrl ?? '');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? 'New Tutorial Step' : 'Edit Tutorial Step',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: orderCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        _glassInputDecoration(context, label: 'Order (1, 2, 3...)'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textCtrl,
                    maxLines: 3,
                    decoration:
                        _glassInputDecoration(context, label: 'Text'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: imageUrlCtrl,
                    decoration: _glassInputDecoration(
                      context,
                      label: 'Image URL',
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: buttonTextCtrl,
                    decoration: _glassInputDecoration(
                      context,
                      label: 'Button Text (optional)',
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: buttonUrlCtrl,
                    decoration: _glassInputDecoration(
                      context,
                      label: 'Button URL (optional)',
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAdminAccent,
                        ),
                        onPressed: () async {
                          final order = int.tryParse(orderCtrl.text.trim()) ?? 0;
                          final step = TutorialStep(
                            id: existing?.id ?? '',
                            order: order,
                            text: textCtrl.text.trim(),
                            imageUrl: imageUrlCtrl.text.trim(),
                            buttonText: buttonTextCtrl.text.trim().isEmpty
                                ? null
                                : buttonTextCtrl.text.trim(),
                            buttonUrl: buttonUrlCtrl.text.trim().isEmpty
                                ? null
                                : buttonUrlCtrl.text.trim(),
                          );
                          if (existing == null) {
                            await service.createStep(step);
                          } else {
                            await service.updateStep(step);
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Text(existing == null ? 'Create' : 'Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _scale(context);
    final service = TutorialStepsService();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Tutorial Steps',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18 * s,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 36 * s,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () => _openStepDialog(context, service),
                  icon: Icon(
                    Icons.add_rounded,
                    size: 18 * s,
                    color: Colors.white,
                  ),
                  label: Text(
                    'New Step',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13 * s,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          Expanded(
            child: StreamBuilder<List<TutorialStep>>(
              stream: service.watchSteps(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                final steps = snapshot.data ?? [];
                if (steps.isEmpty) {
                  return Center(
                    child: Text(
                      'No tutorial steps yet.\nClick "New Step" to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 14 * s,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: steps.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.white.withOpacity(0.12)),
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        child: Text(
                          step.order.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        step.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 14 * s,
                        ),
                      ),
                      subtitle: step.buttonText != null &&
                              step.buttonText!.trim().isNotEmpty
                          ? Text(
                              step.buttonText!,
                              style: TextStyle(
                                color: Colors.cyanAccent.withOpacity(0.9),
                                fontSize: 12 * s,
                              ),
                            )
                          : Text(
                              'No button',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 12 * s,
                              ),
                            ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 18 * s,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            onPressed: () =>
                                _openStepDialog(context, service, existing: step),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 18 * s,
                              color: Colors.redAccent.withOpacity(0.9),
                            ),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Delete step?'),
                                      content: Text(
                                        'This will permanently delete step "${step.text}".',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text(
                                            'Delete',
                                            style:
                                                TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                              if (confirmed) {
                                await service.deleteStep(step.id);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
