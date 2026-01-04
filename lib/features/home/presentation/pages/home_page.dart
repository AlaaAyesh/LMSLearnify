// Re-export MainNavigationPage as HomePage for backwards compatibility
export 'main_navigation_page.dart' show MainNavigationPage;

import 'package:flutter/material.dart';
import 'main_navigation_page.dart';

/// HomePage is now an alias for MainNavigationPage
/// which contains the persistent bottom navigation bar
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigationPage();
  }
}
