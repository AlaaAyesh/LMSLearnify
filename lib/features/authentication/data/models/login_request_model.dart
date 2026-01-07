import 'package:dio/dio.dart';

class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  /// Convert to FormData for multipart/form-data request
  FormData toFormData() {
    return FormData.fromMap({
      'email': email,
      'password': password,
    });
  }
}


