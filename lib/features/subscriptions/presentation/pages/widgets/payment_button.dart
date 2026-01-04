import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
class PaymentButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PaymentButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'الدفع',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
