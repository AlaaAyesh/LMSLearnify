import '../../domain/entities/reels_feed_meta.dart';

class ReelsFeedMetaModel extends ReelsFeedMeta {
  const ReelsFeedMetaModel({
    required super.perPage,
    super.nextCursor,
    required super.hasMore,
  });

  factory ReelsFeedMetaModel.fromJson(Map<String, dynamic> json) {
    return ReelsFeedMetaModel(
      perPage: _parseInt(json['per_page']),
      nextCursor: json['next_cursor']?.toString(),
      hasMore: _parseBool(json['has_more']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'per_page': perPage,
      'next_cursor': nextCursor,
      'has_more': hasMore,
    };
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }
}

