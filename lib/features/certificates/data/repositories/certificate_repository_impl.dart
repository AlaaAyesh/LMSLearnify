import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/repositories/certificate_repository.dart';
import '../datasources/certificate_remote_datasource.dart';

class CertificateRepositoryImpl implements CertificateRepository {
  final CertificateRemoteDataSource remoteDataSource;

  CertificateRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Certificate>> generateCertificate({
    required int courseId,
  }) async {
    try {
      final certificate = await remoteDataSource.generateCertificate(courseId);
      return Right(certificate);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Certificate>>> getOwnedCertificates() async {
    try {
      final certificates = await remoteDataSource.getOwnedCertificates();
      return Right(certificates);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, Certificate>> getCertificateById({
    required int certificateId,
  }) async {
    try {
      final certificate = await remoteDataSource.getCertificateById(certificateId);
      return Right(certificate);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}



