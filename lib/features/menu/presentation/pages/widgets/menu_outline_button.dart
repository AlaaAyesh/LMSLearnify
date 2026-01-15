import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Cairo',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 24),
            const Icon(Icons.arrow_forward_rounded,size: 24,),


          ],
        ),
      ),
    );
  }
}



