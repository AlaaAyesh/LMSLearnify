import 'banner_model.dart';

class BannersResponseModel {
  final List<BannerModel> banners;
  final BannersMetaModel meta;

  const BannersResponseModel({
    required this.banners,
    required this.meta,
  });

  factory BannersResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final bannersList = data['data'] as List<dynamic>? ?? [];
    final metaData = data['meta'] as Map<String, dynamic>? ?? {};

    return BannersResponseModel(
      banners: bannersList
          .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: BannersMetaModel.fromJson(metaData),
    );
  }
}

class BannersMetaModel {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  const BannersMetaModel({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory BannersMetaModel.fromJson(Map<String, dynamic> json) {
    return BannersMetaModel(
      total: _parseInt(json['total']),
      perPage: _parseInt(json['per_page']),
      currentPage: _parseInt(json['current_page']),
      lastPage: _parseInt(json['last_page']),
      nextPageUrl: json['next_page_url']?.toString(),
      prevPageUrl: json['prev_page_url']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  bool get hasMore => nextPageUrl != null && nextPageUrl!.isNotEmpty;
}
