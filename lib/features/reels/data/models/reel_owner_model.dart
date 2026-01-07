import '../../domain/entities/reel_owner.dart';

class ReelOwnerModel extends ReelOwner {
  const ReelOwnerModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
  });

  factory ReelOwnerModel.fromJson(Map<String, dynamic> json) {
    return ReelOwnerModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}



