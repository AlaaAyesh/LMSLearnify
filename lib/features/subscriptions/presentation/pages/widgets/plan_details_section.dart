import 'package:flutter/material.dart';
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
            const SizedBox(width: 8),

            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: 1.2,
              ),
              textAlign: TextAlign.right,
            ),

          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: Color(0xFF565E6C),
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