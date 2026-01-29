import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;
  final String role;
  final String phone;
  final int specialtyId;
  final String gender;
  final String? religion; // 'muslim' or 'christian'
  final String? birthday; // Format: YYYY-MM-DD

  const RegisterEvent({
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

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation, role, phone, specialtyId, gender, religion, birthday];
}

class SocialLoginEvent extends AuthEvent {
  final String provider; // 'google' or 'apple'

  const SocialLoginEvent({required this.provider});

  @override
  List<Object?> get props => [provider];
}

class CompleteProfileEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String role;
  final int specialtyId;
  final String gender;
  final String? religion; // 'muslim' or 'christian'
  final String? birthday;
  final String providerId;
  final String accessToken; // Google/Apple token for registration

  const CompleteProfileEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.specialtyId,
    required this.gender,
    this.religion,
    this.birthday,
    required this.providerId,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [name, email, phone, role, specialtyId, gender, religion, birthday, providerId, accessToken];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordEvent({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [email, otp, password, passwordConfirmation];
}

// Email verification events
class SendEmailOtpEvent extends AuthEvent {}

class VerifyEmailOtpEvent extends AuthEvent {
  final String otp;

  const VerifyEmailOtpEvent({required this.otp});

  @override
  List<Object?> get props => [otp];
}

class CheckEmailVerificationEvent extends AuthEvent {}

// Change password event
class ChangePasswordEvent extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  final String passwordConfirmation;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, passwordConfirmation];
}


// Google OAuth events (WebView flow)
class GoogleSignInEvent extends AuthEvent {}

class GoogleCallbackEvent extends AuthEvent {
  final String code;

  const GoogleCallbackEvent({required this.code});

  @override
  List<Object?> get props => [code];
}

// Mobile OAuth events (Native SDK flow)
class MobileOAuthLoginEvent extends AuthEvent {
  final String provider; // 'google' or 'facebook'
  final String accessToken;

  const MobileOAuthLoginEvent({
    required this.provider,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [provider, accessToken];
}

// Native Google Sign-In event
class NativeGoogleSignInEvent extends AuthEvent {}

// Native Apple Sign-In event
class NativeAppleSignInEvent extends AuthEvent {}

// Update profile event
class UpdateProfileEvent extends AuthEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? gender;
  final String? religion;
  final String? about;
  final String? birthday;
  final int? specialtyId;
  final String? role;

  const UpdateProfileEvent({
    this.name,
    this.email,
    this.phone,
    this.gender,
    this.religion,
    this.about,
    this.birthday,
    this.specialtyId,
    this.role,
  });

  @override
  List<Object?> get props => [name, email, phone, gender, religion, about, birthday, specialtyId, role];
}


