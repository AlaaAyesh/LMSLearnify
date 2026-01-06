import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    on<GuestLoginEvent>(_onGuestLogin);
    on<GoogleSignInEvent>(_onGoogleSignIn);
    on<GoogleCallbackEvent>(_onGoogleCallback);
    on<MobileOAuthLoginEvent>(_onMobileOAuthLogin);
    on<NativeGoogleSignInEvent>(_onNativeGoogleSignIn);
  }

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '91869598940-gndd1i75dk53hhu101e3hr2o9o4d5u0j.apps.googleusercontent.com',
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

    // TODO: Implement actual social login with Firebase/Google/Apple
    // For now, simulate the flow

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Simulate incomplete profile scenario
    emit(const SocialLoginNeedsCompletion(
      email: 'user@gmail.com',
      name: null,
      providerId: 'google',
    ));
  }

  Future<void> _onCompleteProfile(
    CompleteProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      name: event.name,
      email: event.email,
      password: '', // No password for social login
      passwordConfirmation: '',
      role: event.role,
      phone: event.phone,
      specialtyId: event.specialtyId,
      gender: event.gender,
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

  // Guest login handler
  Future<void> _onGuestLogin(
    GuestLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.loginAsGuest();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
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
      final String? accessToken = auth.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        emit(const AuthError('فشل في الحصول على رمز الوصول'));
        return;
      }

      // Send access token to backend
      final result = await authRepository.mobileOAuthLogin(
        provider: 'google',
        accessToken: accessToken,
      );

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
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
}
