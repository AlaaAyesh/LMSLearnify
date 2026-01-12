import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/payment_model.dart';
import '../../domain/entities/subscription.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';
import 'widgets/payment_success_dialog.dart';

class KashierPaymentPage extends StatelessWidget {
  final Subscription subscription;
  final String? promoCode;

  const KashierPaymentPage({
    super.key,
    required this.subscription,
    this.promoCode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SubscriptionBloc>(),
      child: _KashierPaymentPageContent(
        subscription: subscription,
        promoCode: promoCode,
      ),
    );
  }
}

class _KashierPaymentPageContent extends StatefulWidget {
  final Subscription subscription;
  final String? promoCode;

  const _KashierPaymentPageContent({
    required this.subscription,
    this.promoCode,
  });

  @override
  State<_KashierPaymentPageContent> createState() => _KashierPaymentPageContentState();
}

class _KashierPaymentPageContentState extends State<_KashierPaymentPageContent> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String _selectedPaymentMethod = 'card'; // 'card' or 'wallet'
  
  String get _currencySymbol => CurrencyService.getCurrencySymbol();
  String get _currencyCode => CurrencyService.getCurrencyCode();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
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

  void _fillTestCard() {
    setState(() {
      _cardNumberController.text = '5123450000000008';
      _expiryController.text = '12/25';
      _cvvController.text = '123';
      _cardNameController.text = 'Test Card';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'إتمام الدفع'),
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
        child: SingleChildScrollView(
          padding: Responsive.padding(context, all: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Payment Method Selection
                _buildPaymentMethodSelection(context),
                SizedBox(height: Responsive.spacing(context, 24)),
                
                // Test Card Button (only for card method)
                if (_selectedPaymentMethod == 'card') ...[
                  _buildTestCardButton(context),
                  SizedBox(height: Responsive.spacing(context, 24)),
                ],
                
                // Card Information (only for card method)
                if (_selectedPaymentMethod == 'card') ...[
                  _buildCardInformation(context),
                  SizedBox(height: Responsive.spacing(context, 32)),
                ],
                
                // Pay Button
                _buildPayButton(context),
                SizedBox(height: Responsive.spacing(context, 16)),
                
                // Security Note
                _buildSecurityNote(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose how you would like to pay',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: Responsive.fontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 16)),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodButton(
                context,
                'card',
                'Card',
                Icons.credit_card,
                _selectedPaymentMethod == 'card',
              ),
            ),
            SizedBox(width: Responsive.width(context, 12)),
            Expanded(
              child: _buildPaymentMethodButton(
                context,
                'wallet',
                'Wallet',
                Icons.qr_code,
                _selectedPaymentMethod == 'wallet',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodButton(
    BuildContext context,
    String method,
    String label,
    IconData icon,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: Responsive.padding(context, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? Responsive.width(context, 2) : Responsive.width(context, 1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey[600],
              size: Responsive.iconSize(context, 32),
            ),
            SizedBox(height: Responsive.spacing(context, 8)),
            Text(
              label,
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCardButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _fillTestCard,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: Responsive.padding(context, vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.radius(context, 8)),
        ),
      ),
      child: Text(
        'Click to fill test card',
        style: TextStyle(
          fontFamily: cairoFontFamily,
          fontSize: Responsive.fontSize(context, 14),
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCardInformation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card information',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: Responsive.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 16)),
        
        // Card Number
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19),
            CardNumberFormatter(),
          ],
          decoration: InputDecoration(
            labelText: 'Card number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: Icon(Icons.credit_card, color: AppColors.primary, size: Responsive.iconSize(context, 24)),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
              borderSide: BorderSide(color: AppColors.primary, width: Responsive.width(context, 2)),
            ),
          ),
          validator: (value) {
            if (value == null || value.replaceAll(' ', '').length < 13) {
              return 'يرجى إدخال رقم البطاقة صحيح';
            }
            return null;
          },
        ),
        SizedBox(height: Responsive.spacing(context, 16)),
        
        // Expiry and CVV Row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                  ExpiryDateFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'MM/YY',
                  hintText: '12/25',
                  prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary, size: Responsive.iconSize(context, 24)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                    borderSide: BorderSide(color: AppColors.primary, width: Responsive.width(context, 2)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 5) {
                    return 'MM/YY';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: Responsive.width(context, 12)),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  prefixIcon: Icon(Icons.lock, color: AppColors.primary, size: Responsive.iconSize(context, 24)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                    borderSide: BorderSide(color: AppColors.primary, width: Responsive.width(context, 2)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 3) {
                    return 'CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.spacing(context, 16)),
        
        // Card Name
        TextFormField(
          controller: _cardNameController,
          decoration: InputDecoration(
            labelText: 'Name on card',
            hintText: 'John Doe',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
              borderSide: BorderSide(color: AppColors.primary, width: Responsive.width(context, 2)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال اسم حامل البطاقة';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, // Yellow (app primary color)
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          padding: Responsive.padding(context, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
                height: Responsive.height(context, 24),
                width: Responsive.width(context, 24),
                child: CircularProgressIndicator(
                  strokeWidth: Responsive.width(context, 2),
                  color: Colors.white,
                ),
              )
            : Text(
                'Pay ${widget.subscription.price} $_currencySymbol',
                style: TextStyle(
                  fontFamily: cairoFontFamily,
                  fontSize: Responsive.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSecurityNote(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock, size: Responsive.iconSize(context, 16), color: Colors.grey[500]),
        SizedBox(width: Responsive.width(context, 8)),
        Text(
          'جميع المعاملات مشفرة وآمنة',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: Responsive.fontSize(context, 12),
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  void _processPayment() {
    if (!_formKey.currentState!.validate()) return;

    // Validate card fields if card method is selected
    if (_selectedPaymentMethod == 'card') {
      if (_cardNumberController.text.trim().isEmpty ||
          _expiryController.text.trim().isEmpty ||
          _cvvController.text.trim().isEmpty ||
          _cardNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى إدخال جميع معلومات البطاقة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Phone is optional for Kashier, use empty string
    context.read<SubscriptionBloc>().add(
          ProcessPaymentEvent(
            service: PaymentService.kashier,
            currency: _currencyCode,
            subscriptionId: widget.subscription.id,
            phone: '', // Phone is optional for Kashier
            couponCode: widget.promoCode,
          ),
        );
  }

  Future<void> _openCheckoutUrl(String checkoutUrl) async {
    try {
      final uri = Uri.parse(checkoutUrl);

      if (!await canLaunchUrl(uri)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح رابط الدفع'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // افتح الرابط في المتصفح/التطبيق الخارجي
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      // أبلغ المستخدم بمتابعة الدفع في المتصفح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم فتح صفحة الدفع. يرجى إتمام العملية في المتصفح'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء فتح صفحة الدفع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              content: const Text('تم تفعيل الاشتراك بنجاح! يمكنك الآن مشاهدة جميع الدروس'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }
}

// Custom formatters
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i == 2 && text.length > 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
