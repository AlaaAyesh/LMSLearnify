import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'payment_method_icon.dart';

class PaymentMethodsRow extends StatelessWidget {
  const PaymentMethodsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'طرق الدفع المتاحة',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 8),
        PaymentMethodIcon(imagePath: 'assets/images/visa.png'),
        PaymentMethodIcon(imagePath: 'assets/images/mastercard.png',paymentName: "master card"),
        PaymentMethodIcon(imagePath: 'assets/images/instaPay.png',height: 28,width: 28,),
        PaymentMethodIcon(imagePath: 'assets/images/vcash.png',),

      ],
    );
  }
}
