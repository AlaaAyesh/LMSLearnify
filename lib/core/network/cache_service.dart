import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

String _cacheKeyBuilder(RequestOptions request) {
  final cacheUser = request.headers['X-Cache-User'] ?? 'guest';
  return '${cacheUser}_${request.uri}';
}

class CacheService {
  static CacheOptions? _cacheOptions;
  static CacheStore? _cacheStore;

  static Future<void> init() async {
    try {
      _cacheStore = MemCacheStore(
        maxSize: 52428800,
        maxEntrySize: 5242880,
      );

      _cacheOptions = CacheOptions(
        store: _cacheStore!,
        policy: CachePolicy.request,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(days: 7),
        priority: CachePriority.normal,
        cipher: null,
        keyBuilder: _cacheKeyBuilder,
        allowPostMethod: false,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing cache: $e');
      _cacheStore = MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576);
      _cacheOptions = CacheOptions(
        store: _cacheStore!,
        policy: CachePolicy.request,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(days: 7),
        keyBuilder: _cacheKeyBuilder,
      );
    }
  }

  static CacheOptions? get cacheOptions => _cacheOptions;

  static CacheStore? get cacheStore => _cacheStore;

  static Future<void> clearCache() async {
    try {
      await _cacheStore?.clean();
    } catch (e) {
      if (kDebugMode) debugPrint('Error clearing cache: $e');
    }
  }

  static Future<void> clearCacheForPath(String path) async {
    try {
      await _cacheStore?.delete(path);
    } catch (e) {
      if (kDebugMode) debugPrint('Error clearing cache for path: $e');
    }
  }

  static CacheOptions getCacheOptionsForEndpoint({
    required String endpoint,
    Duration? maxAge,
    CachePolicy? policy,
  }) {
    return CacheOptions(
      store: _cacheStore,
      policy: policy ?? CachePolicy.request,
      hitCacheOnErrorExcept: [401, 403],
      maxStale: maxAge ?? AppConstants.cacheExpiration,
      priority: CachePriority.normal,
      keyBuilder: (request) {
        final uri = request.uri;
        return '${uri.path}?${uri.query}';
      },
    );
  }

  static CacheOptions get staticDataCacheOptions => CacheOptions(
    store: _cacheStore,
    policy: CachePolicy.refresh,
    maxStale: AppConstants.longCacheExpiration,
    priority: CachePriority.high,
  );

  static CacheOptions get dynamicDataCacheOptions => CacheOptions(
    store: _cacheStore,
    policy: CachePolicy.request,
    maxStale: AppConstants.shortCacheExpiration,
    priority: CachePriority.normal,
  );
}
