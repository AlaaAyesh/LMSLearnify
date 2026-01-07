import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';


class RecommendedBadge extends StatelessWidget {
  const RecommendedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -10,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB24BF3), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'الأكثر مبيعاً',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}



