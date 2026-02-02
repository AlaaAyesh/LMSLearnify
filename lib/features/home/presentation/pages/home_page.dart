// Re-export MainNavigationPage as HomePage for backwards compatibility
export 'main_navigation_page.dart' show MainNavigationPage;

import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'main_navigation_page.dart';
import 'tablet/tablet_main_navigation_page.dart';

/// HomePage automatically selects the appropriate navigation page
/// based on device type (phone vs tablet)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use tablet navigation for tablets, phone navigation for phones
    if (Responsive.isTablet(context)) {
      return const TabletMainNavigationPage();
    } else {
      return const MainNavigationPage();
    }
  }
}


