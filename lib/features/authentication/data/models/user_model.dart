import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    super.roles,
    super.permissions,
    super.country,
    super.specialtyId,
    super.specialty,
    super.phone,
    super.isSubscribed,
    super.subscriptionExpiryDate,
    super.gender,
    super.religion,
    super.birthday,
    super.age,
    super.approved,
    super.about,
    super.emailVerified,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle specialty_id which can be int or String
      int? specialtyIdValue;
      final rawSpecialtyId = json['specialty_id'];
      if (rawSpecialtyId is int) {
        specialtyIdValue = rawSpecialtyId;
      } else if (rawSpecialtyId is String) {
        specialtyIdValue = int.tryParse(rawSpecialtyId);
      }

      // Handle specialty which can be String or Map
      String? specialtyValue;
      final rawSpecialty = json['specialty'];
      if (rawSpecialty is String) {
        specialtyValue = rawSpecialty;
      } else if (rawSpecialty is Map) {
        specialtyValue = rawSpecialty['name_ar']?.toString() ?? rawSpecialty['name']?.toString();
      }

      // Handle about which can be String or null
      String? aboutValue;
      final rawAbout = json['about'];
      if (rawAbout is String) {
        aboutValue = rawAbout.isEmpty ? null : rawAbout;
      }

      return UserModel(
        id: json['id'] as int,
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        avatarUrl: json['avatar_url']?.toString(),
        roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        permissions: (json['permissions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        country: json['country']?.toString(),
        specialtyId: specialtyIdValue,
        specialty: specialtyValue,
        phone: json['phone']?.toString(),
        isSubscribed: json['isSubscribed'] as bool? ?? false,
        subscriptionExpiryDate: json['subscription_expiry_date']?.toString(),
        gender: json['gender']?.toString(),
        religion: json['religion']?.toString(),
        birthday: json['birthday']?.toString(),
        age: json['age'] as int?,
        approved: json['approved'] as bool? ?? false,
        about: aboutValue,
        emailVerified: json['email_verified'] as bool? ?? false,
        createdAt: json['created_at']?.toString(),
      );
    } catch (e, stackTrace) {
      print('UserModel.fromJson Error: $e');
      print('Stack trace: $stackTrace');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
        'roles': roles,
        'permissions': permissions,
        'country': country,
        'specialty_id': specialtyId,
        'specialty': specialty,
        'phone': phone,
        'isSubscribed': isSubscribed,
        'subscription_expiry_date': subscriptionExpiryDate,
        'gender': gender,
        'religion': religion,
        'birthday': birthday,
        'age': age,
        'approved': approved,
        'about': about,
        'email_verified': emailVerified,
        'created_at': createdAt,
      };

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      avatarUrl: user.avatarUrl,
      roles: user.roles,
      permissions: user.permissions,
      country: user.country,
      specialtyId: user.specialtyId,
      specialty: user.specialty,
      phone: user.phone,
      isSubscribed: user.isSubscribed,
      subscriptionExpiryDate: user.subscriptionExpiryDate,
      gender: user.gender,
      religion: user.religion,
      birthday: user.birthday,
      age: user.age,
      approved: user.approved,
      about: user.about,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
    );
  }
}


