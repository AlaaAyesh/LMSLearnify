import 'package:equatable/equatable.dart';
import 'reel_owner.dart';

class Reel extends Equatable {
  final int id;
  final String title;
  final String description;
  final String redirectType;
  final String redirectLink;
  final String thumbnailUrl;
  final String bunnyUrl;
  final int likesCount;
  final int viewsCount;
  final ReelOwner owner;
  final bool viewed;
  final bool liked;
  final String createdAt;
  final String updatedAt;

  const Reel({
    required this.id,
    required this.title,
    required this.description,
    required this.redirectType,
    required this.redirectLink,
    required this.thumbnailUrl,
    required this.bunnyUrl,
    required this.likesCount,
    required this.viewsCount,
    required this.owner,
    required this.viewed,
    required this.liked,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedLikes {
    if (likesCount >= 1000000) {
      return '${(likesCount / 1000000).toStringAsFixed(1)}M';
    } else if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}K';
    }
    return '$likesCount';
  }

  String get formattedViews {
    if (viewsCount >= 1000000) {
      return '${(viewsCount / 1000000).toStringAsFixed(1)}M views';
    } else if (viewsCount >= 1000) {
      return '${(viewsCount / 1000).toStringAsFixed(1)}K views';
    }
    return '$viewsCount views';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        redirectType,
        redirectLink,
        thumbnailUrl,
        bunnyUrl,
        likesCount,
        viewsCount,
        owner,
        viewed,
        liked,
        createdAt,
        updatedAt,
      ];
}



