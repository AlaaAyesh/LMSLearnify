import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 70,
          left: 30,
          child: Transform.rotate(
            angle: -0.3,
            child: SvgPicture.asset(
              'assets/icons/sun1.svg',
              width: 80,
            ),
          ),
        ),
        Positioned(
          top: 160,
          left: 30,
          child: Transform.rotate(
            angle: 0.25,
            child: SvgPicture.asset(
              'assets/icons/code1.svg',
              width: 50,
            ),
          ),
        ),
        Positioned(
          top: 365,
          right: 30,
          child: Transform.rotate(
            angle: 0.3,
            child: SvgPicture.asset(
              'assets/icons/pen011.svg',
              width: 55,
              colorFilter: ColorFilter.mode(
                Colors.grey.withOpacity(0.08),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
