import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/guest_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../authentication/presentation/widgets/EmailField.dart';
import '../../../authentication/presentation/widgets/PasswordField.dart';
import '../../../authentication/presentation/widgets/name_field.dart';
import '../../../authentication/presentation/widgets/phone_field.dart';
import '../../../authentication/presentation/widgets/primary_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final guestService = sl<GuestService>();

    // Check if user is guest
    if (guestService.isGuestMode()) {
      return _GuestProfilePage();
    }

    // Return normal profile page with BlocProvider
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(CheckAuthStatusEvent()),
      child: const _AuthenticatedProfilePage(),
    );
  }
}

// 🆕 Guest Profile Page
class _GuestProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('الحساب'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_off_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 32),

              // Title
              Text(
                'أنت تتصفح كضيف',
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),

              // Description
              Text(
                'للوصول إلى ملفك الشخصي والمحتوى الكامل، يرجى تسجيل الدخول أو إنشاء حساب جديد',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pushReplacementNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontFamily: cairoFontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pushNamed('/register');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(
                      fontFamily: cairoFontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Existing authenticated profile page
class _AuthenticatedProfilePage extends StatefulWidget {
  const _AuthenticatedProfilePage();

  @override
  State<_AuthenticatedProfilePage> createState() =>
      _AuthenticatedProfilePageState();
}

class _AuthenticatedProfilePageState extends State<_AuthenticatedProfilePage> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? countryCode = '+20'; // Default to Egypt
  User? currentUser;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _populateUserData(User user) {
    currentUser = user;
    nameController.text = user.name;
    emailController.text = user.email;
    
    // Parse phone number to extract country code
    if (user.phone != null && user.phone!.isNotEmpty) {
      final parsed = _parsePhoneNumber(user.phone!);
      countryCode = parsed['countryCode'];
      phoneController.text = parsed['localNumber'] ?? '';
    }
  }
  
  Map<String, String?> _parsePhoneNumber(String fullPhone) {
    // List of country codes to check (longest first to avoid partial matches)
    const countryCodes = [
      '+966', '+971', '+965', '+974', '+973', '+968', '+962', '+961', '+964', '+963',
      '+212', '+216', '+213', '+218', '+249', '+967', '+20',
    ];
    
    for (final code in countryCodes) {
      if (fullPhone.startsWith(code)) {
        return {
          'countryCode': code,
          'localNumber': fullPhone.substring(code.length),
        };
      }
    }
    
    // If no country code found, return as is with default
    return {
      'countryCode': '+20',
      'localNumber': fullPhone.replaceFirst('+', ''),
    };
  }

  void onSave() {
    if (formKey.currentState!.validate()) {
      // TODO: Implement update profile API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ التعديلات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(title: 'الحساب'),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _populateUserData(state.user);
          } else if (state is AuthUnauthenticated) {
            // Navigate to login and clear all routes using root navigator
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is AuthAuthenticated) {
            return _buildProfileContent(state.user);
          }

          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(User user) {
    // Populate data if not already done
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateUserData(user);
        setState(() {});
      });
    }

    return Stack(
      children: [
        const CustomBackground(),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: 24),

                // Profile Avatar
                _buildProfileAvatar(user),
                SizedBox(height: 16),

                // User Info
                Text(
                  user.name,
                  style: AppTextStyles.displayMedium,
                ),
                SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),

                // Subscription Status
                _buildSubscriptionBadge(user),
                SizedBox(height: 32),

                // Form Fields
                NameField(controller: nameController),
                SizedBox(height: 16),

                PhoneField(
                  controller: phoneController,
                  countryCode: countryCode,
                  onCountryChanged: (v) => setState(() => countryCode = v),
                ),
                SizedBox(height: 16),

                EmailField(controller: emailController),
                SizedBox(height: 24),

                // Change Password Section
                _buildSectionTitle('تغيير كلمة المرور'),
                SizedBox(height: 16),

                PasswordField(
                  controller: passwordController,
                  obscure: obscurePassword,
                  hintText: 'كلمة المرور الجديدة',
                  validator: (v) => null, // Optional
                  onToggleVisibility: () =>
                      setState(() => obscurePassword = !obscurePassword),
                ),
                SizedBox(height: 16),

                PasswordField(
                  controller: confirmPasswordController,
                  obscure: obscureConfirmPassword,
                  hintText: 'تأكيد كلمة المرور',
                  validator: (v) {
                    if (passwordController.text.isNotEmpty &&
                        v != passwordController.text) {
                      return 'كلمة المرور غير متطابقة';
                    }
                    return null;
                  },
                  onToggleVisibility: () => setState(
                      () => obscureConfirmPassword = !obscureConfirmPassword),
                ),
                SizedBox(height: 32),

                // Save Button
                PrimaryButton(
                  text: 'حفظ التعديلات',
                  onPressed: onSave,
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(User user) {
    return CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          backgroundImage:
              user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? NetworkImage(user.avatarUrl!)
                  : null,
          child: user.avatarUrl == null || user.avatarUrl!.isEmpty
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              : null,
    );
  }

  Widget _buildSubscriptionBadge(User user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: user.isSubscribed
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            user.isSubscribed ? Icons.verified : Icons.info_outline,
            size: 16,
            color: user.isSubscribed ? AppColors.success : AppColors.warning,
          ),
          SizedBox(width: 8),
          Text(
            user.isSubscribed ? 'مشترك' : 'غير مشترك',
            style: TextStyle(
              fontFamily: cairoFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: user.isSubscribed ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}


