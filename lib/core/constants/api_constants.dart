class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.learnify-stage.xyz/api/';

  // Auth Endpoints
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String logout = 'auth/logout';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';
  static const String changePassword = 'auth/change-password';
  static const String saveFirebaseToken = 'auth/save-firebase-token';

  // OAuth Endpoints
  static const String googleAuth = 'auth/google';
  static const String googleCallback = 'auth/google/callback';
  static const String mobileOAuthLogin = 'auth/mobile/login';

  // Email Verification Endpoints
  static const String sendEmailOtp = 'auth/email/send-otp';
  static const String verifyEmailOtp = 'auth/email/verify-otp';
  static const String checkEmailVerification = 'auth/check-email-verification';

  // User Endpoints
  static const String profile = 'user/profile';
  static const String updateProfile = 'auth/update-profile';

  // Courses Endpoints
  static const String courses = 'courses';
  static const String courseDetails = 'courses/';
  static const String enrollCourse = 'courses/{id}/enroll';
  // Backend endpoint for authenticated user's courses
  static const String myCourses = 'myCourses';

  // Lessons Endpoints
  static const String lessons = 'lessons';

  // Chapters Endpoints
  static const String chapters = 'chapters';

  // Certificates Endpoints
  static const String generateCertificate = 'certificates/request';
  static const String ownedCertificates = 'owned-certificates';

  // Home Endpoints
  static const String homeApi = 'homeAPI';

  // Subscription Endpoints
  static const String subscriptions = 'subscriptions';

  // Coupon Endpoints
  static const String validateCoupon = 'coupons/validate';

  // Payment Endpoints
  static const String processPayment = 'payments/process';
  // IAP Endpoints
  static const String validateIapReceipt = 'iap/validate-receipt';


  // Reels Endpoints
  static const String reelsFeed = 'reels/feed';
  static const String recordReelView = 'reels/{id}/views';
  static const String likeReel = 'reels/{id}/like';
  static const String reelCategoriesWithReels = 'reel-categories/with-reels';
  static const String userReels = 'users/{userId}/reels';
  static const String userLikedReels = 'users/{userId}/reels/liked';

  // Banners Endpoints
  static const String siteBanners = 'site-banners';
  static const String recordBannerClick = 'site-banners/{id}/click';
}


