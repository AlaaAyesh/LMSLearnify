import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';

class ReelPaywallWidget extends StatelessWidget {
  final VoidCallback onSubscribe;
  final VoidCallback? onDismiss;
  final String? thumbnailUrl;

  const ReelPaywallWidget({
    super.key,
    required this.onSubscribe,
    this.onDismiss,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image with yellow overlay
        if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: thumbnailUrl!,
            fit: BoxFit.cover,
            color: AppColors.primary.withOpacity(0.7),
            colorBlendMode: BlendMode.overlay,
            placeholder: (context, url) => Container(
              color: AppColors.primary,
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.primary,
            ),
          )
        else
          Container(
            color: AppColors.primary,
          ),
        
        // Content overlay
        Container(
          color: Colors.black.withOpacity(0.3),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: Responsive.padding(context, all: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lock Icon
                    Icon(
                      Icons.lock_outline,
                      size: Responsive.iconSize(context, 80),
                      color: Colors.white,
                    ),
                    SizedBox(height: Responsive.spacing(context, 24)),
                    
                    // Title
                    Text(
                      'اشترك لفتح باقي الفيديوهات',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: Responsive.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Responsive.spacing(context, 32)),
                    
                    // Subscribe Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onSubscribe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: Responsive.padding(context, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                          ),
                        ),
                        child: Text(
                          'اشترك من هنا',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}

