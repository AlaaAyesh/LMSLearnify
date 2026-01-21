import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../../../core/utils/responsive.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/certificate.dart';
import '../bloc/certificate_bloc.dart';
import '../bloc/certificate_event.dart';
import '../bloc/certificate_state.dart';
import '../../../../core/routing/app_router.dart';
import 'widgets/certificate_plan_card.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final token = await authLocalDataSource.getAccessToken();
    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: 'شهاداتي'),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!_isAuthenticated) {
      return _UnauthenticatedCertificatesPage();
    }

    // User is authenticated - load certificates
    return BlocProvider(
      create: (context) => sl<CertificateBloc>()..add(LoadOwnedCertificatesEvent()),
      child: const _CertificatesPageContent(),
    );
  }
}

// Unauthenticated Certificates Page
class _UnauthenticatedCertificatesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'شهاداتي'),
      body: Center(
        child: Padding(
          padding: Responsive.padding(
            context,
            horizontal: 24,
            vertical: 16,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: Responsive.iconSize(context, 80),
                  color: AppColors.primary,
                ),
                SizedBox(height: Responsive.spacing(context, 24)),
                Text(
                  'تسجيل الدخول مطلوب',
                  style: AppTextStyles.displayMedium.copyWith(
                    fontSize: Responsive.fontSize(context, 24),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.spacing(context, 12)),
                Text(
                  'للوصول إلى شهاداتك، يرجى تسجيل الدخول أو إنشاء حساب جديد',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: Responsive.fontSize(context, 16),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: Responsive.spacing(context, 28)),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: Responsive.height(context, 56),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Go directly to login using the root navigator
                        final result = await Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed(
                          AppRouter.login,
                          arguments: {'returnTo': 'certificates'},
                        );

                        if (result == true && context.mounted) {
                          // After successful login, reload the certificates page
                          Navigator.of(context, rootNavigator: true)
                              .pushReplacementNamed(AppRouter.certificates);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0, // مهم: نشيل elevation الافتراضي
                        padding: EdgeInsets.zero, // إزالة أي padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.spacing(context, 24)),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: Responsive.height(context, 56),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: OutlinedButton(
                      onPressed: () async {
                        // Go directly to register using the root navigator
                        final result = await Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed(
                          AppRouter.register,
                          arguments: {'returnTo': 'certificates'},
                        );

                        if (result == true && context.mounted) {
                          // After successful registration, reload the certificates page
                          Navigator.of(context, rootNavigator: true)
                              .pushReplacementNamed(AppRouter.certificates);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero, // إزالة margin الداخلي
                        side: const BorderSide(color: AppColors.primary),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
                return Center(
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
              return Center(
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: Responsive.padding(
                context,
                horizontal: 20,
                vertical: 12,
              ),
              child: ListView.builder(
                itemCount: certificates.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final certificate = certificates[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.width(context, 6),
                      vertical: Responsive.spacing(context, 10),
                    ),
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
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: Responsive.padding(context, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                size: Responsive.iconSize(context, 80),
                color: Colors.grey[400],
              ),
              SizedBox(height: Responsive.spacing(context, 14)),
              Text(
                'لا توجد شهادات حتى الآن',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 18),
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.spacing(context, 6)),
              Text(
                'أكمل الدورات للحصول على شهادات',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  color: Colors.grey[500],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Responsive.spacing(context, 18)),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<CertificateBloc>().add(LoadOwnedCertificatesEvent());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.width(context, 20),
                    vertical: Responsive.spacing(context, 10),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final isAuthError = message.contains('تسجيل الدخول');
    
    return Padding(
      padding: Responsive.padding(context, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAuthError ? Icons.lock_outline : Icons.error_outline,
                size: Responsive.iconSize(context, 80),
                color: isAuthError ? AppColors.primary : Colors.red[400],
              ),
              SizedBox(height: Responsive.spacing(context, 14)),
              Text(
                isAuthError ? 'يرجى تسجيل الدخول' : 'حدث خطأ',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 18),
                  fontFamily: 'Cairo',
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 8)),
              Padding(
                padding: Responsive.padding(context, horizontal: 16),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 14),
                    fontFamily: 'Cairo',
                    color: Colors.grey[500],
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: Responsive.spacing(context, 18)),
              if (isAuthError)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .pushReplacementNamed(AppRouter.login);
                  },
                  icon: const Icon(Icons.login),
                  label: Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.width(context, 20),
                      vertical: Responsive.spacing(context, 10),
                    ),
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
                  label: Text(
                    'إعادة المحاولة',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.width(context, 20),
                      vertical: Responsive.spacing(context, 10),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
        SnackBar(
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



