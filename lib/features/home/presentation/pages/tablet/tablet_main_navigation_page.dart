import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:learnify_lms/features/home/presentation/pages/tablet/tablet_home_tab.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/utils/responsive.dart';
import '../../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../../authentication/presentation/bloc/auth_state.dart';
import '../../../../authentication/presentation/pages/register/complete_profile_page.dart';
import '../../../../menu/presentation/pages/tablet/tablet_menu_page.dart';
import '../../../../shorts/presentation/pages/tablet/tablet_shorts_page.dart';
import '../../../../subscriptions/presentation/pages/tablet/tablet_subscriptions_page.dart';
import '../main_navigation_page.dart';


class TabletMainNavigationPage extends StatefulWidget {
  const TabletMainNavigationPage({super.key});

  @override
  State<TabletMainNavigationPage> createState() => _TabletMainNavigationPageState();
}

class _TabletMainNavigationPageState extends State<TabletMainNavigationPage> {
  int _selectedIndex = 0;
  late final TabIndexNotifier _tabIndexNotifier;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _tabIndexNotifier = TabIndexNotifier(_selectedIndex);
  }

  @override
  void dispose() {
    _tabIndexNotifier.dispose();
    super.dispose();
  }

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'الرئيسية',
    ),
    _NavItem(
      icon: Icons.play_circle_outline,
      activeIcon: Icons.play_circle,
      label: 'شورتس',
    ),
    _NavItem(
      icon: Icons.diamond_outlined,
      activeIcon: Icons.diamond,
      label: 'الاشتراك',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'ملفي',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is SocialLoginNeedsCompletion) {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => CompleteProfilePage(
                email: state.email,
                name: state.name,
                providerId: state.providerId,
                accessToken: state.accessToken,
                requiresRegistration: state.requiresRegistration,
              ),
            ),
          );
        }
      },
      child: TabIndexProvider(
        notifier: _tabIndexNotifier,
        child: Scaffold(
          body: Row(
            children: [
              _buildSidebar(context),

              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _buildNavigator(0, const TabletHomeTab()),
                    _buildNavigator(1, const TabletShortsPage()),
                    _buildNavigator(2, const TabletSubscriptionsPage()),
                    _buildNavigator(3, const TabletMenuPage()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final screenWidth = context.sw;
    final sidebarWidth = (screenWidth * 0.20).clamp(220.0, 260.0);

    return Container(
      width: sidebarWidth.toDouble(),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Image.asset(
                'assets/images/app_logo.png',
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: Text(
                      'Learnify',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = _selectedIndex == index;
                  
                  return _buildSidebarItem(
                    context,
                    item: item,
                    index: index,
                    isSelected: isSelected,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(

    BuildContext context, {
    required _NavItem item,
    required int index,
    required bool isSelected,
  }) {
    final media = MediaQuery.of(context);
    final isPortrait = media.orientation == Orientation.portrait;
    final isTabletPortrait =
        isPortrait && media.size.shortestSide >= 600;
    return InkWell(
      onTap: () {
        if (_selectedIndex == index) {
          _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
        } else {
          setState(() {
            _selectedIndex = index;
            _tabIndexNotifier.value = _selectedIndex;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(width: 16),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: isTabletPortrait ?  Responsive.spacing(context, 13) :  Responsive.spacing(context, 18),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
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

  void pushPage(Widget page) {
    _navigatorKeys[_selectedIndex].currentState?.push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void switchToTab(int index) {
    setState(() {
      _selectedIndex = index;
      _tabIndexNotifier.value = _selectedIndex;
    });
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

extension TabletMainNavigationContext on BuildContext {
  _TabletMainNavigationPageState? get tabletMainNavigation {
    return findAncestorStateOfType<_TabletMainNavigationPageState>();
  }
  
  void pushWithNavTablet(Widget page) {
    tabletMainNavigation?.pushPage(page);
  }
}
