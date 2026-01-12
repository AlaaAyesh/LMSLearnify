import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';


class RecommendedBadge extends StatelessWidget {
  const RecommendedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -Responsive.height(context, 10),
      right: Responsive.width(context, 20),
      child: Container(
        padding: Responsive.padding(context, horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB24BF3), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
        ),
        child: Text(
          'الأكثر مبيعاً',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: Responsive.fontSize(context, 10),
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}



