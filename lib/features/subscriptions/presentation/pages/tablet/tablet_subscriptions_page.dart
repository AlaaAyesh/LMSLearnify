import 'package:flutter/material.dart';
import '../../../../../../core/di/injection_container.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/custom_background.dart';
import '../../bloc/subscription_bloc.dart';
import '../../bloc/subscription_event.dart';
import '../../bloc/subscription_state.dart';
import '../subscriptions_page.dart';

class TabletSubscriptionsPage extends StatelessWidget {
  const TabletSubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SubscriptionsPage(showBackButton: false);
  }
}
