class AppConstants {
  // App Info
  static const String appName = 'Learnify';
  static const String appVersion = '1.0.0';
// About App Text
  static const String aboutAppText = '''هو تطبيق تعليمي شامل للأطفال بنعلم فيه أولادنا بمتعة وحب مش حفظ وضغط من خلال كورسات ممتعة في اللغات والرسم والبرمجة وتنمية التفكير والإبداع مصممة خصيصاً تناسب أعمارهم وتخلي التعلم تجربة ممتعة خطوة بخطوة بمحتوى آمن ومسجل مسبقاً وواجهة سهلة تشجع الطفل يعتمد على نفسه، وكل ده باشتراك واحد يفتح كل الكورسات علشان الطفل يتعلم في أي وقت ومن أي مكان ويبقى الأمر يكون مطمئن''';

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 10;

  // Cache
  static const String cacheBox = 'learnify_cache';
  static const Duration cacheExpiration = Duration(hours: 24);

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  static const String keyIsFirstTime = 'is_first_time';
  static const String keyLanguage = 'language';
  static const String keyContentPreferencesCompleted = 'content_preferences_completed';

  // Remember Me (secure)
  static const String keyRememberedPassword = 'remembered_password';
}


