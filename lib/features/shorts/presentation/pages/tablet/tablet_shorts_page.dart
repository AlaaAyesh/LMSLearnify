import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/di/injection_container.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../reels/presentation/bloc/reels_bloc.dart';
import '../../../../reels/presentation/bloc/reels_event.dart';
import '../../../../reels/presentation/pages/reels_feed_page.dart';
class TabletShortsPage extends StatefulWidget {
  final int? initialIndex;
  
  const TabletShortsPage({super.key, this.initialIndex});

  @override
  State<TabletShortsPage> createState() => _TabletShortsPageState();
}

class _TabletShortsPageState extends State<TabletShortsPage> {
  ReelsBloc? _reelsBloc;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _reelsBloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For tablets, we can show reels in a grid or use the same full-screen experience
    // Here we'll use the same ReelsFeedPage but it will adapt to tablet screen size
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      _reelsBloc = sl<ReelsBloc>()..add(const LoadReelsFeedEvent(perPage: 10));
    }

    return BlocProvider.value(
      value: _reelsBloc!,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ReelsFeedPage(
          initialIndex: widget.initialIndex ?? 0,
          showBackButton: false,
          freeReelsLimit: 5,
          isTabActive: true,
        ),
      ),
    );
  }
}
