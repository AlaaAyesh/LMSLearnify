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
    final bool isTablet = Responsive.isTablet(context);

    final double backButtonSize =
        isTablet ? 32 : Responsive.width(context, 26);
    final double backIconSize =
        isTablet ? 16 : Responsive.iconSize(context, 18);
    final double backBorderWidth =
        isTablet ? 2 : Responsive.width(context, 2.5);
    final EdgeInsets backPadding = isTablet
        ? const EdgeInsets.all(4)
        : EdgeInsets.all(Responsive.width(context, 8));

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
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ],
              ),
            ),


            const Spacer(),


            if (showBackButton)
              Padding(
                padding: backPadding,
                child: GestureDetector(
                  onTap: onBack ?? () => Navigator.pop(context),
                  child: Container(
                    width: backButtonSize,
                    height: backButtonSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        isTablet
                            ? 6
                            : Responsive.radius(context, 5),
                      ),
                      border: Border.all(
                        color: AppColors.primary,
                        width: backBorderWidth,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: backIconSize,
                      color: AppColors.primary,
                    ),
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



