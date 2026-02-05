import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../home/data/models/chapter_model.dart';

abstract class ChapterRemoteDataSource {
  Future<ChapterModel> getChapterById(int id);
}

class ChapterRemoteDataSourceImpl implements ChapterRemoteDataSource {
  final DioClient dioClient;

  ChapterRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ChapterModel> getChapterById(int id) async {
    try {
      final response = await dioClient.get('${ApiConstants.chapters}/$id');

      if (response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic> chapterData;

        if (responseData['data'] is Map) {
          chapterData = responseData['data'];
        } else if (responseData['chapter'] is Map) {
          chapterData = responseData['chapter'];
        } else {
          chapterData = responseData;
        }

        return ChapterModel.fromJson(chapterData);
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في جلب الفصل',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'فشل في جلب الفصل');
    }
  }

  ServerException _handleDioError(DioException e, String defaultMessage) {
    String errorMessage = defaultMessage;

    if (e.response?.statusCode == 401) {
      errorMessage = 'يجب تسجيل الدخول أولاً';
    } else if (e.response?.statusCode == 403) {
      errorMessage = e.response?.data['message'] ?? 'غير مصرح لك بالوصول لهذا الفصل';
    } else if (e.response?.statusCode == 404) {
      errorMessage = e.response?.data['message'] ?? 'الفصل غير موجود';
    } else if (e.response?.data != null && e.response?.data['message'] != null) {
      errorMessage = e.response?.data['message'];
    }

    return ServerException(
      message: errorMessage,
      statusCode: e.response?.statusCode,
    );
  }
}



