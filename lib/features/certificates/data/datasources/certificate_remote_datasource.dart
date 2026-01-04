import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/certificate_model.dart';

abstract class CertificateRemoteDataSource {
  /// Generate/Request a certificate for a completed course
  /// Throws [ServerException] on failure
  Future<CertificateModel> generateCertificate(int courseId);

  /// Get all certificates owned by the authenticated user
  /// Throws [ServerException] on failure
  Future<List<CertificateModel>> getOwnedCertificates();

  /// Get a specific certificate by its ID
  /// Throws [ServerException] on failure
  Future<CertificateModel> getCertificateById(int certificateId);
}

class CertificateRemoteDataSourceImpl implements CertificateRemoteDataSource {
  final DioClient dioClient;

  CertificateRemoteDataSourceImpl(this.dioClient);

  @override
  Future<CertificateModel> generateCertificate(int courseId) async {
    try {
      final response = await dioClient.post(
        ApiConstants.generateCertificate,
        data: FormData.fromMap({'course_id': courseId}),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = GenerateCertificateResponseModel.fromJson(
          response.data,
        );
        
        if (responseData.certificate != null) {
          return responseData.certificate!;
        }
        
        // If certificate is in a different structure
        if (response.data['certificate'] != null) {
          return CertificateModel.fromJson(response.data['certificate']);
        }
        
        // If the response itself is the certificate
        return CertificateModel.fromJson(response.data);
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في إنشاء الشهادة',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      String errorMessage = 'خطأ في الاتصال بالخادم';
      
      if (e.response?.statusCode == 401) {
        errorMessage = 'يجب تسجيل الدخول أولاً';
      } else if (e.response?.statusCode == 403) {
        errorMessage = e.response?.data['message'] ?? 'لم تكمل هذه الدورة بعد';
      } else if (e.response?.statusCode == 404) {
        errorMessage = e.response?.data['message'] ?? 'الدورة غير موجودة';
      } else if (e.response?.statusCode == 422) {
        errorMessage = e.response?.data['message'] ?? 'معرف الدورة مطلوب';
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
  Future<List<CertificateModel>> getOwnedCertificates() async {
    try {
      final response = await dioClient.get(ApiConstants.ownedCertificates);

      if (response.statusCode == 200) {
        // Handle nested response structure: { data: { data: [...], meta: {...} } }
        List<dynamic> certificatesJson;
        
        final responseData = response.data;
        if (responseData['data'] is Map && responseData['data']['data'] is List) {
          // Nested structure: { data: { data: [...] } }
          certificatesJson = responseData['data']['data'];
        } else if (responseData['data'] is List) {
          // Direct structure: { data: [...] }
          certificatesJson = responseData['data'];
        } else if (responseData['certificates'] is List) {
          // Alternative structure: { certificates: [...] }
          certificatesJson = responseData['certificates'];
        } else if (responseData is List) {
          // Raw list response
          certificatesJson = responseData;
        } else {
          certificatesJson = [];
        }
            
        return certificatesJson
            .map((json) => CertificateModel.fromJson(json))
            .toList();
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في جلب الشهادات',
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
  Future<CertificateModel> getCertificateById(int certificateId) async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.ownedCertificates}/$certificateId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic> certificateData;
        
        // Handle nested structure: { data: { data: {...} } }
        if (responseData['data'] is Map && responseData['data']['data'] is Map) {
          certificateData = responseData['data']['data'];
        } else if (responseData['data'] is Map) {
          certificateData = responseData['data'];
        } else if (responseData['certificate'] is Map) {
          certificateData = responseData['certificate'];
        } else {
          certificateData = responseData;
        }
            
        return CertificateModel.fromJson(certificateData);
      }

      throw ServerException(
        message: response.data['message'] ?? 'فشل في جلب الشهادة',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      String errorMessage = 'خطأ في الاتصال بالخادم';
      
      if (e.response?.statusCode == 401) {
        errorMessage = 'يجب تسجيل الدخول أولاً';
      } else if (e.response?.statusCode == 404) {
        errorMessage = e.response?.data['message'] ?? 'الشهادة غير موجودة';
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

