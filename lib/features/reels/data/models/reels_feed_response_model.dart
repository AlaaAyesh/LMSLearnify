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
    List<dynamic>? itemsList;
    Map<String, dynamic>? metaJson;

    if (json['data'] != null && json['data'] is Map) {
      final data = json['data'] as Map<String, dynamic>;
      if (data['data'] != null && data['data'] is List) {
        itemsList = data['data'] as List;
        metaJson = data['meta'] as Map<String, dynamic>?;
      }
      else if (data['items'] != null && data['items'] is List) {
        itemsList = data['items'] as List;
        metaJson = data['meta'] as Map<String, dynamic>? ?? json['meta'] as Map<String, dynamic>?;
      }
    }
    else if (json['data'] != null && json['data'] is List) {
      itemsList = json['data'] as List;
      metaJson = json['meta'] as Map<String, dynamic>?;
    }
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



