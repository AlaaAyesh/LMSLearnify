import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/strikethrough_price.dart';



class PriceSection extends StatelessWidget {
  final String originalPrice;
  final String discountedPrice;
  final String currency;
  final double? couponDiscountPercentage;
  final String? finalPriceAfterCoupon;

  const PriceSection({
    super.key,
    required this.originalPrice,
    required this.discountedPrice,
    required this.currency,
    this.couponDiscountPercentage,
    this.finalPriceAfterCoupon,
  });

  @override
  Widget build(BuildContext context) {

    final isNarrow = Responsive.screenWidth(context) < 340;
    final hasCouponDiscount = couponDiscountPercentage != null &&
                              couponDiscountPercentage! > 0 &&
                              finalPriceAfterCoupon != null;

    return SizedBox(
      width: Responsive.width(context, isNarrow ? 70 : 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          StrikethroughPrice(price: originalPrice),
          SizedBox(height: Responsive.spacing(context, 4)),

          if (hasCouponDiscount) ...[
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '$discountedPrice $currency',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: Responsive.fontSize(context, isNarrow ? 11 : 13),
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[600],
                  decoration: TextDecoration.lineThrough,
                  height: 1.1,

                ),
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 2)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.width(context, 6),
                vertical: Responsive.height(context, 2),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(Responsive.radius(context, 4)),
              ),
              child: Text(
                'خصم ${couponDiscountPercentage!.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: Responsive.fontSize(context, isNarrow ? 9 : 10),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: Responsive.spacing(context, 2)),
            Text(
              '$finalPriceAfterCoupon $currency',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, isNarrow ? 13 : 15),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50),
                height: 1.1,
              ),
            ),
          ] else ...[
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '$discountedPrice $currency',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: Responsive.fontSize(context, isNarrow ? 13 : 15),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}



