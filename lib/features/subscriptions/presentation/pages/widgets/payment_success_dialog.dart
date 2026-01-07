import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';


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
          SizedBox(height: 16),
          Text(
            'تم الاشتراك بنجاح!',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'يمكنك الآن الوصول لجميع الكورسات',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              child: Text(
                'ابدأ التعلم',
                style: TextStyle(fontFamily: cairoFontFamily),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



