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
    final dataList = json['data'] as List? ?? [];
    final metaJson = json['meta'] as Map<String, dynamic>? ?? {};

    return ReelsFeedResponseModel(
      reels: dataList.map((e) => ReelModel.fromJson(e)).toList(),
      meta: ReelsFeedMetaModel.fromJson(metaJson),
    );
  }
}

