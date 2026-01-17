import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/reel_category_model.dart';
import '../models/reels_feed_meta_model.dart';
import '../models/reels_feed_response_model.dart';

abstract class ReelsRemoteDataSource {
  /// Get reels feed with pagination
  /// [perPage] - Number of reels per page (default: 10)
  /// [cursor] - Cursor for pagination (null for first page) - deprecated, use nextPageUrl instead
  /// [nextPageUrl] - Full URL for next page from meta.next_page_url
  /// [categoryId] - Filter reels by category ID (optional)
  /// Throws [ServerException] on failure
  Future<ReelsFeedResponseModel> getReelsFeed({
    int perPage = 10,
    String? cursor,
    String? nextPageUrl,
    int? categoryId,
  });

  /// Record a view for a reel
  /// [reelId] - The ID of the reel being viewed
  /// Throws [ServerException] on failure
  Future<void> recordReelView(int reelId);

  /// Like a reel
  /// [reelId] - The ID of the reel to like
  /// Throws [ServerException] on failure
  Future<void> likeReel(int reelId);

  /// Unlike a reel
  /// [reelId] - The ID of the reel to unlike
  /// Throws [ServerException] on failure
  Future<void> unlikeReel(int reelId);

  /// Get reel categories with their reel counts
  /// Returns a list of categories with the number of reels in each category
  /// Throws [ServerException] on failure
  Future<List<ReelCategoryModel>> getReelCategoriesWithReels();
}

class ReelsRemoteDataSourceImpl implements ReelsRemoteDataSource {
  final DioClient dioClient;

  ReelsRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ReelsFeedResponseModel> getReelsFeed({
    int perPage = 10,
    String? cursor,
    String? nextPageUrl,
    int? categoryId,
  }) async {
    try {
      String endpoint = ApiConstants.reelsFeed;
      Map<String, dynamic>? queryParams;

      // If next_page_url is provided, use it directly
      if (nextPageUrl != null && nextPageUrl.isNotEmpty) {
        // Extract path and query params from next_page_url
        final uri = Uri.parse(nextPageUrl);
        
        // If it's a full URL, extract just the path part (remove base URL)
        if (nextPageUrl.startsWith('http')) {
          // Extract path after /api/
          final pathParts = uri.path.split('/api/');
          if (pathParts.length > 1) {
            endpoint = pathParts[1];
          } else {
            endpoint = uri.path.replaceFirst('/', '');
          }
        } else {
          // Relative URL - remove /api/ prefix if present
          endpoint = nextPageUrl.replaceFirst('/api/', '').replaceFirst('api/', '');
        }
        
        // Extract query parameters from URL
        queryParams = uri.queryParameters.isNotEmpty ? uri.queryParameters : null;
      } else {
        // Build query params for initial request
        queryParams = <String, dynamic>{
          'per_page': perPage,
        };

        // Add category filter if provided
        if (categoryId != null) {
          queryParams['categories'] = categoryId;
        }

        // Support cursor-based pagination if provided (backward compatibility)
        if (cursor != null && cursor.isNotEmpty) {
          queryParams['cursor'] = cursor;
        }
      }

      final response = await dioClient.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle standard response format: { "status": "success", "data": { "items": [...], "meta": {...} } }
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return ReelsFeedResponseModel.fromJson(responseData['data']);
        }

        // Handle case where data and meta are at root level
        if (responseData['data'] != null || responseData['items'] != null) {
          return ReelsFeedResponseModel.fromJson(responseData);
        }

        return const ReelsFeedResponseModel(
          reels: [],
          meta: ReelsFeedMetaModel(perPage: 10, hasMore: false),
        );
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في جلب الفيديوهات',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      // For 401 errors on getReelsFeed, return empty reels instead of throwing error
      // This allows users to view free reels without authentication
      if (e.response?.statusCode == 401) {
        return const ReelsFeedResponseModel(
          reels: [],
          meta: ReelsFeedMetaModel(perPage: 10, hasMore: false),
        );
      }

      String errorMessage = 'خطأ في الاتصال بالخادم';

      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> recordReelView(int reelId) async {
    try {
      final endpoint = ApiConstants.recordReelView.replaceAll('{id}', reelId.toString());
      debugPrint('ReelsDataSource: Recording view - POST $endpoint');
      
      final response = await dioClient.post(endpoint);
      debugPrint('ReelsDataSource: View response status: ${response.statusCode}');
      debugPrint('ReelsDataSource: View response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('ReelsDataSource: View recorded successfully');
        return;
      }

      throw ServerException(
        message: response.data?['message'] ?? 'فشل في تسجيل المشاهدة',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      debugPrint('ReelsDataSource: View DioException - ${e.message}');
      debugPrint('ReelsDataSource: View error response: ${e.response?.data}');
      
      String errorMessage = 'خطأ في الاتصال بالخادم';

      if (e.response?.statusCode == 401) {
        errorMessage = 'يجب تسجيل الدخول أولاً';
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('ReelsDataSource: View unexpected error - $e');
      throw ServerException(message: 'خطأ غير متوقع: $e');
    }
  }

  @override
  Future<void> likeReel(int reelId) async {
    try {
      final endpoint = ApiConstants.likeReel.replaceAll('{id}', reelId.toString());
      debugPrint('ReelsDataSource: Liking reel - POST $endpoint');
      
      final response = await dioClient.post(endpoint);
      debugPrint('ReelsDataSource: Like response status: ${response.statusCode}');
      debugPrint('ReelsDataSource: Like response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('ReelsDataSource: Like recorded successfully');
        return;
      }

      throw ServerException(
        message: response.data?['message'] ?? 'فشل في الإعجاب',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      debugPrint('ReelsDataSource: Like DioException - ${e.message}');
      debugPrint('ReelsDataSource: Like error response: ${e.response?.data}');
      
      String errorMessage = 'خطأ في الاتصال بالخادم';

      if (e.response?.statusCode == 401) {
        errorMessage = 'يجب تسجيل الدخول أولاً';
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('ReelsDataSource: Like unexpected error - $e');
      throw ServerException(message: 'خطأ غير متوقع: $e');
    }
  }

  @override
  Future<void> unlikeReel(int reelId) async {
    try {
      final endpoint = ApiConstants.likeReel.replaceAll('{id}', reelId.toString());
      debugPrint('ReelsDataSource: Unliking reel - DELETE $endpoint');
      
      final response = await dioClient.delete(endpoint);
      debugPrint('ReelsDataSource: Unlike response status: ${response.statusCode}');
      debugPrint('ReelsDataSource: Unlike response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        debugPrint('ReelsDataSource: Unlike recorded successfully');
        return;
      }

      throw ServerException(
        message: response.data?['message'] ?? 'فشل في إلغاء الإعجاب',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      debugPrint('ReelsDataSource: Unlike DioException - ${e.message}');
      debugPrint('ReelsDataSource: Unlike error response: ${e.response?.data}');
      
      String errorMessage = 'خطأ في الاتصال بالخادم';

      if (e.response?.statusCode == 401) {
        errorMessage = 'يجب تسجيل الدخول أولاً';
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('ReelsDataSource: Unlike unexpected error - $e');
      throw ServerException(message: 'خطأ غير متوقع: $e');
    }
  }

  @override
  Future<List<ReelCategoryModel>> getReelCategoriesWithReels() async {
    try {
      final response = await dioClient.get(
        ApiConstants.reelCategoriesWithReels,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Handle standard response format: { "status": "success", "data": { "data": [...] } }
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final data = responseData['data'];
          
          // Check if data is wrapped in another 'data' key
          final categoriesList = data['data'] ?? data;
          
          if (categoriesList is List) {
            return categoriesList
                .map((json) => ReelCategoryModel.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }

        // Handle case where data might be at root level
        if (responseData['data'] is List) {
          return (responseData['data'] as List)
              .map((json) => ReelCategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        return [];
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في جلب فئات الرييلز',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      String errorMessage = 'خطأ في الاتصال بالخادم';

      if (e.response?.statusCode == 401) {
        errorMessage = 'يجب تسجيل الدخول أولاً';
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'خطأ غير متوقع: $e');
    }
  }
}


