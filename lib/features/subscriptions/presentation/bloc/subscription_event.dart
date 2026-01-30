import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/subscription_model.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

/// Load all subscriptions
class LoadSubscriptionsEvent extends SubscriptionEvent {
  const LoadSubscriptionsEvent();
}

/// Load a specific subscription by ID
class LoadSubscriptionByIdEvent extends SubscriptionEvent {
  final int id;

  const LoadSubscriptionByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Select a subscription plan
class SelectSubscriptionEvent extends SubscriptionEvent {
  final int index;

  const SelectSubscriptionEvent({required this.index});

  @override
  List<Object?> get props => [index];
}

/// Apply a promo code
class ApplyPromoCodeEvent extends SubscriptionEvent {
  final String promoCode;

  const ApplyPromoCodeEvent({required this.promoCode});

  @override
  List<Object?> get props => [promoCode];
}

/// Create a new subscription (admin only)
class CreateSubscriptionEvent extends SubscriptionEvent {
  final CreateSubscriptionRequest request;

  const CreateSubscriptionEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

/// Update an existing subscription (admin only)
class UpdateSubscriptionEvent extends SubscriptionEvent {
  final int id;
  final UpdateSubscriptionRequest request;

  const UpdateSubscriptionEvent({
    required this.id,
    required this.request,
  });

  @override
  List<Object?> get props => [id, request];
}

/// Clear subscription state
class ClearSubscriptionStateEvent extends SubscriptionEvent {
  const ClearSubscriptionStateEvent();
}

/// Process a payment
class ProcessPaymentEvent extends SubscriptionEvent {
  final PaymentService service;
  final String currency;
  final int? courseId;
  final int? subscriptionId;
  final String phone;
  final String? couponCode;

  const ProcessPaymentEvent({
    required this.service,
    required this.currency,
    this.courseId,
    this.subscriptionId,
    required this.phone,
    this.couponCode,
  });

  @override
  List<Object?> get props => [service, currency, courseId, subscriptionId, phone, couponCode];
}

class VerifyIapReceiptEvent extends SubscriptionEvent {
  final String receiptData;
  final String transactionId;
  final int purchaseId;
  final String store;
  final PurchaseDetails? purchaseDetails; // لإكمال الشراء بعد التحقق

  VerifyIapReceiptEvent({
    required this.receiptData,
    required this.transactionId,
    required this.purchaseId,
    required this.store,
    this.purchaseDetails,
  });

  @override
  List<Object?> get props => [receiptData, transactionId, purchaseId, store, purchaseDetails];
}

