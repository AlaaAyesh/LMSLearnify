import 'package:flutter/material.dart';

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
      margin: const EdgeInsets.all(16),
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontSize,
          height: 1.6,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
