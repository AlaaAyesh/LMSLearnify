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
}
