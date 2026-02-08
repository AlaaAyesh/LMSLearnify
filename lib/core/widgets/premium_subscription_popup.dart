import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_colors.dart';
import 'package:learnify_lms/core/utils/responsive.dart';

class PremiumSubscriptionPopup extends StatelessWidget {
  final VoidCallback? onSubscribe;
  final VoidCallback? onClose;
  final String title;
  final String subtitle;
  final String subscribeButtonText;

  const PremiumSubscriptionPopup({
    super.key,
    this.onSubscribe,
    this.onClose,
    this.title = 'هل تريد فتح باقي الدروس وكل كورسات التطبيق ؟',
    this.subtitle = 'استمتع بأكثر من باقة متاحة لابنك',
    this.subscribeButtonText = 'اشترك الآن',
  });

  static const double _baseCardWidth = 280;
  static const double _baseCardHeight = 320;
  static const double _baseRadius = 28;
  static const double _baseRingWidth = 6;

  @override
  Widget build(BuildContext context) {
    final cardWidth = Responsive.isTablet(context)
        ? Responsive.width(context, _baseCardWidth).clamp(280.0, 380.0)
        : Responsive.width(context, _baseCardWidth);
    final cardHeight = Responsive.isTablet(context)
        ? Responsive.height(context, _baseCardHeight).clamp(300.0, 420.0)
        : Responsive.height(context, _baseCardHeight);
    final pillRadius = cardWidth / 2;
    final ringWidth = Responsive.width(context, _baseRingWidth);
    final haloSize = Responsive.width(context, 320);
    final radius = Responsive.radius(context, _baseRadius);
    final hPad = Responsive.spacing(context, 18);
    final vPad = Responsive.spacing(context, 18);
    final titleSize = Responsive.fontSize(context, 18);
    final subtitleSize = Responsive.fontSize(context, 15);
    final btnSize = Responsive.fontSize(context, 16);
    final space1 = Responsive.spacing(context, 8);
    final space2 = Responsive.spacing(context, 14);
    final btnPadding = Responsive.spacing(context, 12);
    final closeSize = Responsive.iconSize(context, 22);
    final closePad = Responsive.spacing(context, 10);
    final closeTop = -Responsive.spacing(context, 14);
    final blur1 = Responsive.width(context, 48);
    final blur2 = Responsive.width(context, 72);
    final spread1 = Responsive.width(context, 8);
    final spread2 = Responsive.width(context, 16);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            child: Container(
              width: haloSize,
              height: haloSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: blur1,
                    spreadRadius: spread1,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: blur2,
                    spreadRadius: spread2,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: cardWidth + ringWidth * 2,
              height: cardHeight + ringWidth * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(pillRadius + ringWidth),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: ringWidth,
                ),
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: cardWidth,
              height: cardHeight,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              decoration: BoxDecoration(
                color: AppColors.primaryCard,
                borderRadius: BorderRadius.circular(pillRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.06),
                    blurRadius: Responsive.width(context, 24),
                    offset: Offset(0, Responsive.height(context, 8)),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: Responsive.width(context, 16),
                    offset: Offset(0, Responsive.height(context, 4)),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: space1),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: subtitleSize,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: space2),
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onSubscribe,
                        borderRadius: BorderRadius.circular(radius),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: btnPadding),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(radius),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: Responsive.width(context, 10),
                                offset: Offset(0, Responsive.height(context, 4)),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              subscribeButtonText,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: btnSize,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: closeTop,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClose,
                customBorder: const CircleBorder(),
                child: Container(
                  padding: EdgeInsets.all(closePad),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: Responsive.width(context, 10),
                        offset: Offset(0, Responsive.height(context, 3)),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    size: closeSize,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumDialogCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onClose;
  final bool showCloseButton;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool ovalShape;

  const PremiumDialogCard({
    super.key,
    required this.child,
    this.onClose,
    this.showCloseButton = true,
    this.maxWidth,
    this.padding,
    this.ovalShape = false,
  });

  @override
  Widget build(BuildContext context) {
    final ringWidth = Responsive.width(context, 6);
    final haloSize = Responsive.width(context, 340);
    final closeSize = Responsive.iconSize(context, 22);
    final closePad = Responsive.spacing(context, 10);
    final contentPadding = padding ?? EdgeInsets.all(Responsive.spacing(context, 24));

    final double cardWidth;
    final double radius;
    if (ovalShape) {
      cardWidth = Responsive.isTablet(context)
          ? Responsive.width(context, 280).clamp(280.0, 340.0)
          : Responsive.width(context, 280);
      radius = cardWidth / 2;
    } else {
      radius = Responsive.radius(context, 28);
      cardWidth = (maxWidth ?? Responsive.width(context, 340)).clamp(0.0, double.infinity);
    }

    final cardMaxWidth = ovalShape ? cardWidth : (maxWidth ?? Responsive.width(context, 340));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            child: Container(
              width: haloSize,
              height: haloSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: Responsive.width(context, 48),
                    spreadRadius: Responsive.width(context, 8),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: Responsive.width(context, 72),
                    spreadRadius: Responsive.width(context, 16),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: ovalShape ? cardWidth : null,
              constraints: ovalShape
                  ? BoxConstraints(maxWidth: cardWidth)
                  : BoxConstraints(maxWidth: cardMaxWidth),
              decoration: BoxDecoration(
                color: AppColors.primaryCard,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: ringWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.06),
                    blurRadius: Responsive.width(context, 24),
                    offset: Offset(0, Responsive.height(context, 8)),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: Responsive.width(context, 16),
                    offset: Offset(0, Responsive.height(context, 4)),
                  ),
                ],
              ),
              child: Padding(
                padding: contentPadding,
                child: child,
              ),
            ),
          ),
          if (showCloseButton)
            Positioned(
              top: -Responsive.spacing(context, 8),
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onClose,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: EdgeInsets.all(closePad),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: Responsive.width(context, 10),
                          offset: Offset(0, Responsive.height(context, 3)),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                      size: closeSize,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PremiumOvalPopup extends StatelessWidget {
  final Widget child;
  final VoidCallback? onClose;
  final bool showCloseButton;

  const PremiumOvalPopup({
    super.key,
    required this.child,
    this.onClose,
    this.showCloseButton = false,
  });

  static const double _baseCardWidth = 280;
  static const double _baseCardHeight = 360;

  @override
  Widget build(BuildContext context) {
    final cardWidth = Responsive.isTablet(context)
        ? Responsive.width(context, _baseCardWidth).clamp(280.0, 340.0)
        : Responsive.width(context, _baseCardWidth);
    final cardHeight = Responsive.height(context, _baseCardHeight);
    final pillRadius = cardWidth / 2;
    final ringWidth = Responsive.width(context, 6);
    final haloSize = Responsive.width(context, 320);
    final closeSize = Responsive.iconSize(context, 22);
    final closePad = Responsive.spacing(context, 10);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            child: Container(
              width: haloSize,
              height: haloSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: Responsive.width(context, 48),
                    spreadRadius: Responsive.width(context, 8),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: Responsive.width(context, 72),
                    spreadRadius: Responsive.width(context, 16),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: cardWidth + ringWidth * 2,
              height: cardHeight + ringWidth * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(pillRadius + ringWidth),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: ringWidth,
                ),
              ),
            ),
          ),
          Positioned(
            child: Container(
              width: cardWidth,
              height: cardHeight,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.spacing(context, 20),
                vertical: Responsive.spacing(context, 24),
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryCard,
                borderRadius: BorderRadius.circular(pillRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.06),
                    blurRadius: Responsive.width(context, 24),
                    offset: Offset(0, Responsive.height(context, 8)),
                  ),
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: Responsive.width(context, 16),
                    offset: Offset(0, Responsive.height(context, 4)),
                  ),
                ],
              ),
              child: child,
            ),
          ),
          if (showCloseButton)
            Positioned(
              top: -Responsive.spacing(context, 14),
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onClose,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: EdgeInsets.all(closePad),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: Responsive.width(context, 10),
                          offset: Offset(0, Responsive.height(context, 3)),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                      size: closeSize,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PremiumSubscriptionOverlay extends StatelessWidget {
  final VoidCallback? onSubscribe;
  final VoidCallback? onClose;
  final String title;
  final String subtitle;
  final String subscribeButtonText;
  final Color barrierColor;

  const PremiumSubscriptionOverlay({
    super.key,
    this.onSubscribe,
    this.onClose,
    this.title = 'هل تريد فتح باقي الدروس وكل كورسات التطبيق ؟',
    this.subtitle = 'استمتع بأكثر من باقة متاحة لابنك',
    this.subscribeButtonText = 'اشترك الآن',
    this.barrierColor = const Color(0x80000000),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Container(color: barrierColor),
          ),
        ),
        Center(
          child: PremiumSubscriptionPopup(
            onSubscribe: onSubscribe,
            onClose: onClose,
            title: title,
            subtitle: subtitle,
            subscribeButtonText: subscribeButtonText,
          ),
        ),
      ],
    );
  }
}
