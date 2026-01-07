import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    required String phone,
    required int specialtyId,
    required String gender,
    String? birthday,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, void>> sendEmailOtp();

  Future<Either<Failure, void>> verifyEmailOtp({required String otp});

  Future<Either<Failure, bool>> checkEmailVerification();

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  });

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, bool>> isLoggedIn();
  
  Future<Either<Failure, User>> loginAsGuest();
  
  /// Get Google OAuth URL for authentication
  Future<Either<Failure, String>> getGoogleAuthUrl();
  
  /// Handle Google OAuth callback and authenticate user
  Future<Either<Failure, User>> handleGoogleCallback({required String code});
  
  /// Mobile OAuth login with access token from native SDK
  /// Optionally includes profile data for first-time registration
  Future<Either<Failure, User>> mobileOAuthLogin({
    required String provider,
    required String accessToken,
    String? name,
    String? phone,
    int? specialtyId,
    String? gender,
    String? birthday,
  });
}


