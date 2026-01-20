import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/responsive.dart';
import 'payment_method_icon.dart';

class PaymentMethodsRow extends StatelessWidget {
  const PaymentMethodsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final isNarrow = Responsive.screenWidth(context) < 340;

    return Padding(
      padding: Responsive.padding(context, horizontal: 12),
      child: Wrap(
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

