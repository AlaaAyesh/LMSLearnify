import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// Server Failure
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Authentication Failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

// Not Found Failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}