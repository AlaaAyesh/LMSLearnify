import 'package:equatable/equatable.dart';

abstract class CertificateEvent extends Equatable {
  const CertificateEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all owned certificates
class LoadOwnedCertificatesEvent extends CertificateEvent {}

/// Event to generate a certificate for a specific course
class GenerateCertificateEvent extends CertificateEvent {
  final int courseId;

  const GenerateCertificateEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

/// Event to load a specific certificate by ID
class LoadCertificateByIdEvent extends CertificateEvent {
  final int certificateId;

  const LoadCertificateByIdEvent({required this.certificateId});

  @override
  List<Object?> get props => [certificateId];
}

/// Event to download a certificate
class DownloadCertificateEvent extends CertificateEvent {
  final String downloadUrl;
  final String? fileName;

  const DownloadCertificateEvent({
    required this.downloadUrl,
    this.fileName,
  });

  @override
  List<Object?> get props => [downloadUrl, fileName];
}

/// Event to clear certificate state
class ClearCertificateStateEvent extends CertificateEvent {}



