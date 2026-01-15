import 'package:flutter/material.dart';
import 'package:learnify_lms/core/theme/app_text_styles.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import 'custom_text_field.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? countryCode;
  final ValueChanged<String> onCountryChanged;

  const PhoneField({
    super.key,
    required this.controller,
    this.countryCode,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hintText: 'رقم التليفون',
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      suffixIcon: InkWell(
        onTap: () => _showCountryPicker(context),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFlag(countryCode) ?? '',
              style: TextStyle(fontSize: Responsive.fontSize(context, 20)),
            ),
            SizedBox(width: Responsive.width(context, 4)),
            Text(
              countryCode ?? 'اختر دولتك',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: countryCode != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            SizedBox(width: Responsive.width(context, 4)),
            Icon(
              Icons.keyboard_arrow_down,
              size: Responsive.iconSize(context, 18),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
      validator: Validators.phone,
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.radius(context, 20)),
        ),
      ),
      builder: (context) => _CountryPickerSheet(
        selectedCode: countryCode,
        onSelected: (code) {
          onCountryChanged(code);
          Navigator.pop(context);
        },
      ),
    );
  }

  String? _getFlag(String? code) {
    if (code == null) return null;
    try {
      final country = _countries.firstWhere(
            (c) => c['code'] == code,
      );
      return country['flag'];
    } catch (e) {
      return null;
    }
  }

  static const List<Map<String, String>> _countries = [
    {'code': '+20', 'name': 'مصر', 'flag': '🇪🇬'},
    {'code': '+966', 'name': 'السعودية', 'flag': '🇸🇦'},
    {'code': '+971', 'name': 'الإمارات', 'flag': '🇦🇪'},
    {'code': '+965', 'name': 'الكويت', 'flag': '🇰🇼'},
    {'code': '+974', 'name': 'قطر', 'flag': '🇶🇦'},
    {'code': '+973', 'name': 'البحرين', 'flag': '🇧🇭'},
    {'code': '+968', 'name': 'عمان', 'flag': '🇴🇲'},
    {'code': '+962', 'name': 'الأردن', 'flag': '🇯🇴'},
    {'code': '+961', 'name': 'لبنان', 'flag': '🇱🇧'},
    {'code': '+964', 'name': 'العراق', 'flag': '🇮🇶'},
    {'code': '+963', 'name': 'سوريا', 'flag': '🇸🇾'},
    {'code': '+212', 'name': 'المغرب', 'flag': '🇲🇦'},
    {'code': '+216', 'name': 'تونس', 'flag': '🇹🇳'},
    {'code': '+213', 'name': 'الجزائر', 'flag': '🇩🇿'},
    {'code': '+218', 'name': 'ليبيا', 'flag': '🇱🇾'},
    {'code': '+249', 'name': 'السودان', 'flag': '🇸🇩'},
    {'code': '+967', 'name': 'اليمن', 'flag': '🇾🇪'},
  ];
}

class _CountryPickerSheet extends StatelessWidget {
  final String? selectedCode;
  final ValueChanged<String> onSelected;

  const _CountryPickerSheet({
    required this.selectedCode,
    required this.onSelected,
  });

  static const List<Map<String, String>> _countries = [
    {'code': '+20', 'name': 'مصر', 'flag': '🇪🇬'},
    {'code': '+966', 'name': 'السعودية', 'flag': '🇸🇦'},
    {'code': '+971', 'name': 'الإمارات', 'flag': '🇦🇪'},
    {'code': '+965', 'name': 'الكويت', 'flag': '🇰🇼'},
    {'code': '+974', 'name': 'قطر', 'flag': '🇶🇦'},
    {'code': '+973', 'name': 'البحرين', 'flag': '🇧🇭'},
    {'code': '+968', 'name': 'عمان', 'flag': '🇴🇲'},
    {'code': '+962', 'name': 'الأردن', 'flag': '🇯🇴'},
    {'code': '+961', 'name': 'لبنان', 'flag': '🇱🇧'},
    {'code': '+964', 'name': 'العراق', 'flag': '🇮🇶'},
    {'code': '+963', 'name': 'سوريا', 'flag': '🇸🇾'},
    {'code': '+212', 'name': 'المغرب', 'flag': '🇲🇦'},
    {'code': '+216', 'name': 'تونس', 'flag': '🇹🇳'},
    {'code': '+213', 'name': 'الجزائر', 'flag': '🇩🇿'},
    {'code': '+218', 'name': 'ليبيا', 'flag': '🇱🇾'},
    {'code': '+249', 'name': 'السودان', 'flag': '🇸🇩'},
    {'code': '+967', 'name': 'اليمن', 'flag': '🇾🇪'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: Responsive.padding(context, all: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.greyLight,
                width: Responsive.width(context, 1),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'اختر الدولة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: Responsive.iconSize(context, 24),
                ),
              ),
            ],
          ),
        ),
        // Country List
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _countries.length,
            itemBuilder: (context, index) {
              final country = _countries[index];
              final isSelected = country['code'] == selectedCode;

              return ListTile(
                onTap: () => onSelected(country['code']!),
                leading: Text(
                  country['flag']!,
                  style: TextStyle(fontSize: Responsive.fontSize(context, 28)),
                ),
                title: Text(
                  country['name']!,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 16),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  country['code']!,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: Responsive.fontSize(context, 14),
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: Responsive.iconSize(context, 24),
                )
                    : null,
                selected: isSelected,
                selectedTileColor: AppColors.primary.withOpacity(0.1),
              );
            },
          ),
        ),
        SizedBox(height: Responsive.spacing(context, 16)),
      ],
    );
  }
}