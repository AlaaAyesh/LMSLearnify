import '../../domain/entities/banner.dart';

class HomeBannerModel extends HomeBanner {
  const HomeBannerModel({
    required super.id,
    super.title,
    super.description,
    super.imageUrl,
    super.linkUrl,
    super.isActive,
  });

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) {
    return HomeBannerModel(
      id: _parseInt(json['id']),
      title: (json['title'] ?? json['title_ar'] ?? json['title_en'])?.toString(),
      description: (json['description'] ?? json['description_ar'] ?? json['description_en'])?.toString(),
      imageUrl: (json['image_url'] ?? json['image'])?.toString(),
      linkUrl: (json['link_url'] ?? json['link'])?.toString(),
      isActive: _parseBool(json['is_active']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return true; // Default to active
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'is_active': isActive,
    };
  }
}



