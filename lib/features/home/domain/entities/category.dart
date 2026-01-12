import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String nameAr;
  final String nameEn;
  final String? description;
  final int? specialtyId;
  final String? imageUrl;
  final int? coursesCount;

  const Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.description,
    this.specialtyId,
    this.imageUrl,
    this.coursesCount,
  });

  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameAr, nameEn, description, specialtyId, imageUrl, coursesCount];
}



