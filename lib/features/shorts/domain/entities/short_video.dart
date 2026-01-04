class ShortVideo {
  final int id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String channelName;
  final String channelAvatarUrl;
  final int viewsCount;
  final int likesCount;
  final bool isLiked;
  final List<String> tags;
  final DateTime createdAt;

  const ShortVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.channelName,
    required this.channelAvatarUrl,
    required this.viewsCount,
    required this.likesCount,
    this.isLiked = false,
    this.tags = const [],
    required this.createdAt,
  });

  String get formattedViews {
    if (viewsCount >= 1000000) {
      return '${(viewsCount / 1000000).toStringAsFixed(1)} M views';
    } else if (viewsCount >= 1000) {
      return '${(viewsCount / 1000).toStringAsFixed(1)} K views';
    }
    return '$viewsCount views';
  }

  String get formattedLikes {
    if (likesCount >= 1000000) {
      return '${(likesCount / 1000000).toStringAsFixed(1)}M';
    } else if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}k';
    }
    return '$likesCount';
  }
}


