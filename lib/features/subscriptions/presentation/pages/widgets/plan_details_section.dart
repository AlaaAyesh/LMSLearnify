import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
import 'package:learnify_lms/core/widgets/radio_indicator.dart';

class PlanDetailsSection extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;

  const PlanDetailsSection({
    super.key,
    required this.title,
    required this.description,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioIndicator(isSelected: isSelected),
            SizedBox(width: Responsive.width(context, 8)),
            // استخدام Flexible للنص لضمان عدم الـ overflow
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: Responsive.fontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.spacing(context, 4)),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: Responsive.fontSize(context, 10),
            color: Colors.black,
            height: 1.4,
          ),
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}



