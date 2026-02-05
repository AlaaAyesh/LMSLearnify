import 'package:equatable/equatable.dart';
import '../../domain/entities/certificate.dart';

abstract class CertificateState extends Equatable {
  const CertificateState();

  @override
  List<Object?> get props => [];
}

class CertificateInitial extends CertificateState {}

class CertificateLoading extends CertificateState {}

class CertificatesLoaded extends CertificateState {
  final List<Certificate> certificates;

  const CertificatesLoaded(this.certificates);

  @override
  List<Object?> get props => [certificates];
}

class CertificateLoaded extends CertificateState {
  final Certificate certificate;

  const CertificateLoaded(this.certificate);

  @override
  List<Object?> get props => [certificate];
}

class CertificateGenerated extends CertificateState {
  final Certificate certificate;
  final String message;

  const CertificateGenerated({
    required this.certificate,
    this.message = 'تم إنشاء الشهادة بنجاح',
  });

  @override
  List<Object?> get props => [certificate, message];
}

class CertificateDownloading extends CertificateState {}

class CertificateDownloaded extends CertificateState {
  final String filePath;

  const CertificateDownloaded(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class CertificatesEmpty extends CertificateState {}

class CertificateError extends CertificateState {
  final String message;

  const CertificateError(this.message);

  @override
  List<Object?> get props => [message];
}



