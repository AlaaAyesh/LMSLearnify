import 'package:equatable/equatable.dart';

class Instructor extends Equatable {
  final int id;
  final String name;
  final String? email;
  final String? avatarUrl;

  const Instructor({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl];
}



