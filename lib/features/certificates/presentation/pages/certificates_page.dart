import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../domain/entities/certificate.dart';
import '../bloc/certificate_bloc.dart';
import '../bloc/certificate_event.dart';
import '../bloc/certificate_state.dart';
import 'widgets/certificate_plan_card.dart';

class CertificatesPage extends StatelessWidget {
  const CertificatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Always try to load certificates - the API will tell us if user is authenticated
    return BlocProvider(
      create: (context) => sl<CertificateBloc>()..add(LoadOwnedCertificatesEvent()),
      child: const _CertificatesPageContent(),
    );
  }
}

class _CertificatesPageContent extends StatelessWidget {
  const _CertificatesPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'شهاداتي',
      ),
      body: Stack(
        children: [
          const CustomBackground(),
          BlocConsumer<CertificateBloc, CertificateState>(
            listener: (context, state) {
              if (state is CertificateError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is CertificateDownloaded) {
                _openUrl(state.filePath);
              } else if (state is CertificateGenerated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                // Reload certificates after generating a new one
                context.read<CertificateBloc>().add(LoadOwnedCertificatesEvent());
              }
            },
            builder: (context, state) {
              if (state is CertificateLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is CertificatesEmpty) {
                return _buildEmptyState(context);
              }

              if (state is CertificatesLoaded) {
                return _buildCertificatesList(context, state.certificates);
              }

              if (state is CertificateError) {
                return _buildErrorState(context, state.message);
              }

              // Initial state - show loading
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesList(BuildContext context, List<Certificate> certificates) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<CertificateBloc>().add(LoadOwnedCertificatesEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: ListView.builder(
            itemCount: certificates.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final certificate = certificates[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                child: CertificatePlanCard(
                  courseName: certificate.courseName ?? 'شهادة #${certificate.id}',
                  description: certificate.issuedDate != null
                      ? 'تاريخ الإصدار: ${certificate.issuedDate}'
                      : 'يمكنك الحصول على الشهادة الآن',
                  onView: () => _viewCertificate(context, certificate),
                  onDownload: () => _downloadCertificate(context, certificate),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد شهادات حتى الآن',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أكمل الدورات للحصول على شهادات',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CertificateBloc>().add(LoadOwnedCertificatesEvent());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('تحديث'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final isAuthError = message.contains('تسجيل الدخول');
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAuthError ? Icons.lock_outline : Icons.error_outline,
            size: 80,
            color: isAuthError ? AppColors.primary : Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            isAuthError ? 'يرجى تسجيل الدخول' : 'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Cairo',
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Cairo',
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (isAuthError)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.login),
              label: const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                context.read<CertificateBloc>().add(LoadOwnedCertificatesEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _viewCertificate(BuildContext context, Certificate certificate) {
    final url = certificate.certificateUrl ?? certificate.downloadUrl;
    if (url != null && url.isNotEmpty) {
      _openUrl(url);
    } else {
      // Load certificate details by ID
      context.read<CertificateBloc>().add(
            LoadCertificateByIdEvent(certificateId: certificate.id),
          );
    }
  }

  void _downloadCertificate(BuildContext context, Certificate certificate) {
    final url = certificate.downloadUrl ?? certificate.certificateUrl;
    if (url != null && url.isNotEmpty) {
      context.read<CertificateBloc>().add(
            DownloadCertificateEvent(
              downloadUrl: url,
              fileName: 'certificate_${certificate.id}.pdf',
            ),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رابط التحميل غير متوفر'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
