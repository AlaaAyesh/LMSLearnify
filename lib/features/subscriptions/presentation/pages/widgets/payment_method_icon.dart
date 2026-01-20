import 'package:flutter/material.dart';

import '../../../../../core/utils/responsive.dart';

class PaymentMethodIcon extends StatelessWidget {
  final String imagePath;
  final String? paymentName;
  final double? width;
  final double? height;

  const PaymentMethodIcon({
    super.key,
    required this.imagePath,
    this.paymentName,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidth = width ?? Responsive.width(context, 26);
    final iconHeight = height ?? Responsive.height(context, 26);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (paymentName != null && paymentName!.isNotEmpty) ...[
          Text(
            paymentName!,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 11),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: Responsive.width(context, 2)),
        ],
        Image.asset(
          imagePath,
          width: iconWidth,
          height: iconHeight,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
