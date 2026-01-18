import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/apply_button.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/benefit_item.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/payment_button.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/payment_methods_row.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/promo_code_text_field.dart';
import 'package:learnify_lms/features/subscriptions/presentation/pages/widgets/subscription_plan_card.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../../../core/widgets/support_section.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/subscription.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';
import '../../data/models/payment_model.dart';

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
  bool _shouldShowPaymentAfterLogin = false;
  int? _pendingSelectedIndex;
  String? _pendingPromoCode;

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
              } else if (state is SubscriptionsLoaded && _shouldShowPaymentAfterLogin) {
                // After login, subscriptions reloaded - show payment sheet
                final selectedSubscription = state.selectedSubscription;
                if (selectedSubscription != null && mounted) {
                  _shouldShowPaymentAfterLogin = false;
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) {
                      _showPaymentBottomSheet(context, selectedSubscription, _pendingPromoCode);
                    }
                  });
                }
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
              padding: Responsive.padding(context, horizontal: 22, vertical: 16),
              child: Column(
                children: [
              _buildPlansList(context, state),
                  SizedBox(height: Responsive.spacing(context, 16)),
                  _buildBenefitsList(),
                  SizedBox(height: Responsive.spacing(context, 16)),
                  _buildPromoCodeSection(context),
                  SizedBox(height: Responsive.spacing(context, 16)),
              _buildPaymentSection(context, state),
                  SizedBox(height: Responsive.spacing(context, 6)),
                  const SupportSection(),
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
            padding: Responsive.padding(
              context,
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

  Widget _buildPromoCodeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'هل لديك كوبون خصم؟',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.black,
            fontSize: Responsive.fontSize(context, 14),
          ),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: Responsive.spacing(context, 8)),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: PromoCodeTextField(controller: _promoController),
            ),
            SizedBox(width: Responsive.width(context, 10)),
            ApplyButton(onPressed: _applyPromoCode),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context, SubscriptionsLoaded state) {
    final selectedSubscription = state.selectedSubscription;
    final currencySymbol = CurrencyService.getCurrencySymbol();
    
    return Padding(
      padding: Responsive.padding(context, all: 16),
      child: Column(
        children: [
          // if (selectedSubscription != null) ...[
          //   Text(
          //     'المجموع: ${selectedSubscription.price} $currencySymbol',
          //     style: AppTextStyles.bodyLarge.copyWith(
          //       fontWeight: FontWeight.bold,
          //       fontSize: Responsive.fontSize(context, AppTextStyles.bodyLarge.fontSize ?? 16),
          //     ),
          //   ),
          //   SizedBox(height: Responsive.spacing(context, 8)),
          // ],
          PaymentButton(
            onPressed: () {
              print('Payment button pressed');
              if (mounted) {
                _processPayment(context, state);
              }
            },
          ),
          SizedBox(height: Responsive.spacing(context, 10)),
          const PaymentMethodsRow(),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context, SubscriptionsLoaded state) async {
    final selectedSubscription = state.selectedSubscription;
    
    if (selectedSubscription == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار باقة أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user is authenticated
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();
    
    final isAuthenticated = token != null && token.isNotEmpty;
    
    if (!isAuthenticated) {
      // Save selected plan index before redirecting to login
      final selectedIndex = state.selectedIndex;
      final promoCode = state.appliedPromoCode;
      
      // Set flag to show payment sheet after login
      setState(() {
        _shouldShowPaymentAfterLogin = true;
        _pendingSelectedIndex = selectedIndex;
        _pendingPromoCode = promoCode;
      });
      
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
          if (mounted && _pendingSelectedIndex != null) {
            context.read<SubscriptionBloc>().add(
              SelectSubscriptionEvent(index: _pendingSelectedIndex!),
            );
          }
        });
      } else {
        // Login cancelled or failed - reset flag
        setState(() {
          _shouldShowPaymentAfterLogin = false;
          _pendingSelectedIndex = null;
          _pendingPromoCode = null;
        });
      }
      return;
    }

    // User is authenticated - show compact payment sheet
    _showPaymentBottomSheet(context, selectedSubscription, state.appliedPromoCode);
  }

  void _showPaymentBottomSheet(
    BuildContext context,
    Subscription selectedSubscription,
    String? promoCode,
  ) {
    final bloc = context.read<SubscriptionBloc>();
    final amount = selectedSubscription.price;
    final currencySymbol = CurrencyService.getCurrencySymbol();
    final currencyCode = CurrencyService.getCurrencyCode();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.radius(context, 24)),
        ),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: bloc,
          child: BlocListener<SubscriptionBloc, SubscriptionState>(
            listener: (context, state) async {
              if (state is PaymentProcessing) {
                // nothing extra, button shows loader outside
              } else if (state is PaymentCheckoutReady) {
                final uri = Uri.parse(state.checkoutUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لا يمكن فتح رابط الدفع'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              } else if (state is PaymentFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is PaymentCompleted || state is PaymentInitiated) {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: Padding(
              padding: EdgeInsets.only(
                left: Responsive.width(ctx, 20),
                right: Responsive.width(ctx, 20),
                bottom: MediaQuery.of(ctx).viewInsets.bottom + Responsive.height(ctx, 20),
                top: Responsive.height(ctx, 16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: Responsive.width(ctx, 50),
                      height: Responsive.height(ctx, 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(Responsive.radius(ctx, 12)),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(ctx, 16)),
                  Text(
                    'اختر طريقة الدفع',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(ctx, 16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(ctx, 12)),
                  _PaymentOptionTile(
                    title: 'بطاقة ائتمانية',
                    subtitle: 'ادفع عبر بوابة Kashier',
                    icon: Icons.credit_card,
                    onTap: () {
                      bloc.add(
                        ProcessPaymentEvent(
                          service: PaymentService.kashier,
                          currency: currencyCode,
                          subscriptionId: selectedSubscription.id,
                          phone: '',
                          couponCode: promoCode,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: Responsive.spacing(ctx, 12)),
                  _PaymentOptionTile(
                    title: 'محفظة / طرق أخرى',
                    subtitle: 'سيتم توجيهك لبوابة الدفع',
                    icon: Icons.account_balance_wallet,
                    onTap: () {
                      bloc.add(
                        ProcessPaymentEvent(
                          service: PaymentService.kashier,
                          currency: currencyCode,
                          subscriptionId: selectedSubscription.id,
                          phone: '',
                          couponCode: promoCode,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: Responsive.spacing(ctx, 16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(ctx, 14),
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$amount $currencySymbol',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(ctx, 18),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.spacing(ctx, 20)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions_outlined,
            size: Responsive.iconSize(context, 80),
            color: Colors.grey[400],
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          Text(
            'لا توجد باقات متاحة حالياً',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 8)),
          Text(
            'يرجى المحاولة لاحقاً',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 14),
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 24)),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SubscriptionBloc>().add(const LoadSubscriptionsEvent());
            },
            icon: Icon(Icons.refresh, size: Responsive.iconSize(context, 20)),
            label: const Text('تحديث'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.white,
              padding: Responsive.padding(context, horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
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
            size: Responsive.iconSize(context, 80),
            color: Colors.red[400],
          ),
          SizedBox(height: Responsive.spacing(context, 16)),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 18),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 8)),
          Padding(
            padding: Responsive.padding(context, horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                color: Colors.grey[500],
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 24)),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SubscriptionBloc>().add(const LoadSubscriptionsEvent());
            },
            icon: Icon(Icons.refresh, size: Responsive.iconSize(context, 20)),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.white,
              padding: Responsive.padding(context, horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
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

class _PaymentOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
      child: Container(
        padding: Responsive.padding(context, vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: Responsive.width(context, 8),
              offset: Offset(0, Responsive.height(context, 3)),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: Responsive.width(context, 40),
              height: Responsive.width(context, 40),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(Responsive.radius(context, 10)),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: Responsive.iconSize(context, 24),
              ),
            ),
            SizedBox(width: Responsive.width(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 14),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 12),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: Responsive.iconSize(context, 16),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}


