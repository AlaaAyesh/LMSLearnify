import 'package:dio/dio.dart';

class RegisterRequestModel {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String role;
  final String phone;
  final int specialtyId;
  final String gender;
  final String? religion;
  final String? birthday;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.role,
    required this.phone,
    required this.specialtyId,
    required this.gender,
    this.religion,
    this.birthday,
  });

  FormData toFormData() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': role,
      'phone': phone,
      'specialty_id': specialtyId,
      'gender': gender,
    };

    if (religion != null && religion!.isNotEmpty) {
      map['religion'] = religion;
    } else {
      map['religion'] = 'muslim';
    }

    if (birthday != null && birthday!.isNotEmpty) {
      map['birthday'] = birthday;
    }

    return FormData.fromMap(map);
  }
}


