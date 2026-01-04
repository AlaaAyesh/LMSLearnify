import 'package:flutter_bloc/flutter_bloc.dart';
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
  }

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
}
