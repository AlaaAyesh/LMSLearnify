import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/guest_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final GuestService guestService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.guestService,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequestModel(email: email, password: password);

      final loginResponse = await remoteDataSource.login(request);

      // Save access token
      await localDataSource.saveTokens(
        accessToken: loginResponse.accessToken,
      );

      // Cache user data
      await localDataSource.cacheUser(loginResponse.user);

      // Disable guest mode when user logs in
      await guestService.disableGuestMode();

      return Right(loginResponse.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('Login Error: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
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
  }) async {
    try {
      final request = RegisterRequestModel(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        phone: phone,
        specialtyId: specialtyId,
        gender: gender,
        birthday: birthday,
      );

      final registerResponse = await remoteDataSource.register(request);

      // Save access token
      await localDataSource.saveTokens(
        accessToken: registerResponse.accessToken,
      );

      // Cache user data
      await localDataSource.cacheUser(registerResponse.user);

      // Disable guest mode when user registers
      await guestService.disableGuestMode();

      return Right(registerResponse.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('Register Error: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Try to logout from server (ignore errors if offline)
      try {
        await remoteDataSource.logout();
      } catch (_) {
        // Ignore server errors - still clear local data
      }
      
      // Clear all local data
      await localDataSource.clearCache();
      
      // Clear guest mode
      await guestService.disableGuestMode();
      
      return const Right(null);
    } catch (_) {
      // Even if there's an error, try to clear local data
      try {
        await localDataSource.clearCache();
        await guestService.disableGuestMode();
      } catch (_) {}
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  }) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailOtp() async {
    try {
      await remoteDataSource.sendEmailOtp();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmailOtp({required String otp}) async {
    try {
      await remoteDataSource.verifyEmailOtp(otp);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailVerification() async {
    try {
      final isVerified = await remoteDataSource.checkEmailVerification();
      return Right(isVerified);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        passwordConfirmation: passwordConfirmation,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    final result = await localDataSource.isLoggedIn();
    return Right(result);
  }

  @override
  Future<Either<Failure, User>> loginAsGuest() async {
    try {
      // حفظ حالة الضيف
      await localDataSource.saveGuestMode(true);

      // إنشاء UserModel كضيف
      final guestUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: 'ضيف',
        email: 'guest@app.com',
      );

      // حفظ بيانات المستخدم الضيف
      await localDataSource.cacheUser(guestUser);

      return Right(guestUser);
    } catch (e) {
      return Left(CacheFailure('فشل الدخول كضيف'));
    }
  }

  @override
  Future<Either<Failure, String>> getGoogleAuthUrl() async {
    try {
      final url = await remoteDataSource.getGoogleAuthUrl();
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> handleGoogleCallback({required String code}) async {
    try {
      final loginResponse = await remoteDataSource.handleGoogleCallback(code);

      // Save access token
      await localDataSource.saveTokens(
        accessToken: loginResponse.accessToken,
      );

      // Cache user data
      await localDataSource.cacheUser(loginResponse.user);

      // Disable guest mode when user logs in via Google
      await guestService.disableGuestMode();

      return Right(loginResponse.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> mobileOAuthLogin({
    required String provider,
    required String accessToken,
    String? name,
    String? phone,
    int? specialtyId,
    String? gender,
    String? birthday,
  }) async {
    try {
      final loginResponse = await remoteDataSource.mobileOAuthLogin(
        provider: provider,
        accessToken: accessToken,
        name: name,
        phone: phone,
        specialtyId: specialtyId,
        gender: gender,
        birthday: birthday,
      );

      // Save access token
      await localDataSource.saveTokens(
        accessToken: loginResponse.accessToken,
      );

      // Cache user data
      await localDataSource.cacheUser(loginResponse.user);

      // Disable guest mode when user logs in via OAuth
      await guestService.disableGuestMode();

      return Right(loginResponse.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}


