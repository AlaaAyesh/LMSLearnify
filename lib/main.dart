import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/storage/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run initialization in parallel for faster startup
  await Future.wait([
    HiveService.init(),
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
    _setSystemUI(),
  ]);
  
  await initDependencies();

  // Disable debug print in release mode for performance
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(const LearnifyApp());
}

Future<void> _setSystemUI() async {
  // Hide only the bottom navigation bar, keep status bar visible
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top], // Only show status bar
  );
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}


