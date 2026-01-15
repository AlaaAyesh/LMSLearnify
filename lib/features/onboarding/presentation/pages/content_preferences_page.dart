import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/hive_service.dart';
import 'package:learnify_lms/features/authentication/presentation/pages/login/widgets/login_background.dart';

import '../../../authentication/presentation/widgets/primary_button.dart';

class ContentPreferencesPage extends StatefulWidget {
  const ContentPreferencesPage({super.key});

  @override
  State<ContentPreferencesPage> createState() => _ContentPreferencesPageState();
}

class _ContentPreferencesPageState extends State<ContentPreferencesPage> {
  // Option 1 and 2 enabled by default, Option 3 disabled by default
  bool _coursesAndSkills = true; // Option 1: enabled by default
  bool _valuesAndEthics = true; // Option 2: enabled by default
  bool _islamicStories = false; // Option 3: disabled by default (optional)

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          // Exit app or navigate back based on user choice
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            const LoginBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: Responsive.padding(context, horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: Responsive.spacing(context, 60)),
                  Text(
                    'اختر المحتوي المناسب',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: Responsive.fontSize(context, 30),
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'لطفلك!',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 30),
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          height: 1,
                        ),
                      ),
                      SizedBox(width: Responsive.width(context, 8)),
                      Text(
                        '👋',
                        style: TextStyle(
                            fontSize: Responsive.fontSize(context, 28)),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.spacing(context, 32)),
                  Container(
                    width: double.infinity,
                    padding: Responsive.padding(context, all: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4D6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'ليرنفاي بتقدم محتوي تعليمي ممتع بيساعد طفلك يتعلم مهارات وقيم ايجابية، مع امكانية تخصيص نوع المحتوي اللي بيشوفه',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: Responsive.fontSize(context, 14),
                        color: const Color(0xFF4A4A4A),
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 32)),
                  // Content Type Question + Options
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // يضع المحتوى على اليمين
                    children: [
                      Text(
                        'نوع المحتوي اللي تحب يظهر لطفلك؟',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: Responsive.fontSize(context, 14),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.right, // النص على اليمين
                      ),
                      SizedBox(height: Responsive.spacing(context, 20)),


                      // Option 1
                      _buildOption(
                        title:
                            'كورسات ومهارات ( البرمجة، الرسم، اللغات و العلوم ... الخ )',
                        isChecked: _coursesAndSkills,
                        onTap: () => setState(
                            () => _coursesAndSkills = !_coursesAndSkills),
                      ),

                      _buildOption(
                        title:
                            'قيم وإخلاق إنسانية عامة ( الصدق الاحترام والمشاركة ... الخ )',
                        isChecked: _valuesAndEthics,
                        onTap: () => setState(
                            () => _valuesAndEthics = !_valuesAndEthics),
                      ),

                      // Option 3
                      _buildOption(
                        title:
                            'قصص وممارسات اسلامية ( الوضوء، الصلاة وقصص الانبياء .. الخ )',
                        isChecked: _islamicStories,
                        onTap: () =>
                            setState(() => _islamicStories = !_islamicStories),
                      ),
                    ],
                  ),

                  SizedBox(height: Responsive.spacing(context, 40)),
                  PrimaryButton(
                    text: 'حفظ',
                    isLoading: _isSaving,
                    // Enable button only when option 1 and 2 are selected
                    onPressed: (_isSaving || !_canSave()) ? null : _savePreferences,
                  ),

                  SizedBox(height: Responsive.spacing(context, 40)),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required bool isChecked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: Responsive.padding(context, horizontal: 0, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color:
                        isChecked ? AppColors.primary : const Color(0xFFBDBDBD),
                    width: 2),
              ),
              child: isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 12),
                    color: Colors.black87,
                    height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if options 1 and 2 are selected (required for saving)
  bool _canSave() {
    return _coursesAndSkills && _valuesAndEthics;
  }

  Future<void> _savePreferences() async {
    // Validate that required options are selected
    if (!_canSave()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يجب اختيار كورسات ومهارات وقيم وإخلاق إنسانية عامة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final hiveService = sl<HiveService>();
      
      // Save preferences to local storage
      await hiveService.saveData('content_preferences', {
        'coursesAndSkills': _coursesAndSkills,
        'valuesAndEthics': _valuesAndEthics,
        'islamicStories': _islamicStories,
      });

      // Mark onboarding as completed
      await hiveService.saveData(
        AppConstants.keyContentPreferencesCompleted,
        true,
      );

      // TODO: Add API call to save preferences to backend
      // await _savePreferencesToBackend();

      if (!mounted) return;

      setState(() => _isSaving = false);

      // Navigate to home and remove all previous routes
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (_) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isSaving = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حفظ التفضيلات. يرجى المحاولة مرة أخرى.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Prevent back navigation - onboarding is mandatory
  Future<bool> _onWillPop() async {
    // Show dialog to confirm if user tries to go back
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تأكيد',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        content: Text(
          'يجب إكمال اختيار التفضيلات للمتابعة. هل تريد الخروج من التطبيق؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('خروج', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
    
    if (shouldPop == true) {
      // Exit app if user confirms
      return true;
    }
    return false;
  }
}
