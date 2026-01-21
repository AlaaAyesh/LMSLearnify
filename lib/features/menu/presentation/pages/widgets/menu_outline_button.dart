import 'package:flutter/material.dart';
import 'package:learnify_lms/core/utils/responsive.dart';

class MenuOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const MenuOutlineButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final height = Responsive.height(context, 64).clamp(52.0, 78.0);
    final radius = Responsive.radius(context, 20);
    final fontSize = Responsive.fontSize(context, 20);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: Responsive.width(context, 20)),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Cairo',
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: Responsive.width(context, 18)),
            Icon(
              Icons.arrow_forward_rounded,
              size: Responsive.iconSize(context, 22),
            ),


          ],
        ),
      ),
    );
  }
}



