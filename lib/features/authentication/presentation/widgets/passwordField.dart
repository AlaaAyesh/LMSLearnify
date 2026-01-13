import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/responsive.dart';

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
    return SizedBox(
      width: Responsive.width(context, 342),
      height: Responsive.height(context, 52),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        textInputAction: TextInputAction.done,
        validator: validator ?? Validators.password,
        style: TextStyle(
          fontSize: Responsive.fontSize(context, 20),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: Responsive.fontSize(context, 20),
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF565D6D),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(right: Responsive.spacing(context, 20),left: Responsive.spacing(context, 10)),
            child: Icon(
              Icons.lock_outline,
              color: AppColors.primary,
              size: Responsive.iconSize(context, 24),
            ),
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(context, 10)),
            child: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF565D6D),
                size: Responsive.iconSize(context, 22),
              ),
              onPressed: onToggleVisibility,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.spacing(context, 20),
            vertical: Responsive.spacing(context, 11),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(context, 24)),
            borderSide: const BorderSide(
              color: Color(0xFFDEE1E6),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(context, 24)),
            borderSide: const BorderSide(
              color: Color(0xFFDEE1E6),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Responsive.radius(context, 24)),
            borderSide: const BorderSide(
              color: Color(0xFFDEE1E6),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}