import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class ForgotPasswordAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ForgotPasswordAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_forward,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


