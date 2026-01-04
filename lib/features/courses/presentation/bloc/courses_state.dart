import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/course.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CoursesInitial extends CoursesState {}

/// Loading state
class CoursesLoading extends CoursesState {}

/// Courses loaded successfully
class CoursesLoaded extends CoursesState {
  final List<Course> courses;
  final int? categoryId;
  final int? specialtyId;
  final int currentPage;
  final bool hasMorePages;
  final bool isLoadingMore;

  const CoursesLoaded({
    required this.courses,
    this.categoryId,
    this.specialtyId,
    this.currentPage = 1,
    this.hasMorePages = false,
    this.isLoadingMore = false,
  });

  CoursesLoaded copyWith({
    List<Course>? courses,
    int? categoryId,
    int? specialtyId,
    int? currentPage,
    bool? hasMorePages,
    bool? isLoadingMore,
  }) {
    return CoursesLoaded(
      courses: courses ?? this.courses,
      categoryId: categoryId ?? this.categoryId,
      specialtyId: specialtyId ?? this.specialtyId,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        courses,
        categoryId,
        specialtyId,
        currentPage,
        hasMorePages,
        isLoadingMore,
      ];
}

/// Single course details loaded
class CourseDetailsLoaded extends CoursesState {
  final Course course;

  const CourseDetailsLoaded({required this.course});

  @override
  List<Object?> get props => [course];
}

/// User's enrolled courses loaded
class MyCoursesLoaded extends CoursesState {
  final List<Course> courses;

  const MyCoursesLoaded({required this.courses});

  @override
  List<Object?> get props => [courses];
}

/// No courses available
class CoursesEmpty extends CoursesState {}

/// Error state
class CoursesError extends CoursesState {
  final String message;

  const CoursesError(this.message);

  @override
  List<Object?> get props => [message];
}


