import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/certificate.dart';

abstract class CertificateRepository {
  /// Generate/Request a certificate for a completed course
  Future<Either<Failure, Certificate>> generateCertificate({
    required int courseId,
  });

  /// Get all certificates owned by the authenticated user
  Future<Either<Failure, List<Certificate>>> getOwnedCertificates();

  /// Get a specific certificate by its ID
  Future<Either<Failure, Certificate>> getCertificateById({
    required int certificateId,
  });
}



