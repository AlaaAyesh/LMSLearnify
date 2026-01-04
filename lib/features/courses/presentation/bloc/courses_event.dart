import 'package:equatable/equatable.dart';

abstract class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object?> get props => [];
}

/// Load all courses with optional filters
class LoadCoursesEvent extends CoursesEvent {
  final int? page;
  final int? perPage;
  final int? categoryId;
  final int? specialtyId;
  final bool refresh;

  const LoadCoursesEvent({
    this.page,
    this.perPage,
    this.categoryId,
    this.specialtyId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, perPage, categoryId, specialtyId, refresh];
}

/// Load more courses for pagination
class LoadMoreCoursesEvent extends CoursesEvent {
  const LoadMoreCoursesEvent();
}

/// Load a specific course by ID
class LoadCourseByIdEvent extends CoursesEvent {
  final int id;

  const LoadCourseByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Load user's enrolled courses
class LoadMyCoursesEvent extends CoursesEvent {
  const LoadMyCoursesEvent();
}

/// Filter courses by category
class FilterByCategoryEvent extends CoursesEvent {
  final int? categoryId;

  const FilterByCategoryEvent({this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

/// Filter courses by specialty (age group)
class FilterBySpecialtyEvent extends CoursesEvent {
  final int? specialtyId;

  const FilterBySpecialtyEvent({this.specialtyId});

  @override
  List<Object?> get props => [specialtyId];
}

/// Clear all filters
class ClearFiltersEvent extends CoursesEvent {
  const ClearFiltersEvent();
}

/// Clear course state
class ClearCoursesStateEvent extends CoursesEvent {
  const ClearCoursesStateEvent();
}


