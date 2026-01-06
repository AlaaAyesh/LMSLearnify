import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/register_usecase.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/certificates/data/datasources/certificate_remote_datasource.dart';
import '../../features/certificates/data/repositories/certificate_repository_impl.dart';
import '../../features/certificates/domain/repositories/certificate_repository.dart';
import '../../features/certificates/domain/usecases/generate_certificate_usecase.dart';
import '../../features/certificates/domain/usecases/get_certificate_by_id_usecase.dart';
import '../../features/certificates/domain/usecases/get_owned_certificates_usecase.dart';
import '../../features/certificates/presentation/bloc/certificate_bloc.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_data_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/subscriptions/data/datasources/subscription_remote_datasource.dart';
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../features/subscriptions/domain/repositories/subscription_repository.dart';
import '../../features/subscriptions/domain/usecases/create_subscription_usecase.dart';
import '../../features/subscriptions/domain/usecases/get_subscription_by_id_usecase.dart';
import '../../features/subscriptions/domain/usecases/get_subscriptions_usecase.dart';
import '../../features/subscriptions/domain/usecases/update_subscription_usecase.dart';
import '../../features/subscriptions/presentation/bloc/subscription_bloc.dart';
import '../../features/courses/data/datasources/course_remote_datasource.dart';
import '../../features/courses/data/repositories/course_repository_impl.dart';
import '../../features/courses/domain/repositories/course_repository.dart';
import '../../features/courses/domain/usecases/get_courses_usecase.dart';
import '../../features/courses/domain/usecases/get_course_by_id_usecase.dart';
import '../../features/courses/domain/usecases/get_my_courses_usecase.dart';
import '../../features/courses/presentation/bloc/courses_bloc.dart';
import '../../features/lessons/data/datasources/lesson_remote_datasource.dart';
import '../../features/lessons/data/repositories/lesson_repository_impl.dart';
import '../../features/lessons/domain/repositories/lesson_repository.dart';
import '../../features/lessons/domain/usecases/get_lesson_by_id_usecase.dart';
import '../../features/lessons/domain/usecases/mark_lesson_viewed_usecase.dart';
import '../../features/lessons/presentation/bloc/lesson_bloc.dart';
import '../../features/chapters/data/datasources/chapter_remote_datasource.dart';
import '../../features/chapters/data/repositories/chapter_repository_impl.dart';
import '../../features/chapters/domain/repositories/chapter_repository.dart';
import '../../features/chapters/domain/usecases/get_chapter_by_id_usecase.dart';
import '../../features/chapters/presentation/bloc/chapter_bloc.dart';
import '../../features/reels/data/datasources/reels_remote_datasource.dart';
import '../../features/reels/data/repositories/reels_repository_impl.dart';
import '../../features/reels/domain/repositories/reels_repository.dart';
import '../../features/reels/domain/usecases/get_reels_feed_usecase.dart';
import '../../features/reels/domain/usecases/record_reel_view_usecase.dart';
import '../../features/reels/domain/usecases/toggle_reel_like_usecase.dart';
import '../../features/reels/presentation/bloc/reels_bloc.dart';
import '../network/dio_client.dart';
import '../services/guest_service.dart';
import '../storage/hive_service.dart';
import '../storage/secure_storage_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton(() => secureStorage);

  // Core
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton(() => HiveService());
  sl.registerLazySingleton(() => DioClient(sl()));

  // 🆕 Guest Service
  sl.registerLazySingleton(() => GuestService(sl()));

  // Features
  _initAuth();
  _initCertificates();
  _initHome();
  _initSubscriptions();
  _initCourses();
  _initLessons();
  _initChapters();
  _initReels();
}

void _initAuth() {
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(
      hiveService: sl(),
      secureStorage: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      guestService: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // Bloc
  sl.registerFactory(
        () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      authRepository: sl(),
    ),
  );
}

void _initCertificates() {
  // Data Sources
  sl.registerLazySingleton<CertificateRemoteDataSource>(
        () => CertificateRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<CertificateRepository>(
        () => CertificateRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GenerateCertificateUseCase(sl()));
  sl.registerLazySingleton(() => GetOwnedCertificatesUseCase(sl()));
  sl.registerLazySingleton(() => GetCertificateByIdUseCase(sl()));

  // Bloc
  sl.registerFactory(
        () => CertificateBloc(
      generateCertificateUseCase: sl(),
      getOwnedCertificatesUseCase: sl(),
      getCertificateByIdUseCase: sl(),
    ),
  );
}

void _initHome() {
  // Data Sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
        () => HomeRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<HomeRepository>(
        () => HomeRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl()));

  // Bloc
  sl.registerFactory(
        () => HomeBloc(
      getHomeDataUseCase: sl(),
    ),
  );
}

void _initSubscriptions() {
  // Data Sources
  sl.registerLazySingleton<SubscriptionRemoteDataSource>(
        () => SubscriptionRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<SubscriptionRepository>(
        () => SubscriptionRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetSubscriptionsUseCase(sl()));
  sl.registerLazySingleton(() => GetSubscriptionByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateSubscriptionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSubscriptionUseCase(sl()));

  // Bloc
  sl.registerFactory(
        () => SubscriptionBloc(
      getSubscriptionsUseCase: sl(),
      getSubscriptionByIdUseCase: sl(),
      createSubscriptionUseCase: sl(),
      updateSubscriptionUseCase: sl(),
    ),
  );
}

void _initCourses() {
  // Data Sources
  sl.registerLazySingleton<CourseRemoteDataSource>(
        () => CourseRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<CourseRepository>(
        () => CourseRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCoursesUseCase(sl()));
  sl.registerLazySingleton(() => GetCourseByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetMyCoursesUseCase(sl()));

  // Bloc
  sl.registerFactory(
        () => CoursesBloc(
      getCoursesUseCase: sl(),
      getCourseByIdUseCase: sl(),
      getMyCoursesUseCase: sl(),
    ),
  );
}

void _initLessons() {
  // Data Sources
  sl.registerLazySingleton<LessonRemoteDataSource>(
        () => LessonRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<LessonRepository>(
        () => LessonRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetLessonByIdUseCase(sl()));
  sl.registerLazySingleton(() => MarkLessonViewedUseCase(sl()));

  // Bloc
  sl.registerFactory(
        () => LessonBloc(
      getLessonByIdUseCase: sl(),
      markLessonViewedUseCase: sl(),
    ),
  );
}

void _initChapters() {
  // Data Sources
  sl.registerLazySingleton<ChapterRemoteDataSource>(
        () => ChapterRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<ChapterRepository>(
        () => ChapterRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetChapterByIdUseCase(sl()));

  // Bloc
  sl.registerFactory(
        () => ChapterBloc(
      getChapterByIdUseCase: sl(),
    ),
  );
}

void _initReels() {
  // Data Sources
  sl.registerLazySingleton<ReelsRemoteDataSource>(
        () => ReelsRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<ReelsRepository>(
        () => ReelsRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetReelsFeedUseCase(sl()));
  sl.registerLazySingleton(() => RecordReelViewUseCase(sl()));
  sl.registerLazySingleton(() => ToggleReelLikeUseCase(sl()));

  // Bloc
  sl.registerFactory(
        () => ReelsBloc(
      getReelsFeedUseCase: sl(),
      recordReelViewUseCase: sl(),
      toggleReelLikeUseCase: sl(),
    ),
  );
}
