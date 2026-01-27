import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/payment_model.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/usecases/create_subscription_usecase.dart';
import '../../domain/usecases/get_subscription_by_id_usecase.dart';
import '../../domain/usecases/get_subscriptions_usecase.dart';
import '../../domain/usecases/update_subscription_usecase.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final GetSubscriptionsUseCase getSubscriptionsUseCase;
  final GetSubscriptionByIdUseCase getSubscriptionByIdUseCase;
  final CreateSubscriptionUseCase createSubscriptionUseCase;
  final UpdateSubscriptionUseCase updateSubscriptionUseCase;
  final SubscriptionRepository subscriptionRepository;

  SubscriptionBloc({
    required this.getSubscriptionsUseCase,
    required this.getSubscriptionByIdUseCase,
    required this.createSubscriptionUseCase,
    required this.updateSubscriptionUseCase,
    required this.subscriptionRepository,
  }) : super(SubscriptionInitial()) {
    on<LoadSubscriptionsEvent>(_onLoadSubscriptions);
    on<LoadSubscriptionByIdEvent>(_onLoadSubscriptionById);
    on<SelectSubscriptionEvent>(_onSelectSubscription);
    on<ApplyPromoCodeEvent>(_onApplyPromoCode);
    on<CreateSubscriptionEvent>(_onCreateSubscription);
    on<UpdateSubscriptionEvent>(_onUpdateSubscription);
    on<ClearSubscriptionStateEvent>(_onClearState);
    on<ProcessPaymentEvent>(_onProcessPayment);
  }

  Future<void> _onLoadSubscriptions(
    LoadSubscriptionsEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    final result = await getSubscriptionsUseCase();

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscriptions) {
        if (subscriptions.isEmpty) {
          emit(SubscriptionsEmpty());
        } else {
          // Find recommended plan (longest duration) or default to first
          int recommendedIndex = 0;
          int maxDuration = 0;
          for (int i = 0; i < subscriptions.length; i++) {
            if (subscriptions[i].duration > maxDuration) {
              maxDuration = subscriptions[i].duration;
              recommendedIndex = i;
            }
          }
          emit(SubscriptionsLoaded(
            subscriptions: subscriptions,
            selectedIndex: recommendedIndex,
          ));
        }
      },
    );
  }

  Future<void> _onLoadSubscriptionById(
    LoadSubscriptionByIdEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    final result = await getSubscriptionByIdUseCase(id: event.id);

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscription) => emit(SubscriptionDetailsLoaded(subscription: subscription)),
    );
  }

  void _onSelectSubscription(
    SelectSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) {
    final currentState = state;
    if (currentState is SubscriptionsLoaded) {
      final newSelectedSubscription = event.index < currentState.subscriptions.length
          ? currentState.subscriptions[event.index]
          : null;
      
      // If coupon is applied, recalculate discount for the new subscription
      if (currentState.appliedPromoCode != null && 
          currentState.appliedPromoCode!.isNotEmpty &&
          currentState.discountPercentage != null &&
          newSelectedSubscription != null) {
        final currentPrice = double.tryParse(newSelectedSubscription.price) ?? 0.0;
        final discountPercentage = currentState.discountPercentage!;
        final discountAmount = (currentPrice * discountPercentage / 100);
        final finalPrice = currentPrice - discountAmount;
        final finalPriceString = finalPrice.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
        
        emit(currentState.copyWith(
          selectedIndex: event.index,
          discountAmount: discountAmount,
          finalPriceAfterCoupon: finalPriceString,
        ));
      } else {
        emit(currentState.copyWith(selectedIndex: event.index));
      }
    }
  }

  Future<void> _onApplyPromoCode(
    ApplyPromoCodeEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    final currentState = state;
    if (currentState is SubscriptionsLoaded) {
      final selectedSubscription = currentState.selectedSubscription;
      
      if (selectedSubscription == null) {
        emit(SubscriptionError('يرجى اختيار باقة أولاً'));
        return;
      }

      if (event.promoCode.isEmpty) {
        emit(SubscriptionError('يرجى إدخال كود الخصم'));
        return;
      }

      // Validate coupon via API
      final result = await subscriptionRepository.validateCoupon(
        code: event.promoCode,
        type: 'subscription',
        id: selectedSubscription.id,
      );

      result.fold(
        (failure) {
          emit(SubscriptionError(failure.message));
          // Return to loaded state after error
          if (state is SubscriptionError) {
            emit(currentState);
          }
        },
        (validationResult) {
          // Extract discount information from API response
          // API may return data in 'data' field or directly
          print('Coupon validation result: $validationResult'); // Debug log
          
          // Check if data is nested in 'data' field
          Map<String, dynamic> responseData;
          if (validationResult['data'] != null && validationResult['data'] is Map) {
            responseData = validationResult['data'] as Map<String, dynamic>;
          } else {
            responseData = validationResult is Map<String, dynamic> 
                ? validationResult 
                : <String, dynamic>{};
          }
          
          // Try different possible field names
          final discountPercentage = responseData['discount_percentage'] != null
              ? (responseData['discount_percentage'] is num
                  ? responseData['discount_percentage'].toDouble()
                  : double.tryParse(responseData['discount_percentage'].toString()) ?? 0.0)
              : (responseData['percentage'] != null
                  ? (responseData['percentage'] is num
                      ? responseData['percentage'].toDouble()
                      : double.tryParse(responseData['percentage'].toString()) ?? 0.0)
                  : null);
          
          final discountAmount = responseData['discount_amount'] != null
              ? (responseData['discount_amount'] is num
                  ? responseData['discount_amount'].toDouble()
                  : double.tryParse(responseData['discount_amount'].toString()) ?? 0.0)
              : (responseData['discount'] != null
                  ? (responseData['discount'] is num
                      ? responseData['discount'].toDouble()
                      : double.tryParse(responseData['discount'].toString()) ?? 0.0)
                  : null);

          final discountType = responseData['discount_type']?.toString().toLowerCase() ?? 
                              responseData['type']?.toString().toLowerCase() ?? 
                              'percentage';
          
          print('Extracted discount_percentage: $discountPercentage, discount_amount: $discountAmount, discount_type: $discountType');
          
          // Calculate final price after coupon discount
          final currentPrice = double.tryParse(selectedSubscription.price) ?? 0.0;
          double finalPrice = currentPrice;
          double? calculatedDiscountPercentage;
          double calculatedDiscountAmount = 0.0;

          if (discountType == 'percentage' && discountPercentage != null && discountPercentage > 0) {
            // Percentage-based discount
            calculatedDiscountPercentage = discountPercentage;
            calculatedDiscountAmount = (currentPrice * discountPercentage / 100);
            finalPrice = currentPrice - calculatedDiscountAmount;
          } else if (discountType == 'fixed' && discountAmount != null && discountAmount > 0) {
            // Fixed amount discount
            calculatedDiscountAmount = discountAmount;
            finalPrice = currentPrice - discountAmount;
            if (finalPrice < 0) finalPrice = 0;
            // Calculate percentage for display
            calculatedDiscountPercentage = currentPrice > 0 
                ? ((discountAmount / currentPrice) * 100) 
                : 0.0;
          } else if (discountPercentage != null && discountPercentage > 0) {
            // Fallback: use percentage if available
            calculatedDiscountPercentage = discountPercentage;
            calculatedDiscountAmount = (currentPrice * discountPercentage / 100);
            finalPrice = currentPrice - calculatedDiscountAmount;
          } else if (discountAmount != null && discountAmount > 0) {
            // Fallback: use fixed amount if available
            calculatedDiscountAmount = discountAmount;
            finalPrice = currentPrice - discountAmount;
            if (finalPrice < 0) finalPrice = 0;
            calculatedDiscountPercentage = currentPrice > 0 
                ? ((discountAmount / currentPrice) * 100) 
                : 0.0;
          } else {
            // If no discount info in response, assume 10% discount as fallback (or you can remove this)
            // For now, we'll just mark coupon as applied but with 0 discount
            // This means the API validated the coupon but didn't provide discount info
            print('Warning: Coupon validated but no discount info found in response');
          }

          // Format final price to string (preserve decimal places if needed)
          final finalPriceString = finalPrice.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');

          print('Calculated discount: ${calculatedDiscountPercentage}%, Amount: $calculatedDiscountAmount, Final price: $finalPriceString');

          // Update state with coupon information
          final updatedState = currentState.copyWith(
            appliedPromoCode: event.promoCode,
            discountAmount: calculatedDiscountAmount,
            discountPercentage: calculatedDiscountPercentage,
            finalPriceAfterCoupon: finalPriceString,
          );
          emit(updatedState);
          
          // Emit success state for UI feedback
          emit(PromoCodeApplied(
            promoCode: event.promoCode,
            discountAmount: calculatedDiscountAmount,
            discountPercentage: calculatedDiscountPercentage,
            message: calculatedDiscountPercentage != null && calculatedDiscountPercentage > 0
                ? 'تم تطبيق كود الخصم بنجاح - خصم ${calculatedDiscountPercentage.toStringAsFixed(0)}%'
                : 'تم تطبيق كود الخصم بنجاح',
          ));
          
          // Return to loaded state after showing success message
          emit(updatedState);
        },
      );
    }
  }

  Future<void> _onCreateSubscription(
    CreateSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    final result = await createSubscriptionUseCase(request: event.request);

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscription) => emit(SubscriptionCreated(subscription: subscription)),
    );
  }

  Future<void> _onUpdateSubscription(
    UpdateSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());

    final result = await updateSubscriptionUseCase(
      id: event.id,
      request: event.request,
    );

    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscription) => emit(SubscriptionUpdated(subscription: subscription)),
    );
  }

  void _onClearState(
    ClearSubscriptionStateEvent event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(SubscriptionInitial());
  }

  Future<void> _onProcessPayment(
    ProcessPaymentEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(PaymentProcessing());

    // Check if this is a free subscription (100% coupon)
    final currentState = state;
    double finalPrice = 0.0;
    if (currentState is SubscriptionsLoaded && 
        currentState.finalPriceAfterCoupon != null) {
      finalPrice = double.tryParse(currentState.finalPriceAfterCoupon!) ?? 0.0;
    } else if (event.subscriptionId != null) {
      // Get subscription price from state
      if (currentState is SubscriptionsLoaded) {
        final subscription = currentState.subscriptions.firstWhere(
          (s) => s.id == event.subscriptionId,
          orElse: () => currentState.subscriptions.first,
        );
        finalPrice = double.tryParse(subscription.price) ?? 0.0;
      }
    }

    final request = ProcessPaymentRequest(
      service: event.service,
      currency: event.currency,
      courseId: event.courseId,
      subscriptionId: event.subscriptionId,
      phone: event.phone,
      couponCode: event.couponCode,
    );

    final result = await subscriptionRepository.processPayment(request: request);

    result.fold(
      (failure) => emit(PaymentFailed(failure.message)),
      (response) {
        if (response.isSuccess) {
          // Check if this is a free subscription (100% coupon) - API returns subscription object directly
          if (response.isFreeSubscription || (finalPrice == 0 && response.subscriptionData != null)) {
            // Free subscription activated directly - no payment needed
            print('Free subscription activated: ${response.subscriptionData}');
            emit(PaymentCompleted(
              purchase: null, // No purchase for free subscriptions
              message: response.dataMessage ?? response.message ?? 'تم تفعيل الاشتراك بنجاح',
            ));
          } else if (response.hasCheckoutUrl) {
            // Check if checkout URL is available (for payment gateways like Kashier)
            emit(PaymentCheckoutReady(
              checkoutUrl: response.checkoutUrl!,
              message: response.dataMessage ?? 'تم بدء عملية الدفع',
            ));
          } else if (response.purchase != null) {
            // Payment initiated - status is pending, waiting for confirmation
            if (response.purchase!.status == PaymentStatus.completed) {
              emit(PaymentCompleted(
                purchase: response.purchase!,
                message: response.dataMessage ?? 'تمت عملية الدفع بنجاح',
              ));
            } else {
              emit(PaymentInitiated(
                purchase: response.purchase!,
                message: response.dataMessage ?? 'تم بدء عملية الدفع',
              ));
            }
          } else {
            // Success but no purchase or checkout URL - might be free subscription
            // Check if final price is 0
            if (finalPrice == 0) {
              emit(PaymentCompleted(
                purchase: null,
                message: response.dataMessage ?? response.message ?? 'تم تفعيل الاشتراك بنجاح',
              ));
            } else {
              // Unknown state - handle gracefully
              emit(PaymentInitiated(
                purchase: null,
                message: response.dataMessage ?? response.message,
              ));
            }
          }
        } else {
          emit(PaymentFailed(response.message));
        }
      },
    );
  }
}


