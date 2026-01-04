import 'package:equatable/equatable.dart';

class Specialty extends Equatable {
  final int id;
  final String nameAr;
  final String nameEn;

  const Specialty({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameAr, nameEn];
}

