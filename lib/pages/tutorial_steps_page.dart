// lib/pages/tutorial_steps_page.dart
import 'package:flutter/material.dart';
import 'package:video_downloader_admin/models/tutorial_step.dart';
import 'package:video_downloader_admin/services/tutorial_steps_service.dart';
import 'package:video_downloader_admin/widgets/glass_card.dart';

class TutorialStepsPage extends StatelessWidget {
  const TutorialStepsPage({super.key});

  Widget _summaryTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(64)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withAlpha(46),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Icon(Icons.image_outlined, color: Colors.grey.shade500, size: 26),
    );
  }

  Widget _buildStepCard(
    BuildContext context,
    TutorialStep step,
    TutorialStepsService service,
  ) {
    final hasImage = step.imageUrl.trim().isNotEmpty;
    final hasButton =
        step.buttonText != null && step.buttonText!.trim().isNotEmpty;
    final buttonUrl = step.buttonUrl?.trim() ?? '';

    return InkWell(
      onTap: () => _openStepDialog(context, service, existing: step),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade50,
              child: Text(
                step.order.toString(),
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade900,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          hasButton ? step.buttonText!.trim() : 'No button',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasButton
                                ? Colors.blue.shade700
                                : Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (buttonUrl.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      buttonUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 100,
                  height: 68,
                  child: hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            step.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _imagePlaceholder(Colors.grey.shade200);
                            },
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return _imagePlaceholder(Colors.grey.shade200);
                            },
                          ),
                        )
                      : _imagePlaceholder(Colors.grey.shade200),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit',
                      icon: Icon(
                        Icons.edit_rounded,
                        size: 20,
                        color: Colors.blue.shade700,
                      ),
                      onPressed: () =>
                          _openStepDialog(context, service, existing: step),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

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
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Manage the onboarding steps shown in the client app.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
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
          const SizedBox(height: 20),
          StreamBuilder<List<TutorialStep>>(
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
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                );
              }
              final withButtons = steps
                  .where(
                    (step) =>
                        step.buttonText != null &&
                        step.buttonText!.trim().isNotEmpty,
                  )
                  .length;
              return Column(
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 240,
                        child: _summaryTile(
                          icon: Icons.layers_rounded,
                          label: 'Total Steps',
                          value: steps.length.toString(),
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        child: _summaryTile(
                          icon: Icons.link_rounded,
                          label: 'Buttons Configured',
                          value: withButtons.toString(),
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListView.separated(
                    itemCount: steps.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _buildStepCard(context, steps[index], service);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
