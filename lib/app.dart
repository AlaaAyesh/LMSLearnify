import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection_container.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/reels/presentation/pages/reels_feed_page.dart';

class LearnifyApp extends StatelessWidget {
  const LearnifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(CheckAuthStatusEvent()),
      child: MaterialApp(
      title: 'Learnify',
      debugShowCheckedModeBanner: false,

        themeAnimationDuration: Duration.zero,

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

        navigatorObservers: [routeObserver],

      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,

        builder: (context, child) {
          return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        );
      },
      ),
    );
  }
}


