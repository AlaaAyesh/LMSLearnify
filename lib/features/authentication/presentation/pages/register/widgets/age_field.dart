import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/utils/validators.dart';
import '../../../widgets/custom_text_field.dart';

class AgeField extends StatelessWidget {
  final TextEditingController controller;

  const AgeField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: 'سن الطفل',
      controller: controller,
      keyboardType: TextInputType.number,
      prefixIcon:
      const Icon(Icons.cake_outlined, color: AppColors.primary),
      validator: Validators.age,
    );
  }
}
