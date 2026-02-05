import 'package:flutter/material.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/plan_details_section.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/price_section.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/recommended_badge.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/active_badge.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../domain/entities/card_color.dart';
import '../../../domain/entities/subscription_plan.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  final double? couponDiscountPercentage;
  final String? finalPriceAfterCoupon;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    this.couponDiscountPercentage,
    this.finalPriceAfterCoupon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getCardColors();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(minHeight: Responsive.height(context, 70)),
            padding: Responsive.padding(context, horizontal: 22),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(Responsive.radius(context, 26)),
              border: Border.all(color: colors.border, width: Responsive.width(context, 1)),

            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  child: PlanDetailsSection(
                    title: plan.title,
                    description: plan.description,
                    isSelected: isSelected,
                  ),
                ),
                SizedBox(width: Responsive.width(context, 8)),
                PriceSection(
                  originalPrice: plan.originalPrice,
                  discountedPrice: plan.discountedPrice,
                  currency: plan.currency,
                  finalPriceAfterCoupon: finalPriceAfterCoupon,
                ),
              ],
            ),
          ),
          if (plan.isActive) const ActiveBadge()
          else if (plan.isRecommended) const RecommendedBadge(),
        ],
      ),
    );
  }

  CardColors _getCardColors() {
    if (isSelected) {
      return CardColors(
        background: const Color(0xFFFEEDBE).withOpacity(0.70),
        border: Colors.black,
      );
    } else {
      return CardColors(
        background: const Color(0xFFFEFEFE).withOpacity(0.4),
        border: Colors.black,
      );
    }
  }
}


