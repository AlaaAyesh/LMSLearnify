import 'package:flutter/material.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              ' .$courseName ',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24
              )
            ),

            const SizedBox(height: 4),
            Text(
              description,
              style:  const TextStyle(
                  color: Colors.black,
                  fontSize: 18
              )
            ),

            const SizedBox(height: 16),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: onView,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE4E7EB),
            foregroundColor: Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'مشاهدة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.visibility_outlined,
                size: 20,
              ),
            ],
          ),
        ),
      ),

          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: onDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تحميل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.download_outlined,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),


        ],
      ),

          ],
        ),
    );

  }
}
