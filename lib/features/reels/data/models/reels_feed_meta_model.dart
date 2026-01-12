import '../../domain/entities/reels_feed_meta.dart';

class ReelsFeedMetaModel extends ReelsFeedMeta {
  const ReelsFeedMetaModel({
    required super.perPage,
    super.nextCursor,
    required super.hasMore,
    super.remaining,
    super.limitMessage,
    super.total,
    super.currentPage,
    super.lastPage,
    super.nextPageUrl,
    super.prevPageUrl,
    super.from,
    super.to,
  });

  factory ReelsFeedMetaModel.fromJson(Map<String, dynamic> json) {
    // Calculate hasMore from various sources
    bool hasMoreValue = false;
    if (json['has_more'] != null) {
      hasMoreValue = _parseBool(json['has_more']);
    } else if (json['next_page_url'] != null && json['next_page_url'].toString().isNotEmpty) {
      hasMoreValue = true;
    } else if (json['remaining'] != null && _parseInt(json['remaining']) > 0) {
      hasMoreValue = true;
    } else if (json['current_page'] != null && json['last_page'] != null) {
      final current = _parseInt(json['current_page']);
      final last = _parseInt(json['last_page']);
      hasMoreValue = current < last;
    }
    
    return ReelsFeedMetaModel(
      perPage: _parseInt(json['per_page'] ?? 2),
      nextCursor: json['next_cursor']?.toString(),
      hasMore: hasMoreValue,
      remaining: json['remaining'] != null ? _parseInt(json['remaining']) : null,
      limitMessage: json['limit_message']?.toString(),
      total: json['total'] != null ? _parseInt(json['total']) : null,
      currentPage: json['current_page'] != null ? _parseInt(json['current_page']) : null,
      lastPage: json['last_page'] != null ? _parseInt(json['last_page']) : null,
      nextPageUrl: json['next_page_url']?.toString(),
      prevPageUrl: json['prev_page_url']?.toString(),
      from: json['from'] != null ? _parseInt(json['from']) : null,
      to: json['to'] != null ? _parseInt(json['to']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'per_page': perPage,
      'next_cursor': nextCursor,
      'has_more': hasMore,
      'remaining': remaining,
      'limit_message': limitMessage,
      'total': total,
      'current_page': currentPage,
      'last_page': lastPage,
      'next_page_url': nextPageUrl,
      'prev_page_url': prevPageUrl,
      'from': from,
      'to': to,
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



