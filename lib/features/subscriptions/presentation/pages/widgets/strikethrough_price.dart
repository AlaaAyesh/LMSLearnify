import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../../core/utils/responsive.dart';



class StrikethroughPrice extends StatelessWidget {
  final String price;

  const StrikethroughPrice({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Text(
          price,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: Responsive.fontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Positioned(
          top: Responsive.height(context, 12),
          left: Responsive.width(context, 10),
          right: Responsive.width(context, 10),
          child: Transform.rotate(
            angle: -0.5,
            child: Container(
              height: Responsive.height(context, 2.5),
              width: Responsive.width(context, 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(Responsive.radius(context, 2)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}



