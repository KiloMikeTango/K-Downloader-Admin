// lib/pages/tutorial_steps_page.dart
import 'package:flutter/material.dart';
import 'package:video_downloader_admin/models/tutorial_step.dart';
import 'package:video_downloader_admin/services/tutorial_steps_service.dart';
import 'package:video_downloader_admin/widgets/app_snackbar.dart';
import 'package:video_downloader_admin/widgets/form_section.dart';
import 'package:video_downloader_admin/widgets/info_card.dart';

class TutorialStepsPage extends StatelessWidget {
  const TutorialStepsPage({super.key});

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

  Widget _imagePreview(TutorialStep step) {
    final hasImage = step.imageUrl.trim().isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: hasImage
          ? Image.network(
              step.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _imagePlaceholder(Colors.grey.shade200);
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _imagePlaceholder(Colors.grey.shade200);
              },
            )
          : _imagePlaceholder(Colors.grey.shade200),
    );
  }

  Widget _buildButtonCell(BuildContext context, TutorialStep step) {
    final theme = Theme.of(context);
    final hasButton =
        step.buttonText != null && step.buttonText!.trim().isNotEmpty;
    final buttonUrl = step.buttonUrl?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          hasButton ? step.buttonText!.trim() : 'No button',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: hasButton
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withAlpha(120),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (buttonUrl.isNotEmpty) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: 180,
            child: Text(
              buttonUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(120),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TutorialStepsService service,
    TutorialStep step,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete step?'),
            content: Text('This will permanently delete step "${step.text}".'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    try {
      await service.deleteStep(step.id);
      if (context.mounted) {
        AppSnackBar.showSuccess(context, 'Step deleted.');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(context, 'Failed to delete step: $e');
      }
    }
  }

  Widget _buildStepsTable(
    BuildContext context,
    List<TutorialStep> steps,
    TutorialStepsService service,
    bool isCompact,
  ) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: isCompact ? 16 : 24,
        headingRowColor: WidgetStateProperty.all(
          theme.colorScheme.primary.withAlpha(10),
        ),
        dataRowMinHeight: 64,
        dataRowMaxHeight: 96,
        columns: const [
          DataColumn(label: Text('Order')),
          DataColumn(label: Text('Text')),
          DataColumn(label: Text('Image')),
          DataColumn(label: Text('Button')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final step in steps)
            DataRow(
              cells: [
                DataCell(Text(step.order.toString())),
                DataCell(
                  SizedBox(
                    width: isCompact ? 180 : 280,
                    child: Text(
                      step.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(width: 96, height: 64, child: _imagePreview(step)),
                ),
                DataCell(_buildButtonCell(context, step)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: Icon(
                          Icons.edit_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () =>
                            _openStepDialog(context, service, existing: step),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () => _confirmDelete(context, service, step),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _openStepDialog(
    BuildContext context,
    TutorialStepsService service, {
    TutorialStep? existing,
  }) {
    final parentContext = context;
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
      builder: (dialogContext) => LayoutBuilder(
        builder: (context, constraints) {
          final dialogWidth = constraints.maxWidth > 600
              ? 500.0
              : constraints.maxWidth * 0.9;
          final theme = Theme.of(context);
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
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
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
                            try {
                              if (existing == null) {
                                await service.createStep(step);
                              } else {
                                await service.updateStep(step);
                              }
                              if (parentContext.mounted) {
                                Navigator.pop(dialogContext);
                                AppSnackBar.showSuccess(
                                  parentContext,
                                  existing == null
                                      ? 'Step created.'
                                      : 'Step updated.',
                                );
                              }
                            } catch (e) {
                              if (parentContext.mounted) {
                                AppSnackBar.showError(
                                  parentContext,
                                  'Failed to save step: $e',
                                );
                              }
                            }
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
    return StreamBuilder<List<TutorialStep>>(
      stream: service.watchSteps(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final steps = snapshot.data ?? [];
        final withButtons = steps
            .where(
              (step) =>
                  step.buttonText != null && step.buttonText!.trim().isNotEmpty,
            )
            .length;
        final withImages = steps
            .where((step) => step.imageUrl.trim().isNotEmpty)
            .length;
        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 720;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormSection(
                  title: 'Tutorial Overview',
                  subtitle: 'Monitor onboarding content coverage',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      InfoCard(
                        label: 'Total Steps',
                        value: steps.length.toString(),
                        icon: Icons.layers_rounded,
                        tone: const Color(0xFF2563EB),
                      ),
                      InfoCard(
                        label: 'Buttons Configured',
                        value: withButtons.toString(),
                        icon: Icons.link_rounded,
                        tone: const Color(0xFF16A34A),
                      ),
                      InfoCard(
                        label: 'Images Added',
                        value: withImages.toString(),
                        icon: Icons.image_rounded,
                        tone: const Color(0xFFEA580C),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isCompact ? 16 : 20),
                FormSection(
                  title: 'Tutorial Steps',
                  subtitle: 'Manage content, images, and actions',
                  trailing: ElevatedButton.icon(
                    onPressed: () => _openStepDialog(context, service),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('New Step'),
                  ),
                  child: steps.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No tutorial steps yet. Create the first step to get started.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      : _buildStepsTable(context, steps, service, isCompact),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
