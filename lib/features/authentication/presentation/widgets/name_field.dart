import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import 'custom_text_field.dart';

class NameField extends StatelessWidget {
  final TextEditingController controller;

  const NameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: 'اسم الطفل الثلاثي',
      controller: controller,
      prefixIcon:
      const Icon(Icons.person_outline, color: AppColors.primary),
      validator: Validators.required,
    );
  }
}


