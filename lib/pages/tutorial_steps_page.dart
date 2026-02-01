// lib/pages/tutorial_steps_page.dart
import 'package:flutter/material.dart';
import 'package:video_downloader_admin/models/tutorial_step.dart';
import 'package:video_downloader_admin/services/tutorial_steps_service.dart';
import 'package:video_downloader_admin/widgets/glass_card.dart';

class TutorialStepsPage extends StatelessWidget {
  const TutorialStepsPage({super.key});

  void _openStepDialog(
    BuildContext context,
    TutorialStepsService service, {
    TutorialStep? existing,
  }) {
    final orderCtrl = TextEditingController(
      text: existing?.order.toString() ?? '',
    );
    final textCtrl = TextEditingController(text: existing?.text ?? '');
    final imageUrlCtrl = TextEditingController(text: existing?.imageUrl ?? '');
    final buttonTextCtrl = TextEditingController(
      text: existing?.buttonText ?? '',
    );
    final buttonUrlCtrl = TextEditingController(
      text: existing?.buttonUrl ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => LayoutBuilder(
        builder: (context, constraints) {
          final dialogWidth = constraints.maxWidth > 600
              ? 500.0
              : constraints.maxWidth * 0.9;
          return Dialog(
            child: Container(
              width: dialogWidth,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      existing == null
                          ? 'New Tutorial Step'
                          : 'Edit Tutorial Step',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: orderCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Order (1, 2, 3...)',
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: textCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Text',
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: imageUrlCtrl,
                      decoration: InputDecoration(
                        labelText: 'Image URL',
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: buttonTextCtrl,
                      decoration: InputDecoration(
                        labelText: 'Button Text (optional)',
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: buttonUrlCtrl,
                      decoration: InputDecoration(
                        labelText: 'Button URL (optional)',
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
                    const SizedBox(height: 24),
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
                            backgroundColor: Colors.blue.shade700,
                          ),
                          onPressed: () async {
                            final order =
                                int.tryParse(orderCtrl.text.trim()) ?? 0;
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
                          child: Text(
                            existing == null ? 'Create' : 'Save',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = TutorialStepsService();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'Tutorial Steps',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _openStepDialog(context, service),
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'New Step',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<List<TutorialStep>>(
              stream: service.watchSteps(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final steps = snapshot.data ?? [];
                if (steps.isEmpty) {
                  return Center(
                    child: Text(
                      'No tutorial steps yet.\nClick "New Step" to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: steps.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          step.order.toString(),
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        step.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      subtitle:
                          step.buttonText != null &&
                              step.buttonText!.trim().isNotEmpty
                          ? Text(
                              step.buttonText!,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            )
                          : Text(
                              'No button',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: Colors.blue.shade700,
                            ),
                            onPressed: () => _openStepDialog(
                              context,
                              service,
                              existing: step,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: Colors.red.shade700,
                            ),
                            onPressed: () async {
                              final confirmed =
                                  await showDialog<bool>(
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
                                            style: TextStyle(color: Colors.red),
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
