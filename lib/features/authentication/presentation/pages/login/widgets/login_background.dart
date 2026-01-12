import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../../core/utils/responsive.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: Responsive.height(context, 70),
          left: Responsive.width(context, 30),
          child: Transform.rotate(
            angle: -0.3,
            child: SvgPicture.asset(
              'assets/icons/sun1.svg',
              width: Responsive.width(context, 80),
            ),
          ),
        ),
        Positioned(
          top: Responsive.height(context, 160),
          left: Responsive.width(context, 30),
          child: Transform.rotate(
            angle: 0.25,
            child: SvgPicture.asset(
              'assets/icons/code1.svg',
              width: Responsive.width(context, 50),
            ),
          ),
        ),
        Positioned(
          top: Responsive.height(context, 365),
          right: Responsive.width(context, 30),
          child: Transform.rotate(
            angle: 0.3,
            child: SvgPicture.asset(
              'assets/icons/pen011.svg',
              width: Responsive.width(context, 55),
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


