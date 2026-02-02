import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);
    final double buttonFontSize =
        isTablet ? Responsive.fontSize(context, 18) : Responsive.fontSize(context, 20);

    return Container(
      width: width ?? double.infinity,
      height: Responsive.height(context, height),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Responsive.radius(context, 22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(context, 22)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.spacing(context, 16),
            vertical: Responsive.spacing(context, 0),
          ),
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
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}