import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/utils/responsive.dart';

class ReligionField extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const ReligionField({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: selectedValue,
      validator: validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: Responsive.width(context, 342),
              height: Responsive.height(context, 52),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Responsive.radius(context, 24)),
                  border: Border.all(
                    color: state.hasError
                        ? AppColors.error
                        : const Color(0xFFDEE1E6),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.spacing(context, 20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.mosque_outlined,
                      color: AppColors.primary,
                      size: Responsive.iconSize(context, 24),
                    ),
                    SizedBox(width: Responsive.spacing(context, 20)),

                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedValue,
                          isExpanded: true,
                          hint: Text(
                            'الديانة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: Responsive.fontSize(context, 20),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF565D6D),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: Responsive.fontSize(context, 20),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: Responsive.iconSize(context, 24),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: 'muslim',
                              child: Text(
                                'مسلم',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: Responsive.fontSize(context, 20),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'christian',
                              child: Text(
                                'مسيحي',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: Responsive.fontSize(context, 20),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            state.didChange(value);
                            onChanged(value);
                          },
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(
                  left: Responsive.spacing(context, 20),
                  top: Responsive.spacing(context, 4),
                ),
                child: Text(
                  state.errorText ?? '',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 12),
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}