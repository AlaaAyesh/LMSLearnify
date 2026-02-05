import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';
import 'payment_method_icon.dart';

class PaymentMethodsRow extends StatelessWidget {
  const PaymentMethodsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = Responsive.screenWidth(context);
    final isNarrow = screenWidth < 340;
    final isTablet = Responsive.isTablet(context);
    final isLandscape = Responsive.isLandscape(context);

    return Padding(
      padding: Responsive.padding(context, horizontal: 12),
      child: isTablet
          ? isLandscape
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'طرق الدفع المتاحة',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 14),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PaymentMethodIcon(imagePath: 'assets/images/visa.png'),
                    const SizedBox(width: 6),
                    PaymentMethodIcon(
                      imagePath: 'assets/images/mastercard.png',
                      paymentName: "master card",
                    ),
                    const SizedBox(width: 6),
                    PaymentMethodIcon(
                      imagePath: 'assets/images/instaPay.png',
                      height: 20,
                      width: 20,
                    ),
                    const SizedBox(width: 6),
                    PaymentMethodIcon(imagePath: 'assets/images/vcash.png'),
                  ],
                )
              : Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'طرق الدفع المتاحة',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: Responsive.fontSize(context, 13),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    PaymentMethodIcon(
                      imagePath: 'assets/images/visa.png',
                      width: 22,
                      height: 22,
                    ),
                    PaymentMethodIcon(
                      imagePath: 'assets/images/mastercard.png',
                      paymentName: "master card",
                      width: 22,
                      height: 22,
                    ),
                    PaymentMethodIcon(
                      imagePath: 'assets/images/instaPay.png',
                      height: 18,
                      width: 18,
                    ),
                    PaymentMethodIcon(
                      imagePath: 'assets/images/vcash.png',
                      width: 22,
                      height: 22,
                    ),
                  ],
                )
          : Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: Responsive.width(context, 8),
        runSpacing: Responsive.spacing(context, 4),
        children: [
          Text(
            'طرق الدفع المتاحة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: Responsive.fontSize(context, isNarrow ? 10 : 12),
              color: AppColors.textSecondary,
            ),
          ),
          PaymentMethodIcon(imagePath: 'assets/images/visa.png'),
          PaymentMethodIcon(
            imagePath: 'assets/images/mastercard.png',
            paymentName: "master card",
          ),
          PaymentMethodIcon(
            imagePath: 'assets/images/instaPay.png',
            height: Responsive.height(context, 22),
            width: Responsive.width(context, 22),
          ),
          PaymentMethodIcon(imagePath: 'assets/images/vcash.png'),
        ],
      ),
    );
  }
}

