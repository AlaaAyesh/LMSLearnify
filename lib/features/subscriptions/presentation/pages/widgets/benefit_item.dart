import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/theme/app_text_styles.dart';
class BenefitItem extends StatelessWidget {
  final String text;

  const BenefitItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final bool isTablet = Responsive.isTablet(context);

    final double circleSize =
        isTablet ? 26 : Responsive.width(context, 22);
    final double iconSize =
        isTablet ? 14 : Responsive.iconSize(context, 16);
    final double horizontalSpacing =
        isTablet ? 8 : Responsive.width(context, 10);
    final double fontSize =
        isTablet ? Responsive.fontSize(context, 16) : Responsive.fontSize(context, 14);
    final EdgeInsets verticalPadding =
        isTablet ? const EdgeInsets.symmetric(vertical: 4) : Responsive.padding(context, vertical: 6);

    return Padding(
      padding: verticalPadding,
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFB300),
                width: isTablet ? 2 : Responsive.width(context, 2),
              ),
            ),
            child: Icon(
              Icons.check,
              size: iconSize,
              color: const Color(0xFFFFB300),
            ),
          ),
          SizedBox(width: horizontalSpacing),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: fontSize,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


