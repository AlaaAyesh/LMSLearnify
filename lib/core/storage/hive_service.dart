import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  Future<Box> getCacheBox() async {
    if (!Hive.isBoxOpen(AppConstants.cacheBox)) {
      return await Hive.openBox(AppConstants.cacheBox);
    }
    return Hive.box(AppConstants.cacheBox);
  }

  Future<void> saveData(String key, dynamic value) async {
    final box = await getCacheBox();
    await box.put(key, value);
  }

  Future<dynamic> getData(String key) async {
    final box = await getCacheBox();
    return box.get(key);
  }

  Future<void> deleteData(String key) async {
    final box = await getCacheBox();
    await box.delete(key);
  }

  Future<void> clearAll() async {
    final box = await getCacheBox();
    await box.clear();
  }
}


