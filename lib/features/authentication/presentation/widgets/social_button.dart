import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 89,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.inputBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            asset,
            height: 20,
          ),
        ),
      ),
    );
  }
}


