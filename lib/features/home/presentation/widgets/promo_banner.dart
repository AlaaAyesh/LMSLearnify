import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/theme/app_colors.dart';

class PromoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Responsive.margin(context, horizontal: 16),
      padding: Responsive.padding(context, all: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFC107),
            Color(0xFFFFD54F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Responsive.radius(context, 20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: Responsive.width(context, 12),
            offset: Offset(0, Responsive.height(context, 4)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: Responsive.fontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 8)),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: Responsive.fontSize(context, 14),
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          ElevatedButton(
            onPressed: onButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: Responsive.padding(context, horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
              ),
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




