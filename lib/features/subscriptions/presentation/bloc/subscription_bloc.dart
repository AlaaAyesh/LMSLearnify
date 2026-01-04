import 'package:flutter_bloc/flutter_bloc.dart';
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

  SubscriptionBloc({
    required this.getSubscriptionsUseCase,
    required this.getSubscriptionByIdUseCase,
    required this.createSubscriptionUseCase,
    required this.updateSubscriptionUseCase,
  }) : super(SubscriptionInitial()) {
    on<LoadSubscriptionsEvent>(_onLoadSubscriptions);
    on<LoadSubscriptionByIdEvent>(_onLoadSubscriptionById);
    on<SelectSubscriptionEvent>(_onSelectSubscription);
    on<ApplyPromoCodeEvent>(_onApplyPromoCode);
    on<CreateSubscriptionEvent>(_onCreateSubscription);
    on<UpdateSubscriptionEvent>(_onUpdateSubscription);
    on<ClearSubscriptionStateEvent>(_onClearState);
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
      // TODO: Implement promo code validation via API
      // For now, just store the promo code
      if (event.promoCode.isNotEmpty) {
        emit(currentState.copyWith(
          appliedPromoCode: event.promoCode,
          // Mock discount - replace with actual API call
          discountAmount: 0.0,
        ));
      }
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
}


