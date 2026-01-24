import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_colors.dart';
import 'package:learnify_lms/core/utils/responsive.dart';

class CertificatePlanCard extends StatelessWidget {
  final String courseName;
  final String description;
  final VoidCallback onView;
  final VoidCallback onDownload;

  const CertificatePlanCard({
    super.key,
    required this.courseName,
    required this.description,
    required this.onView,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final titleSize = Responsive.fontSize(context, 22);
    final descriptionSize = Responsive.fontSize(context, 16);
    final actionHeight = Responsive.height(context, 44);
    final horizontalPadding = Responsive.width(context, 24);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.width(context, 20)),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.black,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '• $courseName',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: titleSize,
              height: 1.25,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 6)),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: descriptionSize,
              height: 1.4,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 14)),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;
              final spacing = Responsive.width(context, 10);

              Widget buildButton({
                required Color background,
                required Color foreground,
                required String label,
                required IconData icon,
                required VoidCallback onTap,
                required FontWeight fontWeight,
              }) {
                return SizedBox(
                  height: actionHeight,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: background,
                      foregroundColor: foreground,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: Responsive.fontSize(context, 15),
                            fontWeight: fontWeight,
                          ),
                        ),
                        SizedBox(width: Responsive.width(context, 6)),
                        Icon(
                          icon,
                          size: Responsive.iconSize(context, 20),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (isCompact) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildButton(
                      background: AppColors.greyLight,
                      foreground: Colors.black,
                      label: 'مشاهدة',
                      icon: Icons.visibility_outlined,
                      onTap: onView,
                      fontWeight: FontWeight.w700,

                    ),
                    buildButton(
                      background: AppColors.primary,
                      foreground: Colors.white,
                      label: 'تحميل',
                      icon: Icons.download_outlined,
                      onTap: onDownload,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                );
              }

              return   Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildButton(
                    background: AppColors.greyLight,
                    foreground: Colors.black,
                    label: 'مشاهدة',
                    icon: Icons.visibility_outlined,
                    onTap: onView,
                    fontWeight: FontWeight.w700,
                  ),
                  buildButton(
                    background: AppColors.primary,
                    foreground: Colors.white,
                    label: 'تحميل',
                    icon: Icons.download_outlined,
                    onTap: onDownload,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}