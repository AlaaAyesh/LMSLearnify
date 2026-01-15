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
          height: Responsive.height(context, 180),
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
    // Use mobile image if available, otherwise use website image
    final imageUrl = banner.mobileImageUrl.isNotEmpty
        ? banner.mobileImageUrl
        : banner.websiteImageUrl;

    return GestureDetector(
      onTap: () => _handleBannerTap(banner),
      child: Container(
        margin: Responsive.margin(context, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB74D), // Light orange/peach solid color
          borderRadius: BorderRadius.circular(Responsive.radius(context, 20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: Responsive.width(context, 10),
              offset: Offset(0, Responsive.height(context, 4)),
            ),
          ],
        ),
        child: Padding(
          padding: Responsive.padding(context, all: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Headline: "افتح إمكاناتك الكاملة" or banner title
              Flexible(
                child: Text(
                  banner.title.isNotEmpty ? banner.title : 'افتح إمكاناتك الكاملة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 22),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              SizedBox(height: Responsive.spacing(context, 12)),
              
              // Body text: Description or default text
              Flexible(
                child: Text(
                  banner.buttonDescription.isNotEmpty 
                      ? banner.buttonDescription 
                      : 'استكشف آلاف الدورات التدريبية والمدربين الخبراء لتعزيز مهاراتك.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 13),
                    color: Colors.white,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              SizedBox(height: Responsive.spacing(context, 16)),
              
              // "Start Now" Button - centered
              Container(
                padding: Responsive.padding(context, horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Responsive.radius(context, 30)),
                ),
                child: Text(
                  'ابدأ الآن',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 15),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFB74D), // Light orange matching card background
                  ),
                ),
              ),
              
              // Pagination dots inside the card at the bottom
              if (totalBanners > 1) ...[
                SizedBox(height: Responsive.spacing(context, 12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    totalBanners,
                    (index) => Container(
                      width: Responsive.width(context, 8),
                      height: Responsive.height(context, 8),
                      margin: Responsive.margin(context, horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentIndex
                            ? const Color(0xFFFF9800) // Darker orange for active (leftmost)
                            : const Color(0xFFFFB74D).withOpacity(0.6), // Lighter orange for inactive
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
