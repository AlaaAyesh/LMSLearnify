import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    // هنا نسجل Adapters إذا لزم الأمر
  }

  // Open Box
  Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  // Get Cache Box
  Future<Box> getCacheBox() async {
    if (!Hive.isBoxOpen(AppConstants.cacheBox)) {
      return await Hive.openBox(AppConstants.cacheBox);
    }
    return Hive.box(AppConstants.cacheBox);
  }

  // Save Data
  Future<void> saveData(String key, dynamic value) async {
    final box = await getCacheBox();
    await box.put(key, value);
  }

  // Get Data
  Future<dynamic> getData(String key) async {
    final box = await getCacheBox();
    return box.get(key);
  }

  // Delete Data
  Future<void> deleteData(String key) async {
    final box = await getCacheBox();
    await box.delete(key);
  }

  // Clear All
  Future<void> clearAll() async {
    final box = await getCacheBox();
    await box.clear();
  }
}