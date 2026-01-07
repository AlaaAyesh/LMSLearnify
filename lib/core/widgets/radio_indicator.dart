import 'package:flutter/material.dart';
class RadioIndicator extends StatelessWidget {
  final bool isSelected;

  const RadioIndicator({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFB800), width: 2),
        color: Colors.transparent,
      ),
      child: isSelected
          ? Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFB800),
          ),
        ),
      )
          : null,
    );
  }
}


