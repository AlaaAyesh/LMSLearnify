import '../../domain/entities/subscription.dart';

class SubscriptionModel extends Subscription {
  const SubscriptionModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.price,
    required super.usdPrice,
    required super.priceBeforeDiscount,
    required super.usdPriceBeforeDiscount,
    required super.duration,
    super.createdAt,
    super.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] ?? 0,
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      price: _parsePrice(json['price']),
      usdPrice: _parsePrice(json['usd_price']),
      priceBeforeDiscount: _parsePrice(json['price_before_discount']),
      usdPriceBeforeDiscount: _parsePrice(json['usd_price_before_discount']),
      duration: json['duration'] is String
          ? int.tryParse(json['duration']) ?? 0
          : json['duration'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  static String _parsePrice(dynamic value) {
    if (value == null) return '0';
    if (value is String) return value;
    if (value is num) return value.toString();
    return '0';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'price': price,
      'usd_price': usdPrice,
      'price_before_discount': priceBeforeDiscount,
      'usd_price_before_discount': usdPriceBeforeDiscount,
      'duration': duration,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

/// Request model for creating a subscription
class CreateSubscriptionRequest {
  final String nameAr;
  final String nameEn;
  final double price;
  final double priceBeforeDiscount;
  final double usdPrice;
  final double usdPriceBeforeDiscount;
  final int duration;

  const CreateSubscriptionRequest({
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.priceBeforeDiscount,
    required this.usdPrice,
    required this.usdPriceBeforeDiscount,
    required this.duration,
  });

  Map<String, dynamic> toFormData() {
    return {
      'name_ar': nameAr,
      'name_en': nameEn,
      'price': price,
      'price_before_discount': priceBeforeDiscount,
      'usd_price': usdPrice,
      'usd_price_before_discount': usdPriceBeforeDiscount,
      'duration': duration,
    };
  }
}

/// Request model for updating a subscription
class UpdateSubscriptionRequest {
  final String? nameAr;
  final String? nameEn;
  final double? price;
  final double? priceBeforeDiscount;
  final double? usdPrice;
  final double? usdPriceBeforeDiscount;
  final int? duration;
  final int? specialtyId;

  const UpdateSubscriptionRequest({
    this.nameAr,
    this.nameEn,
    this.price,
    this.priceBeforeDiscount,
    this.usdPrice,
    this.usdPriceBeforeDiscount,
    this.duration,
    this.specialtyId,
  });

  Map<String, dynamic> toFormData() {
    final map = <String, dynamic>{
      '_method': 'PUT',
    };
    
    if (nameAr != null) map['name_ar'] = nameAr;
    if (nameEn != null) map['name_en'] = nameEn;
    if (price != null) map['price'] = price;
    if (priceBeforeDiscount != null) map['price_before_discount'] = priceBeforeDiscount;
    if (usdPrice != null) map['usd_price'] = usdPrice;
    if (usdPriceBeforeDiscount != null) map['usd_price_before_discount'] = usdPriceBeforeDiscount;
    if (duration != null) map['duration'] = duration;
    if (specialtyId != null) map['specialty_id'] = specialtyId;
    
    return map;
  }
}


