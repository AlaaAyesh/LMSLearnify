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
    final isNarrow = Responsive.screenWidth(context) < 340;

    return SizedBox(
      width: Responsive.width(context, isNarrow ? 70 : 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Original price with strikethrough
          StrikethroughPrice(price: originalPrice),
          SizedBox(height: Responsive.spacing(context, 4)),

          // Discounted price
          Text(
            discountedPrice,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: Responsive.fontSize(context, isNarrow ? 13 : 15),
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}



