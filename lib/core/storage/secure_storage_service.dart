import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.keyRefreshToken);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConstants.keyUserId, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.keyUserId);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

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


