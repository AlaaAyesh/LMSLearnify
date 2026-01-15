import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../../../core/theme/app_colors.dart';

class OptionsRow extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool> onRememberChanged;

  const OptionsRow({
    super.key,
    required this.rememberMe,
    required this.onRememberChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.spacing(context, 8), horizontal: Responsive.spacing(context, 12) ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Remember Me Section
          GestureDetector(
            onTap: () => onRememberChanged(!rememberMe),
            child: Row(
              children: [
                SizedBox(
                  width: Responsive.width(context, 8),
                  height: Responsive.height(context, 8),
                  child: Padding(
                    padding: EdgeInsets.all( Responsive.spacing(context, 4)),
                    child: Checkbox(

                      value: rememberMe,
                      onChanged: (v) => onRememberChanged(v ?? false),
                      activeColor: AppColors.primary,
                      checkColor: Colors.white,
                      side: const BorderSide(
                        color: AppColors.black,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Responsive.spacing(context, 8)),
                Text(
                  'تذكرني',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 14),
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Forgot Password Section
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed('/forgot-password'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'هل نسيت كلمة المرور؟',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, 14),
                color: AppColors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}