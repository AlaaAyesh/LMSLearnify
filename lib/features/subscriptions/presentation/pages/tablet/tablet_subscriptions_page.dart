import 'package:flutter/material.dart';
import '../../../../../../core/di/injection_container.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/custom_background.dart';
import '../../bloc/subscription_bloc.dart';
import '../../bloc/subscription_event.dart';
import '../../bloc/subscription_state.dart';
import '../subscriptions_page.dart';

/// Tablet-specific subscriptions page with optimized layout
/// Reuses the phone subscriptions page which already has responsive design
class TabletSubscriptionsPage extends StatelessWidget {
  const TabletSubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simply use the phone subscriptions page - it already uses responsive utilities
    // and will adapt to tablet screen size automatically
    return SubscriptionsPage(showBackButton: false);
  }
}
