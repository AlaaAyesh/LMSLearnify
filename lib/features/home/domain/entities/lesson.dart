import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? description;
  final String? duration;
  final bool viewed;
  
  // Video fields
  final String? bunnyUrl;
  final String? bunnyUri;
  final String? videoStatus;
  final String? videoDuration;
  
  // Parent references
  final int? courseId;
  final int? chapterId;

  const Lesson({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.description,
    this.duration,
    this.viewed = false,
    this.bunnyUrl,
    this.bunnyUri,
    this.videoStatus,
    this.videoDuration,
    this.courseId,
    this.chapterId,
  });

  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;
  
  /// Check if video is ready to play
  bool get isVideoReady => videoStatus == 'uploaded' && bunnyUrl != null;
  
  /// Get the video URL for playback (prefer bunny_url for embed)
  String? get videoUrl => bunnyUrl ?? bunnyUri;

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        description,
        duration,
        viewed,
        bunnyUrl,
        bunnyUri,
        videoStatus,
        videoDuration,
        courseId,
        chapterId,
      ];
}

