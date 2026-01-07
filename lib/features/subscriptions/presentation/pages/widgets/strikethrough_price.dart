import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';



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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Positioned(
          top: 10,
          left: -5,
          right: -5,
          child: Transform.rotate(
            angle: -0.35,
            child: Container(
              height: 2.5,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}



