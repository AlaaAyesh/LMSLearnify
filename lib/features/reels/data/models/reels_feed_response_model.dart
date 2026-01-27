import 'reel_model.dart';
import 'reels_feed_meta_model.dart';

class ReelsFeedResponseModel {
  final List<ReelModel> reels;
  final ReelsFeedMetaModel meta;

  const ReelsFeedResponseModel({
    required this.reels,
    required this.meta,
  });

  factory ReelsFeedResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle different response structures
    // Structure 1: { "data": { "items": [...], "meta": {...} } }
    // Structure 2: { "data": { "data": [...], "meta": {...} } } - User reels API
    // Structure 3: { "data": [...], "meta": {...} }
    // Structure 4: { "items": [...], "meta": {...} }
    
    List<dynamic>? itemsList;
    Map<String, dynamic>? metaJson;
    
    // Check for nested data structure
    if (json['data'] != null && json['data'] is Map) {
      final data = json['data'] as Map<String, dynamic>;
      // Check for data.data (User reels API structure)
      if (data['data'] != null && data['data'] is List) {
        itemsList = data['data'] as List;
        metaJson = data['meta'] as Map<String, dynamic>?;
      }
      // Check for data.items structure
      else if (data['items'] != null && data['items'] is List) {
        itemsList = data['items'] as List;
        metaJson = data['meta'] as Map<String, dynamic>? ?? json['meta'] as Map<String, dynamic>?;
      }
    } 
    // Check for data as array
    else if (json['data'] != null && json['data'] is List) {
      itemsList = json['data'] as List;
      metaJson = json['meta'] as Map<String, dynamic>?;
    }
    // Check for items at root level
    else if (json['items'] != null && json['items'] is List) {
      itemsList = json['items'] as List;
      metaJson = json['meta'] as Map<String, dynamic>?;
    }
    
    return ReelsFeedResponseModel(
      reels: (itemsList ?? [])
          .map((e) => ReelModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: ReelsFeedMetaModel.fromJson(metaJson ?? {}),
    );
  }
}



