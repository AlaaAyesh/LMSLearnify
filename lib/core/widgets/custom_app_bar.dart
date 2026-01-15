import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../utils/responsive.dart';
import '../theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final bool showBackButton;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,

      title: Padding(
        padding: Responsive.padding(context, horizontal: 20),
        child: Row(
          children: [
            const Spacer(),

            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, 22),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            const Spacer(),


            if (showBackButton)
              GestureDetector(
                onTap: onBack ?? () => Navigator.pop(context),
                child: Container(
                  width: Responsive.width(context, 26),
                  height: Responsive.width(context, 26),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 5)),
                    border: Border.all(
                      color: AppColors.primary,
                      width: Responsive.width(context, 2.5),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: Responsive.iconSize(context, 18),
                    color: AppColors.primary,
                  ),
                ),
              ),



            if (actions != null) ...actions!,
          ],
        ),
      ),

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.grey.withOpacity(0.3),
        ),
      ),
    );
  }
}



