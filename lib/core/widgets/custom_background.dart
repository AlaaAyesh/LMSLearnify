import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomBackground extends StatelessWidget {
  const CustomBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 20,
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
          top: 140,
          right: 190,
          child: Transform.rotate(
            angle: 0.25,
            child: SvgPicture.asset(
              'assets/icons/code1.svg',
              width: 50,
            ),
          ),
        ),
        Positioned(
          top: 350,
          left: 30,
          child: Transform.rotate(
            angle: 0.25,
            child: SvgPicture.asset(
              'assets/icons/laptop.svg',
              width: 70,
            ),
          ),
        ),
        Positioned(
          top: 250,
          right: 70,
          child: Transform.rotate(
            angle: 270,
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
        Positioned(
          bottom: 175,
          left: 180,
          child: Transform.rotate(
            angle: -0.3,
            child: SvgPicture.asset(
              'assets/icons/sun1.svg',
              width: 80,
            ),
          ),
        ),



      ],
    );
  }
}


