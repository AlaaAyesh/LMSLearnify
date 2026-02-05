import 'package:equatable/equatable.dart';
import '../../data/models/payment_model.dart';
import '../../domain/entities/subscription.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionsLoaded extends SubscriptionState {
  final List<Subscription> subscriptions;
  final int selectedIndex;
  final String? appliedPromoCode;
  final double? discountAmount;
  final double? discountPercentage;
  final String? finalPriceAfterCoupon;

  const SubscriptionsLoaded({
    required this.subscriptions,
    this.selectedIndex = 0,
    this.appliedPromoCode,
    this.discountAmount,
    this.discountPercentage,
    this.finalPriceAfterCoupon,
  });

  SubscriptionsLoaded copyWith({
    List<Subscription>? subscriptions,
    int? selectedIndex,
    String? appliedPromoCode,
    double? discountAmount,
    double? discountPercentage,
    String? finalPriceAfterCoupon,
  }) {
    return SubscriptionsLoaded(
      subscriptions: subscriptions ?? this.subscriptions,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      finalPriceAfterCoupon: finalPriceAfterCoupon ?? this.finalPriceAfterCoupon,
    );
  }

  Subscription? get selectedSubscription {
    if (subscriptions.isEmpty || selectedIndex >= subscriptions.length) {
      return null;
    }
    return subscriptions[selectedIndex];
  }

  @override
  List<Object?> get props => [
        subscriptions,
        selectedIndex,
        appliedPromoCode,
        discountAmount,
        discountPercentage,
        finalPriceAfterCoupon,
      ];
}

class SubscriptionDetailsLoaded extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionDetailsLoaded({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

class SubscriptionsEmpty extends SubscriptionState {}

class SubscriptionCreated extends SubscriptionState {
  final Subscription subscription;
  final String message;

  const SubscriptionCreated({
    required this.subscription,
    this.message = 'تم إنشاء الاشتراك بنجاح',
  });

  @override
  List<Object?> get props => [subscription, message];
}

class SubscriptionUpdated extends SubscriptionState {
  final Subscription subscription;
  final String message;

  const SubscriptionUpdated({
    required this.subscription,
    this.message = 'تم تحديث الاشتراك بنجاح',
  });

  @override
  List<Object?> get props => [subscription, message];
}

class PromoCodeApplied extends SubscriptionState {
  final String promoCode;
  final double discountAmount;
  final double? discountPercentage;
  final String message;

  const PromoCodeApplied({
    required this.promoCode,
    required this.discountAmount,
    this.discountPercentage,
    this.message = 'تم تطبيق كود الخصم بنجاح',
  });

  @override
  List<Object?> get props => [promoCode, discountAmount, discountPercentage, message];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentProcessing extends SubscriptionState {}

class PaymentInitiated extends SubscriptionState {
  final PurchaseModel? purchase;
  final String message;

  const PaymentInitiated({
    this.purchase,
    this.message = 'تم بدء عملية الدفع بنجاح',
  });

  @override
  List<Object?> get props => [purchase, message];
}

class PaymentCheckoutReady extends SubscriptionState {
  final String checkoutUrl;
  final String message;

  const PaymentCheckoutReady({
    required this.checkoutUrl,
    this.message = 'تم بدء عملية الدفع',
  });

  @override
  List<Object?> get props => [checkoutUrl, message];
}

class PaymentCompleted extends SubscriptionState {
  final PurchaseModel? purchase;
  final String message;

  const PaymentCompleted({
    this.purchase,
    this.message = 'تمت عملية الدفع بنجاح',
  });

  @override
  List<Object?> get props => [purchase, message];
}

class PaymentFailed extends SubscriptionState {
  final String message;

  const PaymentFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class IapVerificationLoading extends SubscriptionState {}

class IapVerificationSuccess extends SubscriptionState {}

class IapVerificationFailure extends SubscriptionState {
  final String message;
  IapVerificationFailure(this.message);
}

