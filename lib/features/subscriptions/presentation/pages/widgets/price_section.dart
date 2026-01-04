import 'package:flutter/material.dart';
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
      height: 55,
      width: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: StrikethroughPrice(price: originalPrice),
          ),
          Positioned(
            bottom: 4,
            left: 0,
            child: Text(
              ' ج.م$discountedPrice',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
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
