import 'dart:async';
import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/banner.dart';

class BannerCarousel extends StatefulWidget {
  final List<HomeBanner> banners;
  final Function(HomeBanner)? onBannerTap;
  final Duration autoScrollDuration;

  const BannerCarousel({
    super.key,
    required this.banners,
    this.onBannerTap,
    this.autoScrollDuration = const Duration(seconds: 3),
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (widget.banners.length <= 1) return;
    
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (_) {
      if (_pageController.hasClients) {
        final nextPage = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onUserInteraction() {
    // Restart auto-scroll after user interaction
    _stopAutoScroll();
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: GestureDetector(
            onPanDown: (_) => _stopAutoScroll(),
            onPanEnd: (_) => _onUserInteraction(),
            onPanCancel: () => _onUserInteraction(),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.banners.length,
              onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return GestureDetector(
                onTap: () => widget.onBannerTap?.call(banner),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: banner.imageUrl != null && banner.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: banner.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.primary.withOpacity(0.1),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => _buildPlaceholderBanner(banner),
                          )
                        : _buildPlaceholderBanner(banner),
                  ),
                ),
              );
            },
            ),
          ),
        ),
        // Dots indicator
        if (widget.banners.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderBanner(HomeBanner banner) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.campaign,
              size: 48,
              color: Colors.white,
            ),
            if (banner.title != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  banner.title!,
                  style: TextStyle(
                    fontFamily: cairoFontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}




