import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/theme/app_colors.dart';
class PaymentButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PaymentButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Responsive.height(context, 56),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
          ),
        ),
        child: Text(
          'الدفع',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: Responsive.fontSize(context, 18),
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}



