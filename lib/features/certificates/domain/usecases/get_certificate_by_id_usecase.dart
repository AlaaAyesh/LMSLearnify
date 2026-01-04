import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/certificate.dart';
import '../repositories/certificate_repository.dart';

class GetCertificateByIdUseCase {
  final CertificateRepository repository;

  GetCertificateByIdUseCase(this.repository);

  Future<Either<Failure, Certificate>> call({
    required int certificateId,
  }) async {
    return await repository.getCertificateById(certificateId: certificateId);
  }
}

