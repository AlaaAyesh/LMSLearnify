import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/certificate.dart';

abstract class CertificateRepository {
  Future<Either<Failure, Certificate>> generateCertificate({
    required int courseId,
  });

  Future<Either<Failure, List<Certificate>>> getOwnedCertificates();

  Future<Either<Failure, Certificate>> getCertificateById({
    required int certificateId,
  });
}



