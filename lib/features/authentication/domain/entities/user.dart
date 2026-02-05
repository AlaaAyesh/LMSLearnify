import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final List<String> roles;
  final List<String> permissions;
  final String? country;
  final int? specialtyId;
  final String? specialty;
  final String? phone;
  final bool isSubscribed;
  final String? subscriptionExpiryDate;
  final String? gender;
  final String? religion;
  final String? birthday;
  final int? age;
  final bool approved;
  final String? about;
  final bool emailVerified;
  final String? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.roles = const [],
    this.permissions = const [],
    this.country,
    this.specialtyId,
    this.specialty,
    this.phone,
    this.isSubscribed = false,
    this.subscriptionExpiryDate,
    this.gender,
    this.religion,
    this.birthday,
    this.age,
    this.approved = false,
    this.about,
    this.emailVerified = false,
    this.createdAt,
  });

  String get fullName => name;

  bool get isProfileComplete {
    return phone != null && 
           phone!.isNotEmpty && 
           birthday != null && 
           birthday!.isNotEmpty;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatarUrl,
        roles,
        permissions,
        country,
        specialtyId,
        specialty,
        phone,
        isSubscribed,
        subscriptionExpiryDate,
        gender,
        religion,
        birthday,
        age,
        approved,
        about,
        emailVerified,
        createdAt,
      ];
}


