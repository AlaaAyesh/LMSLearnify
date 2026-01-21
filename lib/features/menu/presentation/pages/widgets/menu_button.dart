import 'package:flutter/material.dart';
import 'package:learnify_lms/core/utils/responsive.dart';

import '../../../../../core/theme/app_colors.dart';

class MenuButton extends StatelessWidget {
  final String text;
  final String? badge;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.text,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = Responsive.height(context, 64).clamp(52.0, 78.0);
    final fontSize = Responsive.fontSize(context, 19);
    final badgeFontSize = Responsive.fontSize(context, 12);
    final radius = Responsive.radius(context, 24);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context, 8)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: () {
              print('🟢 MenuButton tapped: $text');
              onTap();
            },
            borderRadius: BorderRadius.circular(radius),
            child: Ink(
              height: buttonHeight,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          /// BADGE
          if (badge != null)
            Positioned(
              right: -10,
              top: -8,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.width(context, 10),
                  vertical: Responsive.spacing(context, 4),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFA567E3),
                  borderRadius: BorderRadius.circular(
                    Responsive.radius(context, 12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: badgeFontSize,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}



