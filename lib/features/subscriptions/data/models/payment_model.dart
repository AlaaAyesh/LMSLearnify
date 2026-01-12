/// Payment service types supported by the API
enum PaymentService {
  iap,     // In-App Purchase
  stripe,  // Stripe payment gateway
  wallet,  // Digital wallet
  kashier, // Kashier payment gateway
}

extension PaymentServiceExtension on PaymentService {
  String get value {
    switch (this) {
      case PaymentService.iap:
        return 'iap';
      case PaymentService.stripe:
        return 'stripe';
      case PaymentService.wallet:
        return 'wallet';
      case PaymentService.kashier:
        return 'kashier';
    }
  }

  static PaymentService fromString(String value) {
    switch (value.toLowerCase()) {
      case 'iap':
        return PaymentService.iap;
      case 'stripe':
        return PaymentService.stripe;
      case 'wallet':
        return PaymentService.wallet;
      case 'kashier':
        return PaymentService.kashier;
      default:
        return PaymentService.iap;
    }
  }
}

/// Payment status types
enum PaymentStatus {
  pending,
  completed,
  failed,
}

extension PaymentStatusExtension on PaymentStatus {
  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.completed:
        return 'completed';
      case PaymentStatus.failed:
        return 'failed';
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }
}

/// Request model for processing payment
class ProcessPaymentRequest {
  final PaymentService service;
  final String currency;
  final int? courseId;
  final int? subscriptionId;
  final String phone;
  final String? couponCode;

  ProcessPaymentRequest({
    required this.service,
    required this.currency,
    this.courseId,
    this.subscriptionId,
    required this.phone,
    this.couponCode,
  }) : assert(courseId != null || subscriptionId != null,
            'Either courseId or subscriptionId must be provided');

  Map<String, dynamic> toFormData() {
    final data = <String, dynamic>{
      'service': service.value,
      'currency': currency,
      'phone': phone,
    };

    if (courseId != null) {
      data['course_id'] = courseId;
    }

    if (subscriptionId != null) {
      data['subscription_id'] = subscriptionId;
    }

    if (couponCode != null && couponCode!.isNotEmpty) {
      data['coupon_code'] = couponCode;
    }

    return data;
  }
}

/// Purchase model returned from payment processing
class PurchaseModel {
  final int id;
  final int userId;
  final String purchasableType;
  final int purchasableId;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final PaymentService paymentService;
  final DateTime createdAt;
  final DateTime updatedAt;

  PurchaseModel({
    required this.id,
    required this.userId,
    required this.purchasableType,
    required this.purchasableId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paymentService,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    // Handle empty or null JSON gracefully
    if (json.isEmpty) {
      throw ArgumentError('Cannot create PurchaseModel from empty JSON');
    }
    
    return PurchaseModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      purchasableType: json['purchasable_type'] as String? ?? '',
      purchasableId: json['purchasable_id'] as int? ?? 0,
      status: PaymentStatusExtension.fromString(json['status'] as String? ?? 'pending'),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      paymentService: PaymentServiceExtension.fromString(json['payment_service'] as String? ?? 'iap'),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'purchasable_type': purchasableType,
      'purchasable_id': purchasableId,
      'status': status.value,
      'amount': amount,
      'currency': currency,
      'payment_service': paymentService.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if this is a course purchase
  bool get isCoursePurchase => purchasableType.contains('Course');

  /// Check if this is a subscription purchase
  bool get isSubscriptionPurchase => purchasableType.contains('Subscription');
}

/// Response model for payment processing
class PaymentResponseModel {
  final String status;
  final String message;
  final String? dataMessage;
  final PurchaseModel? purchase;
  final String? checkoutUrl;

  PaymentResponseModel({
    required this.status,
    required this.message,
    this.dataMessage,
    this.purchase,
    this.checkoutUrl,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    
    // Parse purchase if available
    PurchaseModel? purchaseModel;
    if (data?['purchase'] != null && data!['purchase'] is Map) {
      try {
        purchaseModel = PurchaseModel.fromJson(data['purchase'] as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing purchase: $e');
      }
    }
    
    return PaymentResponseModel(
      status: json['status'] as String? ?? 'success',
      message: json['message'] as String? ?? '',
      dataMessage: data?['message'] as String?,
      purchase: purchaseModel,
      checkoutUrl: data?['checkout_url']?.toString(),
    );
  }

  /// Check if payment was successfully initiated
  bool get isSuccess => status == 'success';
  
  /// Check if checkout URL is available (for redirecting to payment gateway)
  bool get hasCheckoutUrl => checkoutUrl != null && checkoutUrl!.isNotEmpty;
}



