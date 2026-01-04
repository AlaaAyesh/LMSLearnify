import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/home_data_model.dart';

abstract class HomeRemoteDataSource {
  /// Get home page data (banners + latest courses)
  /// Throws [ServerException] on failure
  Future<HomeDataModel> getHomeData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient dioClient;

  HomeRemoteDataSourceImpl(this.dioClient);

  @override
  Future<HomeDataModel> getHomeData() async {
    try {
      final response = await dioClient.get(ApiConstants.homeApi);

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Handle different response structures
        if (responseData['data'] != null) {
          return HomeDataModel.fromJson(responseData['data']);
        } else if (responseData['banners'] != null || responseData['latest_courses'] != null) {
          return HomeDataModel.fromJson(responseData);
        }
        
        return const HomeDataModel();
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في جلب البيانات',
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
}

