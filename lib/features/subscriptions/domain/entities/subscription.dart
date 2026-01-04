import 'package:equatable/equatable.dart';

class Subscription extends Equatable {
  final int id;
  final String nameAr;
  final String nameEn;
  final String price;
  final String usdPrice;
  final String priceBeforeDiscount;
  final String usdPriceBeforeDiscount;
  final int duration;
  final String? createdAt;
  final String? updatedAt;

  const Subscription({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.usdPrice,
    required this.priceBeforeDiscount,
    required this.usdPriceBeforeDiscount,
    required this.duration,
    this.createdAt,
    this.updatedAt,
  });

  /// Returns the name based on locale (defaults to Arabic)
  String getName({bool isEnglish = false}) => isEnglish ? nameEn : nameAr;

  /// Check if the subscription has a discount
  bool get hasDiscount {
    final currentPrice = double.tryParse(price) ?? 0;
    final originalPrice = double.tryParse(priceBeforeDiscount) ?? 0;
    return originalPrice > currentPrice;
  }

  /// Calculate discount percentage
  int get discountPercentage {
    final currentPrice = double.tryParse(price) ?? 0;
    final originalPrice = double.tryParse(priceBeforeDiscount) ?? 0;
    if (originalPrice <= 0) return 0;
    return (((originalPrice - currentPrice) / originalPrice) * 100).round();
  }

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        price,
        usdPrice,
        priceBeforeDiscount,
        usdPriceBeforeDiscount,
        duration,
        createdAt,
        updatedAt,
      ];
}


