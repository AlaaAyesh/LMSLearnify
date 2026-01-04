import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/utils/validators.dart';
import '../../../widgets/custom_text_field.dart';


class ForgotPasswordEmailField extends StatelessWidget {
  final TextEditingController controller;

  const ForgotPasswordEmailField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: 'البريد الإلكتروني',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(
        Icons.email_outlined,
        color: AppColors.primary,
      ),
      validator: Validators.email,
    );
  }
}
