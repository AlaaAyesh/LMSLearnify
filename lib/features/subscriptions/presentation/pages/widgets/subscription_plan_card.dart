import 'package:flutter/material.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/plan_details_section.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/price_section.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/recommended_badge.dart';
import '../../../domain/entities/card_color.dart';
import '../../../domain/entities/subscription_plan.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
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
            constraints: const BoxConstraints(minHeight: 70),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: colors.border, width: 1),

            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                PlanDetailsSection(
                  title: plan.title,
                  description: plan.description,
                  isSelected: isSelected,
                ),
                const Spacer(),
                PriceSection(
                  originalPrice: plan.originalPrice,
                  discountedPrice: plan.discountedPrice,
                  currency: plan.currency,
                ),
              ],
            ),
          ),
          if (plan.isRecommended) const RecommendedBadge(),
        ],
      ),
    );
  }

  CardColors _getCardColors() {
    if (isSelected) {
      // Yellow/golden color for selected card
      return CardColors(
        background: const Color(0xFFFFF4DC).withOpacity(0.70),
        border: const Color(0xFFE6C068),
      );
    } else {
      // Normal white/grey for unselected cards
      return CardColors(
        background: const Color(0xFFFEFEFE).withOpacity(0.4),
        border: Colors.black,
      );
    }
  }
}