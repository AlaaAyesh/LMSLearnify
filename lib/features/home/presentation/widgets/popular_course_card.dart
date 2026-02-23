import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/course.dart';

class PopularCourseCard extends StatelessWidget {
  static const double designWidth = 160.0;
  static const double designHeight = 136.0;
  static const double designRadius = 14.0;

  final Course course;
  final VoidCallback? onTap;
  final double? width;

  const PopularCourseCard({
    super.key,
    required this.course,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? Responsive.width(context, designWidth);
    final cardHeight = Responsive.height(context, designHeight);
    final radius = Responsive.radius(context, designRadius);
    final imageHeight = cardHeight * 0.70;
    final playSize = cardWidth * 0.28;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.only(left: Responsive.width(context, 8)),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: const Color(0x2AFFBB00),
              blurRadius: 12,
              offset: Offset(4, Responsive.height(context, 8)),
            ),
            const BoxShadow(
              color: Color(0x22FFBB00),
              blurRadius: 6,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              height: imageHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(radius),
                    ),
                    child: _buildThumbnail(context, cardWidth, imageHeight),
                  ),
                  Container(
                    width: playSize,
                    height: playSize,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC107),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: playSize * 0.55,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.width(context, 10),
                  vertical: Responsive.height(context, 6),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    course.nameAr,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 12),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF171A1F),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, double cardWidth, double imageHeight) {
    final thumbnailUrl = course.effectiveThumbnail;

    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final cacheW = (cardWidth * dpr).round().clamp(320, 960);
      final cacheH = (imageHeight * dpr).round().clamp(320, 720);
      return CachedNetworkImage(
        imageUrl: thumbnailUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        memCacheWidth: cacheW,
        memCacheHeight: cacheH,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFB4D0F3),
    );
  }
}