import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class PaymentMethodIcon extends StatelessWidget {
  final String imagePath;
  final String? paymentName;
  final double?width;
  final double?height;
  const PaymentMethodIcon({
    super.key,
    required this.imagePath,
    this.paymentName, this.width, this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(paymentName??"",
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold
          ),
        ),
        SizedBox(width: 4,),
        Image.asset(
          imagePath,
          width:width?? 32,
          height: height??32,
          fit: BoxFit.contain,
        ),


      ],
    );
  }
}


