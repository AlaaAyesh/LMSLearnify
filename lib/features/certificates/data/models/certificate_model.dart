import '../../domain/entities/certificate.dart';

class CertificateModel extends Certificate {
  const CertificateModel({
    required super.id,
    required super.courseId,
    super.courseName,
    super.issuedDate,
    super.downloadUrl,
    super.certificateUrl,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] ?? 0,
      courseId: json['course_id'] is String
          ? int.parse(json['course_id'])
          : json['course_id'] ?? 0,
      courseName: json['course_name'] ?? json['course']?['name'],
      issuedDate: json['issued_date'] ?? json['created_at'],
      downloadUrl: json['download_url'],
      certificateUrl: json['certificate_url'] ?? json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'course_name': courseName,
      'issued_date': issuedDate,
      'download_url': downloadUrl,
      'certificate_url': certificateUrl,
    };
  }
}

class GenerateCertificateResponseModel {
  final bool success;
  final String message;
  final CertificateModel? certificate;

  GenerateCertificateResponseModel({
    required this.success,
    required this.message,
    this.certificate,
  });

  factory GenerateCertificateResponseModel.fromJson(Map<String, dynamic> json) {
    return GenerateCertificateResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      certificate: json['certificate'] != null
          ? CertificateModel.fromJson(json['certificate'])
          : null,
    );
  }
}

