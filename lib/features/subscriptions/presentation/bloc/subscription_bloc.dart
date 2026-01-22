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
      emit(currentState.copyWith(selectedIndex: event.index));
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
          // Coupon is valid - store it in state
          // The discount amount will be calculated on the backend during payment
          final updatedState = currentState.copyWith(
            appliedPromoCode: event.promoCode,
            discountAmount: 0.0, // Will be calculated by backend
          );
          emit(updatedState);
          // Emit success state for UI feedback
          emit(PromoCodeApplied(
            promoCode: event.promoCode,
            discountAmount: 0.0,
            message: 'تم تطبيق كود الخصم بنجاح',
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
          // Check if checkout URL is available (for payment gateways like Kashier)
          if (response.hasCheckoutUrl) {
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
            // Success but no purchase or checkout URL (shouldn't happen, but handle gracefully)
            emit(PaymentInitiated(
              purchase: null,
              message: response.dataMessage ?? response.message,
            ));
          }
        } else {
          emit(PaymentFailed(response.message));
        }
      },
    );
  }
}


