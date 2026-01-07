import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

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
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // ✅ correct
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: isLoading
            ? SizedBox(
          height: 28,
          width: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor:
            AlwaysStoppedAnimation<Color>(AppColors.white),
          ),
        )
            : Text(
          text,
          style: AppTextStyles.button,
        ),
      ),
    );
  }
}


