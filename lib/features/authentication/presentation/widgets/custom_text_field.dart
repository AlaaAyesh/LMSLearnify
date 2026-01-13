import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
  final double? width;
  final double? height;

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
    this.width = 342,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width != null ? Responsive.width(context, width!) : null,
          height: height != null ? Responsive.height(context, height!) : null,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            maxLines: maxLines,
            textInputAction: textInputAction,
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
              prefixIcon: prefixIcon != null
                  ? Padding(
                padding: EdgeInsets.only(
                  right: Responsive.spacing(context, 20),
                  left: Responsive.spacing(context, 10),
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: AppColors.primary,
                    size: Responsive.iconSize(context, 24),
                  ),
                  child: prefixIcon!,
                ),
              )
                  : null,
              prefixIconConstraints: BoxConstraints(
                minWidth: Responsive.spacing(context, 40),
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                padding: EdgeInsets.only(
                  left: Responsive.spacing(context, 8),
                ),
                child: IconTheme(
                  data: IconThemeData(
                    size: Responsive.iconSize(context, 24),
                  ),
                  child: suffixIcon!,
                ),
              )
                  : null,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Responsive.radius(context, 24)),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Responsive.radius(context, 24)),
                borderSide: const BorderSide(
                  color: Color(0xFFEF4444),
                  width: 1.5,
                ),
              ),
              // Hide the default error text below the field
              errorStyle: const TextStyle(
                height: 0,
                fontSize: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}