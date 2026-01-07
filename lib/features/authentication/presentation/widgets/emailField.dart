
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import 'custom_text_field.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: 'البريد الإلكتروني',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
      validator: Validators.email,
    );
  }
}


