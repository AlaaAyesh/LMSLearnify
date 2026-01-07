import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/storage/hive_service.dart';
import 'core/theme/app_text_styles.dart';

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
    _preloadFonts(),
  ]);
  
  await initDependencies();

  // Disable debug print in release mode for performance
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(const LearnifyApp());
}

/// Preload Google Fonts to avoid runtime loading delays
Future<void> _preloadFonts() async {
  // Preload Cairo font and cache it
  GoogleFonts.config.allowRuntimeFetching = true;
  // Initialize the cached font family
  cairoFontFamily;
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


