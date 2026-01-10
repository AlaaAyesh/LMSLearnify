import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ReelPaywallWidget extends StatelessWidget {
  final VoidCallback onSubscribe;
  final VoidCallback? onDismiss;

  const ReelPaywallWidget({
    super.key,
    required this.onSubscribe,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'استمتع بمحتوى غير محدود!',
                  style: TextStyle(
                    fontFamily: cairoFontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'اشترك الآن للوصول إلى جميع الفيديوهات التعليمية والدورات المميزة',
                  style: TextStyle(
                    fontFamily: cairoFontFamily,
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Subscribe Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSubscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'اشترك من هنا',
                      style: TextStyle(
                        fontFamily: cairoFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // Benefits
                const SizedBox(height: 32),
                _buildBenefit(Icons.play_circle_filled, 'فيديوهات تعليمية غير محدودة'),
                const SizedBox(height: 12),
                _buildBenefit(Icons.school, 'الوصول لجميع الكورسات'),
                const SizedBox(height: 12),
                _buildBenefit(Icons.workspace_premium, 'شهادات إتمام معتمدة'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

