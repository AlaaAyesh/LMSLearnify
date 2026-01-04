import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/generate_certificate_usecase.dart';
import '../../domain/usecases/get_certificate_by_id_usecase.dart';
import '../../domain/usecases/get_owned_certificates_usecase.dart';
import 'certificate_event.dart';
import 'certificate_state.dart';

class CertificateBloc extends Bloc<CertificateEvent, CertificateState> {
  final GenerateCertificateUseCase generateCertificateUseCase;
  final GetOwnedCertificatesUseCase getOwnedCertificatesUseCase;
  final GetCertificateByIdUseCase getCertificateByIdUseCase;

  CertificateBloc({
    required this.generateCertificateUseCase,
    required this.getOwnedCertificatesUseCase,
    required this.getCertificateByIdUseCase,
  }) : super(CertificateInitial()) {
    on<LoadOwnedCertificatesEvent>(_onLoadOwnedCertificates);
    on<GenerateCertificateEvent>(_onGenerateCertificate);
    on<LoadCertificateByIdEvent>(_onLoadCertificateById);
    on<DownloadCertificateEvent>(_onDownloadCertificate);
    on<ClearCertificateStateEvent>(_onClearState);
  }

  Future<void> _onLoadOwnedCertificates(
    LoadOwnedCertificatesEvent event,
    Emitter<CertificateState> emit,
  ) async {
    emit(CertificateLoading());

    final result = await getOwnedCertificatesUseCase();

    result.fold(
      (failure) => emit(CertificateError(failure.message)),
      (certificates) {
        if (certificates.isEmpty) {
          emit(CertificatesEmpty());
        } else {
          emit(CertificatesLoaded(certificates));
        }
      },
    );
  }

  Future<void> _onGenerateCertificate(
    GenerateCertificateEvent event,
    Emitter<CertificateState> emit,
  ) async {
    emit(CertificateLoading());

    final result = await generateCertificateUseCase(courseId: event.courseId);

    result.fold(
      (failure) => emit(CertificateError(failure.message)),
      (certificate) => emit(CertificateGenerated(certificate: certificate)),
    );
  }

  Future<void> _onLoadCertificateById(
    LoadCertificateByIdEvent event,
    Emitter<CertificateState> emit,
  ) async {
    emit(CertificateLoading());

    final result = await getCertificateByIdUseCase(
      certificateId: event.certificateId,
    );

    result.fold(
      (failure) => emit(CertificateError(failure.message)),
      (certificate) => emit(CertificateLoaded(certificate)),
    );
  }

  Future<void> _onDownloadCertificate(
    DownloadCertificateEvent event,
    Emitter<CertificateState> emit,
  ) async {
    emit(CertificateDownloading());

    // TODO: Implement actual download logic using dio/url_launcher
    // For now, we'll emit success with the download URL
    // In a real implementation, you would:
    // 1. Use dio to download the file
    // 2. Save it to the device storage
    // 3. Return the local file path
    
    emit(CertificateDownloaded(event.downloadUrl));
  }

  void _onClearState(
    ClearCertificateStateEvent event,
    Emitter<CertificateState> emit,
  ) {
    emit(CertificateInitial());
  }
}

