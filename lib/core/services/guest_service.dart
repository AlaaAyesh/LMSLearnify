import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class GuestService {
  final SharedPreferences _prefs;

  GuestService(this._prefs);

  /// Check if user is in guest mode
  bool isGuestMode() {
    return _prefs.getBool(AppConstants.keyIsGuestMode) ?? false;
  }

  /// Enable guest mode
  Future<void> enableGuestMode() async {
    await _prefs.setBool(AppConstants.keyIsGuestMode, true);
  }

  /// Disable guest mode (when user logs in)
  Future<void> disableGuestMode() async {
    await _prefs.setBool(AppConstants.keyIsGuestMode, false);
  }

  /// Check if feature requires authentication
  bool requiresAuth(String feature) {
    // Features that guests can access
    const guestFeatures = [
      'home',
      'about',
      'courses_browse',
      'free_courses',
      'course_preview',
    ];

    // Features that require authentication
    const authFeatures = [
      'profile',
      'certificates',
      'my_courses',
      'premium_content',
      'course_enroll',
    ];

    return authFeatures.contains(feature);
  }
}


