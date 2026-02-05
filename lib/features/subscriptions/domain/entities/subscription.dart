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
  final String? currency;
  final bool isActive;
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
    this.currency,
    this.isActive = false,
    this.createdAt,
    this.updatedAt,
  });

  String getName({bool isEnglish = false}) => isEnglish ? nameEn : nameAr;

  bool get hasDiscount {
    final currentPrice = double.tryParse(price) ?? 0;
    final originalPrice = double.tryParse(priceBeforeDiscount) ?? 0;
    return originalPrice > currentPrice;
  }

  int get discountPercentage {
    final currentPrice = double.tryParse(price) ?? 0;
    final originalPrice = double.tryParse(priceBeforeDiscount) ?? 0;
    if (originalPrice <= 0) return 0;
    return (((originalPrice - currentPrice) / originalPrice) * 100).round();
  }

  String getCurrencySymbol() {
    if (currency == null || currency!.isEmpty) {
      return 'جم';
    }
    switch (currency!.toUpperCase()) {
      case 'EGP':
        return 'جم';
      case 'USD':
        return '\$';
      default:
        return 'جم';
    }
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
        currency,
        isActive,
        createdAt,
        updatedAt,
      ];
}




