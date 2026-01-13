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
    return InkWell(
      borderRadius: BorderRadius.circular(Responsive.radius(context, 18)),
      onTap: onTap,
      child: Container(
        width: Responsive.width(context, 89),
        height: Responsive.height(context, 44),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.radius(context, 18)),
          border: Border.all(
            color: AppColors.inputBorder,
            width: Responsive.width(context, 1),
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            asset,
            height: Responsive.height(context, 18),
          ),
        ),
      ),
    );
  }
}


