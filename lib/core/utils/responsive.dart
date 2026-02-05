import 'package:flutter/material.dart';

class Responsive {
  Responsive._();

  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  static double width(BuildContext context, double width) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (width / _baseWidth) * screenWidth;
  }

  static double height(BuildContext context, double height) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (height / _baseHeight) * screenHeight;
  }

  static double fontSize(BuildContext context, double fontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / _baseWidth;
    final clampedScale = scaleFactor.clamp(0.8, 1.3);
    return fontSize * clampedScale;
  }

  static EdgeInsets padding(BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) {
      final value = width(context, all);
      return EdgeInsets.all(value);
    }
    
    return EdgeInsets.only(
      top: top != null ? height(context, top) : (vertical != null ? height(context, vertical) : 0),
      bottom: bottom != null ? height(context, bottom) : (vertical != null ? height(context, vertical) : 0),
      left: left != null ? width(context, left) : (horizontal != null ? width(context, horizontal) : 0),
      right: right != null ? width(context, right) : (horizontal != null ? width(context, horizontal) : 0),
    );
  }

  static EdgeInsets margin(BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return padding(context,
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );
  }

  static double radius(BuildContext context, double radius) {
    return width(context, radius);
  }

  static double spacing(BuildContext context, double spacing) {
    return height(context, spacing);
  }

  static bool isTablet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;

    return shortestSide >= 600;
  }

  static bool isPhone(BuildContext context) {
    return !isTablet(context);
  }

  static bool isPortrait(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return !isPortrait(context);
  }

  static double iconSize(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / _baseWidth;
    final clampedScale = scaleFactor.clamp(0.9, 1.4);
    return size * clampedScale;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
}

extension ResponsiveExtension on BuildContext {
  double rw(double width) => Responsive.width(this, width);
  double rh(double height) => Responsive.height(this, height);
  double rf(double fontSize) => Responsive.fontSize(this, fontSize);
  double rr(double radius) => Responsive.radius(this, radius);
  double rs(double spacing) => Responsive.spacing(this, spacing);
  double ri(double iconSize) => Responsive.iconSize(this, iconSize);
  
  double get sw => Responsive.screenWidth(this);
  double get sh => Responsive.screenHeight(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isPhone => Responsive.isPhone(this);
  bool get isPortrait => Responsive.isPortrait(this);
  bool get isLandscape => Responsive.isLandscape(this);
}
