import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/register/widgets/have_account_row.dart';
import 'package:learnify_lms/features/authentication/presentation/widgets/name_field.dart';
import 'package:learnify_lms/features/authentication/presentation/widgets/phone_field.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/register/widgets/register_header.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/login_background.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/age_specialty_helper.dart';

import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/EmailField.dart';
import '../../widgets/PasswordField.dart';
import '../../widgets/birthday_field.dart';
import '../../widgets/custom_divider_with_text.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/social_login_buttons.dart';

class RegisterPageView extends StatefulWidget {
  const RegisterPageView({super.key});

  @override
  State<RegisterPageView> createState() => RegisterPageViewState();
}

class RegisterPageViewState extends State<RegisterPageView> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Birthday controllers
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String? countryCode = '+20'; // Default to Egypt
  String selectedRole = 'student';
  String selectedGender = 'male';

  // Calculated from birthday
  int? calculatedAge;
  int? calculatedSpecialtyId;
  String? specialtyName;

  @override
  void initState() {
    super.initState();
    // Listen to birthday changes
    dayController.addListener(_updateAgeAndSpecialty);
    monthController.addListener(_updateAgeAndSpecialty);
    yearController.addListener(_updateAgeAndSpecialty);
  }

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

  void _updateAgeAndSpecialty() {
    final birthday = _getBirthdayString();
    if (birthday != null) {
      try {
        final parts = birthday.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final birthDate = DateTime(year, month, day);
        final age = AgeSpecialtyHelper.calculateAge(birthDate);
        final specialtyId = AgeSpecialtyHelper.getSpecialtyIdFromAge(age);
        final name = AgeSpecialtyHelper.getSpecialtyNameAr(age);

        setState(() {
          calculatedAge = age;
          calculatedSpecialtyId = specialtyId;
          specialtyName = name;
        });
      } catch (e) {
        setState(() {
          calculatedAge = null;
          calculatedSpecialtyId = null;
          specialtyName = null;
        });
      }
    } else {
      setState(() {
        calculatedAge = null;
        calculatedSpecialtyId = null;
        specialtyName = null;
      });
    }
  }

  String? _getBirthdayString() {
    if (dayController.text.isEmpty ||
        monthController.text.isEmpty ||
        yearController.text.isEmpty) {
      return null;
    }

    final day = dayController.text.padLeft(2, '0');
    final month = monthController.text.padLeft(2, '0');
    final year = yearController.text;

    if (year.length != 4) return null;

    return '$year-$month-$day';
  }

  void onRegisterPressed() {
    if (formKey.currentState!.validate()) {
      // Check password match
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('كلمة المرور غير متطابقة'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Check age validity
      if (calculatedAge == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى إدخال تاريخ الميلاد'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (!AgeSpecialtyHelper.isValidAge(calculatedAge!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AgeSpecialtyHelper.getAgeValidationMessage(calculatedAge!) ??
                  'العمر غير صالح للتسجيل',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      context.read<AuthBloc>().add(
            RegisterEvent(
              name: nameController.text.trim(),
              email: emailController.text.trim(),
              password: passwordController.text,
              passwordConfirmation: confirmPasswordController.text,
              role: selectedRole,
              phone: countryCode != null
                  ? '$countryCode${phoneController.text.trim()}'
                  : phoneController.text.trim(),
              specialtyId: calculatedSpecialtyId!,
              gender: selectedGender,
              birthday: _getBirthdayString(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          const LoginBackground(),
          BlocListener<AuthBloc, AuthState>(
            listener: authListener,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      const RegisterHeader(),
                      const SizedBox(height: 45),
                      NameField(controller: nameController),
                      const SizedBox(height: 16),
                      PhoneField(
                        controller: phoneController,
                        countryCode: countryCode,
                        onCountryChanged: (v) =>
                            setState(() => countryCode = v),
                      ),
                      const SizedBox(height: 16),
                      EmailField(controller: emailController),
                      const SizedBox(height: 16),
                      // Birthday Field
                      BirthdayField(
                        dayController: dayController,
                        monthController: monthController,
                        yearController: yearController,
                      ),
                      // Show calculated age and specialty
                      if (calculatedAge != null) ...[
                        const SizedBox(height: 8),
                        _buildAgeSpecialtyInfo(),
                      ],
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      PasswordField(
                        controller: passwordController,
                        obscure: obscurePassword,
                        onToggleVisibility: () =>
                            setState(() => obscurePassword = !obscurePassword),
                      ),
                      const SizedBox(height: 16),
                      PasswordField(
                        controller: confirmPasswordController,
                        obscure: obscureConfirmPassword,
                        hintText: 'تأكيد كلمة المرور',
                        onToggleVisibility: () => setState(
                            () => obscureConfirmPassword = !obscureConfirmPassword),
                      ),
                      const SizedBox(height: 28),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;

                          return PrimaryButton(
                            text: 'تسجيل الحساب',
                            isLoading: isLoading,
                            onPressed: isLoading ? null : onRegisterPressed,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const HaveAccountRow(),
                      const SizedBox(height: 20),
                      const CustomDividerWithText(text: "أو التسجيل بواسطة"),
                      const SizedBox(height: 20),
                      const SocialLoginButtons(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSpecialtyInfo() {
    final isValidAge = AgeSpecialtyHelper.isValidAge(calculatedAge!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isValidAge
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValidAge ? AppColors.success : AppColors.error,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValidAge ? Icons.check_circle : Icons.error,
            color: isValidAge ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'العمر: $calculatedAge سنة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isValidAge ? AppColors.success : AppColors.error,
                  ),
                ),
                if (specialtyName != null)
                  Text(
                    'الفئة العمرية: $specialtyName',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: isValidAge
                          ? AppColors.success.withOpacity(0.8)
                          : AppColors.error.withOpacity(0.8),
                    ),
                  )
                else if (!isValidAge)
                  Text(
                    AgeSpecialtyHelper.getAgeValidationMessage(calculatedAge!) ??
                        'العمر غير صالح',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.error.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              title: const Text('ذكر'),
              value: 'male',
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() => selectedGender = value!);
              },
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: const Text('أنثى'),
              value: 'female',
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() => selectedGender = value!);
              },
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void authListener(BuildContext context, AuthState state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (state is AuthAuthenticated) {
      // Navigate to home after registration
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
