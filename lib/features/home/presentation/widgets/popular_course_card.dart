import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/course.dart';

class PopularCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const PopularCourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.isInfinite
            ? MediaQuery.of(context).size.width * 0.42
            : constraints.maxWidth;

        final radius = cardWidth * 0.09;
        final imageHeight = cardWidth * 0.75;
        final playSize = cardWidth * 0.26;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: cardWidth,
            margin: EdgeInsets.only(
              left: cardWidth * 0.04,
              top: cardWidth * 0.04,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x21FFBB00),
                  blurRadius: 7,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: Color(0x14171A1F),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
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

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: cardWidth * 0.06,
                    vertical: cardWidth * 0.05,
                  ),
                  child: Text(
                    course.nameAr,
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: cardWidth * 0.070,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF171A1F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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