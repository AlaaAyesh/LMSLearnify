import '../../domain/entities/lesson.dart';

class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    super.description,
    super.duration,
    super.viewed,
    super.bunnyUrl,
    super.bunnyUri,
    super.videoStatus,
    super.videoDuration,
    super.courseId,
    super.chapterId,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: _parseInt(json['id']),
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      description: json['description']?.toString(),
      duration: json['duration']?.toString(),
      viewed: json['viewed'] == true || json['viewed'] == 1 || json['viewed'] == '1',
      bunnyUrl: json['bunny_url']?.toString(),
      bunnyUri: json['bunny_uri']?.toString(),
      videoStatus: json['video_status']?.toString(),
      videoDuration: json['video_duration']?.toString(),
      courseId: _parseIntNullable(json['course_id']),
      chapterId: _parseIntNullable(json['chapter_id']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description': description,
      'duration': duration,
      'viewed': viewed,
      'bunny_url': bunnyUrl,
      'bunny_uri': bunnyUri,
      'video_status': videoStatus,
      'video_duration': videoDuration,
      'course_id': courseId,
      'chapter_id': chapterId,
    };
  }
}



