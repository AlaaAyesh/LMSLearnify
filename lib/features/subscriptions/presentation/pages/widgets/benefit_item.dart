import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/theme/app_text_styles.dart';
class BenefitItem extends StatelessWidget {
  final String text;

  const BenefitItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Responsive.padding(context, vertical: 6),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: Responsive.width(context, 22),
            height: Responsive.width(context, 22),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFB300),
                width: Responsive.width(context, 2),
              ),
            ),
            child: Icon(
              Icons.check,
              size: Responsive.iconSize(context, 16),
              color: const Color(0xFFFFB300),
            ),
          ),
          SizedBox(width: Responsive.width(context, 10)),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: Responsive.fontSize(context, 14),
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


