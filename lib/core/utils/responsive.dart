import 'package:flutter/material.dart';

/// Responsive utility class for scaling UI elements based on screen size
/// Maintains pixel-perfect design proportions across all devices
class Responsive {
  Responsive._();

  // Base design dimensions (assuming design was made for iPhone 12/13 Pro - 390x844)
  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  /// Get responsive width based on screen width
  static double width(BuildContext context, double width) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (width / _baseWidth) * screenWidth;
  }

  /// Get responsive height based on screen height
  static double height(BuildContext context, double height) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (height / _baseHeight) * screenHeight;
  }

  /// Get responsive font size that scales with screen width
  static double fontSize(BuildContext context, double fontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / _baseWidth;
    // Clamp between 0.8 and 1.3 to prevent extreme scaling
    final clampedScale = scaleFactor.clamp(0.8, 1.3);
    return fontSize * clampedScale;
  }

  /// Get responsive padding
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

  /// Get responsive margin
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

  /// Get responsive border radius
  static double radius(BuildContext context, double radius) {
    return width(context, radius);
  }

  /// Get responsive spacing (for SizedBox)
  static double spacing(BuildContext context, double spacing) {
    return height(context, spacing);
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;

    return shortestSide >= 600;
  }

  /// Check if device is phone
  static bool isPhone(BuildContext context) {
    return !isTablet(context);
  }

  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.orientation == Orientation.portrait;
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return !isPortrait(context);
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / _baseWidth;
    // Clamp حتى لا تكبر الأيقونات جدًا على التابلت أو تصغر كثيرًا على الشاشات الصغيرة
    final clampedScale = scaleFactor.clamp(0.9, 1.4);
    return size * clampedScale;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
}

/// Extension methods for easier responsive usage
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
