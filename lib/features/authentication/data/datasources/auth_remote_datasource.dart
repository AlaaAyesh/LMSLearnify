import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<LoginResponseModel> register(RegisterRequestModel request);
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });
  Future<void> sendEmailOtp();
  Future<void> verifyEmailOtp(String otp);
  Future<bool> checkEmailVerification();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  });
  
  /// Get Google OAuth URL for authentication
  Future<String> getGoogleAuthUrl();
  
  /// Handle Google OAuth callback and authenticate user
  Future<LoginResponseModel> handleGoogleCallback(String code);
  
  /// Mobile OAuth login with access token from native SDK
  /// [provider] - OAuth provider name (google, facebook)
  /// [accessToken] - Access token from OAuth provider
  /// Optionally includes profile data for first-time registration
  Future<LoginResponseModel> mobileOAuthLogin({
    required String provider,
    required String accessToken,
    String? name,
    String? phone,
    int? specialtyId,
    String? gender,
    String? religion,
    String? birthday,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await dioClient.post(
        ApiConstants.login,
        data: request.toFormData(),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      }

      throw ServerException(
        message: response.data['message'] ?? 'خطأ في تسجيل الدخول',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<LoginResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await dioClient.post(
        ApiConstants.register,
        data: request.toFormData(),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponseModel.fromJson(response.data);
      }

      throw ServerException(
        message: response.data['message'] ?? 'خطأ في التسجيل',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post(ApiConstants.logout);
    } catch (_) {
      throw ServerException(message: 'خطأ في تسجيل الخروج');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await dioClient.post(
        ApiConstants.forgotPassword,
        data: FormData.fromMap({'email': email}),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      throw ServerException(
        message:
            e.response?.data['message'] ?? 'خطأ في إرسال البريد الإلكتروني',
      );
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'خطأ في إعادة تعيين كلمة المرور',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'رمز غير صالح أو منتهي الصلاحية',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> sendEmailOtp() async {
    try {
      final response = await dioClient.post(ApiConstants.sendEmailOtp);

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'خطأ في إرسال رمز التحقق',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في إرسال رمز التحقق',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> verifyEmailOtp(String otp) async {
    try {
      final response = await dioClient.post(
        ApiConstants.verifyEmailOtp,
        data: {'otp': otp},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'رمز التحقق غير صحيح',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'رمز التحقق غير صحيح أو منتهي الصلاحية',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<bool> checkEmailVerification() async {
    try {
      final response = await dioClient.get(ApiConstants.checkEmailVerification);

      if (response.statusCode == 200) {
        return response.data['verified'] == true;
      }

      return false;
    } on DioException catch (_) {
      return false;
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dioClient.post(
        ApiConstants.changePassword,
        data: FormData.fromMap({
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': passwordConfirmation,
        }),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'خطأ في تغيير كلمة المرور',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'كلمة المرور الحالية غير صحيحة',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String> getGoogleAuthUrl() async {
    try {
      final response = await dioClient.get(ApiConstants.googleAuth);

      if (response.statusCode == 200) {
        final url = response.data['url'];
        if (url != null && url is String) {
          return url;
        }
        throw ServerException(
          message: 'لم يتم الحصول على رابط المصادقة',
          statusCode: response.statusCode,
        );
      }

      throw ServerException(
        message: response.data['message'] ?? 'خطأ في الحصول على رابط Google',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'خطأ في الاتصال بالخادم',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<LoginResponseModel> handleGoogleCallback(String code) async {
    try {
      final response = await dioClient.get(
        ApiConstants.googleCallback,
        queryParameters: {'code': code},
      );

      if (response.statusCode == 200) {
        // Handle OAuth callback response format:
        // { "user": {...}, "token": "...", "message": "..." }
        return _parseOAuthResponse(response.data);
      }

      throw ServerException(
        message: response.data['message'] ?? response.data['error'] ?? 'خطأ في تسجيل الدخول عبر Google',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      String errorMessage = 'خطأ في الاتصال بالخادم';
      
      if (e.response?.data != null) {
        errorMessage = e.response?.data['error'] ?? 
                       e.response?.data['message'] ?? 
                       errorMessage;
      }
      
      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    }
  }
  
  /// Parse OAuth response which has a different format than standard login
  LoginResponseModel _parseOAuthResponse(Map<String, dynamic> json) {
    // Mobile OAuth response format: { "user": {...}, "access_token": "...", "token_type": "...", "message": "..." }
    // Standard format: { "status": "success", "data": { "user": {...}, "access_token": "..." } }
    
    // Check if it's standard format first
    if (json.containsKey('data') && json['data'] is Map) {
      return LoginResponseModel.fromJson(json);
    }
    
    // Handle OAuth response format (user and access_token at root level)
    final userData = json['user'] as Map<String, dynamic>?;
    // Support both 'access_token' and 'token' keys
    final token = (json['access_token'] ?? json['token']) as String?;
    final tokenType = (json['token_type'] as String?) ?? 'Bearer';
    
    if (userData == null) {
      throw ServerException(
        message: json['error'] ?? 'فشل في الحصول على بيانات المستخدم',
      );
    }
    
    if (token == null || token.isEmpty) {
      throw ServerException(
        message: 'فشل في الحصول على رمز الوصول',
      );
    }
    
    // Convert OAuth response to standard format
    return LoginResponseModel.fromJson({
      'data': {
        'user': userData,
        'access_token': token,
        'token_type': tokenType,
      }
    });
  }

  @override
  Future<LoginResponseModel> mobileOAuthLogin({
    required String provider,
    required String accessToken,
    String? name,
    String? phone,
    int? specialtyId,
    String? gender,
    String? religion,
    String? birthday,
  }) async {
    try {
      // Build form data with required fields
      final Map<String, dynamic> formFields = {
        'provider': provider,
        'access_token': accessToken,
      };

      // Add optional profile fields if provided (for first-time registration)
      if (name != null) formFields['name'] = name;
      if (phone != null) formFields['phone'] = phone;
      if (specialtyId != null) formFields['specialty_id'] = specialtyId;
      if (gender != null) formFields['gender'] = gender;
      if (religion != null) formFields['religion'] = religion;
      if (birthday != null) formFields['birthday'] = birthday;

      final response = await dioClient.post(
        ApiConstants.mobileOAuthLogin,
        data: FormData.fromMap(formFields),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        // Handle both standard and OAuth response formats
        return _parseOAuthResponse(response.data);
      }

      throw ServerException(
        message: response.data['message'] ?? response.data['error'] ?? 'خطأ في تسجيل الدخول',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      String errorMessage = 'خطأ في الاتصال بالخادم';
      
      if (e.response?.statusCode == 401) {
        errorMessage = e.response?.data['error'] ?? 'رمز الوصول غير صالح';
      } else if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? 
                       e.response?.data['error'] ?? 
                       errorMessage;
      }
      
      throw ServerException(
        message: errorMessage,
        statusCode: e.response?.statusCode,
      );
    }
  }
}


