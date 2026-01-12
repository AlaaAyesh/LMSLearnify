import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';
import '../../../../../core/theme/app_colors.dart';
class PromoCodeTextField extends StatelessWidget {
  final TextEditingController controller;

  const PromoCodeTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Responsive.height(context, 48),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'أدخل الكوبون هنا',
          hintStyle: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: Responsive.fontSize(context, 14),
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: Responsive.padding(context, horizontal: 12, vertical: 0),
          border: _buildBorder(context, Colors.grey.shade300),
          enabledBorder: _buildBorder(context, Colors.grey.shade300),
          focusedBorder: _buildBorder(context, AppColors.primary),
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder(BuildContext context, Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Responsive.radius(context, 10)),
      borderSide: BorderSide(color: color, width: Responsive.width(context, 1)),
    );
  }
}



