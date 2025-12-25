// lib/widgets/daily_stats_card.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DailyStatsCard extends StatelessWidget {
  const DailyStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 1280;
    final s = scale.clamp(0.8, 1.4);

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

        return Container(
          padding: EdgeInsets.all(16 * s),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20 * s),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today Downloads (24h)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * s,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12 * s),
              Row(
                children: [
                  _buildChip('YouTube', yt, Colors.redAccent, s),
                  SizedBox(width: 10 * s),
                  _buildChip('TikTok', tk, Colors.greenAccent, s),
                  SizedBox(width: 10 * s),
                  _buildChip('Facebook', fb, Colors.blueAccent, s),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, int value, Color color, double s) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10 * s, horizontal: 12 * s),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14 * s),
          border: Border.all(color: color.withOpacity(0.6), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12 * s,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4 * s),
            Text(
              value.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18 * s,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
