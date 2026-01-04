import 'package:equatable/equatable.dart';

class Partner extends Equatable {
  final int id;
  final String name;
  final bool active;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;

  const Partner({
    required this.id,
    required this.name,
    this.active = true,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, active, imageUrl];
}

