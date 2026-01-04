import 'package:equatable/equatable.dart';
import '../../domain/entities/certificate.dart';

abstract class CertificateState extends Equatable {
  const CertificateState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CertificateInitial extends CertificateState {}

/// Loading state
class CertificateLoading extends CertificateState {}

/// State when certificates are loaded successfully
class CertificatesLoaded extends CertificateState {
  final List<Certificate> certificates;

  const CertificatesLoaded(this.certificates);

  @override
  List<Object?> get props => [certificates];
}

/// State when a single certificate is loaded
class CertificateLoaded extends CertificateState {
  final Certificate certificate;

  const CertificateLoaded(this.certificate);

  @override
  List<Object?> get props => [certificate];
}

/// State when a certificate is generated successfully
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

/// State when certificate download is in progress
class CertificateDownloading extends CertificateState {}

/// State when certificate is downloaded successfully
class CertificateDownloaded extends CertificateState {
  final String filePath;

  const CertificateDownloaded(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// State when there's no certificates
class CertificatesEmpty extends CertificateState {}

/// Error state
class CertificateError extends CertificateState {
  final String message;

  const CertificateError(this.message);

  @override
  List<Object?> get props => [message];
}

