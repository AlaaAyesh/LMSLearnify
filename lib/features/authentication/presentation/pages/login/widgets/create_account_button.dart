import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../../../core/theme/app_colors.dart';

class CreateAccountButton extends StatelessWidget {
  const CreateAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Responsive.height(context, 56),
      decoration: BoxDecoration(
        color: AppColors.greyLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(Responsive.radius(context, 24)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed('/register'),
          borderRadius: BorderRadius.circular(Responsive.radius(context, 16)),
          child: Padding(
            padding: Responsive.padding(context, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 20),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: Responsive.width(context, 22)),

                Icon(
                  Icons.arrow_forward,
                  color: AppColors.textPrimary,
                  size: Responsive.iconSize(context, 24),
                ),],
            ),
          ),
        ),
      ),
    );
  }
}



