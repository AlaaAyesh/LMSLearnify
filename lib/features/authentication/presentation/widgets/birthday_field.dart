import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class BirthdayField extends StatelessWidget {
  final TextEditingController dayController;
  final TextEditingController monthController;
  final TextEditingController yearController;

  const BirthdayField({
    super.key,
    required this.dayController,
    required this.monthController,
    required this.yearController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تاريخ الميلاد',
          style: TextStyle(
            fontFamily: cairoFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            // Year Field
            Expanded(
              flex: 2,
              child: _buildDatePart(
                controller: yearController,
                hint: 'السنة',
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'مطلوب';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900 || year > DateTime.now().year) {
                    return 'سنة غير صحيحة';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 12),
            // Month Field
            Expanded(
              flex: 1,
              child: _buildDatePart(
                controller: monthController,
                hint: 'الشهر',
                maxLength: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'مطلوب';
                  }
                  final month = int.tryParse(value);
                  if (month == null || month < 1 || month > 12) {
                    return 'خطأ';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 12),
            // Day Field
            Expanded(
              flex: 1,
              child: _buildDatePart(
                controller: dayController,
                hint: 'اليوم',
                maxLength: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'مطلوب';
                  }
                  final day = int.tryParse(value);
                  if (day == null || day < 1 || day > 31) {
                    return 'خطأ';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePart({
    required TextEditingController controller,
    required String hint,
    required int maxLength,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: maxLength,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: cairoFontFamily,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      validator: validator,
    );
  }
}




