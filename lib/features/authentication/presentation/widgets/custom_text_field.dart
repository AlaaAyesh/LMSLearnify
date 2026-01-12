import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int? maxLines;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      maxLines: maxLines,
      textInputAction: textInputAction,
      textAlign: TextAlign.right,
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
        prefixIcon: prefixIcon != null
            ? Padding(
          padding: Responsive.padding(context, left: 16, right: 12),
          child: prefixIcon,
        )
            : null,
        prefixIconConstraints: BoxConstraints(
          minWidth: Responsive.width(context, 24),
          minHeight: Responsive.width(context, 24),
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
          padding: Responsive.padding(context, right: 16, left: 12),
          child: suffixIcon,
        )
            : null,
        suffixIconConstraints: BoxConstraints(
          minWidth: Responsive.width(context, 24),
          minHeight: Responsive.width(context, 24),
        ),
        filled: false, // إلغاء التعبئة
        contentPadding: Responsive.padding(context, horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.radius(context, 30)),
          borderSide: BorderSide(
            color: Colors.grey.shade300, // رمادي فاتح
            width: Responsive.width(context, 1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.radius(context, 30)),
          borderSide: BorderSide(
            color: Colors.grey.shade300, // رمادي فاتح
            width: Responsive.width(context, 1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.radius(context, 30)),
          borderSide: BorderSide(
            color: Colors.grey.shade400, // رمادي أغمق قليلاً عند التركيز
            width: Responsive.width(context, 1.5),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.radius(context, 30)),
          borderSide: BorderSide(
            color: AppColors.error,
            width: Responsive.width(context, 1),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Responsive.radius(context, 30)),
          borderSide: BorderSide(
            color: AppColors.error,
            width: Responsive.width(context, 1.5),
          ),
        ),
      ),
    );
  }
}


