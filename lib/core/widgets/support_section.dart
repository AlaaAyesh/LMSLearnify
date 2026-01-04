import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/subscriptions/presentation/pages/widgets/payment_method_icon.dart';

class SupportSection extends StatelessWidget {
  final VoidCallback? onTap;

  const SupportSection({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'لديك مشاكل أو استفسارات ؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                'تواصل معنا من هنا',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 6),
              PaymentMethodIcon(
                imagePath: 'assets/images/whatsapp.png',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
