import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category.dart';

class CategoryItem extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 120, // نفس القيود اللي جاية من Grid/List
        width: 80,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image takes remaining space
            Expanded(
              child: category.imageUrl != null &&
                  category.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: category.imageUrl!,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) =>
                    Image.asset(
                      'assets/images/programing.png',
                      fit: BoxFit.contain,
                    ),
              )
                  : Image.asset(
                'assets/images/programing.png',
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 4),

            // Category Name (fixed height, no overflow)
            SizedBox(
              height: 28, // يكفي سطرين
              child: Text(
                category.nameAr,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: cairoFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




