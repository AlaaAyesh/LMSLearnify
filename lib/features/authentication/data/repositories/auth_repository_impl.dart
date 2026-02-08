import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/cache_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _kRememberMeKey = 'auth_remember_me';
  static const String _kRememberedEmailKey = 'auth_remembered_email';

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final SharedPreferences sharedPreferences;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequestModel(email: email, password: password);

      final loginResponse = await remoteDataSource.login(request);

      await localDataSource.saveTokens(
        accessToken: loginResponse.accessToken,
      );

      await localDataSource.cacheUser(loginResponse.user);


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
    String? religion,
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
        religion: religion,
        birthday: birthday,
      );

      final registerResponse = await remoteDataSource.register(request);

      await localDataSource.saveTokens(
        accessToken: registerResponse.accessToken,
      );

      await localDataSource.cacheUser(registerResponse.user);


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
      try {
        await remoteDataSource.logout();
      } catch (_) {}

      final rememberMe = sharedPreferences.getBool(_kRememberMeKey) ?? false;
      final rememberedEmail = sharedPreferences.getString(_kRememberedEmailKey) ?? '';
      final rememberedPassword = await secureStorage.getRememberedPassword();

      await localDataSource.clearCache();
      await CacheService.clearCache();
      await sharedPreferences.clear();

      if (rememberMe) {
        await sharedPreferences.setBool(_kRememberMeKey, true);
        if (rememberedEmail.isNotEmpty) {
          await sharedPreferences.setString(_kRememberedEmailKey, rememberedEmail);
        }
        if (rememberedPassword != null && rememberedPassword.isNotEmpty) {
          await secureStorage.saveRememberedPassword(rememberedPassword);
        }
      }

      return const Right(null);
    } catch (_) {
      try {
        final rememberMe = sharedPreferences.getBool(_kRememberMeKey) ?? false;
        final rememberedEmail = sharedPreferences.getString(_kRememberedEmailKey) ?? '';
        final rememberedPassword = await secureStorage.getRememberedPassword();

        await localDataSource.clearCache();
        await CacheService.clearCache();
        await sharedPreferences.clear();

        if (rememberMe) {
          await sharedPreferences.setBool(_kRememberMeKey, true);
          if (rememberedEmail.isNotEmpty) {
            await sharedPreferences.setString(_kRememberedEmailKey, rememberedEmail);
          }
          if (rememberedPassword != null && rememberedPassword.isNotEmpty) {
            await secureStorage.saveRememberedPassword(rememberedPassword);
          }
        }
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

      await localDataSource.saveTokens(
        accessToken: loginResponse.accessToken,
      );

      await localDataSource.cacheUser(loginResponse.user);


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
    String? religion,
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
        religion: religion,
        birthday: birthday,
      );

      await localDataSource.saveTokens(
        accessToken: loginResponse.accessToken,
      );

      await localDataSource.cacheUser(loginResponse.user);


      return Right(loginResponse.user);
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        return Left(NotFoundFailure(e.message));
      }

      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? religion,
    String? about,
    String? birthday,
    int? specialtyId,
    String? role,
  }) async {
    try {
      final updatedUser = await remoteDataSource.updateProfile(
        name: name,
        email: email,
        phone: phone,
        gender: gender,
        religion: religion,
        about: about,
        birthday: birthday,
        specialtyId: specialtyId,
        role: role,
      );

      final userModel = updatedUser is UserModel
          ? updatedUser 
          : UserModel.fromEntity(updatedUser);
      await localDataSource.cacheUser(userModel);

      return Right(updatedUser);
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('UpdateProfile Error: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}


