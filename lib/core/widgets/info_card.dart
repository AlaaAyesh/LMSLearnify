import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../utils/responsive.dart';


class InfoCard extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final TextAlign textAlign;

  const InfoCard({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xFFFDF0D8),
    this.textColor = const Color(0xFF3A3A3A),
    this.fontSize = 20,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 24,
    ),
    this.borderRadius = 24,
    this.textAlign = TextAlign.right,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Responsive.margin(context, all: 16),
      padding: padding is EdgeInsets
          ? Responsive.padding(
              context,
              top: (padding as EdgeInsets).top,
              bottom: (padding as EdgeInsets).bottom,
              left: (padding as EdgeInsets).left,
              right: (padding as EdgeInsets).right,
            )
          : padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Responsive.radius(context, borderRadius)),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: cairoFontFamily,
          fontSize: Responsive.fontSize(context, fontSize),
          height: 1.6,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}



