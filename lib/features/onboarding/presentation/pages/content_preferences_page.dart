import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class ContentPreferencesPage extends StatefulWidget {
  const ContentPreferencesPage({super.key});

  @override
  State<ContentPreferencesPage> createState() => _ContentPreferencesPageState();
}

class _ContentPreferencesPageState extends State<ContentPreferencesPage> {
  // First two options are always checked (mandatory)
  bool _coursesAndSkills = true;
  bool _valuesAndEthics = true;
  // Third option is optional
  bool _islamicStories = false;

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.padding(context, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: Responsive.spacing(context, 40)),
              
              // Title
              Text(
                'اختر المحتوي المناسب',
                style: TextStyle(
                  fontFamily: cairoFontFamily,
                  fontSize: Responsive.fontSize(context, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: Responsive.spacing(context, 8)),
              
              // Subtitle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لطفلك!',
                    style: TextStyle(
                      fontFamily: cairoFontFamily,
                      fontSize: Responsive.fontSize(context, 24),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: Responsive.width(context, 8)),
                  Text(
                    '👋',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 24),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: Responsive.spacing(context, 32)),
              
              // Info Card
              Container(
                padding: Responsive.padding(context, all: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(Responsive.radius(context, 16)),
                ),
                child: Text(
                  'ليرنفاي بتقدم محتوي تعليمي ممتع بيساعد طفلك يتعلم مهارات وقيم ايجابية، مع امكانية تخصيص نوع المحتوي اللي بيشوفه',
                  style: TextStyle(
                    fontFamily: cairoFontFamily,
                    fontSize: Responsive.fontSize(context, 14),
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              SizedBox(height: Responsive.spacing(context, 40)),
              
              // Content Type Question
              Text(
                'نوع المحتوي اللي تحب يظهر لطفلك؟',
                style: TextStyle(
                  fontFamily: cairoFontFamily,
                  fontSize: Responsive.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: Responsive.spacing(context, 24)),
              
              // Option 1: Courses and Skills (always checked)
              _buildOption(
                title: 'كورسات ومهارات ( البرمجة، الرسم، اللغات و العلوم ... الخ )',
                isChecked: _coursesAndSkills,
                onTap: () {
                  // This option is always checked, cannot be unchecked
                },
                isMandatory: true,
              ),
              
              SizedBox(height: Responsive.spacing(context, 16)),
              
              // Option 2: Values and Ethics (always checked)
              _buildOption(
                title: 'قيم وإخلاق إنسانية عامة ( الصدق الاحترام والمشاركة ... الخ )',
                isChecked: _valuesAndEthics,
                onTap: () {
                  // This option is always checked, cannot be unchecked
                },
                isMandatory: true,
              ),
              
              SizedBox(height: Responsive.spacing(context, 16)),
              
              // Option 3: Islamic Stories (optional)
              _buildOption(
                title: 'قصص وممارسات اسلامية ( الوضوء، الصلاة وقصص الانبياء .. الخ )',
                isChecked: _islamicStories,
                onTap: () {
                  setState(() {
                    _islamicStories = !_islamicStories;
                  });
                },
                isMandatory: false,
              ),
              
              SizedBox(height: Responsive.spacing(context, 40)),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: Responsive.padding(context, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
                    ),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          height: Responsive.height(context, 20),
                          width: Responsive.width(context, 20),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'حفظ',
                          style: TextStyle(
                            fontFamily: cairoFontFamily,
                            fontSize: Responsive.fontSize(context, 18),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: Responsive.spacing(context, 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required bool isChecked,
    required VoidCallback onTap,
    required bool isMandatory,
  }) {
    return GestureDetector(
      onTap: isMandatory ? null : onTap,
      child: Container(
        padding: Responsive.padding(context, all: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(Responsive.radius(context, 12)),
          border: Border.all(
            color: isChecked ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: cairoFontFamily,
                  fontSize: Responsive.fontSize(context, 14),
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(width: Responsive.width(context, 12)),
            Container(
              width: Responsive.width(context, 24),
              height: Responsive.height(context, 24),
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isChecked ? AppColors.primary : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: Responsive.iconSize(context, 16),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);

    try {
      final hiveService = sl<HiveService>();
      
      // Save preferences (you can extend this to save to API if needed)
      await hiveService.saveData(
        AppConstants.keyContentPreferencesCompleted,
        true,
      );
      
      // Save individual preferences
      await hiveService.saveData(
        'content_pref_courses',
        _coursesAndSkills.toString(),
      );
      await hiveService.saveData(
        'content_pref_values',
        _valuesAndEthics.toString(),
      );
      await hiveService.saveData(
        'content_pref_islamic',
        _islamicStories.toString(),
      );

      if (!mounted) return;

      // Navigate to home
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء الحفظ',
            style: TextStyle(fontFamily: cairoFontFamily),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
