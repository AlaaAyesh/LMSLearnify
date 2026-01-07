import 'dart:convert';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<String?> getAccessToken();
  Future<bool> isLoggedIn();
  Future<void> saveGuestMode(bool isGuest); // 🆕
  Future<bool> isGuestMode(); // 🆕
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final HiveService hiveService;
  final SecureStorageService secureStorage;

  static const String cachedUserKey = 'cached_user';
  static const String guestModeKey = 'guest_mode'; // 🆕

  AuthLocalDataSourceImpl({
    required this.hiveService,
    required this.secureStorage,
  });

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await hiveService.saveData(cachedUserKey, json.encode(user.toJson()));
    } catch (e) {
      throw CacheException(message: 'فشل حفظ بيانات المستخدم');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = await hiveService.getData(cachedUserKey);
      if (jsonString != null) {
        return UserModel.fromJson(json.decode(jsonString));
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'فشل قراءة بيانات المستخدم');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await hiveService.deleteData(cachedUserKey);
      await hiveService.deleteData(guestModeKey); // 🆕 مسح حالة الضيف
      await secureStorage.clearAll();
    } catch (e) {
      throw CacheException(message: 'فشل مسح البيانات');
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await secureStorage.saveAccessToken(accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await secureStorage.saveRefreshToken(refreshToken);
      }
    } catch (e) {
      throw CacheException(message: 'فشل حفظ التوكن');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await secureStorage.getAccessToken();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      // التحقق من وجود توكن أو حالة ضيف
      final token = await getAccessToken();
      final isGuest = await isGuestMode();
      return (token != null && token.isNotEmpty) || isGuest;
    } catch (e) {
      return false;
    }
  }

  // 🆕 حفظ حالة الضيف
  @override
  Future<void> saveGuestMode(bool isGuest) async {
    try {
      await hiveService.saveData(guestModeKey, isGuest.toString());
    } catch (e) {
      throw CacheException(message: 'فشل حفظ حالة الضيف');
    }
  }

  // 🆕 التحقق من حالة الضيف
  @override
  Future<bool> isGuestMode() async {
    try {
      final value = await hiveService.getData(guestModeKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }
}


