import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class PaymentSuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const PaymentSuccessDialog({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 60,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'تم الاشتراك بنجاح!',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'يمكنك الآن الوصول لجميع الكورسات',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              child: const Text(
                'ابدأ التعلم',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}