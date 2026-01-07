import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';


import '../../../../../core/theme/app_colors.dart';
class PromoCodeTextField extends StatelessWidget {
  final TextEditingController controller;

  const PromoCodeTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'أدخل الكوبون هنا',
          hintStyle: TextStyle(
            fontFamily: cairoFontFamily,
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: _buildBorder(Colors.grey.shade300),
          enabledBorder: _buildBorder(Colors.grey.shade300),
          focusedBorder: _buildBorder(AppColors.primary),
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color),
    );
  }
}



