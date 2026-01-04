import 'package:equatable/equatable.dart';

class Certificate extends Equatable {
  final int id;
  final int courseId;
  final String? courseName;
  final String? issuedDate;
  final String? downloadUrl;
  final String? certificateUrl;

  const Certificate({
    required this.id,
    required this.courseId,
    this.courseName,
    this.issuedDate,
    this.downloadUrl,
    this.certificateUrl,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseName,
        issuedDate,
        downloadUrl,
        certificateUrl,
      ];
}

