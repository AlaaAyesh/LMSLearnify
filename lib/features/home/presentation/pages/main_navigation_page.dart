import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../menu/presentation/pages/menu_page.dart';
import '../../../shorts/presentation/pages/shorts_page.dart';
import '../../../subscriptions/presentation/pages/subscriptions_page.dart';
import 'home_tab.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => MainNavigationPageState();
}

class MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  
  // Global keys for each tab's navigator
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // Track if we should show bottom nav (for full screen pages)
  bool _showBottomNav = true;

  void setShowBottomNav(bool show) {
    if (_showBottomNav != show) {
      setState(() => _showBottomNav = show);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Handle back button - pop the current tab's navigator first
        final currentNavigator = _navigatorKeys[_selectedIndex].currentState;
        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
        } else {
          // Allow system back if we can't pop
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildNavigator(0, const HomeTab()),
            _buildNavigator(1, const ShortsPage()),
            _buildNavigator(2, const SubscriptionsPage(showBackButton: false)),
            _buildNavigator(3, const MenuPage()),
          ],
        ),
        bottomNavigationBar: _showBottomNav 
            ? _buildBottomNavigationBar()
            : null,
      ),
    );
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => child,
          settings: settings,
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000), // 5% black opacity
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'الرئيسية'),
              _buildNavItem(1, Icons.play_circle_outline, Icons.play_circle, 'شورتس'),
              _buildNavItem(2, Icons.diamond_outlined, Icons.diamond, 'الاشتراك'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'ملفي'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_selectedIndex == index) {
          _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: cairoFontFamily,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to push a page onto the current tab's navigator
  void pushPage(Widget page) {
    _navigatorKeys[_selectedIndex].currentState?.push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // Method to switch to a specific tab
  void switchToTab(int index) {
    setState(() => _selectedIndex = index);
  }
}

// Extension to easily access MainNavigationPage from anywhere
extension MainNavigationContext on BuildContext {
  MainNavigationPageState? get mainNavigation {
    return findAncestorStateOfType<MainNavigationPageState>();
  }
  
  void pushWithNav(Widget page) {
    mainNavigation?.pushPage(page);
  }
}




