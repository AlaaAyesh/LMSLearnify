import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/banners_response_model.dart';

abstract class BannersRemoteDataSource {
  /// Get site banners with optional filters
  /// [perPage] - Number of banners per page (default: 10)
  /// [page] - Page number (default: 1)
  /// [fromDate] - Start date filter (format: YYYY-MM-DD)
  /// [toDate] - End date filter (format: YYYY-MM-DD)
  /// [search] - Search query (e.g., "title:Neve")
  /// Throws [ServerException] on failure
  Future<BannersResponseModel> getSiteBanners({
    int perPage = 10,
    int page = 1,
    String? fromDate,
    String? toDate,
    String? search,
  });

  /// Record a click on a banner
  /// [bannerId] - The ID of the banner that was clicked
  /// Throws [ServerException] on failure
  Future<void> recordBannerClick(int bannerId);
}

class BannersRemoteDataSourceImpl implements BannersRemoteDataSource {
  final DioClient dioClient;

  BannersRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BannersResponseModel> getSiteBanners({
    int perPage = 10,
    int page = 1,
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'per_page': perPage,
        'page': page,
      };

      if (fromDate != null && fromDate.isNotEmpty) {
        queryParams['from_date'] = fromDate;
      }
      if (toDate != null && toDate.isNotEmpty) {
        queryParams['to_date'] = toDate;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dioClient.get(
        ApiConstants.siteBanners,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return BannersResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: 'فشل تحميل البانرات',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'حدث خطأ غير متوقع: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> recordBannerClick(int bannerId) async {
    try {
      final endpoint = ApiConstants.recordBannerClick.replaceAll('{id}', bannerId.toString());
      
      final response = await dioClient.post(endpoint);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: 'فشل تسجيل النقر',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'حدث خطأ غير متوقع: $e',
        statusCode: 500,
      );
    }
  }
}
