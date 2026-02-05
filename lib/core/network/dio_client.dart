import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import 'cache_service.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;
  final Map<String, CancelToken> _cancelTokens = {};

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Connection': 'keep-alive',
        },
        persistentConnection: true,
        followRedirects: true,
        maxRedirects: 5,
      ),
    );

    final cacheOptions = CacheService.cacheOptions;
    if (cacheOptions != null) {
      _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
    }

    _dio.interceptors.add(_AuthInterceptor(_secureStorage));

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  void cancelRequest(String tag) {
    _cancelTokens[tag]?.cancel('Request cancelled');
    _cancelTokens.remove(tag);
  }

  void cancelAllRequests() {
    for (final token in _cancelTokens.values) {
      token.cancel('All requests cancelled');
    }
    _cancelTokens.clear();
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        String? cancelTag,
      }) async {
    CancelToken? cancelToken;
    if (cancelTag != null) {
      cancelRequest(cancelTag);
      cancelToken = CancelToken();
      _cancelTokens[cancelTag] = cancelToken;
    }

    final mergedOptions = options ?? Options();

    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
      );

      if (cancelTag != null) {
        _cancelTokens.remove(cancelTag);
      }
      
      return response;
    } catch (e) {
      if (cancelTag != null) {
        _cancelTokens.remove(cancelTag);
      }
      rethrow;
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        String? cancelTag,
      }) async {
    CancelToken? cancelToken;
    if (cancelTag != null) {
      cancelRequest(cancelTag);
      cancelToken = CancelToken();
      _cancelTokens[cancelTag] = cancelToken;
    }

    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      if (cancelTag != null) {
        _cancelTokens.remove(cancelTag);
      }
      
      return response;
    } catch (e) {
      if (cancelTag != null) {
        _cancelTokens.remove(cancelTag);
      }
      rethrow;
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        String? cancelTag,
      }) async {
    CancelToken? cancelToken;
    if (cancelTag != null) {
      cancelRequest(cancelTag);
      cancelToken = CancelToken();
      _cancelTokens[cancelTag] = cancelToken;
    }

    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      if (cancelTag != null) {
        _cancelTokens.remove(cancelTag);
      }
      
      return response;
    } catch (e) {
      if (cancelTag != null) {
        _cancelTokens.remove(cancelTag);
      }
      rethrow;
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        String? cancelTag,
      }) async {
    CancelToken? cancelToken;
    if (cancelTag != null) {
      cancelRequest(cancelTag);
      cancelToken = CancelToken();
      _cancelTokens[cancelTag] = cancelToken;
    }

    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      if (cancelTag != null) {
        _cancelTokens.remove(cancelTag);
      }
      
      return response;
    } catch (e) {
      if (cancelTag != null) {
        _cancelTokens.remove(cancelTag);
      }
      rethrow;
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  _AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}


