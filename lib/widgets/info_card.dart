import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tone;
  final String? helper;

  const InfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tone.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: tone.withAlpha(50)),
              ),
              child: Icon(icon, color: tone, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(140),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (helper != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      helper!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(120),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
