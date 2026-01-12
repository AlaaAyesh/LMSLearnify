import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../utils/responsive.dart';

class CustomBackground extends StatelessWidget {
  const CustomBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: Responsive.height(context, 20),
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
          top: Responsive.height(context, 140),
          right: Responsive.width(context, 190),
          child: Transform.rotate(
            angle: 0.25,
            child: SvgPicture.asset(
              'assets/icons/code1.svg',
              width: Responsive.width(context, 50),
            ),
          ),
        ),
        Positioned(
          top: Responsive.height(context, 350),
          left: Responsive.width(context, 30),
          child: Transform.rotate(
            angle: 0.25,
            child: SvgPicture.asset(
              'assets/icons/laptop.svg',
              width: Responsive.width(context, 70),
            ),
          ),
        ),
        Positioned(
          top: Responsive.height(context, 250),
          right: Responsive.width(context, 70),
          child: Transform.rotate(
            angle: 270,
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
        Positioned(
          bottom: Responsive.height(context, 175),
          left: Responsive.width(context, 180),
          child: Transform.rotate(
            angle: -0.3,
            child: SvgPicture.asset(
              'assets/icons/sun1.svg',
              width: Responsive.width(context, 80),
            ),
          ),
        ),



      ],
    );
  }
}


