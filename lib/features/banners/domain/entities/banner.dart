import 'package:equatable/equatable.dart';

class Banner extends Equatable {
  final int id;
  final String title;
  final int status;
  final String bannerUrl;
  final String buttonDescription;
  final String websiteImageUrl;
  final String mobileImageUrl;
  final int clickCount;

  const Banner({
    required this.id,
    required this.title,
    required this.status,
    required this.bannerUrl,
    required this.buttonDescription,
    required this.websiteImageUrl,
    required this.mobileImageUrl,
    required this.clickCount,
  });

  bool get isActive => status == 1;

  @override
  List<Object?> get props => [
        id,
        title,
        status,
        bannerUrl,
        buttonDescription,
        websiteImageUrl,
        mobileImageUrl,
        clickCount,
      ];
}
