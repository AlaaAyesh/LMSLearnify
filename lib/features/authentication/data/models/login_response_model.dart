import 'user_model.dart';

class LoginResponseModel {
  final UserModel user;
  final String accessToken;
  final String tokenType;

  LoginResponseModel({
    required this.user,
    required this.accessToken,
    this.tokenType = 'Bearer',
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Response structure: { "status": "success", "data": { "user": {...}, "access_token": "..." } }
      final data = json['data'] as Map<String, dynamic>?;
      
      if (data == null) {
        print('LoginResponseModel Error: missing data field');
        print('Response: $json');
        throw FormatException('Invalid response format: missing data field');
      }
      
      final userData = data['user'] as Map<String, dynamic>?;
      if (userData == null) {
        print('LoginResponseModel Error: missing user field');
        print('Data: $data');
        throw FormatException('Invalid response format: missing user field');
      }

      print('Parsing user data: $userData');
      
      return LoginResponseModel(
        user: UserModel.fromJson(userData),
        accessToken: data['access_token'] as String? ?? '',
        tokenType: data['token_type'] as String? ?? 'Bearer',
      );
    } catch (e) {
      print('LoginResponseModel.fromJson Error: $e');
      rethrow;
    }
  }
}
