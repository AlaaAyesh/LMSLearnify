export 'main_navigation_page.dart' show MainNavigationPage;

import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import 'main_navigation_page.dart';
import 'tablet/tablet_main_navigation_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const TabletMainNavigationPage();
    } else {
      return const MainNavigationPage();
    }
  }
}


