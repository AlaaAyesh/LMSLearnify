import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';

class LearnifyApp extends StatelessWidget {
  const LearnifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnify',
      debugShowCheckedModeBanner: false,

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

      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
    // test : for build the pages ui
    // return  MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home:  HomePage(),
    // );

  }
}


