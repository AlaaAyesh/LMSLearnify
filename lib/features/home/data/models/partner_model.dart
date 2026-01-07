import '../../domain/entities/partner.dart';

class PartnerModel extends Partner {
  const PartnerModel({
    required super.id,
    required super.name,
    super.active,
    super.imageUrl,
    super.createdAt,
    super.updatedAt,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      active: _parseBool(json['active']),
      imageUrl: json['image_url']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'active': active,
      'image_url': imageUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }
}



