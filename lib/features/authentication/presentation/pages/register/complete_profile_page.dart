import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/register/widgets/religion_field.dart';
import '../../../../../core/utils/responsive.dart';

import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/login_background.dart';
import 'package:learnify_lms/features/authentication/presentation/widgets/name_field.dart';
import 'package:learnify_lms/features/authentication/presentation/widgets/phone_field.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/register/widgets/register_header.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/age_specialty_helper.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/birthday_field.dart';
import '../../widgets/primary_button.dart';

class CompleteProfilePage extends StatelessWidget {
  final String email;
  final String? name;
  final String providerId; // google | apple
  final String accessToken; // OAuth token for registration

  const CompleteProfilePage({
    super.key,
    required this.email,
    this.name,
    required this.providerId,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: _CompleteProfileView(
        email: email,
        name: name,
        providerId: providerId,
        accessToken: accessToken,
      ),
    );
  }
}

class _CompleteProfileView extends StatefulWidget {
  final String email;
  final String? name;
  final String providerId;
  final String accessToken;

  const _CompleteProfileView({
    required this.email,
    this.name,
    required this.providerId,
    required this.accessToken,
  });

  @override
  State<_CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<_CompleteProfileView> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  final phoneController = TextEditingController();

  // Birthday controllers
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();

  String? countryCode = '+20'; // Default to Egypt
  String selectedRole = 'student';
  String selectedGender = 'male';
  String? selectedReligion;

  // Calculated from birthday
  int? calculatedAge;
  int? calculatedSpecialtyId;
  String? specialtyName;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name ?? '');

    // Listen to birthday changes
    dayController.addListener(_updateAgeAndSpecialty);
    monthController.addListener(_updateAgeAndSpecialty);
    yearController.addListener(_updateAgeAndSpecialty);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
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

  void onCompletePressed() {
    if (formKey.currentState!.validate()) {
      // Check age validity
      if (calculatedAge == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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
            CompleteProfileEvent(
              name: nameController.text.trim(),
              email: widget.email,
              phone: countryCode != null
                  ? '$countryCode${phoneController.text.trim()}'
                  : phoneController.text.trim(),
              role: selectedRole,
              specialtyId: calculatedSpecialtyId!,
              gender: selectedGender,
              religion: selectedReligion,
              birthday: _getBirthdayString(),
              providerId: widget.providerId,
              accessToken: widget.accessToken,
            ),
          );
    }
  }

  Widget _buildAgeSpecialtyInfo(BuildContext context) {
    final isValidAge = AgeSpecialtyHelper.isValidAge(calculatedAge!);

    return Container(
      padding: Responsive.padding(context, horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isValidAge
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
        border: Border.all(
          color: isValidAge ? AppColors.success : AppColors.error,
          width: Responsive.width(context, 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValidAge ? Icons.check_circle : Icons.error,
            color: isValidAge ? AppColors.success : AppColors.error,
            size: Responsive.iconSize(context, 20),
          ),
          SizedBox(width: Responsive.width(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'العمر: $calculatedAge سنة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: isValidAge ? AppColors.success : AppColors.error,
                  ),
                ),
                if (specialtyName != null)
                  Text(
                    'الفئة العمرية: $specialtyName',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 12),
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
                      fontSize: Responsive.fontSize(context, 12),
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



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            const LoginBackground(),
            BlocListener<AuthBloc, AuthState>(
              listener: authListener,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: Responsive.padding(context, horizontal: 24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        SizedBox(height: Responsive.spacing(context, 50)),

                        /// Same Register Header
                        const RegisterHeader(
                          title: 'استكمل بياناتك',
                          highlight: 'لنبدأ!',
                        ),

                        SizedBox(height: Responsive.spacing(context, 45)),

                        /// Name
                        NameField(controller: nameController),
                        SizedBox(height: Responsive.spacing(context, 16)),

                        /// Phone
                        PhoneField(
                          controller: phoneController,
                          countryCode: countryCode,
                          onCountryChanged: (v) =>
                              setState(() => countryCode = v),
                        ),
                        SizedBox(height: Responsive.spacing(context, 16)),

                        /// Birthday
                        BirthdayField(
                          dayController: dayController,
                          monthController: monthController,
                          yearController: yearController,
                        ),

                        // Show calculated age and specialty
                        if (calculatedAge != null) ...[
                          SizedBox(height: Responsive.spacing(context, 8)),
                          _buildAgeSpecialtyInfo(context),
                        ],
                        SizedBox(height: Responsive.spacing(context, 16)),

                        /// Gender
                        GenderField(
                          selectedValue: selectedGender,
                          onChanged: (value) {
                            setState(() => selectedGender = value!);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'يرجى اختيار النوع';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Responsive.spacing(context, 16)),

                        /// Religion
                        /// Religion
                        ReligionField(
                          selectedValue: selectedReligion,
                          onChanged: (value) {
                            setState(() => selectedReligion = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'من فضلك اختر الديانة';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: Responsive.spacing(context, 32)),

                        /// Button (same register button)
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;

                            return PrimaryButton(
                              text: 'حفظ',
                              isLoading: isLoading,
                              onPressed: isLoading ? null : onCompletePressed,
                            );
                          },
                        ),

                        SizedBox(height: Responsive.spacing(context, 30)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
      // Navigate to content preferences page after profile completion
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/content-preferences',
        (_) => false,
      );
    }
  }
}


class GenderField extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const GenderField({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: selectedValue,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: Responsive.width(context, 342),
              height: Responsive.height(context, 52),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(Responsive.radius(context, 24)),
                  border: Border.all(
                    color: state.hasError
                        ? AppColors.error
                        : const Color(0xFFDEE1E6),
                    width: 1,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.spacing(context, 20),
                ),
                child: Row(
                  children: [
                    /// Icon
                    Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: Responsive.iconSize(context, 24),
                    ),
                    SizedBox(width: Responsive.spacing(context, 20)),

                    /// Male
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'male',
                        groupValue: selectedValue,
                        onChanged: (value) {
                          state.didChange(value);
                          onChanged(value);
                        },
                        title: Text(
                          'ولد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: Responsive.fontSize(context, 14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),

                    /// Female
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'female',
                        groupValue: selectedValue,
                        onChanged: (value) {
                          state.didChange(value);
                          onChanged(value);
                        },
                        title: Text(
                          'بنت',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: Responsive.fontSize(context, 14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Error text
            if (state.hasError)
              Padding(
                padding: EdgeInsets.only(
                  left: Responsive.spacing(context, 20),
                  top: Responsive.spacing(context, 4),
                ),
                child: Text(
                  state.errorText ?? '',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 12),
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

