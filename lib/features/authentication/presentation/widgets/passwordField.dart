import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import 'custom_text_field.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleVisibility;
  final String hintText;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggleVisibility,
    this.hintText = 'كلمة المرور',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: hintText,
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
      suffixIcon: IconButton(
        icon: Icon(
          obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: const Color(0xFF565D6D),
        ),
        onPressed: onToggleVisibility,
      ),
      validator: validator ?? Validators.password,
    );
  }
}