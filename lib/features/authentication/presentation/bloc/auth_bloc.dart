import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository authRepository;

  // Store email for password reset flow
  String? _resetPasswordEmail;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<SocialLoginEvent>(_onSocialLogin);
    on<CompleteProfileEvent>(_onCompleteProfile);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<SendEmailOtpEvent>(_onSendEmailOtp);
    on<VerifyEmailOtpEvent>(_onVerifyEmailOtp);
    on<CheckEmailVerificationEvent>(_onCheckEmailVerification);
    on<ChangePasswordEvent>(_onChangePassword);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<GoogleCallbackEvent>(_onGoogleCallback);
    on<MobileOAuthLoginEvent>(_onMobileOAuthLogin);
    on<NativeGoogleSignInEvent>(_onNativeGoogleSignIn);
    on<NativeAppleSignInEvent>(_onNativeAppleSignIn);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '695539439418-g40jdtebreloi78lkk4f4t24v1fktu8q.apps.googleusercontent.com',
  );

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      name: event.name,
      email: event.email,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
      role: event.role,
      phone: event.phone,
      specialtyId: event.specialtyId,
      gender: event.gender,
      religion: event.religion,
      birthday: event.birthday,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSocialLogin(
    SocialLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // For Google, use NativeGoogleSignInEvent instead
    // For Apple, implementation pending
    if (event.provider == 'apple') {
      emit(const AuthError('تسجيل الدخول عبر Apple غير متاح حالياً'));
      return;
    }

    // Fallback error for unknown providers
    emit(const AuthError('مزود تسجيل الدخول غير مدعوم'));
  }

  Future<void> _onCompleteProfile(
    CompleteProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // Register with social provider token + complete profile data
    final result = await authRepository.mobileOAuthLogin(
      provider: event.providerId,
      accessToken: event.accessToken,
      name: event.name,
      phone: event.phone,
      specialtyId: event.specialtyId,
      gender: event.gender,
      religion: event.religion,
      birthday: event.birthday,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await authRepository.logout();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedInResult = await authRepository.isLoggedIn();

    await isLoggedInResult.fold(
      (failure) async => emit(AuthUnauthenticated()),
      (isLoggedIn) async {
        if (isLoggedIn) {
          final userResult = await authRepository.getCurrentUser();
          userResult.fold(
            (failure) => emit(AuthUnauthenticated()),
            (user) => user != null
                ? emit(AuthAuthenticated(user))
                : emit(AuthUnauthenticated()),
          );
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.forgotPassword(email: event.email);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        _resetPasswordEmail = event.email; // Store email for reset password
        emit(ForgotPasswordSuccess(email: event.email));
      },
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.resetPassword(
      email: event.email,
      otp: event.otp,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(PasswordResetSuccess()),
    );
  }

  Future<void> _onSendEmailOtp(
    SendEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.sendEmailOtp();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(EmailOtpSent()),
    );
  }

  Future<void> _onVerifyEmailOtp(
    VerifyEmailOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.verifyEmailOtp(otp: event.otp);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(EmailVerified()),
    );
  }

  Future<void> _onCheckEmailVerification(
    CheckEmailVerificationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.checkEmailVerification();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (isVerified) => emit(EmailVerificationStatus(isVerified: isVerified)),
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
      passwordConfirmation: event.passwordConfirmation,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(PasswordChanged()),
    );
  }


  // Google OAuth handlers
  Future<void> _onGoogleSignIn(
    GoogleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.getGoogleAuthUrl();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (url) => emit(GoogleAuthUrlLoaded(url: url)),
    );
  }

  Future<void> _onGoogleCallback(
    GoogleCallbackEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.handleGoogleCallback(code: event.code);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // Mobile OAuth login handler
  Future<void> _onMobileOAuthLogin(
    MobileOAuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.mobileOAuthLogin(
      provider: event.provider,
      accessToken: event.accessToken,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // Native Google Sign-In handler
  Future<void> _onNativeGoogleSignIn(
    NativeGoogleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Sign out first to ensure fresh sign-in
      await _googleSignIn.signOut();
      
      // Trigger Google Sign-In
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        // User cancelled sign-in
        emit(const AuthError('تم إلغاء تسجيل الدخول'));
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      final String? accessToken = auth.accessToken;

      // Prefer ID token for backend authentication, fallback to access token
      final String? tokenToSend = idToken ?? accessToken;

      if (tokenToSend == null || tokenToSend.isEmpty) {
        emit(const AuthError('فشل في الحصول على رمز الوصول'));
        return;
      }

      // Try to login first - check if user already exists
      final result = await authRepository.mobileOAuthLogin(
        provider: 'google',
        accessToken: tokenToSend,
      );

      result.fold(
        (failure) {
          // If the backend reports that the user was not found, redirect
          // to the complete profile flow so we can register a new user
          // using the Google account data.
          if (failure is NotFoundFailure) {
            emit(
              SocialLoginNeedsCompletion(
                email: account.email ?? '',
                name: account.displayName,
                providerId: 'google',
                accessToken: tokenToSend,
                requiresRegistration: true,
              ),
            );
          } else {
            emit(AuthError(failure.message));
          }
        },
        (user) {
          // If the user exists but has incomplete profile information
          // (e.g. missing phone, birthday, or specialty), force them to
          // complete the profile before accessing the app.
          if (!user.isProfileComplete) {
            emit(
              SocialLoginNeedsCompletion(
                email: user.email,
                name: user.name,
                providerId: 'google',
                accessToken: tokenToSend,
                requiresRegistration: false,
              ),
            );
          } else {
            emit(AuthAuthenticated(user));
          }
        },
      );
    } catch (e) {
      // Handle specific Google Sign-In errors
      final errorMessage = _parseGoogleSignInError(e.toString());
      emit(AuthError(errorMessage));
    }
  }

  /// Parse Google Sign-In errors to user-friendly messages
  String _parseGoogleSignInError(String error) {
    if (error.contains('ApiException: 10')) {
      // DEVELOPER_ERROR - SHA-1 or package name not configured
      return 'خطأ في إعدادات التطبيق. يرجى التواصل مع الدعم الفني.';
    } else if (error.contains('ApiException: 7')) {
      // NETWORK_ERROR
      return 'خطأ في الاتصال بالإنترنت. يرجى المحاولة مرة أخرى.';
    } else if (error.contains('ApiException: 12501')) {
      // SIGN_IN_CANCELLED
      return 'تم إلغاء تسجيل الدخول';
    } else if (error.contains('ApiException: 12502')) {
      // SIGN_IN_CURRENTLY_IN_PROGRESS
      return 'عملية تسجيل الدخول قيد التنفيذ';
    } else if (error.contains('ApiException: 12500')) {
      // SIGN_IN_FAILED
      return 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.';
    } else if (error.contains('sign_in_canceled')) {
      return 'تم إلغاء تسجيل الدخول';
    } else if (error.contains('network_error')) {
      return 'خطأ في الاتصال بالإنترنت';
    }
    return 'خطأ في تسجيل الدخول. يرجى المحاولة مرة أخرى.';
  }

  // Native Apple Sign-In handler
  Future<void> _onNativeAppleSignIn(
    NativeAppleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Check if Apple Sign-In is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        emit(const AuthError('تسجيل الدخول عبر Apple غير متاح على هذا الجهاز'));
        return;
      }

      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request Apple Sign-In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Get the identity token
      final identityToken = credential.identityToken;
      
      if (identityToken == null || identityToken.isEmpty) {
        emit(const AuthError('فشل في الحصول على رمز الوصول'));
        return;
      }

      // Get user info from credential (only available on first sign-in)
      final String? email = credential.email;
      final String? givenName = credential.givenName;
      final String? familyName = credential.familyName;
      final String? fullName = (givenName != null || familyName != null)
          ? '${givenName ?? ''} ${familyName ?? ''}'.trim()
          : null;

      // Try to login first - check if user already exists
      final result = await authRepository.mobileOAuthLogin(
        provider: 'apple',
        accessToken: identityToken,
      );

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) {
          // Check if user profile is complete
          if (user.isProfileComplete) {
            // Existing user with complete profile - go to home
            emit(AuthAuthenticated(user));
          } else {
            // New user or incomplete profile - show complete profile page.
            // At this point we already have a backend session, so we just
            // need to complete the profile via update-profile endpoint.
            emit(SocialLoginNeedsCompletion(
              email: email ?? user.email,
              name: fullName ?? user.name,
              providerId: 'apple',
              accessToken: identityToken,
              requiresRegistration: false,
            ));
          }
        },
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      final errorMessage = _parseAppleSignInError(e);
      emit(AuthError(errorMessage));
    } catch (e) {
      emit(AuthError('خطأ في تسجيل الدخول. يرجى المحاولة مرة أخرى.'));
    }
  }

  /// Generate a random nonce string
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// SHA256 hash of a string
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Parse Apple Sign-In errors to user-friendly messages
  String _parseAppleSignInError(SignInWithAppleAuthorizationException e) {
    switch (e.code) {
      case AuthorizationErrorCode.canceled:
        return 'تم إلغاء تسجيل الدخول';
      case AuthorizationErrorCode.failed:
        return 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.';
      case AuthorizationErrorCode.invalidResponse:
        return 'استجابة غير صالحة من Apple';
      case AuthorizationErrorCode.notHandled:
        return 'لم يتم التعامل مع الطلب';
      case AuthorizationErrorCode.notInteractive:
        return 'تسجيل الدخول غير تفاعلي';
      case AuthorizationErrorCode.unknown:
      default:
        return 'خطأ غير معروف. يرجى المحاولة مرة أخرى.';
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.updateProfile(
      name: event.name,
      email: event.email,
      phone: event.phone,
      gender: event.gender,
      religion: event.religion,
      about: event.about,
      birthday: event.birthday,
      specialtyId: event.specialtyId,
      role: event.role,
    );

    result.fold(
      (failure) {
        // If 401 Unauthorized, automatically logout the user
        if (failure is AuthenticationFailure) {
          // Trigger logout by adding LogoutEvent
          // This will be handled by the _onLogout handler
          add(LogoutEvent());
          emit(AuthError('انتهت صلاحية الجلسة. تم تسجيل الخروج تلقائياً'));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) {
        // Emit both ProfileUpdated for UI feedback and AuthAuthenticated to update the state
        emit(ProfileUpdated(user));
        emit(AuthAuthenticated(user));
      },
    );
  }
}


