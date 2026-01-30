/// Payment service types supported by the API
enum PaymentService {
  gplay,   // Google Play (Android IAP)
  iap,     // In-App Purchase
  stripe,  // Stripe payment gateway
  wallet,  // Digital wallet
  kashier, // Kashier payment gateway
}

extension PaymentServiceExtension on PaymentService {
  String get value {
    switch (this) {
      case PaymentService.gplay:
        return 'gplay';
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
      case 'gplay':
        return PaymentService.gplay;
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
      case 'success': // API returns "success" for completed transactions
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
  final Map<String, dynamic>? subscriptionData; // For free subscriptions (100% coupon)

  PaymentResponseModel({
    required this.status,
    required this.message,
    this.dataMessage,
    this.purchase,
    this.checkoutUrl,
    this.subscriptionData,
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
    
    // Parse subscription if available (for free subscriptions with 100% coupon)
    Map<String, dynamic>? subscriptionData;
    if (data?['subscription'] != null && data!['subscription'] is Map) {
      subscriptionData = data['subscription'] as Map<String, dynamic>;
    } else if (data != null && data.containsKey('id') && !data.containsKey('checkout_url') && purchaseModel == null) {
      // If data itself is subscription object (no checkout_url, no purchase)
      subscriptionData = data;
    }
    
    return PaymentResponseModel(
      status: json['status'] as String? ?? 'success',
      message: json['message'] as String? ?? '',
      dataMessage: data?['message'] as String?,
      purchase: purchaseModel,
      checkoutUrl: data?['checkout_url']?.toString(),
      subscriptionData: subscriptionData,
    );
  }

  /// Check if payment was successfully initiated
  bool get isSuccess => status == 'success';
  
  /// Check if checkout URL is available (for redirecting to payment gateway)
  bool get hasCheckoutUrl => checkoutUrl != null && checkoutUrl!.isNotEmpty;
  
  /// Check if this is a free subscription (100% coupon) - no payment needed
  bool get isFreeSubscription => subscriptionData != null && !hasCheckoutUrl && purchase == null;
}

/// Transaction model for user transactions
class TransactionModel {
  final int id;
  final int userId;
  final String purchasableType;
  final String? purchasableName;
  final int purchasableId;
  final String amount;
  final String currency;
  final String? transactionId;
  final PaymentService paymentService;
  final PaymentStatus status;
  final String? receiptPath;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.purchasableType,
    this.purchasableName,
    required this.purchasableId,
    required this.amount,
    required this.currency,
    this.transactionId,
    required this.paymentService,
    required this.status,
    this.receiptPath,
    this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      purchasableType: json['purchasable_type'] as String? ?? '',
      purchasableName: json['purchasable_name'] as String?,
      purchasableId: json['purchasable_id'] as int? ?? 0,
      amount: json['amount']?.toString() ?? '0',
      currency: json['currency'] as String? ?? 'EGP',
      transactionId: json['transaction_id'] as String?,
      paymentService: PaymentServiceExtension.fromString(json['payment_service'] as String? ?? 'kashier'),
      status: PaymentStatusExtension.fromString(json['status'] as String? ?? 'pending'),
      receiptPath: json['receipt_path'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Check if this is a subscription transaction
  bool get isSubscriptionTransaction => purchasableType.contains('Subscription');

  /// Check if this is a successful subscription transaction
  bool get isSuccessfulSubscription => isSubscriptionTransaction && status == PaymentStatus.completed;
}

/// Response model for transactions list
class TransactionsResponseModel {
  final List<TransactionModel> transactions;
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  TransactionsResponseModel({
    required this.transactions,
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory TransactionsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return TransactionsResponseModel(
      transactions: data
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: meta['total'] as int? ?? 0,
      perPage: meta['per_page'] as int? ?? 10,
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      nextPageUrl: meta['next_page_url'] as String?,
      prevPageUrl: meta['prev_page_url'] as String?,
    );
  }

  /// Get the most recent successful subscription transaction
  TransactionModel? get activeSubscriptionTransaction {
    final subscriptionTransactions = transactions
        .where((t) => t.isSuccessfulSubscription)
        .toList();
    
    if (subscriptionTransactions.isEmpty) return null;
    
    // Sort by created_at descending and return the most recent
    subscriptionTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return subscriptionTransactions.first;
  }
}



