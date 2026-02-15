import 'package:equatable/equatable.dart';
import 'reel_category.dart';
import 'reel_owner.dart';

class Reel extends Equatable {
  final int id;
  final String title;
  final String description;
  final String redirectType;
  final String redirectLink;
  final String thumbnailUrl;
  final String bunnyUrl;
  final int durationSeconds;
  final int likesCount;
  final int viewsCount;
  final ReelOwner owner;
  final List<ReelCategory> categories;
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
    this.durationSeconds = 0,
    required this.likesCount,
    required this.viewsCount,
    required this.owner,
    this.categories = const [],
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
        durationSeconds,
        likesCount,
        viewsCount,
        owner,
        categories,
        viewed,
        liked,
        createdAt,
        updatedAt,
      ];
}



