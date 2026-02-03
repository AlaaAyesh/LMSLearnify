import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';


class RecommendedBadge extends StatelessWidget {
  const RecommendedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
    final screenWidth = Responsive.screenWidth(context);
    
    // جعل موضع البادجت responsive بناءً على عرض الشاشة
    final double topOffset = isTablet 
        ? -Responsive.height(context, 12) 
        : -Responsive.height(context, 10);
    final double rightOffset = (screenWidth * 0.06).clamp(16.0, 32.0).toDouble();

    return Positioned(
      top: topOffset,
      right: rightOffset,
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



