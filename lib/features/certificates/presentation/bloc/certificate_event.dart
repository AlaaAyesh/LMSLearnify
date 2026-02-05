import 'package:equatable/equatable.dart';

abstract class CertificateEvent extends Equatable {
  const CertificateEvent();

  @override
  List<Object?> get props => [];
}

class LoadOwnedCertificatesEvent extends CertificateEvent {}

class GenerateCertificateEvent extends CertificateEvent {
  final int courseId;

  const GenerateCertificateEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

class LoadCertificateByIdEvent extends CertificateEvent {
  final int certificateId;

  const LoadCertificateByIdEvent({required this.certificateId});

  @override
  List<Object?> get props => [certificateId];
}

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

class ClearCertificateStateEvent extends CertificateEvent {}



