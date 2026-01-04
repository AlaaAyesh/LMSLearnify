class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});
}

class ValidationException implements Exception {
  final String message;

  ValidationException({required this.message});
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException({required this.message});
}