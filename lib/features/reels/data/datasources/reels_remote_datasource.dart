import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/reels_feed_meta_model.dart';
import '../models/reels_feed_response_model.dart';

abstract class ReelsRemoteDataSource {
  /// Get reels feed with pagination
  /// [perPage] - Number of reels per page (default: 10)
  /// [cursor] - Cursor for pagination (null for first page)
  /// Throws [ServerException] on failure
  Future<ReelsFeedResponseModel> getReelsFeed({
    int perPage = 10,
    String? cursor,
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
}

class ReelsRemoteDataSourceImpl implements ReelsRemoteDataSource {
  final DioClient dioClient;

  ReelsRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ReelsFeedResponseModel> getReelsFeed({
    int perPage = 10,
    String? cursor,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'per_page': perPage,
      };

      if (cursor != null && cursor.isNotEmpty) {
        queryParams['cursor'] = cursor;
      }

      final response = await dioClient.get(
        ApiConstants.reelsFeed,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return ReelsFeedResponseModel.fromJson(responseData['data']);
        }

        // Handle case where data might be at root level
        if (responseData['data'] != null && responseData['meta'] != null) {
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
}


