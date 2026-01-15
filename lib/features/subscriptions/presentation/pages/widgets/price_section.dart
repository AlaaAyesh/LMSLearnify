import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/strikethrough_price.dart';



class PriceSection extends StatelessWidget {
  final String originalPrice;
  final String discountedPrice;
  final String currency;

  const PriceSection({
    super.key,
    required this.originalPrice,
    required this.discountedPrice,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.height(context, 55),
      width: Responsive.width(context, 80),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: StrikethroughPrice(price: originalPrice),
          ),
          Positioned(
            bottom: Responsive.height(context, 4),
            left: 0,
            child: Text(
              ' ج.م$discountedPrice',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



