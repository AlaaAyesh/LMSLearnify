import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/theme/app_colors.dart';

class PaymentButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PaymentButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: Responsive.height(context, 64),
      decoration: BoxDecoration(
        color: const Color(0xFFFFBB00),
        borderRadius: BorderRadius.circular(Responsive.radius(context, 16)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x806B46C1), // #6B46C180
            blurRadius: 7,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(context, 16)),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.width(context, 12),
          ),
        ),
        child: Text(
          'الدفع',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: Responsive.fontSize(context, 18),
            height: 28 / 18, // line-height
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}