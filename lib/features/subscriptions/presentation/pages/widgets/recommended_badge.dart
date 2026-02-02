import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';


class RecommendedBadge extends StatelessWidget {
  const RecommendedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);

    return Positioned(
      // في التابلت نقلل الإزاحة للأعلى ونحافظ على موضع مناسب على الحافة اليمنى
      top: isTablet ? -12 : -Responsive.height(context, 10),
      right: isTablet ? 24 : Responsive.width(context, 20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 16 : 12,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB24BF3), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(isTablet ? 14 : Responsive.radius(context, 12)),
        ),
        child: Text(
          'الأكثر مبيعاً',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: isTablet ? Responsive.fontSize(context, 11) : Responsive.fontSize(context, 10),
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}



