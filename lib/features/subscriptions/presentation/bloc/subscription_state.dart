import 'package:equatable/equatable.dart';
import '../../domain/entities/subscription.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SubscriptionInitial extends SubscriptionState {}

/// Loading state
class SubscriptionLoading extends SubscriptionState {}

/// Subscriptions loaded successfully
class SubscriptionsLoaded extends SubscriptionState {
  final List<Subscription> subscriptions;
  final int selectedIndex;
  final String? appliedPromoCode;
  final double? discountAmount;

  const SubscriptionsLoaded({
    required this.subscriptions,
    this.selectedIndex = 0,
    this.appliedPromoCode,
    this.discountAmount,
  });

  SubscriptionsLoaded copyWith({
    List<Subscription>? subscriptions,
    int? selectedIndex,
    String? appliedPromoCode,
    double? discountAmount,
  }) {
    return SubscriptionsLoaded(
      subscriptions: subscriptions ?? this.subscriptions,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }

  /// Get the currently selected subscription
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
      ];
}

/// Single subscription loaded (for details view)
class SubscriptionDetailsLoaded extends SubscriptionState {
  final Subscription subscription;

  const SubscriptionDetailsLoaded({required this.subscription});

  @override
  List<Object?> get props => [subscription];
}

/// No subscriptions available
class SubscriptionsEmpty extends SubscriptionState {}

/// Subscription created successfully
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

/// Subscription updated successfully
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

/// Promo code applied successfully
class PromoCodeApplied extends SubscriptionState {
  final String promoCode;
  final double discountAmount;
  final String message;

  const PromoCodeApplied({
    required this.promoCode,
    required this.discountAmount,
    this.message = 'تم تطبيق كود الخصم بنجاح',
  });

  @override
  List<Object?> get props => [promoCode, discountAmount, message];
}

/// Error state
class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}


