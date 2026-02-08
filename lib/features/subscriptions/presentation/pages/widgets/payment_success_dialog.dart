import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_colors.dart';
import 'package:learnify_lms/core/utils/responsive.dart';
import 'package:learnify_lms/core/widgets/premium_subscription_popup.dart';

class PaymentSuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const PaymentSuccessDialog({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: PremiumDialogCard(
        showCloseButton: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.spacing(context, 16)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: Responsive.iconSize(context, 56),
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 16)),
            Text(
              'تم الاشتراك بنجاح!',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.spacing(context, 8)),
            Text(
              'يمكنك الآن الوصول لجميع الكورسات',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, 15),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.spacing(context, 24)),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onContinue,
                  borderRadius: BorderRadius.circular(Responsive.radius(context, 28)),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context, 14)),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(Responsive.radius(context, 28)),
                    ),
                    child: Center(
                      child: Text(
                        'ابدأ التعلم',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



