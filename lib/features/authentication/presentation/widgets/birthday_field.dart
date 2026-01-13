import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/theme/app_colors.dart';

class BirthdayField extends StatelessWidget {
  final TextEditingController dayController;
  final TextEditingController monthController;
  final TextEditingController yearController;
  final String? Function(String?)? validator;

  const BirthdayField({
    super.key,
    required this.dayController,
    required this.monthController,
    required this.yearController,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Responsive.width(context, 342),
      height: Responsive.height(context, 52),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.radius(context, 24)),
          border: Border.all(
            color: const Color(0xFFDEE1E6),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Prefix Icon
            Padding(
              padding: EdgeInsets.only(
                right: Responsive.spacing(context, 20),
                left: Responsive.spacing(context, 10),
              ),
              child: Icon(
                Icons.cake_outlined,
                color: AppColors.primary,
                size: Responsive.iconSize(context, 24),
              ),
            ),

            // Day Field
            Expanded(
              flex: 1,
              child: _buildDatePart(
                context,
                controller: dayController,
                hint: 'اليوم',
                maxLength: 2,
              ),
            ),

            Text(
              '/',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF565D6D),
              ),
            ),

            // Month Field
            Expanded(
              flex: 1,
              child: _buildDatePart(
                context,
                controller: monthController,
                hint: ' الشهر',
                maxLength: 2,
              ),
            ),

            Text(
              '/',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF565D6D),
              ),
            ),

            // Year Field
            Expanded(
              flex: 2,
              child: _buildDatePart(
                context,
                controller: yearController,
                hint: ' السنة ',
                maxLength: 4,
              ),
            ),

            SizedBox(width: Responsive.spacing(context, 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePart(
      BuildContext context, {
        required TextEditingController controller,
        required String hint,
        required int maxLength,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.right,
      maxLength: maxLength,
      style: TextStyle(
        fontSize: Responsive.fontSize(context, 20),
        fontWeight: FontWeight.w500,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: Responsive.fontSize(context, 20),
          fontWeight: FontWeight.w500,
          color: const Color(0xFF565D6D),
        ),
        counterText: '',
        contentPadding: EdgeInsets.zero,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        errorStyle: const TextStyle(
          height: 0,
          fontSize: 0,
        ),
      ),
      validator: validator ?? _defaultValidator(hint, maxLength),
    );
  }

  String? Function(String?) _defaultValidator(String hint, int maxLength) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'مطلوب';
      }

      if (hint == 'اليوم') {
        final day = int.tryParse(value);
        if (day == null || day < 1 || day > 31) {
          return 'خطأ';
        }
      } else if (hint == 'الشهر') {
        final month = int.tryParse(value);
        if (month == null || month < 1 || month > 12) {
          return 'خطأ';
        }
      } else if (hint == 'السنة') {
        final year = int.tryParse(value);
        if (year == null || year < 1900 || year > DateTime.now().year) {
          return 'خطأ';
        }
      }

      return null;
    };
  }
}