import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/certificate.dart';
import '../repositories/certificate_repository.dart';

class GenerateCertificateUseCase {
  final CertificateRepository repository;

  GenerateCertificateUseCase(this.repository);

  Future<Either<Failure, Certificate>> call({
    required int courseId,
  }) async {
    return await repository.generateCertificate(courseId: courseId);
  }
}



