import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../../features/subscriptions/presentation/pages/widgets/payment_method_icon.dart';

class SupportSection extends StatelessWidget {
  static const String _whatsappNumber = '201019865875';
  
  const SupportSection({super.key});

  Future<void> _openWhatsApp(BuildContext context) async {
    // Try WhatsApp native URL first
    final Uri whatsappNative = Uri.parse('whatsapp://send?phone=$_whatsappNumber');
    
    try {
      bool launched = await launchUrl(whatsappNative);
      if (launched) return;
    } catch (_) {}
    
    // Fallback to wa.me link
    final Uri waMe = Uri.parse('https://wa.me/$_whatsappNumber');
    try {
      bool launched = await launchUrl(waMe, mode: LaunchMode.externalApplication);
      if (launched) return;
    } catch (_) {}
    
    // Fallback to api.whatsapp.com
    final Uri apiWhatsapp = Uri.parse('https://api.whatsapp.com/send?phone=$_whatsappNumber');
    try {
      await launchUrl(apiWhatsapp, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على تطبيق واتساب', style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet =
        MediaQuery.of(context).size.shortestSide >= 600;

    return Column(
      children: [
        Text(
          'لديك مشاكل أو استفسارات ؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: isTablet ? 18 : 16,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: () => _openWhatsApp(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                'تواصل معنا من هنا',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: isTablet ? 16 : 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              PaymentMethodIcon(
                imagePath: 'assets/images/whatsapp.png',
                width: isTablet ? 26 : null,
                height: isTablet ? 26 : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}



