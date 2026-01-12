import 'package:equatable/equatable.dart';

class ReelCategory extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final bool isActive;
  final int reelsCount;

  const ReelCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.isActive,
    required this.reelsCount,
  });

  @override
  List<Object?> get props => [id, name, slug, description, isActive, reelsCount];
}
