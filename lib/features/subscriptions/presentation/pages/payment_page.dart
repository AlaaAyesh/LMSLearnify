import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../data/models/payment_model.dart';
import '../../domain/entities/subscription.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';
import 'payment_checkout_webview_page.dart';
import 'widgets/payment_methods_row.dart';
import 'widgets/payment_success_dialog.dart';

class PaymentPage extends StatelessWidget {
  final Subscription subscription;
  final String? promoCode;

  const PaymentPage({
    super.key,
    required this.subscription,
    this.promoCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SubscriptionBloc>(),
      child: _PaymentPageContent(
        subscription: subscription,
        promoCode: promoCode,
      ),
    );
  }
}

class _PaymentPageContent extends StatefulWidget {
  final Subscription subscription;
  final String? promoCode;

  const _PaymentPageContent({
    required this.subscription,
    this.promoCode,
  });

  @override
  State<_PaymentPageContent> createState() => _PaymentPageContentState();
}

class _PaymentPageContentState extends State<_PaymentPageContent> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  String get _currencySymbol => CurrencyService.getCurrencySymbol();
  String get _currencyCode => CurrencyService.getCurrencyCode();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(title: 'إتمام الدفع'),
      body: BlocListener<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is PaymentProcessing) {
            setState(() => _isLoading = true);
          } else if (state is PaymentCheckoutReady) {
            setState(() => _isLoading = false);
            _openCheckoutUrl(state.checkoutUrl);
          } else if (state is PaymentInitiated || state is PaymentCompleted) {
            setState(() => _isLoading = false);
            _showPaymentSuccessDialog();
          } else if (state is PaymentFailed) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Stack(
          children: [
            const CustomBackground(),
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Order Summary Card
                    _buildOrderSummary(),
                    SizedBox(height: 24),

                    // Phone Input
                    _buildPhoneInput(),
                    SizedBox(height: 24),

                    // Payment Methods
                    _buildPaymentMethods(),
                    SizedBox(height: 32),

                    // Pay Button
                    _buildPayButton(),
                    SizedBox(height: 16),

                    // Security Note
                    _buildSecurityNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الطلب',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            'الباقة',
            _getDurationTitle(widget.subscription.duration),
          ),
          SizedBox(height: 12),
          if (widget.subscription.priceBeforeDiscount != widget.subscription.price &&
              widget.subscription.priceBeforeDiscount.isNotEmpty)
            _buildSummaryRow(
              'السعر الأصلي',
              '${widget.subscription.priceBeforeDiscount} $_currencySymbol',
              isStrikethrough: true,
            ),
          if (widget.subscription.priceBeforeDiscount != widget.subscription.price &&
              widget.subscription.priceBeforeDiscount.isNotEmpty)
            SizedBox(height: 12),
          if (widget.promoCode != null && widget.promoCode!.isNotEmpty)
            _buildSummaryRow(
              'كود الخصم',
              widget.promoCode!,
              valueColor: AppColors.success,
            ),
          if (widget.promoCode != null && widget.promoCode!.isNotEmpty)
            SizedBox(height: 12),
          const Divider(height: 24),
          _buildSummaryRow(
            'المجموع',
            '${widget.subscription.price} $_currencySymbol',
            isBold: true,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isStrikethrough = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'رقم الهاتف للدفع',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: '+201XXXXXXXXX',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontFamily: cairoFontFamily,
              ),
              prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال رقم الهاتف';
              }
              return null;
            },
          ),
          SizedBox(height: 8),
          Text(
            'سيتم استخدام هذا الرقم لإتمام عملية الدفع',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'طرق الدفع المتاحة',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          const PaymentMethodsRow(),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _processPayment,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              'ادفع ${widget.subscription.price} $_currencySymbol',
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildSecurityNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock, size: 16, color: Colors.grey[500]),
        SizedBox(width: 8),
        Text(
          'جميع المعاملات مشفرة وآمنة',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  void _processPayment() {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();

    // Use kashier for web-based payment gateways, iap for in-app purchases
    final paymentService = PaymentService.kashier;

    context.read<SubscriptionBloc>().add(
          ProcessPaymentEvent(
            service: paymentService,
            currency: _currencyCode,
            subscriptionId: widget.subscription.id,
            phone: phone,
            couponCode: widget.promoCode,
          ),
        );
  }

  Future<void> _openCheckoutUrl(String checkoutUrl) async {
    // Open checkout URL in WebView
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentCheckoutWebViewPage(
          checkoutUrl: checkoutUrl,
        ),
      ),
    );

    // Handle payment result
    if (result == true && mounted) {
      // Payment successful
      _showPaymentSuccessDialog();
    } else if (result == false && mounted) {
      // Payment failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشلت عملية الدفع. يرجى المحاولة مرة أخرى'),
          backgroundColor: Colors.red,
        ),
      );
    }
    // If result is null, user closed the page manually
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PaymentSuccessDialog(
        onContinue: () {
          Navigator.pop(ctx); // Close dialog
          Navigator.pop(context); // Go back to subscriptions page
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تفعيل الاشتراك بنجاح! يمكنك الآن مشاهدة جميع الدروس'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }
}




