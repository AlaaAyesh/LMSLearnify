import 'package:equatable/equatable.dart';
import 'category.dart';
import 'chapter.dart';
import 'instructor.dart';
import 'specialty.dart';

class Course extends Equatable {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? about;
  final String? whatYouWillLearn;
  final String? thumbnail;

  final String? price;
  final String? priceBeforeDiscount;
  final String? usdPrice;
  final String? usdPriceBeforeDiscount;

  final String? seoTitle;
  final String? seoDescription;
  final String? seoKeywords;

  final Specialty? specialty;
  final List<Category> categories;
  final Instructor? instructor;
  final List<Chapter> chapters;

  final int reviews;
  final String? reviewsAvg;

  final String? introBunnyUri;
  final String? introBunnyUrl;
  final String? introVideoDuration;
  final String? introVideoStatus;

  final int purchaseCount;
  final bool hidden;
  final bool soon;
  final bool locked;
  final bool hasAccess;
  final bool userHasCertificate;

  const Course({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.about,
    this.whatYouWillLearn,
    this.thumbnail,
    this.price,
    this.priceBeforeDiscount,
    this.usdPrice,
    this.usdPriceBeforeDiscount,
    this.seoTitle,
    this.seoDescription,
    this.seoKeywords,
    this.specialty,
    this.categories = const [],
    this.instructor,
    this.chapters = const [],
    this.reviews = 0,
    this.reviewsAvg,
    this.introBunnyUri,
    this.introBunnyUrl,
    this.introVideoDuration,
    this.introVideoStatus,
    this.purchaseCount = 0,
    this.hidden = false,
    this.soon = false,
    this.locked = false,
    this.hasAccess = false,
    this.userHasCertificate = false,
  });

  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;
  
  bool get hasDiscount => 
      priceBeforeDiscount != null && 
      priceBeforeDiscount!.isNotEmpty &&
      price != priceBeforeDiscount;

  String? get effectiveThumbnail {
    if (thumbnail != null && thumbnail!.isNotEmpty) {
      return thumbnail;
    }

    if (introBunnyUri != null &&
        introBunnyUri!.isNotEmpty && 
        introBunnyUri!.startsWith('http') &&
        !introBunnyUri!.contains('placeholder')) {
      if (introBunnyUri!.contains('thumbnail')) {
        return introBunnyUri;
      }
      return '${introBunnyUri}/thumbnail.jpg';
    }

    for (final chapter in chapters) {
      for (final lesson in chapter.lessons) {
        if (lesson.bunnyUri != null && 
            lesson.bunnyUri!.isNotEmpty &&
            lesson.bunnyUri!.startsWith('http') &&
            !lesson.bunnyUri!.contains('placeholder')) {
          if (lesson.bunnyUri!.contains('thumbnail')) {
            return lesson.bunnyUri;
          }
          return '${lesson.bunnyUri}/thumbnail.jpg';
        }
      }
    }
    return null;
  }

  int get totalLessons => chapters.fold(0, (sum, ch) => sum + ch.lessons.length);
  
  String get totalDuration {
    int totalMinutes = 0;
    for (final chapter in chapters) {
      for (final lesson in chapter.lessons) {
        if (lesson.duration != null) {
          final parts = lesson.duration!.split(':');
          if (parts.length >= 2) {
            totalMinutes += int.tryParse(parts[0]) ?? 0 * 60;
            totalMinutes += int.tryParse(parts[1]) ?? 0;
          }
        }
      }
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0) {
      return '$hours ساعة ${minutes > 0 ? 'و $minutes دقيقة' : ''}';
    }
    return '$minutes دقيقة';
  }

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        about,
        thumbnail,
        price,
        specialty,
        categories,
        instructor,
        chapters,
        reviews,
        hasAccess,
        soon,
        locked,
      ];
}



