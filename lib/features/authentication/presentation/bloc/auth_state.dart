import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Forgot password states
class ForgotPasswordSuccess extends AuthState {
  final String email;

  const ForgotPasswordSuccess({required this.email});

  @override
  List<Object?> get props => [email];
}

class PasswordResetSuccess extends AuthState {}

// Email verification states
class EmailOtpSent extends AuthState {}

class EmailVerified extends AuthState {}

class EmailVerificationStatus extends AuthState {
  final bool isVerified;

  const EmailVerificationStatus({required this.isVerified});

  @override
  List<Object?> get props => [isVerified];
}

// Change password states
class PasswordChanged extends AuthState {}

// Social login states
class SocialLoginNeedsCompletion extends AuthState {
  final String email;
  final String? name;
  final String providerId;
  final String accessToken; // Google/Apple token to be used after profile completion
  // If true => we don't have a backend session yet (new user), so we must
  // complete profile using social token via `auth/mobile/login`.
  // If false => user already logged in but profile is incomplete, so we can
  // complete profile using `auth/update-profile`.
  final bool requiresRegistration;

  const SocialLoginNeedsCompletion({
    required this.email,
    this.name,
    required this.providerId,
    required this.accessToken,
    required this.requiresRegistration,
  });

  @override
  List<Object?> get props => [email, name, providerId, accessToken, requiresRegistration];
}

// Google OAuth states
class GoogleAuthUrlLoaded extends AuthState {
  final String url;

  const GoogleAuthUrlLoaded({required this.url});

  @override
  List<Object?> get props => [url];
}

// Profile update states
class ProfileUpdated extends AuthState {
  final User user;

  const ProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}


