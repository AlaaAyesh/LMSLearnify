import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;

  const SocialButton({super.key,
    required this.asset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    
    // على التابلت: أحجام أصغر لتجنب overflow
    final buttonWidth = isTablet ? 70.0 : Responsive.width(context, 89);
    final buttonHeight = isTablet ? 50.0 : Responsive.height(context, 44);
    final iconHeight = isTablet ? 22.0 : Responsive.height(context, 18);
    final borderRadius = isTablet ? 12.0 : Responsive.radius(context, 18);
    
    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onTap,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppColors.inputBorder,
            width: Responsive.width(context, 1),
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            asset,
            height: iconHeight,
          ),
        ),
      ),
    );
  }
}


