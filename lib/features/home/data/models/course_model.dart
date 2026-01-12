import '../../domain/entities/course.dart';
import 'category_model.dart';
import 'chapter_model.dart';
import 'instructor_model.dart';
import 'specialty_model.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    super.about,
    super.whatYouWillLearn,
    super.thumbnail,
    super.price,
    super.priceBeforeDiscount,
    super.usdPrice,
    super.usdPriceBeforeDiscount,
    super.seoTitle,
    super.seoDescription,
    super.seoKeywords,
    super.specialty,
    super.categories,
    super.instructor,
    super.chapters,
    super.reviews,
    super.reviewsAvg,
    super.introBunnyUri,
    super.introBunnyUrl,
    super.introVideoDuration,
    super.introVideoStatus,
    super.purchaseCount,
      super.hidden,
      super.soon,
      super.locked,
      super.hasAccess,
      super.userHasCertificate,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: _parseInt(json['id']),
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      about: json['about']?.toString(),
      whatYouWillLearn: json['what_you_will_learn']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      price: json['price']?.toString(),
      priceBeforeDiscount: json['price_before_discount']?.toString(),
      usdPrice: json['usd_price']?.toString(),
      usdPriceBeforeDiscount: json['usd_price_before_discount']?.toString(),
      seoTitle: json['seo_title']?.toString(),
      seoDescription: json['seo_description']?.toString(),
      seoKeywords: json['seo_keywords']?.toString(),
      specialty: json['specialty'] != null && json['specialty'] is Map
          ? SpecialtyModel.fromJson(json['specialty'])
          : null,
      categories: json['categories'] != null && json['categories'] is List
          ? (json['categories'] as List)
              .map((c) => CategoryModel.fromJson(c))
              .toList()
          : [],
      instructor: json['instructor'] != null && json['instructor'] is Map
          ? InstructorModel.fromJson(json['instructor'])
          : null,
      chapters: json['chapters'] != null && json['chapters'] is List
          ? (json['chapters'] as List)
              .map((ch) => ChapterModel.fromJson(ch))
              .toList()
          : [],
      reviews: _parseInt(json['reviews']),
      reviewsAvg: json['reviews_avg']?.toString(),
      introBunnyUri: json['intro_bunny_uri']?.toString(),
      introBunnyUrl: json['intro_bunny_url']?.toString(),
      introVideoDuration: json['intro_video_duration']?.toString(),
      introVideoStatus: json['intro_video_status']?.toString(),
      purchaseCount: _parseInt(json['purchase_count']),
      hidden: _parseBool(json['hidden']),
      soon: _parseBool(json['soon']),
      locked: _parseBool(json['locked']),
      hasAccess: _parseBool(json['hasAccess']),
      userHasCertificate: _parseBool(json['userHasCertificate']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'about': about,
      'what_you_will_learn': whatYouWillLearn,
      'thumbnail': thumbnail,
      'price': price,
      'price_before_discount': priceBeforeDiscount,
      'usd_price': usdPrice,
      'usd_price_before_discount': usdPriceBeforeDiscount,
      'seo_title': seoTitle,
      'seo_description': seoDescription,
      'seo_keywords': seoKeywords,
      'specialty': specialty != null ? (specialty as SpecialtyModel).toJson() : null,
      'categories': categories.map((c) => (c as CategoryModel).toJson()).toList(),
      'instructor': instructor != null ? (instructor as InstructorModel).toJson() : null,
      'chapters': chapters.map((ch) => (ch as ChapterModel).toJson()).toList(),
      'reviews': reviews,
      'reviews_avg': reviewsAvg,
      'intro_bunny_uri': introBunnyUri,
      'intro_bunny_url': introBunnyUrl,
      'intro_video_duration': introVideoDuration,
      'intro_video_status': introVideoStatus,
      'purchase_count': purchaseCount,
      'hidden': hidden,
      'soon': soon,
      'locked': locked,
      'hasAccess': hasAccess,
      'userHasCertificate': userHasCertificate,
    };
  }
}



