import 'package:equatable/equatable.dart';

class Mentor extends Equatable {
  final int id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final int? coursesCount;
  final int? studentsCount;
  final String? rating;

  const Mentor({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.coursesCount,
    this.studentsCount,
    this.rating,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl, coursesCount, studentsCount, rating];
}



