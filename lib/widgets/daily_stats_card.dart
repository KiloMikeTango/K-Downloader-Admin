// lib/widgets/daily_stats_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_downloader_admin/widgets/info_card.dart';

class DailyStatsCard extends StatelessWidget {
  const DailyStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stats')
          .doc('daily_downloads')
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;

        final yt = (data?['youtubeCount'] ?? 0) as int;
        final tk = (data?['tiktokCount'] ?? 0) as int;
        final fb = (data?['facebookCount'] ?? 0) as int;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 680;
            return Card(
              child: Padding(
                padding: EdgeInsets.all(isCompact ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today Downloads',
                    style: TextStyle(
                      fontSize: isCompact ? 14 : 16,
                        fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: isCompact ? 12 : 16),
                  if (isCompact)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                          InfoCard(
                            label: 'YouTube',
                            value: yt.toString(),
                            icon: Icons.play_circle_fill,
                            tone: const Color(0xFFDC2626),
                          ),
                          InfoCard(
                            label: 'TikTok',
                            value: tk.toString(),
                            icon: Icons.music_note_rounded,
                            tone: const Color(0xFF059669),
                          ),
                          InfoCard(
                            label: 'Facebook',
                            value: fb.toString(),
                            icon: Icons.facebook_rounded,
                            tone: const Color(0xFF2563EB),
                          ),
                      ],
                    )
                  else
                    Row(
                      children: [
                          Expanded(
                            child: InfoCard(
                              label: 'YouTube',
                              value: yt.toString(),
                              icon: Icons.play_circle_fill,
                              tone: const Color(0xFFDC2626),
                            ),
                          ),
                        const SizedBox(width: 12),
                          Expanded(
                            child: InfoCard(
                              label: 'TikTok',
                              value: tk.toString(),
                              icon: Icons.music_note_rounded,
                              tone: const Color(0xFF059669),
                            ),
                          ),
                        const SizedBox(width: 12),
                          Expanded(
                            child: InfoCard(
                              label: 'Facebook',
                              value: fb.toString(),
                              icon: Icons.facebook_rounded,
                              tone: const Color(0xFF2563EB),
                            ),
                          ),
                      ],
                    ),
                ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
