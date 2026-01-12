import 'package:equatable/equatable.dart';

class ReelsFeedMeta extends Equatable {
  final int perPage;
  final String? nextCursor;
  final bool hasMore;
  
  // New pagination fields
  final int? remaining;
  final String? limitMessage;
  final int? total;
  final int? currentPage;
  final int? lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final int? from;
  final int? to;

  const ReelsFeedMeta({
    required this.perPage,
    this.nextCursor,
    required this.hasMore,
    this.remaining,
    this.limitMessage,
    this.total,
    this.currentPage,
    this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
    this.from,
    this.to,
  });

  @override
  List<Object?> get props => [
        perPage,
        nextCursor,
        hasMore,
        remaining,
        limitMessage,
        total,
        currentPage,
        lastPage,
        nextPageUrl,
        prevPageUrl,
        from,
        to,
      ];
}



