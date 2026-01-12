import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // ✅ nullable
  final bool isLoading;
  final double? width;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed, // ✅ nullable
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: Responsive.height(context, height),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // ✅ correct
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(context, 22)),
          ),
          padding: Responsive.padding(context, horizontal: 24, vertical: 16),
        ),
        child: isLoading
            ? SizedBox(
          height: Responsive.height(context, 28),
          width: Responsive.width(context, 26),
          child: CircularProgressIndicator(
            strokeWidth: Responsive.width(context, 2.5),
            valueColor:
            AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        )
            : Text(
          text,
          style: AppTextStyles.button.copyWith(
            fontSize: Responsive.fontSize(context, AppTextStyles.button.fontSize ?? 16),
          ),
        ),
      ),
    );
  }
}


