import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/transactions_response_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<TransactionsResponseModel> getMyTransactions({
    int? page,
    String? nextPageUrl,
  });
}

class TransactionsRemoteDataSourceImpl implements TransactionsRemoteDataSource {
  final DioClient dioClient;

  TransactionsRemoteDataSourceImpl(this.dioClient);

  @override
  Future<TransactionsResponseModel> getMyTransactions({
    int? page,
    String? nextPageUrl,
  }) async {
    try {
      String endpoint = ApiConstants.myTransactions;
      Map<String, dynamic>? queryParams;

      if (nextPageUrl != null && nextPageUrl.isNotEmpty) {
        final uri = Uri.parse(nextPageUrl);

        if (nextPageUrl.startsWith('http')) {
          final pathParts = uri.path.split('/api/');
          if (pathParts.length > 1) {
            endpoint = pathParts[1];
          } else {
            endpoint = uri.path.replaceFirst('/', '');
          }
        } else {
          endpoint = nextPageUrl.replaceFirst('/api/', '').replaceFirst('api/', '');
        }
        
        queryParams = uri.queryParameters.isNotEmpty ? uri.queryParameters : null;
      } else {
        queryParams = <String, dynamic>{};
        if (page != null) {
          queryParams['page'] = page;
        }
      }

      final response = await dioClient.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return TransactionsResponseModel.fromJson(responseData);
        }

        if (responseData['data'] != null) {
          return TransactionsResponseModel.fromJson(responseData);
        }
        
        throw ServerException(
          message: 'تنسيق استجابة غير متوقع',
          statusCode: response.statusCode,
        );
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في جلب المعاملات',
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
