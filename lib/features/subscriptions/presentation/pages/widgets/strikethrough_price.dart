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
            fontFamily: cairoFontFamily,
            fontSize: Responsive.fontSize(context, 22),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Positioned(
          top: Responsive.height(context, 10),
          left: -Responsive.width(context, 5),
          right: -Responsive.width(context, 5),
          child: Transform.rotate(
            angle: -0.35,
            child: Container(
              height: Responsive.height(context, 2.5),
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



