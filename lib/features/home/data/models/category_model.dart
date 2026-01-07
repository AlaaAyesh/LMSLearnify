import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    super.description,
    super.specialtyId,
    super.imageUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _parseInt(json['id']),
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      description: json['description']?.toString(),
      specialtyId: _parseNullableInt(json['specialty_id']),
      imageUrl: json['image_url']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseNullableInt(dynamic value) {
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
      'specialty_id': specialtyId,
      'image_url': imageUrl,
    };
  }
}



