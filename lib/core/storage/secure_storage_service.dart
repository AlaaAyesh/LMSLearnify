import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // Save Access Token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: token);
  }

  // Get Access Token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.keyAccessToken);
  }

  // Save Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.keyRefreshToken, value: token);
  }

  // Get Refresh Token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.keyRefreshToken);
  }

  // Save User ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConstants.keyUserId, value: userId);
  }

  // Get User ID
  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.keyUserId);
  }

  // Clear All
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Delete Specific Key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Remembered Password (secure)
  Future<void> saveRememberedPassword(String password) async {
    await _storage.write(key: AppConstants.keyRememberedPassword, value: password);
  }

  Future<String?> getRememberedPassword() async {
    return await _storage.read(key: AppConstants.keyRememberedPassword);
  }

  Future<void> clearRememberedPassword() async {
    await _storage.delete(key: AppConstants.keyRememberedPassword);
  }
}


