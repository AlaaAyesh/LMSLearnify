import '../../domain/entities/reel_category.dart';

class ReelCategoryModel extends ReelCategory {
  const ReelCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    required super.isActive,
    required super.reelsCount,
  });

  factory ReelCategoryModel.fromJson(Map<String, dynamic> json) {
    return ReelCategoryModel(
      id: _parseInt(json['id']),
      name: json['name_ar']?.toString() ?? json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description_ar']?.toString() ?? json['description']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == null,
      reelsCount: json['reels_count'] != null ? _parseInt(json['reels_count']) : 0,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'is_active': isActive,
      'reels_count': reelsCount,
    };
  }
}
