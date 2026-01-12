import '../../domain/entities/banner.dart';

class BannerModel extends Banner {
  const BannerModel({
    required super.id,
    required super.title,
    required super.status,
    required super.bannerUrl,
    required super.buttonDescription,
    required super.websiteImageUrl,
    required super.mobileImageUrl,
    required super.clickCount,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      status: _parseInt(json['status']),
      bannerUrl: json['banner_url']?.toString() ?? '',
      buttonDescription: json['button_description']?.toString() ?? '',
      websiteImageUrl: json['website_image_url']?.toString() ?? '',
      mobileImageUrl: json['mobile_image_url']?.toString() ?? '',
      clickCount: _parseInt(json['click_count']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'banner_url': bannerUrl,
      'button_description': buttonDescription,
      'website_image_url': websiteImageUrl,
      'mobile_image_url': mobileImageUrl,
      'click_count': clickCount,
    };
  }
}
