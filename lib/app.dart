import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/reels/presentation/pages/reels_feed_page.dart';

class LearnifyApp extends StatelessWidget {
  const LearnifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnify',
      debugShowCheckedModeBanner: false,

      // Performance optimizations
      themeAnimationDuration: Duration.zero, // Disable theme animation
      
      theme: AppTheme.lightTheme,

      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Route observer for tracking page visibility
      navigatorObservers: [routeObserver],

      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      
      // Performance: Use builder to add performance overlay in debug
      builder: (context, child) {
        // Disable text scaling for consistent UI
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
    );
  }
}


