import 'dart:async';
import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../banners/domain/entities/banner.dart' as banner_entity;
import '../../../banners/domain/usecases/record_banner_click_usecase.dart';

class SiteBannerCarousel extends StatefulWidget {
  final List<banner_entity.Banner> banners;
  final Duration autoScrollDuration;

  const SiteBannerCarousel({
    super.key,
    required this.banners,
    this.autoScrollDuration = const Duration(seconds: 3),
  });

  @override
  State<SiteBannerCarousel> createState() => _SiteBannerCarouselState();
}

class _SiteBannerCarouselState extends State<SiteBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoScrollTimer;
  final RecordBannerClickUseCase _recordBannerClickUseCase = sl<RecordBannerClickUseCase>();

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
    _stopAutoScroll();
    _startAutoScroll();
  }

  Future<void> _handleBannerTap(banner_entity.Banner banner) async {
    // Record click
    await _recordBannerClickUseCase(banner.id);

    // Open URL
    final uri = Uri.parse(banner.bannerUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeBanners = widget.banners.where((b) => b.isActive).toList();

    if (activeBanners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: Responsive.height(context, 210),
          child: GestureDetector(
            onPanDown: (_) => _stopAutoScroll(),
            onPanEnd: (_) => _onUserInteraction(),
            onPanCancel: () => _onUserInteraction(),
            child: PageView.builder(
              controller: _pageController,
              itemCount: activeBanners.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final banner = activeBanners[index];
                return _buildBannerCard(context, banner, activeBanners.length);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard(BuildContext context, banner_entity.Banner banner, int totalBanners) {
    return GestureDetector(
      onTap: () => _handleBannerTap(banner),
      child: Container(
        margin: Responsive.margin(context, horizontal: 16,vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFC966),
              Color(0xFFFDCA65),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Responsive.radius(context, 22)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x38171a1f),
              blurRadius: 13.75,
              offset: Offset(2, 3),
            ),
            BoxShadow(
              color: Color(0x14171a1f),
              blurRadius: 1,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Padding(
          padding: Responsive.padding(context, horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title at the start
              Padding(
                padding: Responsive.padding(context, top: 18),
                child: Text(
                  banner.title.isNotEmpty ? banner.title : 'Learnify',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Subtitle under title
              if (banner.buttonDescription.isNotEmpty)
                Padding(
                  padding: Responsive.padding(context, top: 4),
                  child: Text(
                    banner.buttonDescription,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 13),
                      color: Colors.white.withOpacity(0.9),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Spacer
              const Spacer(),

              // Button at the end (left aligned)
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(context, 22),
                    vertical: Responsive.height(context, 12),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Responsive.radius(context, 18)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'ابدأ الآن',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFAA33),
                    ),
                  ),
                ),
              ),

              // Circles at the bottom center
              if (totalBanners > 1)
                Padding(
                  padding: Responsive.padding(context, top: 6),
                  child: Center(
                    child: Container(
                      height: Responsive.height(context, 18),
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.width(context, 4),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(Responsive.radius(context, 18)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          totalBanners,
                              (index) => Container(
                            width: Responsive.width(context, 8),
                            height: Responsive.height(context, 8),
                            margin: EdgeInsets.symmetric(horizontal: Responsive.width(context, 3)),
                            decoration: BoxDecoration(
                              color: index == _currentIndex
                                  ? const Color(0xFFFBA051)
                                  : const Color(0xFFFBA051).withOpacity(0.4),
                              shape: BoxShape.circle,
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
    );
  }
}