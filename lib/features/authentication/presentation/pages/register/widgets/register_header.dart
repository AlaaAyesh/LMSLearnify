import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';

class RegisterHeader extends StatelessWidget {
  final String title;
  final String highlight;

  const RegisterHeader({
    super.key,
    this.title = 'مستقبل ابنك يبدأ',
    this.highlight = 'هنا',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              highlight,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            const Text('👋', style: TextStyle(fontSize: 28)),
          ],
        ),
      ],
    );
  }
}
