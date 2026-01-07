import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/apply_button.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/benefit_item.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/payment_button.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/payment_methods_row.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/promo_code_text_field.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/subscription_plan_card.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../../../core/widgets/support_section.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/subscription_plan.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';
import 'payment_page.dart';

class SubscriptionsPage extends StatelessWidget {
  /// When true, shows the back button in the app bar.
  /// Set to false when accessed from bottom navigation (nothing to go back to).
  final bool showBackButton;

  const SubscriptionsPage({
    super.key,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SubscriptionBloc>()..add(const LoadSubscriptionsEvent()),
      child: _SubscriptionsPageContent(showBackButton: showBackButton),
    );
  }
}

class _SubscriptionsPageContent extends StatefulWidget {
  final bool showBackButton;

  const _SubscriptionsPageContent({
    this.showBackButton = true,
  });

  @override
  State<_SubscriptionsPageContent> createState() => _SubscriptionsPageContentState();
}

class _SubscriptionsPageContentState extends State<_SubscriptionsPageContent> {
  final TextEditingController _promoController = TextEditingController();

  static const List<String> _benefits = [
    'الوصول الكامل لجميع الكورسات الحالية والمستقبلية',
    'شهادة إتمام بعد كل كورس',
    'محتوى متجدد باستمرار',
  ];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
      title: 'اختر باقتك الآن',
        showBackButton: widget.showBackButton,
    ),
      body: Stack(
        children: [
          const CustomBackground(),
          BlocConsumer<SubscriptionBloc, SubscriptionState>(
            listener: (context, state) {
              if (state is SubscriptionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is PromoCodeApplied) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is SubscriptionLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is SubscriptionsEmpty) {
                return _buildEmptyState(context);
              }

              if (state is SubscriptionsLoaded) {
                return _buildContent(context, state);
              }

              if (state is SubscriptionError) {
                return _buildErrorState(context, state.message);
              }

              // Initial state - show loading
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, SubscriptionsLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SubscriptionBloc>().add(const LoadSubscriptionsEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Column(
                children: [
              _buildPlansList(context, state),
                  SizedBox(height: 24),
                  _buildBenefitsList(),
                  SizedBox(height: 24),
                  _buildPromoCodeSection(),
                  SizedBox(height: 24),
              _buildPaymentSection(state),
                  SizedBox(height: 16),
                  const SupportSection(),
                  SizedBox(height: 24),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, SubscriptionsLoaded state) {
    final currencySymbol = CurrencyService.getCurrencySymbol();
    
    return Column(
      children: List.generate(
        state.subscriptions.length,
        (index) {
          final subscription = state.subscriptions[index];
          // Find the longest duration to mark as recommended
          final maxDuration = state.subscriptions
              .map((s) => s.duration)
              .reduce((a, b) => a > b ? a : b);
          final isRecommended = subscription.duration == maxDuration;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < state.subscriptions.length - 1 ? 12 : 0,
            ),
          child: SubscriptionPlanCard(
              plan: SubscriptionPlan(
                title: _getDurationTitle(subscription.duration),
                originalPrice: subscription.priceBeforeDiscount,
                discountedPrice: subscription.price,
                currency: currencySymbol,
                description: _getDurationDescription(subscription.duration),
                isRecommended: isRecommended,
              ),
              isSelected: state.selectedIndex == index,
              onTap: () {
                context.read<SubscriptionBloc>().add(
                      SelectSubscriptionEvent(index: index),
                    );
              },
        ),
          );
        },
      ),
    );
  }

  String _getDurationTitle(int duration) {
    if (duration == 1) {
      return 'باقة شهرية';
    } else if (duration == 6) {
      return 'باقة 6 شهور';
    } else if (duration == 12) {
      return 'باقة سنوية';
    } else {
      return 'باقة $duration شهور';
    }
  }

  String _getDurationDescription(int duration) {
    if (duration == 1) {
      return 'الوصول للكورسات والشروحات لمدة شهر';
    } else if (duration == 12) {
      return 'الوصول للكورسات والشروحات لمدة سنة';
    } else {
      return 'الوصول للكورسات والشروحات لمدة $duration شهور';
    }
  }

  Widget _buildBenefitsList() {
    return Column(
      children: _benefits.map((benefit) => BenefitItem(text: benefit)).toList(),
    );
  }

  Widget _buildPromoCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'هل لديك كوبون خصم؟',
          style: AppTextStyles.bodyLarge,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 8),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: PromoCodeTextField(controller: _promoController),
            ),
            SizedBox(width: 10),
            ApplyButton(onPressed: _applyPromoCode),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSection(SubscriptionsLoaded state) {
    final selectedSubscription = state.selectedSubscription;
    final currencySymbol = CurrencyService.getCurrencySymbol();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (selectedSubscription != null) ...[
            Text(
              'المجموع: ${selectedSubscription.price} $currencySymbol',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
          ],
          PaymentButton(onPressed: () => _processPayment(state)),
          SizedBox(height: 16),
          const PaymentMethodsRow(),
        ],
      ),
    );
  }

  void _processPayment(SubscriptionsLoaded state) async {
    final selectedSubscription = state.selectedSubscription;
    if (selectedSubscription == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى اختيار باقة أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user is authenticated (not guest)
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();
    final isGuest = await authLocalDataSource.isGuestMode();
    
    final isAuthenticated = token != null && token.isNotEmpty && !isGuest;
    
    if (!isAuthenticated) {
      // Save selected plan index before redirecting to login
      final selectedIndex = state.selectedIndex;
      final promoCode = state.appliedPromoCode;
      
      // Navigate to login with return info
      final result = await Navigator.pushNamed(
        context,
        '/login',
        arguments: {
          'returnTo': 'subscriptions',
          'selectedPlanIndex': selectedIndex,
          'promoCode': promoCode,
        },
      );
      
      // After login success, reload subscriptions and restore selection
      if (result == true && mounted) {
        context.read<SubscriptionBloc>().add(const LoadSubscriptionsEvent());
        // Restore selection after a brief delay for state to update
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.read<SubscriptionBloc>().add(
              SelectSubscriptionEvent(index: selectedIndex),
            );
          }
        });
      }
      return;
    }

    // User is authenticated - navigate to payment page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          subscription: selectedSubscription,
          promoCode: state.appliedPromoCode,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد باقات متاحة حالياً',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'يرجى المحاولة لاحقاً',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SubscriptionBloc>().add(const LoadSubscriptionsEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('تحديث'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SubscriptionBloc>().add(const LoadSubscriptionsEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applyPromoCode() {
    final promoCode = _promoController.text.trim();
    if (promoCode.isNotEmpty) {
      context.read<SubscriptionBloc>().add(
            ApplyPromoCodeEvent(promoCode: promoCode),
          );
    }
  }
}


