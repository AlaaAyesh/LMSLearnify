import 'package:equatable/equatable.dart';

class ReelsFeedMeta extends Equatable {
  final int perPage;
  final String? nextCursor;
  final bool hasMore;

  const ReelsFeedMeta({
    required this.perPage,
    this.nextCursor,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [perPage, nextCursor, hasMore];
}



