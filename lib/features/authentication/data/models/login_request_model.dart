import 'package:dio/dio.dart';

class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  FormData toFormData() {
    return FormData.fromMap({
      'email': email,
      'password': password,
    });
  }
}


