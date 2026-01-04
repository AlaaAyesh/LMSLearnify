class SubscriptionPlan {
  final String title;
  final String originalPrice;
  final String discountedPrice;
  final String currency;
  final String description;
  final bool isRecommended;

  const SubscriptionPlan({
    required this.title,
    required this.originalPrice,
    required this.discountedPrice,
    required this.currency,
    required this.description,
    this.isRecommended = false,
  });
}