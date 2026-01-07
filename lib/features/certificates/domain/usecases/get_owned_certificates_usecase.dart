import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/certificate.dart';
import '../repositories/certificate_repository.dart';

class GetOwnedCertificatesUseCase {
  final CertificateRepository repository;

  GetOwnedCertificatesUseCase(this.repository);

  Future<Either<Failure, List<Certificate>>> call() async {
    return await repository.getOwnedCertificates();
  }
}



