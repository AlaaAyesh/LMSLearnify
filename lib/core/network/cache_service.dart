import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Service for managing HTTP response caching
class CacheService {
  static CacheOptions? _cacheOptions;
  static CacheStore? _cacheStore;

  /// Initialize cache store
  static Future<void> init() async {
    try {
      // Use in-memory cache store (faster and doesn't require file system permissions)
      // 50MB max cache size, 5MB per entry max
      _cacheStore = MemCacheStore(
        maxSize: 52428800, // 50MB
        maxEntrySize: 5242880, // 5MB per entry
      );
      
      // Configure cache options
      _cacheOptions = CacheOptions(
        store: _cacheStore!,
        policy: CachePolicy.request, // Use cache when available, but still make request
        hitCacheOnErrorExcept: [401, 403], // Use cache on error except auth errors
        maxStale: const Duration(days: 7), // Max age for stale cache
        priority: CachePriority.normal,
        cipher: null, // No encryption for performance
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        allowPostMethod: false, // Don't cache POST requests
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing cache: $e');
      // Use smaller memory cache as last resort
      _cacheStore = MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576); // 10MB max, 1MB per entry
      _cacheOptions = CacheOptions(
        store: _cacheStore!,
        policy: CachePolicy.request,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(days: 7),
      );
    }
  }

  /// Get cache options
  static CacheOptions? get cacheOptions => _cacheOptions;

  /// Get cache store
  static CacheStore? get cacheStore => _cacheStore;

  /// Clear all cached responses
  static Future<void> clearCache() async {
    try {
      await _cacheStore?.clean();
    } catch (e) {
      if (kDebugMode) debugPrint('Error clearing cache: $e');
    }
  }

  /// Clear cache for specific path
  static Future<void> clearCacheForPath(String path) async {
    try {
      await _cacheStore?.delete(path);
    } catch (e) {
      if (kDebugMode) debugPrint('Error clearing cache for path: $e');
    }
  }

  /// Get cache options for specific endpoint
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
        // Include query parameters in cache key
        final uri = request.uri;
        return '${uri.path}?${uri.query}';
      },
    );
  }

  /// Cache options for static data (long cache)
  static CacheOptions get staticDataCacheOptions => CacheOptions(
    store: _cacheStore,
    policy: CachePolicy.refresh, // Refresh cache but use it if available
    maxStale: AppConstants.longCacheExpiration,
    priority: CachePriority.high,
  );

  /// Cache options for frequently changing data (short cache)
  static CacheOptions get dynamicDataCacheOptions => CacheOptions(
    store: _cacheStore,
    policy: CachePolicy.request, // Always check server but use cache if available
    maxStale: AppConstants.shortCacheExpiration,
    priority: CachePriority.normal,
  );
}
