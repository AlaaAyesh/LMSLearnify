import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/apply_button.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/benefit_item.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/payment_button.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/payment_methods_row.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/payment_success_dialog.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/promo_code_text_field.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/subscription_plan_card.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../../../core/widgets/support_section.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/entities/subscription_plan.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';

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
                return const Center(
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
              return const Center(
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
                  const SizedBox(height: 24),
                  _buildBenefitsList(),
                  const SizedBox(height: 24),
                  _buildPromoCodeSection(),
                  const SizedBox(height: 24),
              _buildPaymentSection(state),
                  const SizedBox(height: 16),
                  const SupportSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildPlansList(BuildContext context, SubscriptionsLoaded state) {
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
                currency: 'جم',
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
        const Text(
          'هل لديك كوبون خصم؟',
          style: AppTextStyles.bodyLarge,
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: PromoCodeTextField(controller: _promoController),
            ),
            const SizedBox(width: 10),
            ApplyButton(onPressed: _applyPromoCode),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSection(SubscriptionsLoaded state) {
    final selectedSubscription = state.selectedSubscription;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (selectedSubscription != null) ...[
            Text(
              'المجموع: ${selectedSubscription.price} جم',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          PaymentButton(onPressed: _showPaymentSuccessDialog),
          const SizedBox(height: 16),
          const PaymentMethodsRow(),
        ],
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
          const SizedBox(height: 16),
          Text(
            'لا توجد باقات متاحة حالياً',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يرجى المحاولة لاحقاً',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 24),
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

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PaymentSuccessDialog(
        onContinue: () {
          Navigator.pop(ctx);
          Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
            '/home',
                (route) => false,
          );
        },
      ),
    );
  }
}
