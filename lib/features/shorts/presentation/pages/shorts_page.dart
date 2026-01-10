import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../home/presentation/pages/main_navigation_page.dart';
import '../../../reels/presentation/bloc/reels_bloc.dart';
import '../../../reels/presentation/bloc/reels_event.dart';
import '../../../reels/presentation/pages/reels_feed_page.dart';

/// ShortsPage now directly shows the ReelsFeedPage
/// User scrolls through reels directly when tapping Shorts tab
class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key});

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  ReelsBloc? _reelsBloc;
  bool _hasLoadedOnce = false;
  bool _isActive = false;
  TabIndexNotifier? _tabNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to tab index changes
    final notifier = TabIndexProvider.of(context);
    if (notifier != null && _tabNotifier != notifier) {
      // Remove listener from old notifier
      _tabNotifier?.removeListener(_onTabChanged);
      // Add listener to new notifier
      _tabNotifier = notifier;
      _tabNotifier!.addListener(_onTabChanged);
      // Update active state immediately
      final newIsActive = _tabNotifier!.value == 1; // Shorts tab is index 1
      if (_isActive != newIsActive) {
        _isActive = newIsActive;
      }
    }
  }

  void _onTabChanged() {
    if (_tabNotifier != null && mounted) {
      final newIsActive = _tabNotifier!.value == 1;
      if (_isActive != newIsActive) {
        setState(() {
          _isActive = newIsActive;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabNotifier?.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't load anything until tab is active for the first time
    if (!_hasLoadedOnce) {
      if (_isActive) {
        _hasLoadedOnce = true;
      } else {
        // Return empty black screen when tab has never been active
        return const ColoredBox(color: Colors.black);
      }
    }

    // Use existing bloc if already created, pass current active state
    if (_reelsBloc != null) {
      return BlocProvider.value(
        value: _reelsBloc!,
        child: ReelsFeedPage(
          showBackButton: false,
          freeReelsLimit: 5,
          isTabActive: _isActive,
        ),
      );
    }

    // First time creating bloc
    return BlocProvider(
      create: (_) {
        _reelsBloc = sl<ReelsBloc>()..add(const LoadReelsFeedEvent(perPage: 10));
        return _reelsBloc!;
      },
      child: ReelsFeedPage(
        showBackButton: false,
        freeReelsLimit: 5,
        isTabActive: _isActive,
      ),
    );
  }
}



