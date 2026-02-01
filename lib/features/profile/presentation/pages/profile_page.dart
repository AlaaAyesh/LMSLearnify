import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
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
import '../../../authentication/presentation/widgets/birthday_field.dart';
import '../../../authentication/presentation/widgets/primary_button.dart';
import '../../../../core/routing/app_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Use the AuthBloc from app level, don't create a new one
    // This prevents _dependents.isEmpty errors when logging out and logging in again
    // Check auth status when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(CheckAuthStatusEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _ProfilePageContent();
  }
}

// Profile page content that handles both authenticated and unauthenticated states
class _ProfilePageContent extends StatefulWidget {
  const _ProfilePageContent();

  @override
  State<_ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<_ProfilePageContent> {
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    // Try to use the in-memory auth state first to avoid showing the
    // placeholder/loading every time the page is opened.
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _isAuthenticated = true;
      _isCheckingAuth = false;
    } else {
      // Fallback to checking the stored token when we don't have an
      // authenticated state yet (e.g. first app open).
      _checkAuthentication();
    }
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
        backgroundColor: AppColors.white,
        appBar: const CustomAppBar(title: 'الحساب'),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!_isAuthenticated) {
      return _UnauthenticatedProfilePage();
    }

    return const _AuthenticatedProfilePage();
  }
}

// Unauthenticated Profile Page
class _UnauthenticatedProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(title: 'الحساب'),
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
                'تسجيل الدخول مطلوب',
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
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pushNamed(
                        AppRouter.login,
                        arguments: {'returnTo': 'profile'},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0, // مهم: نشيل elevation الافتراضي
                      padding: EdgeInsets.zero, // إزالة أي padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
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
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pushNamed(
                        AppRouter.register,
                        arguments: {'returnTo': 'profile'},
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero, // إزالة margin الداخلي
                      side: const BorderSide(color: AppColors.primary),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
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
    );
  }
}

// Authenticated profile page
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
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();

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
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
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
    
    // Parse birthday to populate day, month, year fields
    if (user.birthday != null && user.birthday!.isNotEmpty) {
      final birthdayParts = _parseBirthday(user.birthday!);
      dayController.text = birthdayParts['day'] ?? '';
      monthController.text = birthdayParts['month'] ?? '';
      yearController.text = birthdayParts['year'] ?? '';
    }
  }
  
  /// Parse birthday from YYYY-MM-DD format to day, month, year
  Map<String, String> _parseBirthday(String birthday) {
    try {
      final parts = birthday.split('-');
      if (parts.length == 3) {
        return {
          'year': parts[0],
          'month': parts[1],
          'day': parts[2],
        };
      }
    } catch (e) {
      print('Error parsing birthday: $e');
    }
    return {'day': '', 'month': '', 'year': ''};
  }
  
  /// Convert day, month, year to YYYY-MM-DD format
  String? _getBirthdayString() {
    final day = dayController.text.trim();
    final month = monthController.text.trim();
    final year = yearController.text.trim();
    
    if (day.isEmpty || month.isEmpty || year.isEmpty) {
      return null;
    }
    
    // Validate and format
    final dayInt = int.tryParse(day);
    final monthInt = int.tryParse(month);
    final yearInt = int.tryParse(year);
    
    if (dayInt == null || monthInt == null || yearInt == null) {
      return null;
    }
    
    // Format as YYYY-MM-DD
    return '$year-${month.padLeft(2, '0')}-${day.padLeft(2, '0')}';
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

  /// Normalize phone number to international format
  /// Handles numbers with or without leading 0
  /// Example: 01098018628 or 1098018628 -> +201098018628
  String _normalizePhoneNumber(String localNumber, String countryCode) {
    // Remove any whitespace
    localNumber = localNumber.trim();
    
    // If number already has country code, return as is
    if (localNumber.startsWith('+')) {
      return localNumber;
    }
    
    // Remove leading 0 if present (common in Egypt and other countries)
    if (localNumber.startsWith('0')) {
      localNumber = localNumber.substring(1);
    }
    
    // Combine country code with local number
    return '$countryCode$localNumber';
  }

  void onSave() {
    if (formKey.currentState!.validate()) {
      // Normalize phone number
      String? normalizedPhone;
      if (phoneController.text.isNotEmpty) {
        normalizedPhone = _normalizePhoneNumber(
          phoneController.text,
          countryCode ?? '+20',
        );
      }

      // Get birthday string
      final birthday = _getBirthdayString();

      // Dispatch update profile event
      context.read<AuthBloc>().add(
        UpdateProfileEvent(
          name: nameController.text.isNotEmpty ? nameController.text : null,
          phone: normalizedPhone,
          birthday: birthday,
        ),
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
          } else if (state is ProfileUpdated) {
            // Update local user data
            _populateUserData(state.user);
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ التعديلات بنجاح'),
                backgroundColor: AppColors.success,
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

                // Birthday Field
                BirthdayField(
                  dayController: dayController,
                  monthController: monthController,
                  yearController: yearController,
                  validator: (value) {
                    // Optional field - no validation required
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // EmailField(controller: emailController),
                // SizedBox(height: 24),

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
              fontFamily: 'Cairo',
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


