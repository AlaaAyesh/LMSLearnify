import 'package:equatable/equatable.dart';

class HomeBanner extends Equatable {
  final int id;
  final String? title;
  final String? description;
  final String? imageUrl;
  final String? linkUrl;
  final bool isActive;

  const HomeBanner({
    required this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.linkUrl,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, title, description, imageUrl, linkUrl, isActive];
}



